/// 训练馆数据模型 — 映射 gyms 表
class GymModel {
  final String id;
  final String name;
  final String? description;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? website;
  final String? openingHours;
  final List<String> sportTypes;
  final List<String> photoUrls;
  final double rating;
  final int reviewCount;
  final String status; // 'pending', 'verified', 'rejected'
  final String submittedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  // 由 RPC 返回的距离（单位：km）
  final double? distanceKm;

  const GymModel({
    required this.id,
    required this.name,
    this.description,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.website,
    this.openingHours,
    this.sportTypes = const [],
    this.photoUrls = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.status = 'pending',
    required this.submittedBy,
    required this.createdAt,
    required this.updatedAt,
    this.distanceKm,
  });

  /// 从 Supabase JSON 构造
  factory GymModel.fromJson(Map<String, dynamic> json) {
    return GymModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      address: json['address'] as String,
      city: json['city'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      openingHours: json['opening_hours'] as String?,
      sportTypes: (json['sport_types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      photoUrls: (json['photo_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      status: json['status'] as String? ?? 'pending',
      submittedBy: json['submitted_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }

  /// 转为 Supabase JSON（不含时间戳和计算字段）
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'website': website,
      'opening_hours': openingHours,
      'sport_types': sportTypes,
      'photo_urls': photoUrls,
      'submitted_by': submittedBy,
    };
  }

  /// 复制修改
  GymModel copyWith({
    String? name,
    String? description,
    String? address,
    String? city,
    double? latitude,
    double? longitude,
    String? phone,
    String? website,
    String? openingHours,
    List<String>? sportTypes,
    List<String>? photoUrls,
    double? rating,
    int? reviewCount,
    String? status,
    double? distanceKm,
  }) {
    return GymModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      openingHours: openingHours ?? this.openingHours,
      sportTypes: sportTypes ?? this.sportTypes,
      photoUrls: photoUrls ?? this.photoUrls,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      status: status ?? this.status,
      submittedBy: submittedBy,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }

  /// 评分显示（如 "4.5"）
  String get ratingDisplay {
    if (reviewCount == 0) return '-';
    return rating.toStringAsFixed(1);
  }

  /// 距离显示（如 "1.2km" 或 "800m"）
  String get distanceDisplay {
    if (distanceKm == null) return '';
    if (distanceKm! < 1.0) {
      return '${(distanceKm! * 1000).round()}m';
    }
    return '${distanceKm!.toStringAsFixed(1)}km';
  }

  /// 状态标签
  String get statusLabel {
    switch (status) {
      case 'verified':
        return '已认证';
      case 'rejected':
        return '已拒绝';
      default:
        return '待审核';
    }
  }

  /// 是否已认证
  bool get isVerified => status == 'verified';
}
