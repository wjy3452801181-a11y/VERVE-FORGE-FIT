-- ============================================================
-- VerveForge Migration 00019: 自动回复增强
-- 新增 ai_auto_reply_log 表（频率限制 + 审计追踪）
-- 更新触发器函数：增加频率限制检查
-- ============================================================

-- 1. 创建自动回复日志表
-- 用途：频率限制查询 + 后台审计 + 数据分析
CREATE TABLE ai_auto_reply_log (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  avatar_id           UUID NOT NULL REFERENCES ai_avatars(id) ON DELETE CASCADE,
  conversation_id     UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  recipient_id        UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  sender_id           UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  trigger_message_id  UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 索引：按对话 + 时间查询（频率限制）
CREATE INDEX idx_auto_reply_log_conv_time
  ON ai_auto_reply_log(conversation_id, created_at DESC);

-- 索引：按分身查询（数据分析）
CREATE INDEX idx_auto_reply_log_avatar
  ON ai_auto_reply_log(avatar_id, created_at DESC);

-- RLS：仅分身主人可查看自己的自动回复日志
ALTER TABLE ai_auto_reply_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "auto_reply_log_owner_read" ON ai_auto_reply_log FOR SELECT
  USING (auth.uid() = recipient_id);

-- service_role 可以插入（Edge Function 使用 service_role_key）
-- 默认 RLS 对 service_role 不生效，无需额外策略

-- 2. 替换触发器函数：增加频率限制检查
-- 5 分钟内同一对话最多触发 3 次自动回复
CREATE OR REPLACE FUNCTION trigger_ai_auto_reply()
RETURNS TRIGGER AS $$
DECLARE
  _recipient_id UUID;
  _avatar_record RECORD;
  _last_seen TIMESTAMPTZ;
  _recent_reply_count INT;
  _edge_fn_url TEXT;
BEGIN
  -- 防循环：跳过 AI 生成的消息
  IF NEW.metadata IS NOT NULL
     AND (NEW.metadata->>'is_ai_generated')::boolean = true THEN
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

  -- 检查接收者是否有分身且启用了自动回复 + 已授权（PIPL）
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

  -- 如果用户在线（5 分钟内有心跳）则不触发自动回复
  IF _last_seen IS NOT NULL AND (NOW() - _last_seen) < INTERVAL '5 minutes' THEN
    RETURN NEW;
  END IF;

  -- 频率限制：查询 5 分钟内该对话已有多少条自动回复
  SELECT COUNT(*) INTO _recent_reply_count
  FROM messages
  WHERE conversation_id = NEW.conversation_id
    AND sender_id = _recipient_id
    AND metadata IS NOT NULL
    AND (metadata->>'is_ai_generated')::boolean = true
    AND created_at > NOW() - INTERVAL '5 minutes';

  -- 超过 3 次则不再触发
  IF _recent_reply_count >= 3 THEN
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

-- 注意：触发器 trg_messages_ai_auto_reply 已在 00018 中创建
-- CREATE OR REPLACE FUNCTION 会原地更新函数体，触发器自动使用新版本
-- 无需 DROP/重建触发器

-- 3. 为频率限制查询添加 messages 表的 metadata 部分索引
-- 仅索引 is_ai_generated = true 的消息，查询速度更快
CREATE INDEX IF NOT EXISTS idx_messages_ai_generated
  ON messages(conversation_id, sender_id, created_at DESC)
  WHERE metadata IS NOT NULL AND (metadata->>'is_ai_generated')::boolean = true;
