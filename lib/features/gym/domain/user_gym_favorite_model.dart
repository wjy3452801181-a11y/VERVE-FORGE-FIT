/// 用户收藏训练馆模型 — 映射 user_gym_favorites 表
class UserGymFavoriteModel {
  final String id;
  final String userId;
  final String gymId;
  final DateTime createdAt;

  // JOIN 扩展字段（列表查询时附带训练馆信息）
  final String? gymName;
  final String? gymCity;
  final String? gymAddress;
  final List<String> gymPhotoUrls;
  final List<String> gymSportTypes;
  final double? gymRating;
  final int? gymReviewCount;

  const UserGymFavoriteModel({
    required this.id,
    required this.userId,
    required this.gymId,
    required this.createdAt,
    this.gymName,
    this.gymCity,
    this.gymAddress,
    this.gymPhotoUrls = const [],
    this.gymSportTypes = const [],
    this.gymRating,
    this.gymReviewCount,
  });

  /// 从 Supabase JSON 构造
  /// 支持两种格式：
  /// 1. 纯 user_gym_favorites 记录
  /// 2. 带 gyms(...) 嵌套 JOIN 的记录
  factory UserGymFavoriteModel.fromJson(Map<String, dynamic> json) {
    // 嵌套 JOIN 的训练馆数据
    final gym = json['gyms'] as Map<String, dynamic>?;

    return UserGymFavoriteModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      gymId: json['gym_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      gymName: gym?['name'] as String?,
      gymCity: gym?['city'] as String?,
      gymAddress: gym?['address'] as String?,
      gymPhotoUrls: (gym?['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      gymSportTypes: (gym?['sport_types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      gymRating: (gym?['avg_rating'] as num?)?.toDouble(),
      gymReviewCount: gym?['review_count'] as int?,
    );
  }

  /// 转为 Supabase JSON（插入用，仅需 user_id + gym_id）
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'gym_id': gymId,
    };
  }

  /// 是否有训练馆详情（JOIN 查询时才有）
  bool get hasGymDetail => gymName != null;
}
