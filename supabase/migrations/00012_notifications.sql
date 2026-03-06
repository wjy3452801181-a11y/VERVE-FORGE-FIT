-- ============================================================
-- VerveForge Migration 00012: notifications 通知表
-- ============================================================

CREATE TABLE notifications (
  id                   UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id              UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  type                 notification_type NOT NULL,
  title                TEXT NOT NULL,
  body                 TEXT DEFAULT '',
  ref_user_id          UUID REFERENCES profiles(id),
  ref_post_id          UUID REFERENCES posts(id),
  ref_challenge_id     UUID REFERENCES challenges(id),
  ref_conversation_id  UUID REFERENCES conversations(id),
  ref_buddy_request_id UUID REFERENCES buddy_requests(id),
  is_read              BOOLEAN DEFAULT FALSE,
  read_at              TIMESTAMPTZ,
  created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id, is_read, created_at DESC);

-- RLS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "notifications_owner" ON notifications FOR ALL USING (auth.uid() = user_id);
