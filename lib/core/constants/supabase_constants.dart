/// Supabase 表名和 Bucket 名常量
class SupabaseConstants {
  SupabaseConstants._();

  // 数据表名
  static const String profiles = 'profiles';
  static const String workoutLogs = 'workout_logs';
  static const String gyms = 'gyms';
  static const String gymReviews = 'gym_reviews';
  static const String userGymFavorites = 'user_gym_favorites';
  static const String gymClaims = 'gym_claims';
  static const String buddyRequests = 'buddy_requests';
  static const String conversations = 'conversations';
  static const String conversationParticipants = 'conversation_participants';
  static const String messages = 'messages';
  static const String challenges = 'challenges';
  static const String challengeParticipants = 'challenge_participants';
  static const String challengeCheckIns = 'challenge_check_ins';
  static const String posts = 'posts';
  static const String postLikes = 'post_likes';
  static const String postComments = 'post_comments';
  static const String userFollows = 'user_follows';
  static const String userBlocks = 'user_blocks';
  static const String reports = 'reports';
  static const String notifications = 'notifications';

  // Storage Bucket 名
  static const String avatarsBucket = 'avatars';
  static const String workoutPhotosBucket = 'workout-photos';
  static const String gymPhotosBucket = 'gym-photos';
  static const String postPhotosBucket = 'post-photos';
  static const String chatMediaBucket = 'chat-media';

  // RPC 函数名
  static const String nearbyGyms = 'nearby_gyms';
  static const String nearbyBuddies = 'nearby_buddies';
}
