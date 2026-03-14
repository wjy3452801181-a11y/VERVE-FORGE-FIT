/// 挑战赛参与者数据模型 — 映射 challenge_participants 表
class ChallengeParticipantModel {
  final String id;
  final String challengeId;
  final String usedId;
  final int progressValue;
  final int checkInCount;
  final int? rank;
  final DateTime joinedAt;
  final DateTime? lastCheckInAt;

  // 视图字段（来自 challenge_leaderboard）
  final String? nickname;
  final String? avatarUrl;
  final String? goalType;
  final int? goalValue;
  final String? sportType;
  final double? progressPct;

  const ChallengeParticipantModel({
    required this.id,
    required this.challengeId,
    required this.usedId,
    this.progressValue = 0,
    this.checkInCount = 0,
    this.rank,
    required this.joinedAt,
    this.lastCheckInAt,
    this.nickname,
    this.avatarUrl,
    this.goalType,
    this.goalValue,
    this.sportType,
    this.progressPct,
  });

  /// 从 Supabase JSON 构造（兼容嵌套 profiles JOIN 和平面视图两种格式）
  factory ChallengeParticipantModel.fromJson(Map<String, dynamic> json) {
    // 支持嵌套 profiles JOIN
    final profile = json['profiles'] as Map<String, dynamic>?;

    return ChallengeParticipantModel(
      id: (json['participant_id'] ?? json['id']) as String,
      challengeId: json['challenge_id'] as String,
      usedId: json['user_id'] as String,
      progressValue: json['progress_value'] as int? ?? 0,
      checkInCount: json['check_in_count'] as int? ?? 0,
      rank: json['rank'] as int?,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      lastCheckInAt: json['last_check_in_at'] != null
          ? DateTime.parse(json['last_check_in_at'] as String)
          : null,
      nickname: profile?['nickname'] as String? ??
          json['nickname'] as String?,
      avatarUrl: profile?['avatar_url'] as String? ??
          json['avatar_url'] as String?,
      goalType: json['goal_type'] as String?,
      goalValue: json['goal_value'] as int?,
      sportType: json['sport_type'] as String?,
      progressPct: (json['progress_pct'] as num?)?.toDouble(),
    );
  }

  /// 转为 Supabase JSON（加入挑战用）
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'challenge_id': challengeId,
      'user_id': usedId,
    };
  }

  /// 复制修改
  ChallengeParticipantModel copyWith({
    int? progressValue,
    int? checkInCount,
    int? rank,
    DateTime? lastCheckInAt,
    double? progressPct,
  }) {
    return ChallengeParticipantModel(
      id: id,
      challengeId: challengeId,
      usedId: usedId,
      progressValue: progressValue ?? this.progressValue,
      checkInCount: checkInCount ?? this.checkInCount,
      rank: rank ?? this.rank,
      joinedAt: joinedAt,
      lastCheckInAt: lastCheckInAt ?? this.lastCheckInAt,
      nickname: nickname,
      avatarUrl: avatarUrl,
      goalType: goalType,
      goalValue: goalValue,
      sportType: sportType,
      progressPct: progressPct ?? this.progressPct,
    );
  }

  /// 进度显示（如 "12/30 次" 或 "45%"）
  String get progressDisplay {
    if (goalValue != null && goalValue! > 0) {
      return '$progressValue/$goalValue';
    }
    return '$progressValue';
  }

  /// 进度百分比（0.0 ~ 1.0，用于进度条）
  double get progressRatio {
    if (progressPct != null) return (progressPct! / 100).clamp(0.0, 1.0);
    if (goalValue != null && goalValue! > 0) {
      return (progressValue / goalValue!).clamp(0.0, 1.0);
    }
    return 0.0;
  }

  /// 排名显示（如 "#1"、"#12"）
  String get rankDisplay => rank != null ? '#$rank' : '--';

  /// 是否是当前用户
  bool isCurrentUser(String userId) => usedId == userId;
}
