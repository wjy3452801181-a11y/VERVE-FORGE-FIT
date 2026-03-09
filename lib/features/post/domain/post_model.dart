/// 用户动态模型 — 映射 posts 表
class PostModel {
  final String id;
  final String userId;
  final String content;
  final List<String> photos;
  final String? workoutLogId;
  final String? gymId;
  final String? challengeId;
  final String? city;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  // JOIN 扩展字段（来自 profiles）
  final String? authorNickname;
  final String? authorAvatar;

  // 当前用户是否已点赞（查询时额外字段）
  final bool? isLiked;

  const PostModel({
    required this.id,
    required this.userId,
    this.content = '',
    this.photos = const [],
    this.workoutLogId,
    this.gymId,
    this.challengeId,
    this.city,
    this.likeCount = 0,
    this.commentCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.authorNickname,
    this.authorAvatar,
    this.isLiked,
  });

  /// 从 Supabase JSON 构造（支持嵌套 profiles JOIN）
  factory PostModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;

    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String? ?? '',
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      workoutLogId: json['workout_log_id'] as String?,
      gymId: json['gym_id'] as String?,
      challengeId: json['challenge_id'] as String?,
      city: json['city'] as String?,
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      authorNickname: profile?['nickname'] as String?,
      authorAvatar: profile?['avatar_url'] as String?,
      isLiked: json['is_liked'] as bool?,
    );
  }

  /// 转为 Supabase JSON（创建用，不含时间戳和 JOIN 字段）
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'content': content,
      'photos': photos,
      'workout_log_id': workoutLogId,
      'gym_id': gymId,
      'challenge_id': challengeId,
      'city': city,
    };
  }

  /// 复制修改
  PostModel copyWith({
    String? content,
    List<String>? photos,
    String? city,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
  }) {
    return PostModel(
      id: id,
      userId: userId,
      content: content ?? this.content,
      photos: photos ?? this.photos,
      workoutLogId: workoutLogId,
      gymId: gymId,
      challengeId: challengeId,
      city: city ?? this.city,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      authorNickname: authorNickname,
      authorAvatar: authorAvatar,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  /// 是否有照片
  bool get hasPhotos => photos.isNotEmpty;

  /// 是否关联了训练日志
  bool get hasWorkoutLog => workoutLogId != null;

  /// 是否关联了训练馆
  bool get hasGym => gymId != null;

  /// 是否关联了挑战赛
  bool get hasChallenge => challengeId != null;

  /// 发布时间显示（如 "3分钟前"、"2小时前"、"昨天"）
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${createdAt.month}-${createdAt.day.toString().padLeft(2, '0')}';
  }
}
