-- ============================================================
-- 验证脚本: AI 分身分享模块
-- 用途: 迁移后逐项验证表结构、RLS、频率限制、公开视图
--
-- 使用方式:
--   在 Supabase SQL Editor 中按区块执行（不要一次全跑）
--   标记 [需替换] 的地方需要填入真实 UUID
-- ============================================================


-- ============================================================
-- A. 表结构验证 — 确认所有 PRD 字段存在且类型正确
-- ============================================================

-- A1. ai_avatar_share_log 字段清单
-- 预期: id(uuid), avatar_id(uuid), sharer_id(uuid), target_type(text),
--       target_id(text), share_time(timestamptz), share_token(text),
--       share_link(text), created_at(timestamptz)
SELECT
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'ai_avatar_share_log'
ORDER BY ordinal_position;

-- A2. 约束验证 — 确认 chk_target_type + share_token UNIQUE
SELECT
  conname  AS constraint_name,
  contype  AS constraint_type,  -- c=check, u=unique, p=primary, f=foreign
  pg_get_constraintdef(oid) AS definition
FROM pg_constraint
WHERE conrelid = 'ai_avatar_share_log'::regclass
ORDER BY contype, conname;

-- A3. 索引验证 — 确认 3 个索引已创建
SELECT
  indexname,
  indexdef
FROM pg_indexes
WHERE tablename = 'ai_avatar_share_log'
ORDER BY indexname;

-- A4. ai_avatars.share_token 列存在性
-- 预期: 1 行, data_type=text
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'ai_avatars'
  AND column_name = 'share_token';


-- ============================================================
-- B. RLS 策略验证 — 确认 3 条策略生效
-- ============================================================

-- B1. 列出 ai_avatar_share_log 上的所有 RLS 策略
-- 预期: owner_read_share_log, owner_insert_share_log, service_role_full_share_log
SELECT
  policyname,
  cmd       AS applies_to,  -- SELECT / INSERT / ALL
  qual      AS using_expr,
  with_check
FROM pg_policies
WHERE tablename = 'ai_avatar_share_log'
ORDER BY policyname;

-- B2. 确认 RLS 已启用
-- 预期: relrowsecurity = true, relforcerowsecurity = false
SELECT
  relname,
  relrowsecurity,
  relforcerowsecurity
FROM pg_class
WHERE relname = 'ai_avatar_share_log';


-- ============================================================
-- C. 公开视图验证
-- ============================================================

-- C1. 视图字段 — 确认仅暴露公开字段
-- 预期: id, name, avatar_url, personality_traits, speaking_style,
--       share_token, owner_nickname, owner_city（共 8 列）
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'ai_avatar_public_view'
ORDER BY ordinal_position;

-- C2. 视图安全属性 — 确认 security_invoker = true（00023 迁移）
-- 预期: security_invoker = true
SELECT
  c.relname,
  COALESCE(
    (SELECT option_value FROM pg_options_to_table(c.reloptions)
     WHERE option_name = 'security_invoker'),
    'false'
  ) AS security_invoker
FROM pg_class c
WHERE c.relname = 'ai_avatar_public_view'
  AND c.relkind = 'v';


-- ============================================================
-- D. 数据写入 + 频率限制验证（功能测试）
-- ============================================================
-- 注意: 以下语句需使用 service_role 连接执行
-- [需替换] 将 <AVATAR_ID> / <USER_ID> 替换为真实 UUID

-- D1. 插入一条测试分享记录
/*
INSERT INTO ai_avatar_share_log (avatar_id, sharer_id, target_type, target_id, share_token, share_link)
VALUES (
  '<AVATAR_ID>',
  '<USER_ID>',
  'feed',
  NULL,
  encode(gen_random_bytes(16), 'hex'),
  '/ai-avatar-shared/' || encode(gen_random_bytes(16), 'hex')
);
*/

-- D2. 查询该用户的分享记录
-- 预期: 至少 1 行, share_time / share_link 均有值
/*
SELECT
  id,
  avatar_id,
  target_type,
  target_id,
  share_time,
  share_token,
  share_link,
  created_at
FROM ai_avatar_share_log
WHERE sharer_id = '<USER_ID>'
ORDER BY share_time DESC
LIMIT 10;
*/

-- D3. 每日频率限制检查（当天 UTC 已分享次数）
-- 预期: today_count < 5 时允许分享
/*
SELECT
  COUNT(*)                          AS today_count,
  5 - COUNT(*)                      AS remaining,
  CASE WHEN COUNT(*) >= 5
       THEN '已达上限'
       ELSE '可继续分享'
  END                               AS status
FROM ai_avatar_share_log
WHERE sharer_id = '<USER_ID>'
  AND share_time >= DATE_TRUNC('day', NOW() AT TIME ZONE 'UTC');
*/

-- D4. 通过 share_token 查询公开视图（模拟打开分享链接）
-- 预期: 返回仅公开字段，不含 custom_prompt / auto_reply_enabled 等私密列
/*
SELECT *
FROM ai_avatar_public_view
WHERE share_token = '<SHARE_TOKEN>';
*/


-- ============================================================
-- E. RLS 隔离性验证（安全测试）
-- ============================================================
-- 需要以不同用户身份执行，验证跨用户隔离

-- E1. 非 owner 不能读取他人的分享记录
-- 操作: 以 <OTHER_USER_ID> 身份连接后执行
-- 预期: 返回 0 行
/*
SET request.jwt.claim.sub = '<OTHER_USER_ID>';
SET role TO authenticated;

SELECT * FROM ai_avatar_share_log
WHERE sharer_id = '<USER_ID>';
-- 预期: 0 行（RLS 阻止跨用户读取）

RESET role;
*/

-- E2. 非 owner 不能插入伪造分享记录
-- 预期: 违反 RLS WITH CHECK，插入失败
/*
SET request.jwt.claim.sub = '<OTHER_USER_ID>';
SET role TO authenticated;

INSERT INTO ai_avatar_share_log (avatar_id, sharer_id, target_type, share_token, share_link)
VALUES (
  '<AVATAR_ID>',
  '<USER_ID>',          -- 伪造为他人的 sharer_id
  'feed',
  'fake-token-123',
  '/ai-avatar-shared/fake-token-123'
);
-- 预期: ERROR, new row violates row-level security policy

RESET role;
*/

-- E3. CHECK 约束验证 — 非法 target_type 被拒绝
-- 预期: 违反 chk_target_type，插入失败
/*
INSERT INTO ai_avatar_share_log (avatar_id, sharer_id, target_type, share_token, share_link)
VALUES (
  '<AVATAR_ID>',
  '<USER_ID>',
  'invalid_type',
  encode(gen_random_bytes(16), 'hex'),
  '/ai-avatar-shared/test'
);
-- 预期: ERROR, new row violates check constraint "chk_target_type"
*/


-- ============================================================
-- F. 数据统计（运营分析用）
-- ============================================================

-- F1. 按目标类型统计分享量
SELECT
  target_type,
  COUNT(*)                   AS share_count,
  COUNT(DISTINCT sharer_id)  AS unique_sharers,
  COUNT(DISTINCT avatar_id)  AS unique_avatars
FROM ai_avatar_share_log
GROUP BY target_type
ORDER BY share_count DESC;

-- F2. 近 7 天每日分享趋势
SELECT
  DATE_TRUNC('day', share_time)::date AS share_date,
  COUNT(*)                            AS daily_count
FROM ai_avatar_share_log
WHERE share_time >= NOW() - INTERVAL '7 days'
GROUP BY share_date
ORDER BY share_date DESC;

-- F3. 分享最多的 Top 10 分身
SELECT
  a.name           AS avatar_name,
  p.nickname       AS owner_nickname,
  COUNT(sl.id)     AS total_shares
FROM ai_avatar_share_log sl
JOIN ai_avatars a ON a.id = sl.avatar_id
JOIN profiles p   ON p.id = sl.sharer_id
GROUP BY a.name, p.nickname
ORDER BY total_shares DESC
LIMIT 10;
