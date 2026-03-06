-- ============================================================
-- VerveForge Migration 00013: 触发器函数 + RPC 函数
-- ============================================================

-- 通用 updated_at 触发器函数
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 为所有需要的表创建 updated_at 触发器
DO $$
DECLARE t TEXT;
BEGIN
  FOR t IN SELECT unnest(ARRAY[
    'profiles', 'workout_logs', 'gyms', 'gym_reviews',
    'buddy_requests', 'conversations', 'posts', 'post_comments', 'challenges'
  ]) LOOP
    EXECUTE format(
      'CREATE TRIGGER trg_%s_updated_at BEFORE UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION update_updated_at()', t, t
    );
  END LOOP;
END; $$;

-- 训练馆评分统计触发器
CREATE OR REPLACE FUNCTION update_gym_rating()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE gyms SET
    avg_rating = (SELECT ROUND(AVG(rating)::numeric, 1) FROM gym_reviews WHERE gym_id = COALESCE(NEW.gym_id, OLD.gym_id) AND deleted_at IS NULL),
    review_count = (SELECT COUNT(*) FROM gym_reviews WHERE gym_id = COALESCE(NEW.gym_id, OLD.gym_id) AND deleted_at IS NULL),
    updated_at = NOW()
  WHERE id = COALESCE(NEW.gym_id, OLD.gym_id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_gym_review_stats
  AFTER INSERT OR UPDATE OR DELETE ON gym_reviews
  FOR EACH ROW EXECUTE FUNCTION update_gym_rating();

-- 动态点赞数触发器
CREATE OR REPLACE FUNCTION update_post_like_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE posts SET like_count = like_count + 1, updated_at = NOW() WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE posts SET like_count = GREATEST(like_count - 1, 0), updated_at = NOW() WHERE id = OLD.post_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_post_like_count
  AFTER INSERT OR DELETE ON post_likes
  FOR EACH ROW EXECUTE FUNCTION update_post_like_count();

-- 动态评论数触发器
CREATE OR REPLACE FUNCTION update_post_comment_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE posts SET comment_count = comment_count + 1, updated_at = NOW() WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE posts SET comment_count = GREATEST(comment_count - 1, 0), updated_at = NOW() WHERE id = OLD.post_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_post_comment_count
  AFTER INSERT OR DELETE ON post_comments
  FOR EACH ROW EXECUTE FUNCTION update_post_comment_count();

-- 挑战赛参与人数触发器
CREATE OR REPLACE FUNCTION update_challenge_participant_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE challenges SET participant_count = participant_count + 1, updated_at = NOW() WHERE id = NEW.challenge_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE challenges SET participant_count = GREATEST(participant_count - 1, 0), updated_at = NOW() WHERE id = OLD.challenge_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_challenge_participant_count
  AFTER INSERT OR DELETE ON challenge_participants
  FOR EACH ROW EXECUTE FUNCTION update_challenge_participant_count();

-- 挑战打卡进度更新触发器
CREATE OR REPLACE FUNCTION update_challenge_progress()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE challenge_participants SET
    progress_value = progress_value + NEW.value,
    check_in_count = check_in_count + 1,
    last_check_in_at = NOW()
  WHERE id = NEW.participant_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_challenge_check_in_progress
  AFTER INSERT ON challenge_check_ins
  FOR EACH ROW EXECUTE FUNCTION update_challenge_progress();

-- 附近训练馆查询 RPC 函数
CREATE OR REPLACE FUNCTION nearby_gyms(
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  radius_km DOUBLE PRECISION DEFAULT 10,
  sport_filter sport_type DEFAULT NULL,
  result_limit INT DEFAULT 50
)
RETURNS TABLE (
  id UUID, name TEXT, address TEXT, sport_types sport_type[],
  latitude DOUBLE PRECISION, longitude DOUBLE PRECISION,
  distance_km DOUBLE PRECISION, avg_rating DECIMAL,
  review_count INT, photos TEXT[], is_verified BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT g.id, g.name, g.address, g.sport_types, g.latitude, g.longitude,
    ROUND((ST_Distance(g.location, ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography) / 1000)::numeric, 2)::double precision AS distance_km,
    g.avg_rating, g.review_count, g.photos, g.is_verified
  FROM gyms g
  WHERE g.deleted_at IS NULL AND g.status = 'approved'
    AND ST_DWithin(g.location, ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography, radius_km * 1000)
    AND (sport_filter IS NULL OR sport_filter = ANY(g.sport_types))
  ORDER BY distance_km ASC
  LIMIT result_limit;
END;
$$ LANGUAGE plpgsql;
