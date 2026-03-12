-- ============================================================
-- Migration 00023: 修复 Supabase Linter 安全告警
--
-- 修复 3 个视图的 SECURITY DEFINER 问题：
--   将视图改为 security_invoker = true（以查询者权限执行 RLS）
--
-- 注意：spatial_ref_sys 由 PostGIS 扩展创建，属于 supabase_admin，
--       无法在普通迁移中修改。该告警为误报（PostGIS 系统表），
--       在 Supabase 托管环境中会自动处理。
-- ============================================================

-- ------------------------------------------------------------
-- 1. ai_avatar_public_view → security_invoker
-- ------------------------------------------------------------
ALTER VIEW ai_avatar_public_view SET (security_invoker = true);

-- ------------------------------------------------------------
-- 2. challenge_leaderboard → security_invoker
-- ------------------------------------------------------------
ALTER VIEW challenge_leaderboard SET (security_invoker = true);

-- ------------------------------------------------------------
-- 3. challenge_summary → security_invoker
-- ------------------------------------------------------------
ALTER VIEW challenge_summary SET (security_invoker = true);
