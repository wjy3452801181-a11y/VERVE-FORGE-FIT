-- =============================================================
-- 00015: workout_logs 增加 metrics JSONB 和 media_urls TEXT[]
-- =============================================================
-- metrics JSONB 结构约定：
--   hyrox:    { "stations": [{"name": "SkiErg", "time_sec": 120}, ...], "total_time_sec": 4200 }
--   crossfit: { "wod_name": "Fran", "wod_type": "for_time|amrap|emom", "score": "3:45", "movements": ["Thrusters", "Pull-ups"] }
--   yoga/pilates: { "class_name": "Flow Yoga", "focus_areas": ["flexibility", "core"], "difficulty": "intermediate" }
--   running:  { "distance_km": 10.0, "pace_min_per_km": 5.5, "elevation_m": 120 }
--
-- media_urls TEXT[] 统一存放照片和视频的公开 URL（扩展原 photo_urls 能力）

ALTER TABLE workout_logs
  ADD COLUMN IF NOT EXISTS metrics JSONB DEFAULT '{}';

ALTER TABLE workout_logs
  ADD COLUMN IF NOT EXISTS media_urls TEXT[] DEFAULT '{}';

-- GIN 索引加速 metrics JSONB 查询
CREATE INDEX IF NOT EXISTS idx_workout_logs_metrics
  ON workout_logs USING GIN (metrics);
