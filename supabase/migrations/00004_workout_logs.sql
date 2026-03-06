-- ============================================================
-- VerveForge Migration 00004: workout_logs 训练日志表
-- ============================================================

CREATE TABLE workout_logs (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id           UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  sport_type        sport_type NOT NULL,
  title             TEXT DEFAULT '',
  duration_minutes  INT NOT NULL CHECK (duration_minutes > 0),
  intensity         INT NOT NULL CHECK (intensity BETWEEN 1 AND 10),
  notes             TEXT DEFAULT '',
  photos            TEXT[] DEFAULT '{}',
  gym_id            UUID,  -- W4 建立外键关联
  calories_burned   INT,
  avg_heart_rate    INT,
  steps             INT,
  health_kit_id     TEXT,
  workout_date      DATE NOT NULL DEFAULT CURRENT_DATE,
  started_at        TIMESTAMPTZ,
  ended_at          TIMESTAMPTZ,
  is_draft          BOOLEAN DEFAULT FALSE,
  synced_at         TIMESTAMPTZ,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at        TIMESTAMPTZ
);

CREATE INDEX idx_workout_logs_user_date ON workout_logs(user_id, workout_date DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_workout_logs_sport ON workout_logs(sport_type) WHERE deleted_at IS NULL;

-- RLS
ALTER TABLE workout_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "workout_logs_owner" ON workout_logs FOR ALL
  USING (auth.uid() = user_id);

CREATE POLICY "workout_logs_public_read" ON workout_logs FOR SELECT
  USING (
    deleted_at IS NULL
    AND EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = workout_logs.user_id
        AND profiles.show_workout_stats = TRUE
        AND profiles.deleted_at IS NULL
    )
  );
