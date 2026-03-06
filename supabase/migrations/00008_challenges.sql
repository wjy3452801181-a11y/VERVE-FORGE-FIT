-- ============================================================
-- VerveForge Migration 00008: challenges 挑战赛表
-- ============================================================

CREATE TABLE challenges (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  creator_id        UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title             TEXT NOT NULL,
  description       TEXT DEFAULT '',
  sport_type        sport_type NOT NULL,
  cover_image       TEXT,
  goal_type         TEXT NOT NULL CHECK (goal_type IN ('total_sessions', 'total_minutes', 'total_days')),
  goal_value        INT NOT NULL CHECK (goal_value > 0),
  starts_at         TIMESTAMPTZ NOT NULL,
  ends_at           TIMESTAMPTZ NOT NULL,
  max_participants  INT DEFAULT 100,
  city              TEXT,
  status            challenge_status NOT NULL DEFAULT 'active',
  participant_count INT DEFAULT 0,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at        TIMESTAMPTZ,
  CONSTRAINT valid_date_range CHECK (ends_at > starts_at)
);

CREATE INDEX idx_challenges_status ON challenges(status, starts_at DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_challenges_city ON challenges(city) WHERE deleted_at IS NULL AND city IS NOT NULL;
CREATE INDEX idx_challenges_sport ON challenges(sport_type) WHERE deleted_at IS NULL;

CREATE TABLE challenge_participants (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  challenge_id    UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  progress_value  INT NOT NULL DEFAULT 0,
  check_in_count  INT NOT NULL DEFAULT 0,
  rank            INT,
  joined_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_check_in_at TIMESTAMPTZ,
  UNIQUE(challenge_id, user_id)
);

CREATE INDEX idx_challenge_parts_challenge ON challenge_participants(challenge_id, progress_value DESC);
CREATE INDEX idx_challenge_parts_user ON challenge_participants(user_id);

CREATE TABLE challenge_check_ins (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  challenge_id    UUID NOT NULL REFERENCES challenges(id) ON DELETE CASCADE,
  participant_id  UUID NOT NULL REFERENCES challenge_participants(id) ON DELETE CASCADE,
  workout_log_id  UUID NOT NULL REFERENCES workout_logs(id) ON DELETE CASCADE,
  value           INT NOT NULL DEFAULT 1,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(challenge_id, workout_log_id)
);

-- RLS
ALTER TABLE challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenge_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenge_check_ins ENABLE ROW LEVEL SECURITY;

CREATE POLICY "challenges_read" ON challenges FOR SELECT USING (deleted_at IS NULL);
CREATE POLICY "challenges_insert" ON challenges FOR INSERT WITH CHECK (auth.uid() = creator_id);
CREATE POLICY "challenges_update" ON challenges FOR UPDATE USING (auth.uid() = creator_id);

CREATE POLICY "challenge_parts_read" ON challenge_participants FOR SELECT USING (TRUE);
CREATE POLICY "challenge_parts_insert" ON challenge_participants FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "challenge_checkins_insert" ON challenge_check_ins FOR INSERT
  WITH CHECK (EXISTS (
    SELECT 1 FROM challenge_participants WHERE id = challenge_check_ins.participant_id AND user_id = auth.uid()
  ));
CREATE POLICY "challenge_checkins_read" ON challenge_check_ins FOR SELECT USING (TRUE);
