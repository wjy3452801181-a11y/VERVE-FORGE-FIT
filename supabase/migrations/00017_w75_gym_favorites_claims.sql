-- ============================================================
-- VerveForge Migration 00017: 训练馆收藏 + 馆主认领
-- W7.5 增量迁移
-- ============================================================

-- -----------------------------------------------------------
-- 1. gym_claim_status 枚举
-- -----------------------------------------------------------

CREATE TYPE gym_claim_status AS ENUM ('pending', 'approved', 'rejected');

-- -----------------------------------------------------------
-- 2. user_gym_favorites 收藏表
-- -----------------------------------------------------------

CREATE TABLE user_gym_favorites (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  gym_id      UUID NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, gym_id)
);

CREATE INDEX idx_user_gym_favorites_user ON user_gym_favorites(user_id);
CREATE INDEX idx_user_gym_favorites_gym  ON user_gym_favorites(gym_id);

-- RLS
ALTER TABLE user_gym_favorites ENABLE ROW LEVEL SECURITY;

-- 任何登录用户可查看自己的收藏
CREATE POLICY "gym_fav_select_own"
  ON user_gym_favorites FOR SELECT
  USING (auth.uid() = user_id);

-- 登录用户可添加收藏
CREATE POLICY "gym_fav_insert_own"
  ON user_gym_favorites FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 登录用户可取消自己的收藏
CREATE POLICY "gym_fav_delete_own"
  ON user_gym_favorites FOR DELETE
  USING (auth.uid() = user_id);

-- -----------------------------------------------------------
-- 3. gym_claims 馆主认领表
-- -----------------------------------------------------------

CREATE TABLE gym_claims (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  gym_id           UUID NOT NULL REFERENCES gyms(id) ON DELETE CASCADE,
  claimant_user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  status           gym_claim_status NOT NULL DEFAULT 'pending',
  -- 认领理由 / 证明材料（预留）
  reason           TEXT DEFAULT '',
  evidence_urls    TEXT[] DEFAULT '{}',
  applied_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  reviewed_at      TIMESTAMPTZ,
  reviewed_by      UUID REFERENCES profiles(id),
  UNIQUE(gym_id, claimant_user_id)
);

CREATE INDEX idx_gym_claims_gym       ON gym_claims(gym_id);
CREATE INDEX idx_gym_claims_claimant  ON gym_claims(claimant_user_id);
CREATE INDEX idx_gym_claims_status    ON gym_claims(status) WHERE status = 'pending';

-- RLS
ALTER TABLE gym_claims ENABLE ROW LEVEL SECURITY;

-- 用户可查看自己提交的认领
CREATE POLICY "gym_claims_select_own"
  ON gym_claims FOR SELECT
  USING (auth.uid() = claimant_user_id);

-- 管理员/审核员可查看所有待审核（通过 service role 操作，不在 RLS 内）
-- 暂不添加管理员策略，后期通过 Dashboard 或 service_role key 审核

-- 登录用户可提交认领申请
CREATE POLICY "gym_claims_insert_own"
  ON gym_claims FOR INSERT
  WITH CHECK (auth.uid() = claimant_user_id);

-- -----------------------------------------------------------
-- 4. 触发器：认领审核通过后自动更新 gyms.claimed_by
-- -----------------------------------------------------------

CREATE OR REPLACE FUNCTION handle_gym_claim_approved()
RETURNS TRIGGER AS $$
BEGIN
  -- 仅在状态变更为 approved 时执行
  IF NEW.status = 'approved' AND (OLD.status IS NULL OR OLD.status != 'approved') THEN
    UPDATE gyms
    SET claimed_by = NEW.claimant_user_id,
        is_verified = TRUE,
        verified_at = NOW(),
        updated_at = NOW()
    WHERE id = NEW.gym_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_gym_claim_approved
  AFTER UPDATE ON gym_claims
  FOR EACH ROW
  EXECUTE FUNCTION handle_gym_claim_approved();
