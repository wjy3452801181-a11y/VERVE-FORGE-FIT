/// 训练日志数据模型 — 映射 workout_logs 表
class WorkoutModel {
  final String id;
  final String userId;
  final String sportType;
  final int durationMinutes;
  final int intensity;
  final DateTime workoutDate;
  final String? notes;
  final List<String> photoUrls;
  final bool isPublic;
  final bool isDraft;
  final int? caloriesBurned;
  final int? avgHeartRate;
  final int? steps;
  final String? healthKitId;
  final Map<String, dynamic> metrics;
  final List<String> mediaUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const WorkoutModel({
    required this.id,
    required this.userId,
    required this.sportType,
    required this.durationMinutes,
    required this.intensity,
    required this.workoutDate,
    this.notes,
    this.photoUrls = const [],
    this.isPublic = false,
    this.isDraft = false,
    this.caloriesBurned,
    this.avgHeartRate,
    this.steps,
    this.healthKitId,
    this.metrics = const {},
    this.mediaUrls = const [],
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// 从 Supabase JSON 构造
  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      sportType: json['sport_type'] as String,
      durationMinutes: json['duration_minutes'] as int,
      intensity: json['intensity'] as int,
      workoutDate: DateTime.parse(json['workout_date'] as String),
      notes: json['notes'] as String?,
      photoUrls: (json['photo_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isPublic: json['is_public'] as bool? ?? false,
      isDraft: json['is_draft'] as bool? ?? false,
      caloriesBurned: json['calories_burned'] as int?,
      avgHeartRate: json['avg_heart_rate'] as int?,
      steps: json['steps'] as int?,
      healthKitId: json['health_kit_id'] as String?,
      metrics: (json['metrics'] as Map<String, dynamic>?) ?? {},
      mediaUrls: (json['media_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  /// 转为 Supabase JSON（不含时间戳）
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'sport_type': sportType,
      'duration_minutes': durationMinutes,
      'intensity': intensity,
      'workout_date': workoutDate.toIso8601String(),
      'notes': notes,
      'photo_urls': photoUrls,
      'is_public': isPublic,
      'is_draft': isDraft,
      'calories_burned': caloriesBurned,
      'avg_heart_rate': avgHeartRate,
      'steps': steps,
      'health_kit_id': healthKitId,
      'metrics': metrics,
      'media_urls': mediaUrls,
    };
  }

  /// 复制修改
  WorkoutModel copyWith({
    String? sportType,
    int? durationMinutes,
    int? intensity,
    DateTime? workoutDate,
    String? notes,
    List<String>? photoUrls,
    bool? isPublic,
    bool? isDraft,
    int? caloriesBurned,
    int? avgHeartRate,
    int? steps,
    String? healthKitId,
    Map<String, dynamic>? metrics,
    List<String>? mediaUrls,
    DateTime? deletedAt,
  }) {
    return WorkoutModel(
      id: id,
      userId: userId,
      sportType: sportType ?? this.sportType,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      intensity: intensity ?? this.intensity,
      workoutDate: workoutDate ?? this.workoutDate,
      notes: notes ?? this.notes,
      photoUrls: photoUrls ?? this.photoUrls,
      isPublic: isPublic ?? this.isPublic,
      isDraft: isDraft ?? this.isDraft,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      avgHeartRate: avgHeartRate ?? this.avgHeartRate,
      steps: steps ?? this.steps,
      healthKitId: healthKitId ?? this.healthKitId,
      metrics: metrics ?? this.metrics,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  /// 是否有运动专项成绩
  bool get hasMetrics => metrics.isNotEmpty;

  /// 运动专项成绩摘要显示
  String get metricsDisplay {
    if (!hasMetrics) return '';
    // 延迟导入避免循环依赖，使用内联逻辑
    switch (sportType) {
      case 'hyrox':
        final totalSec = metrics['total_time_sec'] as int?;
        if (totalSec == null) return '';
        final h = totalSec ~/ 3600;
        final m = (totalSec % 3600) ~/ 60;
        final s = totalSec % 60;
        if (h > 0) {
          return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
        }
        return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
      case 'crossfit':
        final parts = <String>[];
        final wod = metrics['wod_name'] as String?;
        final score = metrics['score'] as String?;
        if (wod != null && wod.isNotEmpty) parts.add(wod);
        if (score != null && score.isNotEmpty) parts.add(score);
        return parts.join(' ');
      case 'yoga':
      case 'pilates':
        return (metrics['class_name'] as String?) ?? '';
      case 'running':
        final parts = <String>[];
        final dist = metrics['distance_km'];
        final pace = metrics['pace_min_per_km'];
        if (dist != null) parts.add('${dist}km');
        if (pace != null) {
          final totalSec = ((pace as num).toDouble() * 60).round();
          final min = totalSec ~/ 60;
          final sec = totalSec % 60;
          parts.add("$min'${sec.toString().padLeft(2, '0')}\"");
        }
        return parts.join(' ');
      default:
        return '';
    }
  }

  /// 时长显示（如 "1h 30min" 或 "45min"）
  String get durationDisplay {
    if (durationMinutes >= 60) {
      final hours = durationMinutes ~/ 60;
      final mins = durationMinutes % 60;
      return mins > 0 ? '${hours}h ${mins}min' : '${hours}h';
    }
    return '${durationMinutes}min';
  }

  /// 强度标签
  String get intensityLabel {
    if (intensity <= 2) return '轻松';
    if (intensity <= 4) return '适中';
    if (intensity <= 6) return '中等';
    if (intensity <= 8) return '高强度';
    return '极限';
  }

  /// 是否已删除（软删除）
  bool get isDeleted => deletedAt != null;
}
