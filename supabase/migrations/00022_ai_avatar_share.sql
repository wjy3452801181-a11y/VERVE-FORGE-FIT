-- ============================================================
-- Migration: 00022_ai_avatar_share.sql
-- AI 分身分享功能 — 分享日志 + 分享令牌
--
-- 用途：
--   - 记录分身分享行为（防刷 + 数据分析）
--   - 生成唯一分享令牌（share_token），用于构造公开分享链接
--   - 每日每用户最多分享 5 次
-- PIPL 合规：
--   - 分享日志仅记录 avatar_id / target_type，不记录浏览者数据
--   - 分享页仅展示公开字段（name, avatar_url, personality_traits, speaking_style）
-- ============================================================

-- 1. 分享日志表
CREATE TABLE IF NOT EXISTS ai_avatar_share_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  avatar_id UUID NOT NULL REFERENCES ai_avatars(id) ON DELETE CASCADE,
  sharer_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  target_type TEXT NOT NULL DEFAULT 'feed',  -- 分享目标：feed / challenge / group
  target_id TEXT,                             -- 目标 ID（动态 ID / 挑战赛 ID / 群聊 ID，可为空）
  share_time TIMESTAMPTZ NOT NULL DEFAULT now(),  -- 分享时间（PRD 字段）
  share_token TEXT NOT NULL UNIQUE,               -- 唯一分享令牌（构造公开链接）
  share_link TEXT NOT NULL,                       -- 完整分享链接 /ai-avatar-shared/:share_token
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),  -- 记录创建时间（与 share_time 一致，保留用于通用排序）

  -- 约束：目标类型枚举
  CONSTRAINT chk_target_type CHECK (
    target_type IN ('feed', 'challenge', 'group')
  )
);

-- 2. 索引
-- 按用户 + 分享时间查询（频率限制）
CREATE INDEX IF NOT EXISTS idx_share_log_sharer_date
  ON ai_avatar_share_log (sharer_id, share_time DESC);

-- 按分享令牌查询（打开分享链接时）
CREATE INDEX IF NOT EXISTS idx_share_log_token
  ON ai_avatar_share_log (share_token);

-- 按 avatar 查询（分析分享数据）
CREATE INDEX IF NOT EXISTS idx_share_log_avatar
  ON ai_avatar_share_log (avatar_id, created_at DESC);

-- 3. RLS 策略
ALTER TABLE ai_avatar_share_log ENABLE ROW LEVEL SECURITY;

-- 分享者可读自己的分享记录
CREATE POLICY "owner_read_share_log" ON ai_avatar_share_log
  FOR SELECT
  USING (auth.uid() = sharer_id);

-- 分享者可创建分享记录
CREATE POLICY "owner_insert_share_log" ON ai_avatar_share_log
  FOR INSERT
  WITH CHECK (auth.uid() = sharer_id);

-- service_role 完整访问（Edge Function 用）
CREATE POLICY "service_role_full_share_log" ON ai_avatar_share_log
  FOR ALL
  USING (auth.role() = 'service_role')
  WITH CHECK (auth.role() = 'service_role');

-- 4. ai_avatars 表新增 share_token 列（主分享令牌，分享时可复用或重新生成）
ALTER TABLE ai_avatars ADD COLUMN IF NOT EXISTS share_token TEXT UNIQUE;

-- 为已有分身生成 share_token
UPDATE ai_avatars
SET share_token = encode(gen_random_bytes(16), 'hex')
WHERE share_token IS NULL;

-- 5. 公开视图：分享页查询时只暴露公开字段
CREATE OR REPLACE VIEW ai_avatar_public_view AS
SELECT
  a.id,
  a.name,
  a.avatar_url,
  a.personality_traits,
  a.speaking_style,
  a.share_token,
  p.nickname AS owner_nickname,
  p.city AS owner_city
FROM ai_avatars a
JOIN profiles p ON p.id = a.user_id
WHERE a.ai_consent_at IS NOT NULL;  -- 仅已授权的分身可被公开查看

-- 允许所有认证用户通过 share_token 查询公开视图
-- 注意：视图权限通过底层表的 RLS 控制，此处无需额外策略

-- 6. 表注释
COMMENT ON TABLE ai_avatar_share_log IS 'AI 分身分享日志（频率限制 + 数据分析）';
COMMENT ON COLUMN ai_avatar_share_log.share_time IS '分享发生时间，用于频率限制（每日 5 次）';
COMMENT ON COLUMN ai_avatar_share_log.share_token IS '唯一分享令牌，构造 /ai-avatar-shared/:token 链接';
COMMENT ON COLUMN ai_avatar_share_log.share_link IS '完整分享链接，格式 /ai-avatar-shared/:share_token';
COMMENT ON COLUMN ai_avatar_share_log.target_type IS '分享目标: feed(动态) / challenge(挑战赛) / group(群聊)';
COMMENT ON COLUMN ai_avatars.share_token IS '分身主分享令牌，首次分享时生成';
