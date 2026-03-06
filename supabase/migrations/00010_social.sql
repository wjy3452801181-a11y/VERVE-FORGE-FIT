-- ============================================================
-- VerveForge Migration 00010: 社交关系表（关注 + 屏蔽）
-- ============================================================

CREATE TABLE user_follows (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  follower_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  following_id    UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(follower_id, following_id),
  CONSTRAINT no_self_follow CHECK (follower_id != following_id)
);

CREATE INDEX idx_follows_follower ON user_follows(follower_id);
CREATE INDEX idx_follows_following ON user_follows(following_id);

CREATE TABLE user_blocks (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  blocker_id      UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  blocked_id      UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(blocker_id, blocked_id),
  CONSTRAINT no_self_block CHECK (blocker_id != blocked_id)
);

CREATE INDEX idx_blocks_blocker ON user_blocks(blocker_id);

-- RLS
ALTER TABLE user_follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_blocks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "follows_read" ON user_follows FOR SELECT USING (TRUE);
CREATE POLICY "follows_owner" ON user_follows FOR ALL USING (auth.uid() = follower_id);

CREATE POLICY "blocks_owner" ON user_blocks FOR ALL USING (auth.uid() = blocker_id);
