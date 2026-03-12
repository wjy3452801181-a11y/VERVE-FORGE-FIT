-- ============================================================
-- Migration 00024: 修复函数搜索路径可变告警
--
-- 为所有自定义函数设置 search_path = public，防止 schema 劫持。
--
-- 注意：postgis / pg_trgm 扩展保留在 public schema，因为：
--   - PostGIS 不支持 ALTER EXTENSION SET SCHEMA
--   - geography/geometry 类型和 ST_* 函数被多处迁移引用
--   - 这是 Supabase 本地和托管环境的默认行为
--   该 Linter 告警可安全忽略。
-- ============================================================

ALTER FUNCTION public.trigger_ai_auto_reply()
  SET search_path = public;

ALTER FUNCTION public.update_challenge_participant_count()
  SET search_path = public;

ALTER FUNCTION public.update_updated_at()
  SET search_path = public;

ALTER FUNCTION public.update_post_like_count()
  SET search_path = public;

ALTER FUNCTION public.update_ai_avatars_updated_at()
  SET search_path = public;

ALTER FUNCTION public.update_ai_reply_keywords_updated_at()
  SET search_path = public;

ALTER FUNCTION public.nearby_gyms(double precision, double precision, double precision, sport_type, integer)
  SET search_path = public;

ALTER FUNCTION public.update_gym_rating()
  SET search_path = public;

ALTER FUNCTION public.handle_gym_claim_approved()
  SET search_path = public;

ALTER FUNCTION public.update_post_comment_count()
  SET search_path = public;

ALTER FUNCTION public.update_challenge_progress()
  SET search_path = public;
