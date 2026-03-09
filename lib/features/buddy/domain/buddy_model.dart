/// 附近伙伴数据模型
/// 由 nearby_buddies RPC 返回，包含距离信息
class BuddyModel {
  final String id;
  final String nickname;
  final String? avatarUrl;
  final String bio;
  final String city;
  final List<String> sportTypes;
  final String? experienceLevel;
  final int? fitnessScore;
  final double? distanceKm;

  const BuddyModel({
    required this.id,
    required this.nickname,
    this.avatarUrl,
    this.bio = '',
    this.city = '',
    this.sportTypes = const [],
    this.experienceLevel,
    this.fitnessScore,
    this.distanceKm,
  });

  /// 从 Supabase RPC JSON 构造
  factory BuddyModel.fromJson(Map<String, dynamic> json) {
    return BuddyModel(
      id: json['id'] as String,
      nickname: json['nickname'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String? ?? '',
      city: json['city'] as String? ?? '',
      sportTypes: (json['sport_types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      experienceLevel: json['experience_level'] as String?,
      fitnessScore: json['fitness_score'] as int?,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }

  /// 距离显示文本
  String get distanceDisplay {
    if (distanceKm == null) return '';
    if (distanceKm! < 1) {
      return '${(distanceKm! * 1000).round()}m';
    }
    return '${distanceKm!.toStringAsFixed(1)}km';
  }

  /// 经验等级显示文本
  String get experienceLevelDisplay {
    switch (experienceLevel) {
      case 'beginner':
        return '入门';
      case 'intermediate':
        return '进阶';
      case 'advanced':
        return '高级';
      case 'elite':
        return '精英';
      default:
        return '';
    }
  }
}
