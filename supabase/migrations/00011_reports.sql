-- ============================================================
-- VerveForge Migration 00011: reports 举报表
-- ============================================================

CREATE TABLE reports (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reporter_id       UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  reported_user_id  UUID REFERENCES profiles(id) ON DELETE SET NULL,
  reported_post_id  UUID REFERENCES posts(id) ON DELETE SET NULL,
  reported_gym_id   UUID REFERENCES gyms(id) ON DELETE SET NULL,
  report_type       report_type NOT NULL,
  description       TEXT DEFAULT '',
  is_resolved       BOOLEAN DEFAULT FALSE,
  resolved_by       UUID REFERENCES profiles(id),
  resolved_at       TIMESTAMPTZ,
  resolution_note   TEXT,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_reports_unresolved ON reports(is_resolved) WHERE is_resolved = FALSE;

-- RLS
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "reports_owner" ON reports FOR ALL USING (auth.uid() = reporter_id);
