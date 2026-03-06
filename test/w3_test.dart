import 'package:flutter_test/flutter_test.dart';

import 'package:verveforge/features/workout/domain/workout_model.dart';
import 'package:verveforge/features/workout/domain/workout_stats.dart';
import 'package:verveforge/core/utils/validators.dart';

void main() {
  // ===========================================
  // WorkoutModel 测试
  // ===========================================
  group('WorkoutModel', () {
    final now = DateTime.now();
    final sampleJson = {
      'id': 'workout-123',
      'user_id': 'user-456',
      'sport_type': 'running',
      'duration_minutes': 45,
      'intensity': 6,
      'workout_date': now.toIso8601String(),
      'notes': '晨跑 5 公里',
      'photo_urls': ['https://example.com/a.jpg', 'https://example.com/b.jpg'],
      'is_public': true,
      'is_draft': false,
      'calories_burned': 350,
      'avg_heart_rate': 145,
      'steps': 6200,
      'health_kit_id': 'hk-abc',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'deleted_at': null,
    };

    test('fromJson 正确解析所有字段', () {
      final workout = WorkoutModel.fromJson(sampleJson);
      expect(workout.id, 'workout-123');
      expect(workout.userId, 'user-456');
      expect(workout.sportType, 'running');
      expect(workout.durationMinutes, 45);
      expect(workout.intensity, 6);
      expect(workout.notes, '晨跑 5 公里');
      expect(workout.photoUrls.length, 2);
      expect(workout.isPublic, isTrue);
      expect(workout.isDraft, isFalse);
      expect(workout.caloriesBurned, 350);
      expect(workout.avgHeartRate, 145);
      expect(workout.steps, 6200);
      expect(workout.healthKitId, 'hk-abc');
      expect(workout.isDeleted, isFalse);
    });

    test('fromJson 缺失字段使用默认值', () {
      final minimalJson = {
        'id': 'w-min',
        'user_id': 'u-min',
        'sport_type': 'yoga',
        'duration_minutes': 30,
        'intensity': 3,
        'workout_date': now.toIso8601String(),
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };
      final workout = WorkoutModel.fromJson(minimalJson);
      expect(workout.notes, isNull);
      expect(workout.photoUrls, isEmpty);
      expect(workout.isPublic, isFalse);
      expect(workout.isDraft, isFalse);
      expect(workout.caloriesBurned, isNull);
      expect(workout.avgHeartRate, isNull);
      expect(workout.steps, isNull);
      expect(workout.healthKitId, isNull);
      expect(workout.deletedAt, isNull);
    });

    test('toJson 输出正确结构', () {
      final workout = WorkoutModel.fromJson(sampleJson);
      final json = workout.toJson();
      expect(json['id'], 'workout-123');
      expect(json['sport_type'], 'running');
      expect(json['duration_minutes'], 45);
      expect(json['intensity'], 6);
      expect(json['photo_urls'], hasLength(2));
      expect(json['is_public'], isTrue);
      expect(json['health_kit_id'], 'hk-abc');
      // toJson 不含时间戳
      expect(json.containsKey('created_at'), isFalse);
      expect(json.containsKey('updated_at'), isFalse);
      expect(json.containsKey('deleted_at'), isFalse);
    });

    test('copyWith 正确覆盖字段', () {
      final workout = WorkoutModel.fromJson(sampleJson);
      final updated = workout.copyWith(
        sportType: 'swimming',
        durationMinutes: 60,
        intensity: 8,
        notes: '游泳 1500 米',
      );
      expect(updated.sportType, 'swimming');
      expect(updated.durationMinutes, 60);
      expect(updated.intensity, 8);
      expect(updated.notes, '游泳 1500 米');
      // 未修改字段保持不变
      expect(updated.id, 'workout-123');
      expect(updated.userId, 'user-456');
      expect(updated.photoUrls.length, 2);
      expect(updated.caloriesBurned, 350);
    });

    test('durationDisplay 短于 1 小时', () {
      final workout = WorkoutModel.fromJson(sampleJson);
      expect(workout.durationDisplay, '45min');
    });

    test('durationDisplay 恰好 1 小时', () {
      final json = Map<String, dynamic>.from(sampleJson);
      json['duration_minutes'] = 60;
      final workout = WorkoutModel.fromJson(json);
      expect(workout.durationDisplay, '1h');
    });

    test('durationDisplay 超过 1 小时', () {
      final json = Map<String, dynamic>.from(sampleJson);
      json['duration_minutes'] = 90;
      final workout = WorkoutModel.fromJson(json);
      expect(workout.durationDisplay, '1h 30min');
    });

    test('intensityLabel 各级别映射', () {
      final levels = {
        1: '轻松',
        2: '轻松',
        3: '适中',
        4: '适中',
        5: '中等',
        6: '中等',
        7: '高强度',
        8: '高强度',
        9: '极限',
        10: '极限',
      };
      for (final entry in levels.entries) {
        final json = Map<String, dynamic>.from(sampleJson);
        json['intensity'] = entry.key;
        final workout = WorkoutModel.fromJson(json);
        expect(workout.intensityLabel, entry.value,
            reason: 'intensity ${entry.key} should be "${entry.value}"');
      }
    });

    test('isDeleted 反映 deletedAt', () {
      final json = Map<String, dynamic>.from(sampleJson);
      json['deleted_at'] = now.toIso8601String();
      final workout = WorkoutModel.fromJson(json);
      expect(workout.isDeleted, isTrue);
    });
  });

  // ===========================================
  // WorkoutStats 测试
  // ===========================================
  group('WorkoutStats', () {
    test('fromWorkouts 空列表', () {
      final stats = WorkoutStats.fromWorkouts([]);
      expect(stats.weeklyCount, 0);
      expect(stats.monthlyCount, 0);
      expect(stats.totalMinutes, 0);
      expect(stats.totalWorkouts, 0);
    });

    test('fromWorkouts 正确聚合', () {
      final now = DateTime.now();
      final workouts = [
        _createWorkout(
          workoutDate: now,
          durationMinutes: 30,
        ),
        _createWorkout(
          workoutDate: now.subtract(const Duration(days: 1)),
          durationMinutes: 45,
        ),
        _createWorkout(
          workoutDate: now.subtract(const Duration(days: 60)),
          durationMinutes: 60,
        ),
      ];

      final stats = WorkoutStats.fromWorkouts(workouts);
      expect(stats.totalWorkouts, 3);
      expect(stats.totalMinutes, 135); // 30 + 45 + 60
      expect(stats.monthlyCount, greaterThanOrEqualTo(2));
    });

    test('fromWorkouts 排除草稿和已删除', () {
      final now = DateTime.now();
      final workouts = [
        _createWorkout(workoutDate: now, durationMinutes: 30),
        _createWorkout(workoutDate: now, durationMinutes: 20, isDraft: true),
        _createWorkout(
            workoutDate: now,
            durationMinutes: 40,
            deletedAt: now),
      ];

      final stats = WorkoutStats.fromWorkouts(workouts);
      expect(stats.totalWorkouts, 1);
      expect(stats.totalMinutes, 30);
    });

    test('totalHoursDisplay 不足 1 小时', () {
      const stats = WorkoutStats(totalMinutes: 45);
      expect(stats.totalHoursDisplay, '45m');
    });

    test('totalHoursDisplay 整数小时', () {
      const stats = WorkoutStats(totalMinutes: 120);
      expect(stats.totalHoursDisplay, '2h');
    });

    test('totalHoursDisplay 带余数', () {
      const stats = WorkoutStats(totalMinutes: 150);
      expect(stats.totalHoursDisplay, '2h30m');
    });
  });

  // ===========================================
  // Validators 补充测试（训练相关）
  // ===========================================
  group('Validators - 训练时长', () {
    test('正常时长通过校验', () {
      expect(Validators.duration('1'), isNull);
      expect(Validators.duration('60'), isNull);
      expect(Validators.duration('600'), isNull);
    });

    test('零和负数不通过', () {
      expect(Validators.duration('0'), isNotNull);
      expect(Validators.duration('-1'), isNotNull);
    });

    test('超过 600 分钟不通过', () {
      expect(Validators.duration('601'), isNotNull);
    });

    test('非数字不通过', () {
      expect(Validators.duration('abc'), isNotNull);
      expect(Validators.duration(''), isNotNull);
      expect(Validators.duration(null), isNotNull);
    });
  });
}

/// 测试辅助：创建 WorkoutModel
WorkoutModel _createWorkout({
  required DateTime workoutDate,
  int durationMinutes = 30,
  bool isDraft = false,
  DateTime? deletedAt,
}) {
  return WorkoutModel(
    id: 'test-${workoutDate.millisecondsSinceEpoch}',
    userId: 'user-test',
    sportType: 'running',
    durationMinutes: durationMinutes,
    intensity: 5,
    workoutDate: workoutDate,
    isDraft: isDraft,
    deletedAt: deletedAt,
    createdAt: workoutDate,
    updatedAt: workoutDate,
  );
}
