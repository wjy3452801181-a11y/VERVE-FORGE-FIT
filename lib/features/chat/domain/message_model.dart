/// 消息模型
class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final String messageType; // text, image, workout_invite, system
  final bool isRead;
  final DateTime createdAt;

  // 发送者信息（可选，用于显示头像）
  final String? senderNickname;
  final String? senderAvatarUrl;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.messageType = 'text',
    this.isRead = false,
    required this.createdAt,
    this.senderNickname,
    this.senderAvatarUrl,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'] as Map<String, dynamic>?;

    return MessageModel(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      content: json['content'] as String? ?? '',
      messageType: json['message_type'] as String? ?? 'text',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      senderNickname: sender?['nickname'] as String?,
      senderAvatarUrl: sender?['avatar_url'] as String?,
    );
  }

  /// 是否是当前用户发送的
  bool isMine(String currentUserId) => senderId == currentUserId;
}
