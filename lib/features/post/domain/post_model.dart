/// 用户动态模型 — 映射 posts 表
class PostModel {
  final String id;
  final String userId;
  final String content;
  final List<String> imageUrls;
  final String? workoutId;
  final bool isPublic;
  final int likesCount;
  final int commentsCount;
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
    this.imageUrls = const [],
    this.workoutId,
    this.isPublic = true,
    this.likesCount = 0,
    this.commentsCount = 0,
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
      imageUrls: (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      workoutId: json['workout_id'] as String?,
      isPublic: json['is_public'] as bool? ?? true,
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
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
      'image_urls': imageUrls,
      'workout_id': workoutId,
    };
  }

  /// 复制修改
  PostModel copyWith({
    String? content,
    List<String>? imageUrls,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
  }) {
    return PostModel(
      id: id,
      userId: userId,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      workoutId: workoutId,
      isPublic: isPublic,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      authorNickname: authorNickname,
      authorAvatar: authorAvatar,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  /// 是否有照片
  bool get hasPhotos => imageUrls.isNotEmpty;

  /// 是否关联了训练日志
  bool get hasWorkoutLog => workoutId != null;

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
