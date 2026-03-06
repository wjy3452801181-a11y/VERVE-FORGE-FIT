/// 用户档案数据模型
class ProfileModel {
  final String id;
  final String nickname;
  final String? avatarUrl;
  final String bio;
  final String? gender;
  final int? birthYear;
  final String city;
  final String country;
  final List<String> sportTypes;
  final String? experienceLevel;
  final bool healthSyncEnabled;
  final bool isDiscoverable;
  final bool showWorkoutStats;
  final int? fitnessScore;
  final DateTime? privacyAgreedAt;
  final DateTime? dataExportRequestedAt;
  final DateTime? accountDeletionRequestedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileModel({
    required this.id,
    required this.nickname,
    this.avatarUrl,
    this.bio = '',
    this.gender,
    this.birthYear,
    this.city = '',
    this.country = 'CN',
    this.sportTypes = const [],
    this.experienceLevel,
    this.healthSyncEnabled = false,
    this.isDiscoverable = true,
    this.showWorkoutStats = true,
    this.fitnessScore,
    this.privacyAgreedAt,
    this.dataExportRequestedAt,
    this.accountDeletionRequestedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从 Supabase JSON 构造
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      nickname: json['nickname'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String? ?? '',
      gender: json['gender'] as String?,
      birthYear: json['birth_year'] as int?,
      city: json['city'] as String? ?? '',
      country: json['country'] as String? ?? 'CN',
      sportTypes: (json['sport_types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      experienceLevel: json['experience_level'] as String?,
      healthSyncEnabled: json['health_sync_enabled'] as bool? ?? false,
      isDiscoverable: json['is_discoverable'] as bool? ?? true,
      showWorkoutStats: json['show_workout_stats'] as bool? ?? true,
      fitnessScore: json['fitness_score'] as int?,
      privacyAgreedAt: json['privacy_agreed_at'] != null
          ? DateTime.parse(json['privacy_agreed_at'] as String)
          : null,
      dataExportRequestedAt: json['data_export_requested_at'] != null
          ? DateTime.parse(json['data_export_requested_at'] as String)
          : null,
      accountDeletionRequestedAt:
          json['account_deletion_requested_at'] != null
              ? DateTime.parse(
                  json['account_deletion_requested_at'] as String)
              : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// 转为 Supabase JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'avatar_url': avatarUrl,
      'bio': bio,
      'gender': gender,
      'birth_year': birthYear,
      'city': city,
      'country': country,
      'sport_types': sportTypes,
      'experience_level': experienceLevel,
      'health_sync_enabled': healthSyncEnabled,
      'is_discoverable': isDiscoverable,
      'show_workout_stats': showWorkoutStats,
    };
  }

  /// 复制修改
  ProfileModel copyWith({
    String? nickname,
    String? avatarUrl,
    String? bio,
    String? gender,
    int? birthYear,
    String? city,
    String? country,
    List<String>? sportTypes,
    String? experienceLevel,
    bool? healthSyncEnabled,
    bool? isDiscoverable,
    bool? showWorkoutStats,
    DateTime? privacyAgreedAt,
  }) {
    return ProfileModel(
      id: id,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      gender: gender ?? this.gender,
      birthYear: birthYear ?? this.birthYear,
      city: city ?? this.city,
      country: country ?? this.country,
      sportTypes: sportTypes ?? this.sportTypes,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      healthSyncEnabled: healthSyncEnabled ?? this.healthSyncEnabled,
      isDiscoverable: isDiscoverable ?? this.isDiscoverable,
      showWorkoutStats: showWorkoutStats ?? this.showWorkoutStats,
      privacyAgreedAt: privacyAgreedAt ?? this.privacyAgreedAt,
      dataExportRequestedAt: dataExportRequestedAt,
      accountDeletionRequestedAt: accountDeletionRequestedAt,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// 是否已完成引导流（有昵称 + 有城市 + 有运动偏好）
  bool get isOnboardingComplete =>
      nickname.isNotEmpty && city.isNotEmpty && sportTypes.isNotEmpty;

  /// 显示用的经验等级文字
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
        return '未设置';
    }
  }
}
