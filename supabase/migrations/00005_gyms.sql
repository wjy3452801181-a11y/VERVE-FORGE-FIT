-- ============================================================
-- VerveForge Migration 00005: gyms + gym_reviews 训练馆表
-- ============================================================

CREATE TABLE gyms (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name            TEXT NOT NULL,
  name_en         TEXT,
  description     TEXT DEFAULT '',
  address         TEXT NOT NULL,
  city            TEXT NOT NULL,
  country         TEXT NOT NULL DEFAULT 'CN',
  location        GEOGRAPHY(POINT, 4326) NOT NULL,
  latitude        DOUBLE PRECISION NOT NULL,
  longitude       DOUBLE PRECISION NOT NULL,
  sport_types     sport_type[] NOT NULL DEFAULT '{}',
  photos          TEXT[] DEFAULT '{}',
  phone           TEXT,
  website         TEXT,
  opening_hours   JSONB,
  status          gym_status NOT NULL DEFAULT 'pending',
  submitted_by    UUID NOT NULL REFERENCES profiles(id) ON DELETE SET NULL,
  reviewed_by     UUID REFERENCES profiles(id),
  reviewed_at     TIMESTAMPTZ,
  is_verified     BOOLEAN DEFAULT FALSE,
  verified_at     TIMESTAMPTZ,
  claimed_by      UUID REFERENCES profiles(id),
  avg_rating      DECIMAL(2,1) DEFAULT 0,
  review_count    INT DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX idx_gyms_location ON gyms USING GIST(location) WHERE deleted_at IS NULL AND status = 'approved';
CREATE INDEX idx_gyms_city ON gyms(city) WHERE deleted_at IS NULL AND status = 'approved';
CREATE INDEX idx_gyms_sport_types ON gyms USING GIN(sport_types) WHERE deleted_at IS NULL AND status = 'approved';

-- 添加 workout_logs 外键（此时 gyms 表已创建）
ALTER TABLE workout_logs ADD CONSTRAINT fk_workout_gym FOREIGN KEY (gym_id) REFERENCES gyms(id) ON DELETE SET NULL;
CREATE INDEX idx_workout_logs_gym ON workout_logs(gym_id) WHERE deleted_at IS NULL AND gym_id IS NOT NULL;

-- gym_reviews 训练馆评价
CREATE TABLE gym_reviews (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  gym_id          UUID NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  rating          INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  content         TEXT DEFAULT '',
  photos          TEXT[] DEFAULT '{}',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at      TIMESTAMPTZ,
  UNIQUE(gym_id, user_id)
);

CREATE INDEX idx_gym_reviews_gym ON gym_reviews(gym_id) WHERE deleted_at IS NULL;

-- RLS
ALTER TABLE gyms ENABLE ROW LEVEL SECURITY;
ALTER TABLE gym_reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "gyms_public_read" ON gyms FOR SELECT
  USING (deleted_at IS NULL AND status = 'approved');
CREATE POLICY "gyms_insert" ON gyms FOR INSERT
  WITH CHECK (auth.uid() = submitted_by);
CREATE POLICY "gyms_owner_read" ON gyms FOR SELECT
  USING (auth.uid() = submitted_by);

CREATE POLICY "gym_reviews_read" ON gym_reviews FOR SELECT
  USING (deleted_at IS NULL);
CREATE POLICY "gym_reviews_insert" ON gym_reviews FOR INSERT
  WITH CHECK (auth.uid() = user_id);
CREATE POLICY "gym_reviews_update" ON gym_reviews FOR UPDATE
  USING (auth.uid() = user_id);
