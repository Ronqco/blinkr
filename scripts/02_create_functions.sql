-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to relevant tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_posts_updated_at BEFORE UPDATE ON posts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_comments_updated_at BEFORE UPDATE ON comments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_conversations_updated_at BEFORE UPDATE ON conversations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_xp_updated_at BEFORE UPDATE ON user_xp
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to get nearby users
CREATE OR REPLACE FUNCTION get_nearby_users(
  user_location GEOGRAPHY,
  radius_km FLOAT DEFAULT 50.0,
  limit_count INTEGER DEFAULT 50
)
RETURNS TABLE (
  id UUID,
  username TEXT,
  display_name TEXT,
  avatar_url TEXT,
  distance_km FLOAT,
  common_interests INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    u.id,
    u.username,
    u.display_name,
    u.avatar_url,
    ST_Distance(u.location, user_location) / 1000 AS distance_km,
    0 AS common_interests -- Will be calculated in application layer
  FROM users u
  WHERE 
    u.location IS NOT NULL
    AND u.show_location = true
    AND u.is_active = true
    AND ST_DWithin(u.location, user_location, radius_km * 1000)
  ORDER BY u.location <-> user_location
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate XP level
CREATE OR REPLACE FUNCTION calculate_level(xp INTEGER)
RETURNS INTEGER AS $$
BEGIN
  -- Level formula: level = floor(sqrt(xp / 100))
  RETURN FLOOR(SQRT(xp::FLOAT / 100.0))::INTEGER + 1;
END;
$$ LANGUAGE plpgsql;

-- Function to add XP and update level
CREATE OR REPLACE FUNCTION add_user_xp(
  p_user_id UUID,
  p_category_id TEXT,
  p_xp_amount INTEGER
)
RETURNS TABLE (
  new_xp INTEGER,
  new_level INTEGER,
  level_up BOOLEAN
) AS $$
DECLARE
  v_old_level INTEGER;
  v_new_level INTEGER;
  v_new_xp INTEGER;
BEGIN
  -- Insert or update XP
  INSERT INTO user_xp (user_id, category_id, xp, level)
  VALUES (p_user_id, p_category_id, p_xp_amount, calculate_level(p_xp_amount))
  ON CONFLICT (user_id, category_id)
  DO UPDATE SET 
    xp = user_xp.xp + p_xp_amount,
    level = calculate_level(user_xp.xp + p_xp_amount)
  RETURNING xp, level INTO v_new_xp, v_new_level;
  
  -- Check if leveled up
  SELECT level INTO v_old_level
  FROM user_xp
  WHERE user_id = p_user_id AND category_id = p_category_id;
  
  RETURN QUERY SELECT 
    v_new_xp,
    v_new_level,
    (v_new_level > COALESCE(v_old_level, 1)) AS level_up;
END;
$$ LANGUAGE plpgsql;

-- Function to check message limit
CREATE OR REPLACE FUNCTION check_message_limit(
  p_user_id UUID,
  p_is_premium BOOLEAN DEFAULT false
)
RETURNS TABLE (
  can_send BOOLEAN,
  messages_remaining INTEGER
) AS $$
DECLARE
  v_messages_sent INTEGER;
  v_messages_unlocked INTEGER;
  v_total_allowed INTEGER;
BEGIN
  -- Premium users have unlimited messages
  IF p_is_premium THEN
    RETURN QUERY SELECT true, 999999;
    RETURN;
  END IF;
  
  -- Get today's message count
  SELECT 
    COALESCE(messages_sent, 0),
    COALESCE(messages_unlocked_by_ads, 0)
  INTO v_messages_sent, v_messages_unlocked
  FROM message_limits
  WHERE user_id = p_user_id AND date = CURRENT_DATE;
  
  -- If no record, create one
  IF NOT FOUND THEN
    INSERT INTO message_limits (user_id, date, messages_sent, messages_unlocked_by_ads)
    VALUES (p_user_id, CURRENT_DATE, 0, 0);
    v_messages_sent := 0;
    v_messages_unlocked := 0;
  END IF;
  
  -- Calculate total allowed (50 free + unlocked by ads)
  v_total_allowed := 50 + v_messages_unlocked;
  
  RETURN QUERY SELECT 
    (v_messages_sent < v_total_allowed),
    (v_total_allowed - v_messages_sent);
END;
$$ LANGUAGE plpgsql;

-- Function to increment message count
CREATE OR REPLACE FUNCTION increment_message_count(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
  INSERT INTO message_limits (user_id, date, messages_sent)
  VALUES (p_user_id, CURRENT_DATE, 1)
  ON CONFLICT (user_id, date)
  DO UPDATE SET messages_sent = message_limits.messages_sent + 1;
END;
$$ LANGUAGE plpgsql;

-- Function to unlock messages by watching ad
CREATE OR REPLACE FUNCTION unlock_messages_by_ad(
  p_user_id UUID,
  p_messages_to_unlock INTEGER DEFAULT 10
)
RETURNS INTEGER AS $$
DECLARE
  v_new_total INTEGER;
BEGIN
  INSERT INTO message_limits (user_id, date, messages_unlocked_by_ads)
  VALUES (p_user_id, CURRENT_DATE, p_messages_to_unlock)
  ON CONFLICT (user_id, date)
  DO UPDATE SET messages_unlocked_by_ads = message_limits.messages_unlocked_by_ads + p_messages_to_unlock
  RETURNING messages_unlocked_by_ads INTO v_new_total;
  
  RETURN v_new_total;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update post likes count
CREATE OR REPLACE FUNCTION update_post_likes_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE posts SET likes_count = likes_count + 1 WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE posts SET likes_count = likes_count - 1 WHERE id = OLD.post_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_post_likes_trigger
AFTER INSERT OR DELETE ON likes
FOR EACH ROW
WHEN (NEW.post_id IS NOT NULL OR OLD.post_id IS NOT NULL)
EXECUTE FUNCTION update_post_likes_count();

-- Trigger to update post comments count
CREATE OR REPLACE FUNCTION update_post_comments_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE posts SET comments_count = comments_count + 1 WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE posts SET comments_count = comments_count - 1 WHERE id = OLD.post_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_post_comments_trigger
AFTER INSERT OR DELETE ON comments
FOR EACH ROW
EXECUTE FUNCTION update_post_comments_count();

-- Trigger to update conversation last_message_at
CREATE OR REPLACE FUNCTION update_conversation_last_message()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE conversations 
  SET last_message_at = NEW.created_at 
  WHERE id = NEW.conversation_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_conversation_last_message_trigger
AFTER INSERT ON messages
FOR EACH ROW
EXECUTE FUNCTION update_conversation_last_message();
