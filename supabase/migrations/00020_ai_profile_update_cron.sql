-- ============================================================
-- VerveForge Migration 00020: AI 画像字段扩展
-- 新增字段：fitness_habits (JSONB) + profile_updated_at
--
-- ⚠️ 已废弃自动定时任务
-- 原因：PIPL/PDPO 合规要求，画像更新必须由用户手动同意触发，
-- 不得自动进行。cron job 及触发函数已移除。
-- 画像更新改为用户在分身详情页点击"更新画像"按钮 → 确认弹窗
-- → 调用 Edge Function 单次更新。
-- ============================================================

-- 1. ai_avatars 表新增 fitness_habits 列（运动习惯画像）
-- 数据结构示例：
-- {
--   "preferred_sports": ["running", "crossfit"],
--   "avg_intensity": 7,
--   "workout_frequency": "每周3-4次",
--   "active_time": "早晨",
--   "fitness_level": "intermediate",
--   "summary": "热爱晨跑和CrossFit的中级运动者"
-- }
ALTER TABLE ai_avatars
  ADD COLUMN IF NOT EXISTS fitness_habits JSONB DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS profile_updated_at TIMESTAMPTZ;

-- 2. 为 fitness_habits 创建 GIN 索引（支持 JSONB 内容查询）
CREATE INDEX IF NOT EXISTS idx_ai_avatars_fitness_habits
  ON ai_avatars USING GIN (fitness_habits);

-- 3. 清理已废弃的 cron job（如果之前已部署）
-- 安全地取消调度，不存在时忽略错误
DO $$
BEGIN
  PERFORM cron.unschedule('ai-profile-daily-update');
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'cron job ai-profile-daily-update 不存在，无需清理';
END $$;

-- 4. 删除已废弃的 cron 触发函数
DROP FUNCTION IF EXISTS cron_update_ai_profiles();

-- 5. 更新 RLS 策略：fitness_habits 和 profile_updated_at 遵循现有 owner 策略
-- ai_avatars_owner_all 已在 00018 中创建，覆盖所有列，无需额外策略

COMMENT ON COLUMN ai_avatars.fitness_habits IS 'AI 分析的运动习惯画像 (JSONB)，由用户手动触发更新';
COMMENT ON COLUMN ai_avatars.profile_updated_at IS '画像最后更新时间（用户手动触发）';
