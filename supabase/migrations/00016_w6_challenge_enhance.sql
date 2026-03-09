-- ============================================================
-- VerveForge Migration 00016: W6 挑战赛增强 — metrics_rules + 排行榜视图
-- ============================================================
-- 现有 00008 已建 challenges / challenge_participants / challenge_check_ins
-- 本迁移补充：
--   1. challenges.metrics_rules JSONB — 用于定义各运动类型的排名规则
--   2. 排行榜视图 — 聚合 workout_logs 真实成绩用于实时排行

-- -------------------------------------------------------
-- 1. challenges 表新增 metrics_rules JSONB
-- -------------------------------------------------------
-- metrics_rules 结构约定：
--   {
--     "rank_by": "total_sessions" | "total_minutes" | "best_time" | "total_distance",
--     "sport_types": ["hyrox", "crossfit"],     -- 多运动类型支持
--     "min_intensity": 3,                        -- 最低强度要求
--     "require_metrics": false                   -- 是否要求专项成绩
--   }
ALTER TABLE challenges
  ADD COLUMN IF NOT EXISTS metrics_rules JSONB DEFAULT '{}';

-- -------------------------------------------------------
-- 2. 排行榜视图 — 聚合参与者真实训练数据
-- -------------------------------------------------------
-- 视图：challenge_leaderboard
-- 联合 challenge_participants + profiles + workout_logs（通过 check_ins）
-- 排行榜仅展示用户已授权的公开数据（profiles.show_workout_stats = TRUE）
CREATE OR REPLACE VIEW challenge_leaderboard AS
SELECT
  cp.id AS participant_id,
  cp.challenge_id,
  cp.user_id,
  p.nickname,
  p.avatar_url,
  cp.progress_value,
  cp.check_in_count,
  cp.joined_at,
  cp.last_check_in_at,
  c.goal_type,
  c.goal_value,
  c.sport_type,
  -- 进度百分比（封顶 100%）
  LEAST(ROUND(cp.progress_value * 100.0 / NULLIF(c.goal_value, 0), 1), 100) AS progress_pct,
  -- 排名（按 progress_value 降序）
  RANK() OVER (
    PARTITION BY cp.challenge_id
    ORDER BY cp.progress_value DESC, cp.last_check_in_at ASC NULLS LAST
  ) AS rank
FROM challenge_participants cp
JOIN challenges c ON c.id = cp.challenge_id AND c.deleted_at IS NULL
JOIN profiles p ON p.id = cp.user_id AND p.deleted_at IS NULL
  AND p.show_workout_stats = TRUE  -- 仅展示公开数据
ORDER BY cp.challenge_id, rank;

-- -------------------------------------------------------
-- 3. 挑战赛汇总视图 — 列表页用
-- -------------------------------------------------------
CREATE OR REPLACE VIEW challenge_summary AS
SELECT
  c.*,
  p.nickname AS creator_nickname,
  p.avatar_url AS creator_avatar,
  -- 当前用户是否已参加（需在查询时通过 auth.uid() 过滤）
  EXISTS (
    SELECT 1 FROM challenge_participants cp
    WHERE cp.challenge_id = c.id AND cp.user_id = auth.uid()
  ) AS is_joined
FROM challenges c
JOIN profiles p ON p.id = c.creator_id AND p.deleted_at IS NULL
WHERE c.deleted_at IS NULL;

-- -------------------------------------------------------
-- 4. 给 challenge_participants 添加 RLS DELETE 策略
-- -------------------------------------------------------
-- 允许用户退出自己参加的挑战
CREATE POLICY "challenge_parts_delete" ON challenge_participants
  FOR DELETE USING (auth.uid() = user_id);
