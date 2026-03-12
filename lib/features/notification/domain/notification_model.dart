/// 通知类型枚举
enum NotificationType {
  buddyRequest,
  buddyAccepted,
  newMessage,
  challengeInvite,
  challengeReminder,
  postLike,
  postComment,
  system;

  static NotificationType fromString(String value) {
    switch (value) {
      case 'buddy_request':
        return buddyRequest;
      case 'buddy_accepted':
        return buddyAccepted;
      case 'new_message':
        return newMessage;
      case 'challenge_invite':
        return challengeInvite;
      case 'challenge_reminder':
        return challengeReminder;
      case 'post_like':
        return postLike;
      case 'post_comment':
        return postComment;
      default:
        return system;
    }
  }
}

/// 通知数据模型
class NotificationModel {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final String? refUserId;
  final String? refPostId;
  final String? refChallengeId;
  final String? refConversationId;
  final String? refBuddyRequestId;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  // 关联用户信息（来自 JOIN）
  final String? refUserNickname;
  final String? refUserAvatarUrl;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.refUserId,
    this.refPostId,
    this.refChallengeId,
    this.refConversationId,
    this.refBuddyRequestId,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    this.refUserNickname,
    this.refUserAvatarUrl,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final refProfile = json['ref_user'] as Map<String, dynamic>?;
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: NotificationType.fromString(json['type'] as String),
      title: json['title'] as String,
      body: (json['body'] as String?) ?? '',
      refUserId: json['ref_user_id'] as String?,
      refPostId: json['ref_post_id'] as String?,
      refChallengeId: json['ref_challenge_id'] as String?,
      refConversationId: json['ref_conversation_id'] as String?,
      refBuddyRequestId: json['ref_buddy_request_id'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      refUserNickname: refProfile?['nickname'] as String?,
      refUserAvatarUrl: refProfile?['avatar_url'] as String?,
    );
  }

  NotificationModel copyWith({bool? isRead, DateTime? readAt}) {
    return NotificationModel(
      id: id,
      userId: userId,
      type: type,
      title: title,
      body: body,
      refUserId: refUserId,
      refPostId: refPostId,
      refChallengeId: refChallengeId,
      refConversationId: refConversationId,
      refBuddyRequestId: refBuddyRequestId,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
      refUserNickname: refUserNickname,
      refUserAvatarUrl: refUserAvatarUrl,
    );
  }
}
