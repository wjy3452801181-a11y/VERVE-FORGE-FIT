// ============================================================
// VerveForge Edge Function: ai-avatar-share
// AI 分身分享 — 生成分享链接、记录分享日志、频率限制
//
// 调用方式：客户端 JWT 鉴权（POST only）
// 安全机制：
//   - JWT 鉴权（仅分身主人可分享）
//   - 频率限制：每日最多 5 次（UTC 日切）
//   - 请求体校验：avatar_id / target_type 非空 + 枚举
//   - CORS：允许浏览器 preflight
//   - PIPL 合规：分享链接仅暴露公开字段
// ============================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

// 每日分享频率限制
const DAILY_SHARE_LIMIT = 5;

// 合法的 target_type 枚举值
const VALID_TARGET_TYPES = new Set(["feed", "challenge", "group"]);

// CORS 响应头（客户端直接调用，需处理浏览器 preflight）
const CORS_HEADERS: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Authorization, Content-Type",
};

interface ShareRequest {
  avatar_id: string;
  target_type: "feed" | "challenge" | "group";
  target_id?: string;
}

serve(async (req: Request) => {
  // ========== 0. CORS preflight ==========
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: CORS_HEADERS });
  }

  // 仅接受 POST 请求
  if (req.method !== "POST") {
    return jsonError("Method not allowed", 405);
  }

  try {
    // ========== 1. JWT 鉴权 ==========
    const authHeader = req.headers.get("Authorization");
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return jsonError("Unauthorized", 401);
    }
    const token = authHeader.replace("Bearer ", "");

    // 使用用户 JWT 创建客户端（受 RLS 约束）
    const userClient = createClient(SUPABASE_URL, Deno.env.get("SUPABASE_ANON_KEY")!, {
      global: { headers: { Authorization: `Bearer ${token}` } },
    });

    // 获取当前用户
    const { data: { user }, error: authError } = await userClient.auth.getUser();
    if (authError || !user) {
      return jsonError("Unauthorized", 401);
    }

    // ========== 1.5 请求体校验 ==========
    const body: ShareRequest = await req.json();
    const { avatar_id, target_type, target_id } = body;

    if (!avatar_id || typeof avatar_id !== "string") {
      return jsonError("Missing or invalid avatar_id", 400);
    }
    if (!target_type || !VALID_TARGET_TYPES.has(target_type)) {
      return jsonError("Invalid target_type, must be feed|challenge|group", 400);
    }

    // 使用 service_role 客户端执行管理操作
    const adminClient = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // ========== 2. 验证分身归属 ==========
    const { data: avatar, error: avatarError } = await adminClient
      .from("ai_avatars")
      .select("id, user_id, share_token, ai_consent_at, name")
      .eq("id", avatar_id)
      .single();

    if (avatarError || !avatar) {
      return jsonError("Avatar not found", 404);
    }

    // 仅分身主人可分享
    if (avatar.user_id !== user.id) {
      return jsonError("Forbidden: not avatar owner", 403);
    }

    // PIPL 合规：必须已授权
    if (!avatar.ai_consent_at) {
      return jsonError("AI consent required", 403);
    }

    // ========== 3. 频率限制（UTC 日切，滚动 24h 可选） ==========
    const todayStart = new Date();
    todayStart.setUTCHours(0, 0, 0, 0);

    const { count: todayShareCount } = await adminClient
      .from("ai_avatar_share_log")
      .select("id", { count: "exact", head: true })
      .eq("sharer_id", user.id)
      .gte("share_time", todayStart.toISOString());

    if ((todayShareCount ?? 0) >= DAILY_SHARE_LIMIT) {
      return jsonError("Daily share limit reached", 429);
    }

    // ========== 4. 生成或复用 share_token ==========
    let shareToken = avatar.share_token as string | null;

    if (!shareToken) {
      // 首次分享：生成令牌并写入 ai_avatars
      shareToken = generateToken();
      await adminClient
        .from("ai_avatars")
        .update({ share_token: shareToken })
        .eq("id", avatar_id);
    }

    // 为本次分享生成独立日志令牌（追踪不同分享渠道）
    const logToken = generateToken();

    // 构造完整分享链接
    const shareLink = `/ai-avatar-shared/${shareToken}`;

    // ========== 5. 记录分享日志 ==========
    // share_time 由数据库 DEFAULT now() 生成，保证与频率限制查询时钟一致
    const { error: logError } = await adminClient
      .from("ai_avatar_share_log")
      .insert({
        avatar_id,
        sharer_id: user.id,
        target_type,
        target_id: target_id ?? null,
        share_token: logToken,
        share_link: shareLink,
      });

    if (logError) {
      console.error("分享日志记录失败:", logError);
      return jsonError("Failed to log share", 500);
    }

    // ========== 6. 返回分享链接 ==========
    console.log(`分享成功: 用户 ${user.id} 分享分身 ${avatar.name} 到 ${target_type}`);

    return new Response(
      JSON.stringify({
        success: true,
        share_token: shareToken,
        share_link: shareLink,
        remaining_today: DAILY_SHARE_LIMIT - (todayShareCount ?? 0) - 1,
      }),
      { status: 200, headers: { "Content-Type": "application/json", ...CORS_HEADERS } }
    );
  } catch (err) {
    console.error("ai-avatar-share error:", err);
    return jsonError("Internal server error", 500);
  }
});

// ============================================================
// Helper Functions
// ============================================================

/// 生成 32 字符的随机十六进制令牌
function generateToken(): string {
  const array = new Uint8Array(16);
  crypto.getRandomValues(array);
  return Array.from(array, (b) => b.toString(16).padStart(2, "0")).join("");
}

/// 统一错误响应（附带 CORS 头）
function jsonError(message: string, status: number): Response {
  return new Response(
    JSON.stringify({ error: message }),
    { status, headers: { "Content-Type": "application/json", ...CORS_HEADERS } }
  );
}
