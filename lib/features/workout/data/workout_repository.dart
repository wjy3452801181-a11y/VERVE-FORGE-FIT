import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/network/supabase_client.dart';
import '../../../core/utils/image_utils.dart';
import '../domain/workout_model.dart';
import '../domain/workout_stats.dart';

const _uuid = Uuid();

/// 训练日志 Repository
class WorkoutRepository {
  /// 创建训练记录
  Future<WorkoutModel> create({
    required String sportType,
    required int durationMinutes,
    required int intensity,
    required DateTime workoutDate,
    String? notes,
    List<String> photoUrls = const [],
    bool isPublic = false,
    bool isDraft = false,
    int? caloriesBurned,
    int? avgHeartRate,
    int? steps,
    String? healthKitId,
  }) async {
    final userId = SupabaseClientHelper.currentUserId!;
    final id = _uuid.v4();
    final now = DateTime.now();

    final data = {
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
    };

    await SupabaseClientHelper.from(SupabaseConstants.workoutLogs).insert(data);

    return WorkoutModel(
      id: id,
      userId: userId,
      sportType: sportType,
      durationMinutes: durationMinutes,
      intensity: intensity,
      workoutDate: workoutDate,
      notes: notes,
      photoUrls: photoUrls,
      isPublic: isPublic,
      isDraft: isDraft,
      caloriesBurned: caloriesBurned,
      avgHeartRate: avgHeartRate,
      steps: steps,
      healthKitId: healthKitId,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 更新训练记录
  Future<void> update(WorkoutModel workout) async {
    await SupabaseClientHelper.from(SupabaseConstants.workoutLogs)
        .update(workout.toJson())
        .eq('id', workout.id)
        .eq('user_id', SupabaseClientHelper.currentUserId!);
  }

  /// 软删除
  Future<void> softDelete(String id) async {
    await SupabaseClientHelper.from(SupabaseConstants.workoutLogs)
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', id)
        .eq('user_id', SupabaseClientHelper.currentUserId!);
  }

  /// 获取单条记录
  Future<WorkoutModel?> get(String id) async {
    final data = await SupabaseClientHelper.from(SupabaseConstants.workoutLogs)
        .select()
        .eq('id', id)
        .isFilter('deleted_at', null)
        .maybeSingle();
    if (data == null) return null;
    return WorkoutModel.fromJson(data);
  }

  /// 获取列表（分页 + 筛选）
  Future<List<WorkoutModel>> list({
    int page = 0,
    int pageSize = 20,
    String? sportType,
    DateTime? from,
    DateTime? to,
    bool includeDrafts = false,
  }) async {
    final userId = SupabaseClientHelper.currentUserId!;
    var query = SupabaseClientHelper.from(SupabaseConstants.workoutLogs)
        .select()
        .eq('user_id', userId)
        .isFilter('deleted_at', null);

    if (!includeDrafts) {
      query = query.eq('is_draft', false);
    }
    if (sportType != null) {
      query = query.eq('sport_type', sportType);
    }
    if (from != null) {
      query = query.gte('workout_date', from.toIso8601String());
    }
    if (to != null) {
      query = query.lte('workout_date', to.toIso8601String());
    }

    final data = await query
        .order('workout_date', ascending: false)
        .range(page * pageSize, (page + 1) * pageSize - 1);

    return (data as List).map((e) => WorkoutModel.fromJson(e)).toList();
  }

  /// 按日期范围查询（日历用）
  Future<List<WorkoutModel>> listByDateRange({
    required DateTime start,
    required DateTime end,
  }) async {
    final userId = SupabaseClientHelper.currentUserId!;
    final data = await SupabaseClientHelper.from(SupabaseConstants.workoutLogs)
        .select()
        .eq('user_id', userId)
        .eq('is_draft', false)
        .isFilter('deleted_at', null)
        .gte('workout_date', start.toIso8601String())
        .lte('workout_date', end.toIso8601String())
        .order('workout_date', ascending: false);

    return (data as List).map((e) => WorkoutModel.fromJson(e)).toList();
  }

  /// 获取日历日期标记（哪些日期有训练）
  Future<Set<DateTime>> getCalendarDates({
    required DateTime start,
    required DateTime end,
  }) async {
    final workouts = await listByDateRange(start: start, end: end);
    return workouts
        .map((w) => DateTime(w.workoutDate.year, w.workoutDate.month, w.workoutDate.day))
        .toSet();
  }

  /// 获取统计数据
  Future<WorkoutStats> getStats() async {
    final userId = SupabaseClientHelper.currentUserId!;
    final data = await SupabaseClientHelper.from(SupabaseConstants.workoutLogs)
        .select()
        .eq('user_id', userId)
        .eq('is_draft', false)
        .isFilter('deleted_at', null)
        .order('workout_date', ascending: false);

    final workouts =
        (data as List).map((e) => WorkoutModel.fromJson(e)).toList();
    return WorkoutStats.fromWorkouts(workouts);
  }

  /// 获取草稿列表
  Future<List<WorkoutModel>> getDrafts() async {
    final userId = SupabaseClientHelper.currentUserId!;
    final data = await SupabaseClientHelper.from(SupabaseConstants.workoutLogs)
        .select()
        .eq('user_id', userId)
        .eq('is_draft', true)
        .isFilter('deleted_at', null)
        .order('updated_at', ascending: false);

    return (data as List).map((e) => WorkoutModel.fromJson(e)).toList();
  }

  /// HealthKit ID 去重查询
  Future<bool> existsByHealthKitId(String healthKitId) async {
    final userId = SupabaseClientHelper.currentUserId!;
    final data = await SupabaseClientHelper.from(SupabaseConstants.workoutLogs)
        .select('id')
        .eq('user_id', userId)
        .eq('health_kit_id', healthKitId)
        .isFilter('deleted_at', null)
        .maybeSingle();
    return data != null;
  }

  /// 上传训练照片
  Future<List<String>> uploadPhotos(List<File> files) async {
    return ImageUtils.uploadImages(
      files: files,
      bucket: SupabaseConstants.workoutPhotosBucket,
      folder: SupabaseClientHelper.currentUserId,
    );
  }
}

/// Provider
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository();
});
