-- ============================================================
-- VerveForge Migration 00006: buddy_requests 约练请求表
-- ============================================================

CREATE TABLE buddy_requests (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sender_id       UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  receiver_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  status          buddy_request_status NOT NULL DEFAULT 'pending',
  message         TEXT DEFAULT '',
  responded_at    TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT no_self_request CHECK (sender_id != receiver_id)
);

CREATE INDEX idx_buddy_requests_receiver ON buddy_requests(receiver_id, status) WHERE status = 'pending';
CREATE INDEX idx_buddy_requests_sender ON buddy_requests(sender_id);
CREATE UNIQUE INDEX idx_buddy_unique_pending ON buddy_requests(sender_id, receiver_id) WHERE status = 'pending';

-- RLS
ALTER TABLE buddy_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "buddy_requests_access" ON buddy_requests FOR ALL
  USING (auth.uid() IN (sender_id, receiver_id));
