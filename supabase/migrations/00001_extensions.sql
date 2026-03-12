-- ============================================================
-- VerveForge Migration 00001: 启用 PostgreSQL 扩展
--
-- 注意：postgis 和 pg_trgm 安装在 public schema。
-- Supabase Linter 会提示将扩展移到独立 schema，但 PostGIS
-- 不支持 SET SCHEMA，且 geography/geometry 类型和函数被多处引用。
-- 这是 Supabase 本地和托管环境的默认行为，安全风险较低。
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
