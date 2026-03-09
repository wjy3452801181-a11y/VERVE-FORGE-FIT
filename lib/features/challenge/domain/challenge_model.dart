/// 挑战赛数据模型 — 映射 challenges 表
class ChallengeModel {
  final String id;
  final String creatorId;
  final String title;
  final String description;
  final String sportType;
  final String? coverImage;
  final String goalType; // total_sessions / total_minutes / total_days
  final int goalValue;
  final DateTime startsAt;
  final DateTime endsAt;
  final int maxParticipants;
  final String? city;
  final String status; // draft / active / completed / cancelled
  final int participantCount;
  final Map<String, dynamic> metricsRules;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  // 视图字段（来自 challenge_summary）
  final String? creatorNickname;
  final String? creatorAvatar;
  final bool? isJoined;

  const ChallengeModel({
    required this.id,
    required this.creatorId,
    required this.title,
    this.description = '',
    required this.sportType,
    this.coverImage,
    required this.goalType,
    required this.goalValue,
    required this.startsAt,
    required this.endsAt,
    this.maxParticipants = 100,
    this.city,
    this.status = 'active',
    this.participantCount = 0,
    this.metricsRules = const {},
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.creatorNickname,
    this.creatorAvatar,
    this.isJoined,
  });

  /// 从 Supabase JSON 构造
  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json['id'] as String,
      creatorId: json['creator_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      sportType: json['sport_type'] as String,
      coverImage: json['cover_image'] as String?,
      goalType: json['goal_type'] as String,
      goalValue: json['goal_value'] as int,
      startsAt: DateTime.parse(json['starts_at'] as String),
      endsAt: DateTime.parse(json['ends_at'] as String),
      maxParticipants: json['max_participants'] as int? ?? 100,
      city: json['city'] as String?,
      status: json['status'] as String? ?? 'active',
      participantCount: json['participant_count'] as int? ?? 0,
      metricsRules: (json['metrics_rules'] as Map<String, dynamic>?) ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      creatorNickname: json['creator_nickname'] as String?,
      creatorAvatar: json['creator_avatar'] as String?,
      isJoined: json['is_joined'] as bool?,
    );
  }

  /// 转为 Supabase JSON（创建/更新用，不含时间戳和视图字段）
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator_id': creatorId,
      'title': title,
      'description': description,
      'sport_type': sportType,
      'cover_image': coverImage,
      'goal_type': goalType,
      'goal_value': goalValue,
      'starts_at': startsAt.toIso8601String(),
      'ends_at': endsAt.toIso8601String(),
      'max_participants': maxParticipants,
      'city': city,
      'status': status,
      'metrics_rules': metricsRules,
    };
  }

  /// 复制修改
  ChallengeModel copyWith({
    String? title,
    String? description,
    String? sportType,
    String? coverImage,
    String? goalType,
    int? goalValue,
    DateTime? startsAt,
    DateTime? endsAt,
    int? maxParticipants,
    String? city,
    String? status,
    int? participantCount,
    Map<String, dynamic>? metricsRules,
    bool? isJoined,
  }) {
    return ChallengeModel(
      id: id,
      creatorId: creatorId,
      title: title ?? this.title,
      description: description ?? this.description,
      sportType: sportType ?? this.sportType,
      coverImage: coverImage ?? this.coverImage,
      goalType: goalType ?? this.goalType,
      goalValue: goalValue ?? this.goalValue,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      city: city ?? this.city,
      status: status ?? this.status,
      participantCount: participantCount ?? this.participantCount,
      metricsRules: metricsRules ?? this.metricsRules,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      creatorNickname: creatorNickname,
      creatorAvatar: creatorAvatar,
      isJoined: isJoined ?? this.isJoined,
    );
  }

  /// 是否正在进行
  bool get isActive => status == 'active';

  /// 是否已结束
  bool get isCompleted => status == 'completed';

  /// 是否已满员
  bool get isFull => participantCount >= maxParticipants;

  /// 是否已软删除
  bool get isDeleted => deletedAt != null;

  /// 是否由当前用户创建
  bool isCreatedBy(String userId) => creatorId == userId;

  /// 剩余天数
  int get remainingDays {
    final now = DateTime.now();
    if (now.isAfter(endsAt)) return 0;
    return endsAt.difference(now).inDays;
  }

  /// 总天数
  int get totalDays => endsAt.difference(startsAt).inDays;

  /// 目标类型显示名
  String get goalTypeDisplay {
    switch (goalType) {
      case 'total_sessions':
        return '总次数';
      case 'total_minutes':
        return '总时长(分钟)';
      case 'total_days':
        return '总天数';
      default:
        return goalType;
    }
  }

  /// 状态显示名
  String get statusDisplay {
    switch (status) {
      case 'draft':
        return '草稿';
      case 'active':
        return '进行中';
      case 'completed':
        return '已结束';
      case 'cancelled':
        return '已取消';
      default:
        return status;
    }
  }

  /// 运动类型显示名
  String get sportTypeDisplay {
    const labels = {
      'hyrox': 'HYROX',
      'crossfit': 'CrossFit',
      'yoga': '瑜伽',
      'pilates': '普拉提',
      'running': '跑步',
      'swimming': '游泳',
      'strength': '力量训练',
      'other': '其他',
    };
    return labels[sportType] ?? sportType;
  }
}
