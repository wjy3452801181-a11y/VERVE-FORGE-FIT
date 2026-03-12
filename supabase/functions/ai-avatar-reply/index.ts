// ============================================================
// VerveForge Edge Function: ai-avatar-reply
// 离线自动回复 — 当用户离线时，AI 分身代替用户回复消息
//
// 触发方式：数据库触发器通过 pg_net 异步调用
// 安全机制：
//   - service_role_key 鉴权（仅允许后端调用）
//   - 防循环检测：跳过 is_ai_generated 消息
//   - 频率限制：5 分钟内同一对话最多自动回复 3 次
//   - PIPL 合规：仅对 ai_consent_at 已授权的分身生效
//   - 内容审核：AI 回复经 ai-reply-filter 审核后才插入
// ============================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY")!;

// 频率限制常量
const RATE_LIMIT_WINDOW_MINUTES = 5; // 时间窗口（分钟）
const RATE_LIMIT_MAX_REPLIES = 3; // 窗口内最大自动回复次数

interface AutoReplyRequest {
  message_id: string;
  conversation_id: string;
  sender_id: string;
  recipient_id: string;
  avatar_id: string;
  content: string;
}

serve(async (req: Request) => {
  try {
    // ========== 1. 鉴权 ==========
    const authHeader = req.headers.get("Authorization");
    if (!authHeader || authHeader !== `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }

    const body: AutoReplyRequest = await req.json();
    const { message_id, conversation_id, sender_id, recipient_id, avatar_id, content } = body;

    // 使用 service_role 访问数据库（绕过 RLS）
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // ========== 2. 防循环检测 ==========
    // 检查触发消息本身是否为 AI 生成（双重防护，触发器已检查一次）
    const { data: triggerMsg } = await supabase
      .from("messages")
      .select("metadata")
      .eq("id", message_id)
      .single();

    if (triggerMsg?.metadata?.is_ai_generated === true) {
      console.log(`跳过 AI 生成消息: ${message_id}`);
      return new Response(JSON.stringify({ skipped: true, reason: "ai_generated" }), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    }

    // ========== 3. 频率限制 ==========
    // 查询时间窗口内该对话的 AI 自动回复次数
    const windowStart = new Date(
      Date.now() - RATE_LIMIT_WINDOW_MINUTES * 60 * 1000
    ).toISOString();

    const { count: recentReplyCount } = await supabase
      .from("messages")
      .select("id", { count: "exact", head: true })
      .eq("conversation_id", conversation_id)
      .eq("sender_id", recipient_id) // 以分身主人身份发送的
      .gte("created_at", windowStart)
      .not("metadata->is_ai_generated", "is", null); // metadata 中有 is_ai_generated 标记

    if ((recentReplyCount ?? 0) >= RATE_LIMIT_MAX_REPLIES) {
      console.log(
        `频率限制: 对话 ${conversation_id} 在 ${RATE_LIMIT_WINDOW_MINUTES} 分钟内已有 ${recentReplyCount} 条自动回复`
      );
      return new Response(
        JSON.stringify({ skipped: true, reason: "rate_limited" }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }

    // ========== 4. 获取 avatar 配置 ==========
    const { data: avatar, error: avatarError } = await supabase
      .from("ai_avatars")
      .select("*")
      .eq("id", avatar_id)
      .single();

    if (avatarError || !avatar) {
      return new Response(JSON.stringify({ error: "Avatar not found" }), {
        status: 404,
        headers: { "Content-Type": "application/json" },
      });
    }

    // PIPL 合规二次校验：必须已授权
    if (!avatar.ai_consent_at) {
      console.log(`分身 ${avatar_id} 未完成 AI 数据授权，跳过`);
      return new Response(
        JSON.stringify({ skipped: true, reason: "no_consent" }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }

    // ========== 5. 获取用户画像 ==========
    // 分身主人的 profile
    const { data: ownerProfile } = await supabase
      .from("profiles")
      .select("nickname, bio, city, sport_types, experience_level")
      .eq("id", recipient_id)
      .single();

    // 发送者的 profile（用于上下文称呼）
    const { data: senderProfile } = await supabase
      .from("profiles")
      .select("nickname")
      .eq("id", sender_id)
      .single();

    // ========== 6. 获取对话最近 10 条消息（上下文） ==========
    const { data: recentMessages } = await supabase
      .from("messages")
      .select("sender_id, content, metadata, created_at")
      .eq("conversation_id", conversation_id)
      .is("deleted_at", null)
      .order("created_at", { ascending: false })
      .limit(10);

    // ========== 7. 获取分身主人最近 5 条公开动态 ==========
    const { data: recentPosts } = await supabase
      .from("posts")
      .select("content, created_at")
      .eq("user_id", recipient_id)
      .order("created_at", { ascending: false })
      .limit(5);

    // ========== 8. 构造 System Prompt ==========
    const systemPrompt = buildSystemPrompt(avatar, ownerProfile, recentPosts);

    // ========== 9. 构造对话历史 ==========
    const conversationHistory = buildConversationHistory(
      recentMessages ?? [],
      recipient_id,
      ownerProfile?.nickname ?? "我",
      senderProfile?.nickname ?? "对方"
    );

    // ========== 10. 调用 Claude API ==========
    const rawReply = await callClaudeAPI(systemPrompt, conversationHistory, content);

    // ========== 10.5 内容审核：调用 ai-reply-filter 过滤 AI 回复 ==========
    const filterResult = await filterReplyContent(rawReply);
    const aiReply = filterResult.passed ? rawReply : filterResult.fallback_reply;
    const isFiltered = !filterResult.passed;

    if (isFiltered) {
      console.log(
        `内容审核拦截: 对话 ${conversation_id}, 类别=${filterResult.category ?? "unknown"}`
      );
    }

    // ========== 11. 插入 AI 回复消息 ==========
    const { error: insertError } = await supabase.from("messages").insert({
      conversation_id,
      sender_id: recipient_id, // 以分身主人的身份发送
      message_type: "text",
      content: aiReply,
      metadata: {
        is_ai_generated: true,
        avatar_id: avatar.id,
        avatar_name: avatar.name,
        auto_reply: true, // 标记为离线自动回复（区别于手动聊天）
        ...(isFiltered && { content_filtered: true }), // 标记内容已被过滤
      },
    });

    if (insertError) {
      console.error("插入 AI 回复失败:", insertError);
      return new Response(JSON.stringify({ error: "Failed to insert reply" }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    }

    // ========== 12. 更新 conversation 的 last_message ==========
    await supabase
      .from("conversations")
      .update({
        last_message_text: aiReply,
        last_message_at: new Date().toISOString(),
        last_message_sender_id: recipient_id,
      })
      .eq("id", conversation_id);

    // ========== 13. 记录自动回复日志（用于后续分析/频率限制增强） ==========
    await supabase.from("ai_auto_reply_log").insert({
      avatar_id: avatar.id,
      conversation_id,
      recipient_id,
      sender_id,
      trigger_message_id: message_id,
    }).then(() => {}, (err: unknown) => {
      // 日志记录失败不影响主流程
      console.warn("自动回复日志记录失败:", err);
    });

    console.log(
      `自动回复成功: 对话 ${conversation_id}, 分身 ${avatar.name} 代替 ${ownerProfile?.nickname ?? recipient_id} 回复`
    );

    return new Response(JSON.stringify({ success: true, reply: aiReply }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("ai-avatar-reply error:", err);
    return new Response(JSON.stringify({ error: "Internal server error" }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});

// ============================================================
// Helper Functions
// ============================================================

/// 构造 System Prompt
/// 数据源: avatar 配置 + 用户画像 + 最近动态
function buildSystemPrompt(
  avatar: Record<string, unknown>,
  profile: Record<string, unknown> | null,
  recentPosts: Array<Record<string, unknown>> | null
): string {
  const traits = (avatar.personality_traits as string[])?.join("、") ?? "";

  // 说话风格映射（与 Flutter 端 availableStyles 一致）
  const styleMap: Record<string, string> = {
    lively: "充满活力、热情洋溢，喜欢用感叹号和 emoji",
    steady: "冷静且理性，言简意赅、就事论事，不用太多修饰",
    humorous: "有趣幽默，轻松愉快，偶尔自嘲和玩梗",
    friendly: "友好随意，像朋友之间聊天",
    professional: "专业简洁，言之有物",
    encouraging: "温暖鼓励，积极正面",
  };
  const styleDesc = styleMap[avatar.speaking_style as string] ?? styleMap.friendly;

  const sportTypes = (profile?.sport_types as string[])?.join("、") ?? "";
  const postsContext =
    recentPosts
      ?.map((p, i) => `${i + 1}. ${p.content}`)
      .join("\n") ?? "暂无动态";

  let prompt = `你是「${avatar.name}」，一个运动爱好者的 AI 虚拟分身。你在代替主人回复消息，因为主人当前不在线。

主人的信息：
- 昵称: ${profile?.nickname ?? "用户"}
- 城市: ${profile?.city ?? "未知"}
- 运动类型: ${sportTypes || "未设置"}
- 运动水平: ${profile?.experience_level ?? "未设置"}
- 个人简介: ${profile?.bio ?? ""}

你的性格特征: ${traits || "友好"}
你的说话风格: ${styleDesc}`;

  if (avatar.custom_prompt) {
    prompt += `\n\n主人的特别要求: ${avatar.custom_prompt}`;
  }

  prompt += `\n\n主人最近的动态:
${postsContext}

回复规则:
1. 用第一人称回复，像真人一样自然
2. 回复简短，一般 1-3 句话，最多不超过 100 字
3. 基于主人的运动背景回复相关话题
4. 不要主动透露自己是 AI（对方会看到 AI 标记）
5. 如果遇到敏感或你无法回答的话题，礼貌地说主人稍后会回复
6. 保持主人的说话风格一致性
7. 不要回复涉及个人隐私的具体信息（如手机号、地址等）
8. 不要做出任何承诺或约定（如"明天一起跑步"），因为主人不在线`;

  return prompt;
}

/// 构造对话历史（按时间正序排列）
function buildConversationHistory(
  messages: Array<Record<string, unknown>>,
  ownerId: string,
  ownerName: string,
  senderName: string
): Array<{ role: string; content: string }> {
  // messages 已按 created_at DESC 排列，需要反转为正序
  const sorted = [...messages].reverse();

  return sorted.map((msg) => ({
    role: msg.sender_id === ownerId ? "assistant" : "user",
    content: `${msg.sender_id === ownerId ? ownerName : senderName}: ${msg.content}`,
  }));
}

/// 调用 Claude API 生成回复
async function callClaudeAPI(
  systemPrompt: string,
  conversationHistory: Array<{ role: string; content: string }>,
  latestMessage: string
): Promise<string> {
  const messages = [
    ...conversationHistory,
    { role: "user", content: latestMessage },
  ];

  const response = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-api-key": ANTHROPIC_API_KEY,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify({
      model: "claude-sonnet-4-20250514",
      max_tokens: 256,
      system: systemPrompt,
      messages,
    }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    console.error("Claude API error:", errorText);
    throw new Error(`Claude API returned ${response.status}`);
  }

  const data = await response.json();
  return data.content?.[0]?.text ?? "抱歉，我现在不方便回复，主人稍后会联系你。";
}

/// 调用 ai-reply-filter 进行内容审核
/// 过滤服务异常时默认放行（不阻断正常回复）
async function filterReplyContent(
  content: string
): Promise<{
  passed: boolean;
  category?: string;
  fallback_reply: string;
}> {
  const FALLBACK_REPLY = "分身暂时无法回复，请稍后尝试。";

  try {
    const filterUrl = `${SUPABASE_URL}/functions/v1/ai-reply-filter`;
    const response = await fetch(filterUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      },
      body: JSON.stringify({ content }),
    });

    if (!response.ok) {
      console.warn(`ai-reply-filter 返回 ${response.status}，默认放行`);
      return { passed: true, fallback_reply: "" };
    }

    const result = await response.json();
    return {
      passed: result.passed ?? true,
      category: result.category,
      fallback_reply: result.passed ? "" : (result.fallback_reply ?? FALLBACK_REPLY),
    };
  } catch (err) {
    // 过滤服务不可用时默认放行，不影响正常回复体验
    console.warn("ai-reply-filter 调用失败，默认放行:", err);
    return { passed: true, fallback_reply: "" };
  }
}
