-- ============================================================
-- VerveForge Migration 00018: AI 虚拟分身 (AI Avatars)
-- ============================================================

-- 1. 创建 ai_avatars 表
CREATE TABLE ai_avatars (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id             UUID NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  name                VARCHAR(50) NOT NULL,
  avatar_url          TEXT,
  personality_traits  TEXT[] DEFAULT '{}',
  speaking_style      VARCHAR(20) DEFAULT 'friendly',
  custom_prompt       TEXT DEFAULT '',
  auto_reply_enabled  BOOLEAN DEFAULT FALSE,
  ai_consent_at       TIMESTAMPTZ,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ai_avatars_user ON ai_avatars(user_id);

-- 2. profiles 表新增 last_seen_at 列（离线检测）
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS last_seen_at TIMESTAMPTZ;

-- 3. RLS 策略
ALTER TABLE ai_avatars ENABLE ROW LEVEL SECURITY;

-- Owner 可以完全操作自己的分身
CREATE POLICY "ai_avatars_owner_all" ON ai_avatars FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 所有登录用户可查看分身的公开信息（名称和头像）
CREATE POLICY "ai_avatars_public_read" ON ai_avatars FOR SELECT
  USING (auth.role() = 'authenticated');

-- 4. updated_at 自动更新触发器
CREATE OR REPLACE FUNCTION update_ai_avatars_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_ai_avatars_updated_at
  BEFORE UPDATE ON ai_avatars
  FOR EACH ROW
  EXECUTE FUNCTION update_ai_avatars_updated_at();

-- 5. 自动回复触发器
-- 当 messages 表 INSERT 时，检查接收者是否离线且启用了自动回复
CREATE OR REPLACE FUNCTION trigger_ai_auto_reply()
RETURNS TRIGGER AS $$
DECLARE
  _recipient_id UUID;
  _avatar_record RECORD;
  _last_seen TIMESTAMPTZ;
  _edge_fn_url TEXT;
BEGIN
  -- 防循环：跳过 AI 生成的消息
  IF NEW.metadata IS NOT NULL AND (NEW.metadata->>'is_ai_generated')::boolean = true THEN
    RETURN NEW;
  END IF;

  -- 获取对话的另一方参与者（1v1 聊天）
  SELECT user_id INTO _recipient_id
  FROM conversation_participants
  WHERE conversation_id = NEW.conversation_id
    AND user_id != NEW.sender_id
  LIMIT 1;

  -- 没有接收者则跳过
  IF _recipient_id IS NULL THEN
    RETURN NEW;
  END IF;

  -- 检查接收者是否有分身且启用了自动回复
  SELECT * INTO _avatar_record
  FROM ai_avatars
  WHERE user_id = _recipient_id
    AND auto_reply_enabled = true
    AND ai_consent_at IS NOT NULL;

  IF _avatar_record IS NULL THEN
    RETURN NEW;
  END IF;

  -- 检查接收者是否离线（last_seen_at 超过 5 分钟）
  SELECT last_seen_at INTO _last_seen
  FROM profiles
  WHERE id = _recipient_id;

  IF _last_seen IS NULL OR (NOW() - _last_seen) < INTERVAL '5 minutes' THEN
    RETURN NEW;
  END IF;

  -- 通过 pg_net 异步调用 Edge Function
  _edge_fn_url := current_setting('app.settings.edge_function_url', true)
    || '/ai-avatar-reply';

  PERFORM net.http_post(
    url := _edge_fn_url,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key', true)
    ),
    body := jsonb_build_object(
      'message_id', NEW.id,
      'conversation_id', NEW.conversation_id,
      'sender_id', NEW.sender_id,
      'recipient_id', _recipient_id,
      'avatar_id', _avatar_record.id,
      'content', NEW.content
    )
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_messages_ai_auto_reply
  AFTER INSERT ON messages
  FOR EACH ROW
  EXECUTE FUNCTION trigger_ai_auto_reply();
