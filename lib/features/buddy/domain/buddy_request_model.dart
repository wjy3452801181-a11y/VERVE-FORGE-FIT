/// 好友请求数据模型
/// 用于请求列表展示（包含对方用户的基本信息）
class BuddyRequestModel {
  final String id;
  final String requesterId;
  final String receiverId;
  final String status; // pending, accepted, rejected, cancelled
  final String message;
  final DateTime createdAt;

  // 对方的用户信息（joined query）
  final String otherUserId;
  final String otherNickname;
  final String? otherAvatarUrl;
  final String otherBio;
  final List<String> otherSportTypes;

  const BuddyRequestModel({
    required this.id,
    required this.requesterId,
    required this.receiverId,
    required this.status,
    this.message = '',
    required this.createdAt,
    required this.otherUserId,
    required this.otherNickname,
    this.otherAvatarUrl,
    this.otherBio = '',
    this.otherSportTypes = const [],
  });

  /// 从收到的请求 JSON 构造（other = requester）
  factory BuddyRequestModel.fromReceivedJson(Map<String, dynamic> json) {
    final profile = json['requester'] as Map<String, dynamic>? ?? {};
    return BuddyRequestModel(
      id: json['id'] as String,
      requesterId: json['requester_id'] as String,
      receiverId: json['receiver_id'] as String,
      status: json['status'] as String,
      message: json['message'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      otherUserId: json['requester_id'] as String,
      otherNickname: profile['nickname'] as String? ?? '',
      otherAvatarUrl: profile['avatar_url'] as String?,
      otherBio: profile['bio'] as String? ?? '',
      otherSportTypes: (profile['sport_types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// 从发出的请求 JSON 构造（other = receiver）
  factory BuddyRequestModel.fromSentJson(Map<String, dynamic> json) {
    final profile = json['receiver'] as Map<String, dynamic>? ?? {};
    return BuddyRequestModel(
      id: json['id'] as String,
      requesterId: json['requester_id'] as String,
      receiverId: json['receiver_id'] as String,
      status: json['status'] as String,
      message: json['message'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      otherUserId: json['receiver_id'] as String,
      otherNickname: profile['nickname'] as String? ?? '',
      otherAvatarUrl: profile['avatar_url'] as String?,
      otherBio: profile['bio'] as String? ?? '',
      otherSportTypes: (profile['sport_types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// 从好友列表 JSON 构造（accepted 状态，自动判断对方是谁）
  factory BuddyRequestModel.fromBuddyJson(
    Map<String, dynamic> json,
    String currentUserId,
  ) {
    final isRequester = json['requester_id'] == currentUserId;
    final profileKey = isRequester ? 'receiver' : 'requester';
    final profile = json[profileKey] as Map<String, dynamic>? ?? {};
    final otherUserId = isRequester
        ? json['receiver_id'] as String
        : json['requester_id'] as String;

    return BuddyRequestModel(
      id: json['id'] as String,
      requesterId: json['requester_id'] as String,
      receiverId: json['receiver_id'] as String,
      status: json['status'] as String,
      message: json['message'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      otherUserId: otherUserId,
      otherNickname: profile['nickname'] as String? ?? '',
      otherAvatarUrl: profile['avatar_url'] as String?,
      otherBio: profile['bio'] as String? ?? '',
      otherSportTypes: (profile['sport_types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
}
