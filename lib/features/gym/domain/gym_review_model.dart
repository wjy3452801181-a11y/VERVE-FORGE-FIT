/// 训练馆评价数据模型 — 映射 gym_reviews 表
class GymReviewModel {
  final String id;
  final String gymId;
  final String userId;
  final int rating; // 1-5
  final String? content;
  final List<String> photoUrls;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GymReviewModel({
    required this.id,
    required this.gymId,
    required this.userId,
    required this.rating,
    this.content,
    this.photoUrls = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从 Supabase JSON 构造
  factory GymReviewModel.fromJson(Map<String, dynamic> json) {
    return GymReviewModel(
      id: json['id'] as String,
      gymId: json['gym_id'] as String,
      userId: json['user_id'] as String,
      rating: json['rating'] as int,
      content: json['content'] as String?,
      photoUrls: (json['photo_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// 转为 Supabase JSON（不含时间戳）
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gym_id': gymId,
      'user_id': userId,
      'rating': rating,
      'content': content,
      'photo_urls': photoUrls,
    };
  }

  /// 复制修改
  GymReviewModel copyWith({
    int? rating,
    String? content,
    List<String>? photoUrls,
  }) {
    return GymReviewModel(
      id: id,
      gymId: gymId,
      userId: userId,
      rating: rating ?? this.rating,
      content: content ?? this.content,
      photoUrls: photoUrls ?? this.photoUrls,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
