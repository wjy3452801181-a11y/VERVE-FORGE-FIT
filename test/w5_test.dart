import 'package:flutter_test/flutter_test.dart';

import 'package:verveforge/features/workout/domain/workout_model.dart';
import 'package:verveforge/features/workout/domain/workout_metrics.dart';

void main() {
  // ===========================================
  // WorkoutModel 增强字段测试
  // ===========================================
  group('WorkoutModel - metrics & mediaUrls', () {
    final now = DateTime.now();
    final baseJson = {
      'id': 'w-m1',
      'user_id': 'u-1',
      'sport_type': 'hyrox',
      'duration_minutes': 90,
      'intensity': 8,
      'workout_date': now.toIso8601String(),
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    test('fromJson 缺少 metrics/mediaUrls 使用默认值', () {
      final workout = WorkoutModel.fromJson(baseJson);
      expect(workout.metrics, isEmpty);
      expect(workout.mediaUrls, isEmpty);
      expect(workout.hasMetrics, isFalse);
      expect(workout.metricsDisplay, '');
    });

    test('fromJson 正确解析 metrics JSONB', () {
      final json = Map<String, dynamic>.from(baseJson);
      json['metrics'] = {
        'total_time_sec': 4200,
        'stations': [
          {'name': 'SkiErg', 'time_sec': 120},
        ],
      };
      final workout = WorkoutModel.fromJson(json);
      expect(workout.hasMetrics, isTrue);
      expect(workout.metrics['total_time_sec'], 4200);
    });

    test('fromJson 正确解析 mediaUrls', () {
      final json = Map<String, dynamic>.from(baseJson);
      json['media_urls'] = ['https://example.com/video.mp4', 'https://example.com/photo.jpg'];
      final workout = WorkoutModel.fromJson(json);
      expect(workout.mediaUrls, hasLength(2));
      expect(workout.mediaUrls[0], contains('video.mp4'));
    });

    test('toJson 包含 metrics 和 media_urls', () {
      final json = Map<String, dynamic>.from(baseJson);
      json['metrics'] = {'total_time_sec': 4200};
      json['media_urls'] = ['https://example.com/v.mp4'];
      final workout = WorkoutModel.fromJson(json);
      final output = workout.toJson();
      expect(output['metrics'], isA<Map>());
      expect(output['metrics']['total_time_sec'], 4200);
      expect(output['media_urls'], hasLength(1));
    });

    test('copyWith 覆盖 metrics', () {
      final workout = WorkoutModel.fromJson(baseJson);
      final updated = workout.copyWith(
        metrics: {'wod_name': 'Fran', 'score': '3:45'},
      );
      expect(updated.hasMetrics, isTrue);
      expect(updated.metrics['wod_name'], 'Fran');
      // 原始不变
      expect(workout.hasMetrics, isFalse);
    });

    test('copyWith 覆盖 mediaUrls', () {
      final workout = WorkoutModel.fromJson(baseJson);
      final updated = workout.copyWith(
        mediaUrls: ['https://example.com/a.mp4'],
      );
      expect(updated.mediaUrls, hasLength(1));
      expect(workout.mediaUrls, isEmpty);
    });
  });

  // ===========================================
  // HyroxMetrics 测试
  // ===========================================
  group('HyroxMetrics', () {
    test('fromJson/toJson 往返', () {
      final json = {
        'stations': [
          {'name': 'SkiErg', 'time_sec': 120},
          {'name': 'Sled Push', 'time_sec': 180},
          {'name': 'Sled Pull', 'time_sec': 150},
          {'name': 'Burpee Broad Jump', 'time_sec': 240},
          {'name': 'Row', 'time_sec': 130},
          {'name': 'Farmers Carry', 'time_sec': 100},
          {'name': 'Sandbag Lunges', 'time_sec': 200},
          {'name': 'Wall Balls', 'time_sec': 160},
        ],
        'total_time_sec': 4200,
      };
      final metrics = HyroxMetrics.fromJson(json);
      expect(metrics.stations, hasLength(8));
      expect(metrics.stations[0].name, 'SkiErg');
      expect(metrics.stations[0].timeSec, 120);
      expect(metrics.totalTimeSec, 4200);

      final output = metrics.toJson();
      expect(output['stations'], hasLength(8));
      expect(output['total_time_sec'], 4200);
    });

    test('totalTimeDisplay 超过 1 小时', () {
      final metrics = HyroxMetrics.fromJson({
        'total_time_sec': 4223, // 1h 10m 23s
        'stations': [],
      });
      expect(metrics.totalTimeDisplay, '1:10:23');
    });

    test('totalTimeDisplay 不到 1 小时', () {
      final metrics = HyroxMetrics.fromJson({
        'total_time_sec': 2345, // 39m 05s
        'stations': [],
      });
      expect(metrics.totalTimeDisplay, '39:05');
    });

    test('totalTimeDisplay null 值', () {
      const metrics = HyroxMetrics();
      expect(metrics.totalTimeDisplay, '--:--');
    });

    test('HyroxStation timeDisplay', () {
      const station = HyroxStation(name: 'SkiErg', timeSec: 150);
      expect(station.timeDisplay, '02:30');
    });

    test('HyroxStation timeDisplay null', () {
      const station = HyroxStation(name: 'Row');
      expect(station.timeDisplay, '--:--');
    });
  });

  // ===========================================
  // CrossFitMetrics 测试
  // ===========================================
  group('CrossFitMetrics', () {
    test('fromJson/toJson 往返', () {
      final json = {
        'wod_name': 'Fran',
        'wod_type': 'for_time',
        'score': '3:45',
        'movements': ['Thrusters', 'Pull-ups'],
      };
      final metrics = CrossFitMetrics.fromJson(json);
      expect(metrics.wodName, 'Fran');
      expect(metrics.wodType, 'for_time');
      expect(metrics.score, '3:45');
      expect(metrics.movements, hasLength(2));
      expect(metrics.wodTypeDisplay, 'For Time');

      final output = metrics.toJson();
      expect(output['wod_name'], 'Fran');
      expect(output['movements'], hasLength(2));
    });

    test('fromJson 缺省值', () {
      final metrics = CrossFitMetrics.fromJson({});
      expect(metrics.wodName, isNull);
      expect(metrics.wodType, isNull);
      expect(metrics.score, isNull);
      expect(metrics.movements, isEmpty);
      expect(metrics.wodTypeDisplay, '');
    });

    test('wodTypeDisplay AMRAP', () {
      final metrics = CrossFitMetrics.fromJson({'wod_type': 'amrap'});
      expect(metrics.wodTypeDisplay, 'AMRAP');
    });

    test('wodTypeDisplay EMOM', () {
      final metrics = CrossFitMetrics.fromJson({'wod_type': 'emom'});
      expect(metrics.wodTypeDisplay, 'EMOM');
    });
  });

  // ===========================================
  // YogaPilatesMetrics 测试
  // ===========================================
  group('YogaPilatesMetrics', () {
    test('fromJson/toJson 往返', () {
      final json = {
        'class_name': 'Flow Yoga',
        'focus_areas': ['flexibility', 'core', 'balance'],
        'difficulty': 'intermediate',
      };
      final metrics = YogaPilatesMetrics.fromJson(json);
      expect(metrics.className, 'Flow Yoga');
      expect(metrics.focusAreas, hasLength(3));
      expect(metrics.difficulty, 'intermediate');
      expect(metrics.difficultyDisplay, '中级');

      final output = metrics.toJson();
      expect(output['class_name'], 'Flow Yoga');
      expect(output['focus_areas'], hasLength(3));
      expect(output['difficulty'], 'intermediate');
    });

    test('fromJson 缺省值', () {
      final metrics = YogaPilatesMetrics.fromJson({});
      expect(metrics.className, isNull);
      expect(metrics.focusAreas, isEmpty);
      expect(metrics.difficulty, isNull);
      expect(metrics.difficultyDisplay, '');
    });

    test('difficultyDisplay 各级别', () {
      expect(
        YogaPilatesMetrics.fromJson({'difficulty': 'beginner'}).difficultyDisplay,
        '初级',
      );
      expect(
        YogaPilatesMetrics.fromJson({'difficulty': 'advanced'}).difficultyDisplay,
        '高级',
      );
    });

    test('focusAreaLabels 覆盖所有值', () {
      for (final area in YogaPilatesMetrics.allFocusAreas) {
        expect(YogaPilatesMetrics.focusAreaLabels.containsKey(area), isTrue,
            reason: '$area should have a label');
      }
    });
  });

  // ===========================================
  // RunningMetrics 测试
  // ===========================================
  group('RunningMetrics', () {
    test('fromJson/toJson 往返', () {
      final json = {
        'distance_km': 10.5,
        'pace_min_per_km': 5.5,
        'elevation_m': 120,
      };
      final metrics = RunningMetrics.fromJson(json);
      expect(metrics.distanceKm, 10.5);
      expect(metrics.paceMinPerKm, 5.5);
      expect(metrics.elevationM, 120);

      final output = metrics.toJson();
      expect(output['distance_km'], 10.5);
      expect(output['pace_min_per_km'], 5.5);
      expect(output['elevation_m'], 120);
    });

    test('fromJson 缺省值', () {
      final metrics = RunningMetrics.fromJson({});
      expect(metrics.distanceKm, isNull);
      expect(metrics.paceMinPerKm, isNull);
      expect(metrics.elevationM, isNull);
    });

    test('paceDisplay 5分30秒', () {
      final metrics = RunningMetrics.fromJson({'pace_min_per_km': 5.5});
      expect(metrics.paceDisplay, "5'30\"");
    });

    test('paceDisplay 整数分钟', () {
      final metrics = RunningMetrics.fromJson({'pace_min_per_km': 6.0});
      expect(metrics.paceDisplay, "6'00\"");
    });

    test('paceDisplay null', () {
      const metrics = RunningMetrics();
      expect(metrics.paceDisplay, '--');
    });

    test('fromJson 处理整数类型的 distance_km', () {
      final metrics = RunningMetrics.fromJson({'distance_km': 10});
      expect(metrics.distanceKm, 10.0);
    });
  });

  // ===========================================
  // WorkoutModel.metricsDisplay 各运动类型
  // ===========================================
  group('WorkoutModel.metricsDisplay', () {
    final now = DateTime.now();

    WorkoutModel createWithMetrics(String sportType, Map<String, dynamic> metrics) {
      return WorkoutModel(
        id: 'test-1',
        userId: 'u-1',
        sportType: sportType,
        durationMinutes: 60,
        intensity: 5,
        workoutDate: now,
        metrics: metrics,
        createdAt: now,
        updatedAt: now,
      );
    }

    test('HYROX metricsDisplay', () {
      final workout = createWithMetrics('hyrox', {
        'total_time_sec': 4223,
      });
      expect(workout.metricsDisplay, '1:10:23');
    });

    test('HYROX metricsDisplay 不到 1 小时', () {
      final workout = createWithMetrics('hyrox', {
        'total_time_sec': 2345,
      });
      expect(workout.metricsDisplay, '39:05');
    });

    test('CrossFit metricsDisplay', () {
      final workout = createWithMetrics('crossfit', {
        'wod_name': 'Fran',
        'score': '3:45',
      });
      expect(workout.metricsDisplay, 'Fran 3:45');
    });

    test('CrossFit metricsDisplay 只有名称', () {
      final workout = createWithMetrics('crossfit', {
        'wod_name': 'Murph',
      });
      expect(workout.metricsDisplay, 'Murph');
    });

    test('Yoga metricsDisplay', () {
      final workout = createWithMetrics('yoga', {
        'class_name': 'Flow Yoga',
      });
      expect(workout.metricsDisplay, 'Flow Yoga');
    });

    test('Pilates metricsDisplay', () {
      final workout = createWithMetrics('pilates', {
        'class_name': 'Reformer',
      });
      expect(workout.metricsDisplay, 'Reformer');
    });

    test('Running metricsDisplay', () {
      final workout = createWithMetrics('running', {
        'distance_km': 10.5,
        'pace_min_per_km': 5.5,
      });
      expect(workout.metricsDisplay, contains('10.5km'));
      expect(workout.metricsDisplay, contains("5'30\""));
    });

    test('空 metrics metricsDisplay', () {
      final workout = createWithMetrics('hyrox', {});
      expect(workout.metricsDisplay, '');
    });

    test('其他运动类型 metricsDisplay', () {
      final workout = createWithMetrics('swimming', {'note': 'test'});
      expect(workout.metricsDisplay, '');
    });
  });

  // ===========================================
  // WorkoutMetrics 工厂方法测试
  // ===========================================
  group('WorkoutMetrics.fromSportType', () {
    test('hyrox 返回 HyroxMetrics', () {
      final result = WorkoutMetrics.fromSportType('hyrox', {
        'total_time_sec': 4200,
        'stations': [],
      });
      expect(result, isA<HyroxMetrics>());
    });

    test('crossfit 返回 CrossFitMetrics', () {
      final result = WorkoutMetrics.fromSportType('crossfit', {
        'wod_name': 'Fran',
      });
      expect(result, isA<CrossFitMetrics>());
    });

    test('yoga 返回 YogaPilatesMetrics', () {
      final result = WorkoutMetrics.fromSportType('yoga', {
        'class_name': 'Flow',
      });
      expect(result, isA<YogaPilatesMetrics>());
    });

    test('pilates 返回 YogaPilatesMetrics', () {
      final result = WorkoutMetrics.fromSportType('pilates', {});
      expect(result, isA<YogaPilatesMetrics>());
    });

    test('running 返回 RunningMetrics', () {
      final result = WorkoutMetrics.fromSportType('running', {
        'distance_km': 5.0,
      });
      expect(result, isA<RunningMetrics>());
    });

    test('unknown 返回原始 Map', () {
      final input = {'key': 'value'};
      final result = WorkoutMetrics.fromSportType('swimming', input);
      expect(result, isA<Map>());
    });
  });

  // ===========================================
  // WorkoutMetrics.displaySummary 测试
  // ===========================================
  group('WorkoutMetrics.displaySummary', () {
    test('hyrox 摘要', () {
      expect(
        WorkoutMetrics.displaySummary('hyrox', {'total_time_sec': 4223, 'stations': []}),
        '1:10:23',
      );
    });

    test('crossfit 摘要', () {
      expect(
        WorkoutMetrics.displaySummary('crossfit', {'wod_name': 'Fran', 'score': '3:45'}),
        'Fran 3:45',
      );
    });

    test('yoga 摘要', () {
      expect(
        WorkoutMetrics.displaySummary('yoga', {'class_name': 'Yin Yoga'}),
        'Yin Yoga',
      );
    });

    test('running 摘要', () {
      final summary = WorkoutMetrics.displaySummary('running', {
        'distance_km': 10.0,
        'pace_min_per_km': 5.0,
      });
      expect(summary, contains('10.0km'));
    });

    test('空 metrics 返回空', () {
      expect(WorkoutMetrics.displaySummary('hyrox', {}), '');
    });

    test('未知类型返回空', () {
      expect(WorkoutMetrics.displaySummary('swimming', {'data': 1}), '');
    });
  });
}
