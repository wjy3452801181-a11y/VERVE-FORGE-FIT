/// 会话模型 — 私信列表中的一条会话
class ConversationModel {
  final String odId;
  final String otherUserId;
  final String otherNickname;
  final String? otherAvatarUrl;
  final String? lastMessageContent;
  final String? lastMessageType;
  final DateTime? lastMessageAt;
  final int unreadCount;

  const ConversationModel({
    required this.odId,
    required this.otherUserId,
    required this.otherNickname,
    this.otherAvatarUrl,
    this.lastMessageContent,
    this.lastMessageType,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  factory ConversationModel.fromJson(
    Map<String, dynamic> json,
    String currentUserId,
  ) {
    final senderId = json['sender_id'] as String;
    final receiverId = json['receiver_id'] as String;
    final isOtherSender = senderId != currentUserId;
    final otherProfile = json['other_profile'] as Map<String, dynamic>? ?? {};

    return ConversationModel(
      odId: json['id'] as String? ?? '',
      otherUserId: isOtherSender ? senderId : receiverId,
      otherNickname: otherProfile['nickname'] as String? ?? '',
      otherAvatarUrl: otherProfile['avatar_url'] as String?,
      lastMessageContent: json['content'] as String?,
      lastMessageType: json['message_type'] as String?,
      lastMessageAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }

  /// 最后消息的预览文本
  String get lastMessagePreview {
    if (lastMessageContent == null || lastMessageContent!.isEmpty) return '';
    if (lastMessageType == 'image') return '[图片]';
    if (lastMessageType == 'workout_invite') return '[训练邀请]';
    if (lastMessageType == 'system') return '[系统消息]';
    return lastMessageContent!;
  }

  /// 最后消息的时间显示
  String get timeDisplay {
    if (lastMessageAt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(lastMessageAt!);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${lastMessageAt!.month}/${lastMessageAt!.day}';
  }
}
