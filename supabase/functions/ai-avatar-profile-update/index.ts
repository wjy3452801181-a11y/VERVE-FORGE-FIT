// ============================================================
// VerveForge Edge Function: ai-avatar-profile-update
// AI 画像自动更新 — 分析用户对话与训练数据，提炼分身画像
//
// 触发方式：
//   - pg_cron 每日凌晨 2 点定时调用（批量处理所有已授权分身）
//   - 客户端手动调用（单个分身即时更新）
// 安全机制：
//   - service_role_key 鉴权（定时任务）或 JWT 鉴权（用户手动）
//   - PIPL 合规：仅处理 ai_consent_at 已授权的分身
//   - 仅读取用户自己的数据，不跨用户访问
// 数据源：
//   - 最近 30 条聊天消息（用户在各对话中的发言）
//   - 最近 30 条训练日志（运动类型/时长/强度/笔记）
//   - 最近 10 条公开动态
//   - 当前 profile 信息
// ============================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY")!;

// ============================================================
// 类型定义
// ============================================================

interface ProfileUpdateRequest {
  // 单个分身更新（客户端手动触发）
  avatar_id?: string;
  // 批量更新（定时任务触发，不传 avatar_id 则处理所有）
  batch?: boolean;
}

interface AvatarProfile {
  personality_traits: string[];
  speaking_style: string;
  fitness_habits: Record<string, unknown>;
}

// 允许的性格标签（与 Flutter 端 availableTraits 一致）
const VALID_TRAITS = [
  "earlyRunner", "yogaMaster", "ironAddict", "crossfitFanatic",
  "marathoner", "gymRat", "outdoorExplorer", "flexibilityPro",
  "teamPlayer", "soloWarrior", "techGeek", "nutritionNerd",
  "restDayHater", "warmupSkipper", "prBeast", "cheerleader",
];

// 允许的说话风格（与 Flutter 端 availableStyles 一致）
const VALID_STYLES = ["lively", "steady", "humorous", "friendly", "professional", "encouraging"];

serve(async (req: Request) => {
  try {
    // ========== 1. 鉴权 ==========
    // 支持两种鉴权方式：
    // - service_role_key（定时任务 / 批量更新）
    // - JWT（用户手动触发单个分身更新）
    const authHeader = req.headers.get("Authorization") ?? "";
    const isServiceRole = authHeader === `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`;

    let callerUserId: string | null = null;

    if (!isServiceRole) {
      // 验证 JWT，提取用户 ID
      const supabaseAuth = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
      const token = authHeader.replace("Bearer ", "");
      const { data: { user }, error: authError } = await supabaseAuth.auth.getUser(token);

      if (authError || !user) {
        return jsonResponse({ error: "Unauthorized" }, 401);
      }
      callerUserId = user.id;
    }

    const body: ProfileUpdateRequest = await req.json().catch(() => ({}));

    // 使用 service_role 访问数据库（绕过 RLS）
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // ========== 2. 确定要更新的分身列表 ==========
    let avatars: Array<Record<string, unknown>>;

    if (body.avatar_id) {
      // 单个分身更新
      const { data, error } = await supabase
        .from("ai_avatars")
        .select("*")
        .eq("id", body.avatar_id)
        .single();

      if (error || !data) {
        return jsonResponse({ error: "Avatar not found" }, 404);
      }

      // PIPL：非 service_role 时验证操作者是分身主人
      if (callerUserId && data.user_id !== callerUserId) {
        return jsonResponse({ error: "Forbidden" }, 403);
      }

      // PIPL：必须已授权
      if (!data.ai_consent_at) {
        return jsonResponse({ error: "AI consent required" }, 403);
      }

      avatars = [data];
    } else if (body.batch || isServiceRole) {
      // 批量更新：获取所有已授权 + 已启用的分身
      // 仅 service_role 可执行批量更新
      if (!isServiceRole) {
        return jsonResponse({ error: "Batch update requires service role" }, 403);
      }

      const { data, error } = await supabase
        .from("ai_avatars")
        .select("*")
        .not("ai_consent_at", "is", null); // PIPL：仅处理已授权分身

      if (error) {
        console.error("获取分身列表失败:", error);
        return jsonResponse({ error: "Failed to fetch avatars" }, 500);
      }

      avatars = data ?? [];
    } else {
      return jsonResponse({ error: "Missing avatar_id or batch flag" }, 400);
    }

    if (avatars.length === 0) {
      return jsonResponse({ message: "No avatars to update", updated: 0 }, 200);
    }

    // ========== 3. 逐个更新分身画像 ==========
    const results: Array<{ avatar_id: string; success: boolean; error?: string }> = [];

    for (const avatar of avatars) {
      try {
        const updated = await updateSingleAvatar(supabase, avatar);
        results.push({ avatar_id: avatar.id as string, success: true, ...updated });
      } catch (err) {
        console.error(`更新分身 ${avatar.id} 失败:`, err);
        results.push({
          avatar_id: avatar.id as string,
          success: false,
          error: err instanceof Error ? err.message : "Unknown error",
        });
      }
    }

    const successCount = results.filter((r) => r.success).length;
    console.log(`画像更新完成: ${successCount}/${avatars.length} 成功`);

    return jsonResponse({
      updated: successCount,
      total: avatars.length,
      results,
    }, 200);
  } catch (err) {
    console.error("ai-avatar-profile-update error:", err);
    return jsonResponse({ error: "Internal server error" }, 500);
  }
});

// ============================================================
// 核心逻辑：更新单个分身画像
// ============================================================

async function updateSingleAvatar(
  supabase: ReturnType<typeof createClient>,
  avatar: Record<string, unknown>
): Promise<{ traits: string[]; style: string }> {
  const userId = avatar.user_id as string;

  // ========== 3a. 获取用户 profile ==========
  const { data: profile } = await supabase
    .from("profiles")
    .select("nickname, bio, city, sport_types, experience_level")
    .eq("id", userId)
    .single();

  // ========== 3b. 获取最近 30 条聊天消息（用户自己发的） ==========
  // PIPL：仅读取用户自己发出的消息，不读取他人消息
  const { data: recentMessages } = await supabase
    .from("messages")
    .select("content, created_at")
    .eq("sender_id", userId)
    .is("deleted_at", null)
    .order("created_at", { ascending: false })
    .limit(30);

  // ========== 3c. 获取最近 30 条训练日志 ==========
  const { data: recentWorkouts } = await supabase
    .from("workout_logs")
    .select("sport_type, title, duration_minutes, intensity, notes, workout_date, calories_burned")
    .eq("user_id", userId)
    .is("deleted_at", null)
    .eq("is_draft", false)
    .order("workout_date", { ascending: false })
    .limit(30);

  // ========== 3d. 获取最近 10 条公开动态 ==========
  const { data: recentPosts } = await supabase
    .from("posts")
    .select("content, created_at")
    .eq("user_id", userId)
    .order("created_at", { ascending: false })
    .limit(10);

  // ========== 3e. 构造分析 prompt 并调用 Claude API ==========
  const analysisPrompt = buildAnalysisPrompt(
    profile,
    avatar,
    recentMessages ?? [],
    recentWorkouts ?? [],
    recentPosts ?? [],
  );

  const analysisResult = await callClaudeForAnalysis(analysisPrompt);

  // ========== 3f. 校验并更新数据库 ==========
  const validTraits = (analysisResult.personality_traits ?? [])
    .filter((t: string) => VALID_TRAITS.includes(t))
    .slice(0, 5); // 最多 5 个

  const validStyle = VALID_STYLES.includes(analysisResult.speaking_style)
    ? analysisResult.speaking_style
    : (avatar.speaking_style as string); // 不合法则保持原值

  const fitnessHabits = analysisResult.fitness_habits ?? {};

  // 更新 ai_avatars 表
  const { error: updateError } = await supabase
    .from("ai_avatars")
    .update({
      // 仅在 AI 分析出有效结果时更新 traits
      ...(validTraits.length > 0 ? { personality_traits: validTraits } : {}),
      speaking_style: validStyle,
      fitness_habits: fitnessHabits,
      profile_updated_at: new Date().toISOString(),
    })
    .eq("id", avatar.id);

  if (updateError) {
    throw new Error(`数据库更新失败: ${updateError.message}`);
  }

  console.log(
    `分身 ${avatar.name} 画像更新: traits=[${validTraits}], style=${validStyle}`
  );

  return { traits: validTraits, style: validStyle };
}

// ============================================================
// 构造分析 Prompt
// ============================================================

function buildAnalysisPrompt(
  profile: Record<string, unknown> | null,
  avatar: Record<string, unknown>,
  messages: Array<Record<string, unknown>>,
  workouts: Array<Record<string, unknown>>,
  posts: Array<Record<string, unknown>>,
): string {
  // 用户基本信息
  const profileSection = profile
    ? `用户昵称: ${profile.nickname ?? "未设置"}
城市: ${profile.city ?? "未设置"}
运动类型: ${(profile.sport_types as string[])?.join("、") ?? "未设置"}
运动水平: ${profile.experience_level ?? "未设置"}
个人简介: ${profile.bio ?? ""}`
    : "无用户画像数据";

  // 当前分身配置
  const currentTraits = (avatar.personality_traits as string[])?.join(", ") ?? "无";
  const currentStyle = avatar.speaking_style ?? "friendly";

  // 聊天消息摘要
  const messagesSection = messages.length > 0
    ? messages
        .map((m, i) => `${i + 1}. [${formatDate(m.created_at as string)}] ${truncate(m.content as string, 100)}`)
        .join("\n")
    : "暂无聊天记录";

  // 训练日志摘要
  const workoutsSection = workouts.length > 0
    ? workouts
        .map((w, i) => {
          const parts = [
            `${i + 1}. [${w.workout_date}]`,
            w.sport_type,
            `${w.duration_minutes}分钟`,
            `强度${w.intensity}/10`,
          ];
          if (w.title) parts.push(`"${w.title}"`);
          if (w.notes) parts.push(`备注: ${truncate(w.notes as string, 60)}`);
          if (w.calories_burned) parts.push(`${w.calories_burned}卡`);
          return parts.join(" | ");
        })
        .join("\n")
    : "暂无训练记录";

  // 动态摘要
  const postsSection = posts.length > 0
    ? posts
        .map((p, i) => `${i + 1}. [${formatDate(p.created_at as string)}] ${truncate(p.content as string, 120)}`)
        .join("\n")
    : "暂无动态";

  return `你是一个用户画像分析专家。请根据以下数据分析该运动爱好者的画像特征，用于更新 TA 的 AI 虚拟分身。

=== 用户基本信息 ===
${profileSection}

=== 当前分身配置 ===
性格标签: ${currentTraits}
说话风格: ${currentStyle}

=== 最近聊天记录（用户自己发出的消息） ===
${messagesSection}

=== 最近训练日志 ===
${workoutsSection}

=== 最近公开动态 ===
${postsSection}

=== 分析要求 ===

请从以下维度分析并返回 JSON：

1. personality_traits: 从以下标签中选择最匹配的 3-5 个（按匹配度排序）：
   ${JSON.stringify(VALID_TRAITS)}

2. speaking_style: 从以下风格中选择最匹配的 1 个：
   ${JSON.stringify(VALID_STYLES)}
   - lively: 充满活力、感叹号多、用 emoji
   - steady: 冷静理性、言简意赅
   - humorous: 幽默风趣、爱玩梗
   - friendly: 友好随意、像朋友聊天
   - professional: 专业简洁、有条理
   - encouraging: 温暖鼓励、积极正面

3. fitness_habits: 总结用户的运动习惯，包含以下字段：
   - preferred_sports: string[] — 偏好运动（从训练日志中提炼）
   - avg_intensity: number — 平均训练强度 (1-10)
   - workout_frequency: string — 训练频率描述（如 "每周3-4次"）
   - active_time: string — 活跃时间段（如 "早晨"、"晚间"）
   - fitness_level: string — 健身水平评估（beginner/intermediate/advanced/elite）
   - summary: string — 一句话总结（中文，不超过 50 字）

=== 输出格式 ===
仅返回 JSON，不要任何其他文字：
{
  "personality_traits": ["trait1", "trait2", ...],
  "speaking_style": "style_key",
  "fitness_habits": { ... }
}`;
}

// ============================================================
// 调用 Claude API 进行画像分析
// ============================================================

async function callClaudeForAnalysis(prompt: string): Promise<AvatarProfile> {
  const response = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-api-key": ANTHROPIC_API_KEY,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify({
      model: "claude-sonnet-4-20250514",
      max_tokens: 1024,
      system: "你是一个数据分析助手。根据用户提供的数据，输出结构化的 JSON 分析结果。仅输出合法 JSON，不要包含 markdown 代码块或其他文字。",
      messages: [{ role: "user", content: prompt }],
    }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    console.error("Claude API error:", errorText);
    throw new Error(`Claude API returned ${response.status}`);
  }

  const data = await response.json();
  const text = data.content?.[0]?.text ?? "";

  // 解析 JSON（容错处理：去除可能的 markdown 包裹）
  const jsonStr = text.replace(/```json\n?/g, "").replace(/```\n?/g, "").trim();

  try {
    return JSON.parse(jsonStr) as AvatarProfile;
  } catch {
    console.error("JSON 解析失败，原始文本:", text);
    // 返回空结果，不更新任何字段
    return {
      personality_traits: [],
      speaking_style: "",
      fitness_habits: {},
    };
  }
}

// ============================================================
// 工具函数
// ============================================================

/// 构造 JSON 响应
function jsonResponse(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

/// 截断字符串
function truncate(str: string, maxLen: number): string {
  if (!str) return "";
  return str.length > maxLen ? str.substring(0, maxLen) + "…" : str;
}

/// 格式化日期为简短形式
function formatDate(isoStr: string): string {
  try {
    const d = new Date(isoStr);
    return `${d.getMonth() + 1}/${d.getDate()}`;
  } catch {
    return isoStr;
  }
}
