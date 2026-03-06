-- ============================================================
-- VerveForge Migration 00002: 创建枚举类型
-- ============================================================

CREATE TYPE sport_type AS ENUM (
  'hyrox', 'crossfit', 'yoga', 'pilates',
  'running', 'swimming', 'strength', 'other'
);

CREATE TYPE buddy_request_status AS ENUM (
  'pending', 'accepted', 'rejected', 'cancelled'
);

CREATE TYPE challenge_status AS ENUM (
  'draft', 'active', 'completed', 'cancelled'
);

CREATE TYPE gym_status AS ENUM (
  'pending', 'approved', 'rejected'
);

CREATE TYPE message_type AS ENUM (
  'text', 'image', 'workout_invite', 'system'
);

CREATE TYPE report_type AS ENUM (
  'spam', 'harassment', 'inappropriate_content', 'fake_account', 'other'
);

CREATE TYPE notification_type AS ENUM (
  'buddy_request', 'buddy_accepted', 'new_message',
  'challenge_invite', 'challenge_reminder',
  'post_like', 'post_comment', 'system'
);
