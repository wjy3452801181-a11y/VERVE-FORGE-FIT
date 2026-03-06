-- ============================================================
-- VerveForge Migration 00003: profiles 用户档案表
-- ============================================================

CREATE TABLE profiles (
  id                UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nickname          TEXT NOT NULL,
  avatar_url        TEXT,
  bio               TEXT DEFAULT '',
  gender            TEXT CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
  birth_year        INT,
  city              TEXT NOT NULL DEFAULT '',
  country           TEXT NOT NULL DEFAULT 'CN',
  sport_types       sport_type[] NOT NULL DEFAULT '{}',
  experience_level  TEXT CHECK (experience_level IN ('beginner', 'intermediate', 'advanced', 'elite')),
  health_sync_enabled BOOLEAN DEFAULT FALSE,
  is_discoverable   BOOLEAN DEFAULT TRUE,
  show_workout_stats BOOLEAN DEFAULT TRUE,
  fitness_score     INT,
  privacy_agreed_at TIMESTAMPTZ,
  data_export_requested_at TIMESTAMPTZ,
  account_deletion_requested_at TIMESTAMPTZ,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at        TIMESTAMPTZ
);

CREATE INDEX idx_profiles_city ON profiles(city) WHERE deleted_at IS NULL;
CREATE INDEX idx_profiles_sport_types ON profiles USING GIN(sport_types) WHERE deleted_at IS NULL;
CREATE INDEX idx_profiles_discoverable ON profiles(is_discoverable) WHERE deleted_at IS NULL AND is_discoverable = TRUE;

-- RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "profiles_select" ON profiles FOR SELECT
  USING (deleted_at IS NULL);

CREATE POLICY "profiles_insert" ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "profiles_update" ON profiles FOR UPDATE
  USING (auth.uid() = id);
