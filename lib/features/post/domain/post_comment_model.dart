/// 动态评论模型 — 映射 post_comments 表
class PostCommentModel {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final String? parentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // JOIN 扩展字段
  final String? authorNickname;
  final String? authorAvatar;

  const PostCommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.parentId,
    required this.createdAt,
    required this.updatedAt,
    this.authorNickname,
    this.authorAvatar,
  });

  /// 从 Supabase JSON 构造
  factory PostCommentModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;

    return PostCommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      parentId: json['parent_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      authorNickname: profile?['nickname'] as String?,
      authorAvatar: profile?['avatar_url'] as String?,
    );
  }

  /// 转为 Supabase JSON（创建用）
  Map<String, dynamic> toJson() {
    return {
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'parent_id': parentId,
    };
  }

  /// 是否是回复
  bool get isReply => parentId != null;
}
