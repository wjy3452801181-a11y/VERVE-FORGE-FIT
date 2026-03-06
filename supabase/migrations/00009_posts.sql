-- ============================================================
-- VerveForge Migration 00009: posts 动态表
-- ============================================================

CREATE TABLE posts (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  content         TEXT NOT NULL DEFAULT '',
  photos          TEXT[] DEFAULT '{}',
  workout_log_id  UUID REFERENCES workout_logs(id) ON DELETE SET NULL,
  gym_id          UUID REFERENCES gyms(id) ON DELETE SET NULL,
  challenge_id    UUID REFERENCES challenges(id) ON DELETE SET NULL,
  city            TEXT,
  like_count      INT DEFAULT 0,
  comment_count   INT DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX idx_posts_user ON posts(user_id, created_at DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_posts_city ON posts(city, created_at DESC) WHERE deleted_at IS NULL AND city IS NOT NULL;
CREATE INDEX idx_posts_created ON posts(created_at DESC) WHERE deleted_at IS NULL;

CREATE TABLE post_likes (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id         UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(post_id, user_id)
);

CREATE INDEX idx_post_likes_post ON post_likes(post_id);

CREATE TABLE post_comments (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id         UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  content         TEXT NOT NULL,
  parent_id       UUID REFERENCES post_comments(id) ON DELETE CASCADE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX idx_post_comments_post ON post_comments(post_id, created_at ASC) WHERE deleted_at IS NULL;

-- RLS
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "posts_read" ON posts FOR SELECT USING (deleted_at IS NULL);
CREATE POLICY "posts_owner" ON posts FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "post_likes_read" ON post_likes FOR SELECT USING (TRUE);
CREATE POLICY "post_likes_owner" ON post_likes FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "post_comments_read" ON post_comments FOR SELECT USING (deleted_at IS NULL);
CREATE POLICY "post_comments_owner" ON post_comments FOR ALL USING (auth.uid() = user_id);
