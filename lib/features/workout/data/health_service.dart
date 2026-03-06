import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';

import 'workout_repository.dart';

/// Apple Health 数据同步服务
class HealthService {
  final Health _health = Health();

  /// 请求 HealthKit 权限
  Future<bool> requestPermissions() async {
    if (!Platform.isIOS) return false;

    final types = [
      HealthDataType.WORKOUT,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.HEART_RATE,
      HealthDataType.STEPS,
    ];

    final permissions = types.map((_) => HealthDataAccess.READ).toList();

    try {
      final granted = await _health.requestAuthorization(types, permissions: permissions);
      return granted;
    } catch (_) {
      return false;
    }
  }

  /// 检查是否有 HealthKit 权限
  Future<bool> hasPermissions() async {
    if (!Platform.isIOS) return false;

    try {
      final types = [HealthDataType.WORKOUT];
      final permissions = [HealthDataAccess.READ];
      return await _health.hasPermissions(types, permissions: permissions) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// 读取 HealthKit 训练数据
  Future<List<HealthDataPoint>> getWorkouts({
    required DateTime start,
    required DateTime end,
  }) async {
    if (!Platform.isIOS) return [];

    try {
      return await _health.getHealthDataFromTypes(
        types: [HealthDataType.WORKOUT],
        startTime: start,
        endTime: end,
      );
    } catch (_) {
      return [];
    }
  }

  /// 读取卡路里数据
  Future<double?> getCalories({
    required DateTime start,
    required DateTime end,
  }) async {
    if (!Platform.isIOS) return null;

    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: start,
        endTime: end,
      );
      if (data.isEmpty) return null;
      double total = 0;
      for (final point in data) {
        final value = point.value;
        if (value is NumericHealthValue) {
          total += value.numericValue.toDouble();
        }
      }
      return total;
    } catch (_) {
      return null;
    }
  }

  /// 读取心率数据
  Future<int?> getAvgHeartRate({
    required DateTime start,
    required DateTime end,
  }) async {
    if (!Platform.isIOS) return null;

    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: start,
        endTime: end,
      );
      if (data.isEmpty) return null;
      double sum = 0;
      int count = 0;
      for (final point in data) {
        final value = point.value;
        if (value is NumericHealthValue) {
          sum += value.numericValue.toDouble();
          count++;
        }
      }
      return count > 0 ? (sum / count).round() : null;
    } catch (_) {
      return null;
    }
  }

  /// 读取步数
  Future<int?> getSteps({
    required DateTime start,
    required DateTime end,
  }) async {
    if (!Platform.isIOS) return null;

    try {
      final steps = await _health.getTotalStepsInInterval(start, end);
      return steps;
    } catch (_) {
      return null;
    }
  }

  /// 同步 HealthKit 数据到 Supabase（去重）
  Future<int> syncToSupabase({
    required WorkoutRepository repository,
    int days = 7,
  }) async {
    if (!Platform.isIOS) return 0;

    final end = DateTime.now();
    final start = end.subtract(Duration(days: days));
    final healthWorkouts = await getWorkouts(start: start, end: end);

    int synced = 0;

    for (final point in healthWorkouts) {
      final hkId = point.uuid;

      // 去重检查
      final exists = await repository.existsByHealthKitId(hkId);
      if (exists) continue;

      final duration = point.dateTo.difference(point.dateFrom).inMinutes;
      if (duration <= 0) continue;

      // 获取额外数据
      final calories = await getCalories(start: point.dateFrom, end: point.dateTo);
      final heartRate = await getAvgHeartRate(start: point.dateFrom, end: point.dateTo);
      final steps = await getSteps(start: point.dateFrom, end: point.dateTo);

      final sportType = _mapHealthWorkoutType(point);

      await repository.create(
        sportType: sportType,
        durationMinutes: duration,
        intensity: _estimateIntensity(duration, heartRate),
        workoutDate: point.dateFrom,
        caloriesBurned: calories?.round(),
        avgHeartRate: heartRate,
        steps: steps,
        healthKitId: hkId,
      );

      synced++;
    }

    return synced;
  }

  /// 映射 HealthKit workout 类型到 app 运动类型
  String _mapHealthWorkoutType(HealthDataPoint point) {
    final value = point.value;
    if (value is WorkoutHealthValue) {
      switch (value.workoutActivityType) {
        case HealthWorkoutActivityType.RUNNING:
        case HealthWorkoutActivityType.RUNNING_TREADMILL:
          return 'running';
        case HealthWorkoutActivityType.SWIMMING:
        case HealthWorkoutActivityType.SWIMMING_OPEN_WATER:
          return 'swimming';
        case HealthWorkoutActivityType.YOGA:
          return 'yoga';
        case HealthWorkoutActivityType.PILATES:
          return 'pilates';
        case HealthWorkoutActivityType.CROSS_TRAINING:
        case HealthWorkoutActivityType.HIGH_INTENSITY_INTERVAL_TRAINING:
          return 'crossfit';
        case HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING:
        case HealthWorkoutActivityType.FUNCTIONAL_STRENGTH_TRAINING:
          return 'strength';
        default:
          return 'other';
      }
    }
    return 'other';
  }

  /// 根据时长和心率估算训练强度
  int _estimateIntensity(int durationMinutes, int? avgHeartRate) {
    if (avgHeartRate != null) {
      if (avgHeartRate < 100) return 2;
      if (avgHeartRate < 120) return 4;
      if (avgHeartRate < 140) return 6;
      if (avgHeartRate < 160) return 8;
      return 9;
    }
    // 无心率数据，根据时长估算
    if (durationMinutes < 20) return 3;
    if (durationMinutes < 45) return 5;
    if (durationMinutes < 90) return 6;
    return 7;
  }
}

/// Provider
final healthServiceProvider = Provider<HealthService>((ref) {
  return HealthService();
});
