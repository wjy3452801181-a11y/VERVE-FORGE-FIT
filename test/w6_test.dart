import 'package:flutter_test/flutter_test.dart';
import 'package:verveforge/features/challenge/domain/challenge_model.dart';
import 'package:verveforge/features/challenge/domain/challenge_participant_model.dart';
import 'package:verveforge/features/challenge/domain/challenge_check_in_model.dart';

// ---------------------------------------------------------------------------
// 辅助工厂
// ---------------------------------------------------------------------------

Map<String, dynamic> baseChallengeJson({
  String id = 'c1',
  String creatorId = 'u1',
  String title = 'HYROX 30天挑战',
  String sportType = 'hyrox',
  String goalType = 'total_sessions',
  int goalValue = 30,
  String status = 'active',
  int participantCount = 5,
  int maxParticipants = 100,
  String? city,
  Map<String, dynamic>? metricsRules,
  bool? isJoined,
  String? creatorNickname,
  String? creatorAvatar,
  DateTime? startsAt,
  DateTime? endsAt,
}) {
  final now = DateTime.now();
  return {
    'id': id,
    'creator_id': creatorId,
    'title': title,
    'description': '测试挑战描述',
    'sport_type': sportType,
    'goal_type': goalType,
    'goal_value': goalValue,
    'starts_at': (startsAt ?? now.subtract(const Duration(days: 5)))
        .toIso8601String(),
    'ends_at':
        (endsAt ?? now.add(const Duration(days: 25))).toIso8601String(),
    'max_participants': maxParticipants,
    'city': city,
    'status': status,
    'participant_count': participantCount,
    'metrics_rules': metricsRules ?? {},
    'created_at': now.toIso8601String(),
    'updated_at': now.toIso8601String(),
    'is_joined': isJoined,
    'creator_nickname': creatorNickname,
    'creator_avatar': creatorAvatar,
  };
}

Map<String, dynamic> baseParticipantJson({
  String id = 'p1',
  String challengeId = 'c1',
  String userId = 'u1',
  int progressValue = 12,
  int checkInCount = 10,
  int rank = 1,
  String? nickname,
  String? avatarUrl,
  String? goalType,
  int? goalValue,
  double? progressPct,
}) {
  final now = DateTime.now();
  return {
    'participant_id': id,
    'challenge_id': challengeId,
    'user_id': userId,
    'progress_value': progressValue,
    'check_in_count': checkInCount,
    'rank': rank,
    'joined_at': now.toIso8601String(),
    'last_check_in_at': now.toIso8601String(),
    'nickname': nickname,
    'avatar_url': avatarUrl,
    'goal_type': goalType,
    'goal_value': goalValue,
    'progress_pct': progressPct,
  };
}

Map<String, dynamic> baseCheckInJson({
  String id = 'ci1',
  String challengeId = 'c1',
  String participantId = 'p1',
  String workoutLogId = 'w1',
  int value = 1,
}) {
  return {
    'id': id,
    'challenge_id': challengeId,
    'participant_id': participantId,
    'workout_log_id': workoutLogId,
    'value': value,
    'created_at': DateTime.now().toIso8601String(),
  };
}

// ---------------------------------------------------------------------------
// 测试
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------
  // ChallengeModel
  // -------------------------------------------------------

  group('ChallengeModel - fromJson', () {
    test('基础字段正确解析', () {
      final json = baseChallengeJson();
      final m = ChallengeModel.fromJson(json);

      expect(m.id, 'c1');
      expect(m.creatorId, 'u1');
      expect(m.title, 'HYROX 30天挑战');
      expect(m.sportType, 'hyrox');
      expect(m.goalType, 'total_sessions');
      expect(m.goalValue, 30);
      expect(m.maxParticipants, 100);
      expect(m.participantCount, 5);
      expect(m.status, 'active');
    });

    test('可选字段 null 时使用默认值', () {
      final json = baseChallengeJson();
      json.remove('city');
      json.remove('cover_image');
      json.remove('is_joined');
      json.remove('creator_nickname');
      final m = ChallengeModel.fromJson(json);

      expect(m.city, isNull);
      expect(m.coverImage, isNull);
      expect(m.isJoined, isNull);
      expect(m.creatorNickname, isNull);
    });

    test('视图字段正确解析', () {
      final json = baseChallengeJson(
        isJoined: true,
        creatorNickname: '张三',
        creatorAvatar: 'https://example.com/avatar.jpg',
      );
      final m = ChallengeModel.fromJson(json);

      expect(m.isJoined, true);
      expect(m.creatorNickname, '张三');
      expect(m.creatorAvatar, 'https://example.com/avatar.jpg');
    });

    test('metricsRules JSONB 正确解析', () {
      final json = baseChallengeJson(metricsRules: {
        'min_duration': 30,
        'allowed_types': ['hyrox', 'crossfit'],
      });
      final m = ChallengeModel.fromJson(json);

      expect(m.metricsRules['min_duration'], 30);
      expect(m.metricsRules['allowed_types'], ['hyrox', 'crossfit']);
    });
  });

  group('ChallengeModel - toJson', () {
    test('包含必要字段且不含时间戳和视图字段', () {
      final m = ChallengeModel.fromJson(baseChallengeJson(
        isJoined: true,
        creatorNickname: '张三',
      ));
      final json = m.toJson();

      expect(json.containsKey('id'), true);
      expect(json.containsKey('title'), true);
      expect(json.containsKey('sport_type'), true);
      expect(json.containsKey('metrics_rules'), true);
      // 视图字段不应出现
      expect(json.containsKey('is_joined'), false);
      expect(json.containsKey('creator_nickname'), false);
      expect(json.containsKey('created_at'), false);
      expect(json.containsKey('updated_at'), false);
    });
  });

  group('ChallengeModel - copyWith', () {
    test('正确覆盖指定字段', () {
      final m = ChallengeModel.fromJson(baseChallengeJson());
      final updated = m.copyWith(
        title: '新标题',
        status: 'completed',
        participantCount: 20,
      );

      expect(updated.title, '新标题');
      expect(updated.status, 'completed');
      expect(updated.participantCount, 20);
      // 未修改的字段保持不变
      expect(updated.id, m.id);
      expect(updated.sportType, m.sportType);
    });

    test('copyWith isJoined', () {
      final m = ChallengeModel.fromJson(baseChallengeJson(isJoined: false));
      final updated = m.copyWith(isJoined: true);
      expect(updated.isJoined, true);
    });
  });

  group('ChallengeModel - 计算属性', () {
    test('isActive / isCompleted', () {
      final active =
          ChallengeModel.fromJson(baseChallengeJson(status: 'active'));
      expect(active.isActive, true);
      expect(active.isCompleted, false);

      final completed =
          ChallengeModel.fromJson(baseChallengeJson(status: 'completed'));
      expect(completed.isActive, false);
      expect(completed.isCompleted, true);
    });

    test('isFull', () {
      final notFull = ChallengeModel.fromJson(
          baseChallengeJson(participantCount: 5, maxParticipants: 100));
      expect(notFull.isFull, false);

      final full = ChallengeModel.fromJson(
          baseChallengeJson(participantCount: 100, maxParticipants: 100));
      expect(full.isFull, true);
    });

    test('isCreatedBy', () {
      final m = ChallengeModel.fromJson(baseChallengeJson(creatorId: 'u1'));
      expect(m.isCreatedBy('u1'), true);
      expect(m.isCreatedBy('u2'), false);
    });

    test('remainingDays 正确计算', () {
      final now = DateTime.now();
      // 使用日期级别（去掉时间部分）避免 inDays 舍入问题
      final endDate = DateTime(now.year, now.month, now.day + 10, 23, 59, 59);
      final m = ChallengeModel.fromJson(baseChallengeJson(
        endsAt: endDate,
      ));
      expect(m.remainingDays, 10);
    });

    test('remainingDays 已过期返回 0', () {
      final now = DateTime.now();
      final m = ChallengeModel.fromJson(baseChallengeJson(
        endsAt: now.subtract(const Duration(days: 1)),
      ));
      expect(m.remainingDays, 0);
    });

    test('totalDays 正确计算', () {
      final now = DateTime.now();
      final m = ChallengeModel.fromJson(baseChallengeJson(
        startsAt: now,
        endsAt: now.add(const Duration(days: 30)),
      ));
      expect(m.totalDays, 30);
    });

    test('goalTypeDisplay', () {
      expect(
        ChallengeModel.fromJson(
                baseChallengeJson(goalType: 'total_sessions'))
            .goalTypeDisplay,
        '总次数',
      );
      expect(
        ChallengeModel.fromJson(
                baseChallengeJson(goalType: 'total_minutes'))
            .goalTypeDisplay,
        '总时长(分钟)',
      );
      expect(
        ChallengeModel.fromJson(baseChallengeJson(goalType: 'total_days'))
            .goalTypeDisplay,
        '总天数',
      );
      expect(
        ChallengeModel.fromJson(baseChallengeJson(goalType: 'unknown'))
            .goalTypeDisplay,
        'unknown',
      );
    });

    test('statusDisplay', () {
      expect(
        ChallengeModel.fromJson(baseChallengeJson(status: 'draft'))
            .statusDisplay,
        '草稿',
      );
      expect(
        ChallengeModel.fromJson(baseChallengeJson(status: 'active'))
            .statusDisplay,
        '进行中',
      );
      expect(
        ChallengeModel.fromJson(baseChallengeJson(status: 'completed'))
            .statusDisplay,
        '已结束',
      );
      expect(
        ChallengeModel.fromJson(baseChallengeJson(status: 'cancelled'))
            .statusDisplay,
        '已取消',
      );
    });

    test('sportTypeDisplay', () {
      expect(
        ChallengeModel.fromJson(baseChallengeJson(sportType: 'hyrox'))
            .sportTypeDisplay,
        'HYROX',
      );
      expect(
        ChallengeModel.fromJson(baseChallengeJson(sportType: 'crossfit'))
            .sportTypeDisplay,
        'CrossFit',
      );
      expect(
        ChallengeModel.fromJson(baseChallengeJson(sportType: 'yoga'))
            .sportTypeDisplay,
        '瑜伽',
      );
      expect(
        ChallengeModel.fromJson(baseChallengeJson(sportType: 'running'))
            .sportTypeDisplay,
        '跑步',
      );
    });

    test('isDeleted', () {
      final json = baseChallengeJson();
      json['deleted_at'] = DateTime.now().toIso8601String();
      final m = ChallengeModel.fromJson(json);
      expect(m.isDeleted, true);

      final notDeleted = ChallengeModel.fromJson(baseChallengeJson());
      expect(notDeleted.isDeleted, false);
    });
  });

  // -------------------------------------------------------
  // ChallengeParticipantModel
  // -------------------------------------------------------

  group('ChallengeParticipantModel - fromJson', () {
    test('基础字段正确解析', () {
      final json = baseParticipantJson();
      final p = ChallengeParticipantModel.fromJson(json);

      expect(p.id, 'p1');
      expect(p.challengeId, 'c1');
      expect(p.usedId, 'u1');
      expect(p.progressValue, 12);
      expect(p.checkInCount, 10);
      expect(p.rank, 1);
    });

    test('视图字段正确解析', () {
      final json = baseParticipantJson(
        nickname: '李四',
        avatarUrl: 'https://example.com/a.jpg',
        goalType: 'total_sessions',
        goalValue: 30,
        progressPct: 40.0,
      );
      final p = ChallengeParticipantModel.fromJson(json);

      expect(p.nickname, '李四');
      expect(p.avatarUrl, 'https://example.com/a.jpg');
      expect(p.goalType, 'total_sessions');
      expect(p.goalValue, 30);
      expect(p.progressPct, 40.0);
    });

    test('participant_id 优先于 id', () {
      final json = baseParticipantJson(id: 'p99');
      json['id'] = 'should_be_ignored';
      final p = ChallengeParticipantModel.fromJson(json);
      expect(p.id, 'p99');
    });

    test('无 participant_id 时使用 id', () {
      final json = baseParticipantJson();
      json.remove('participant_id');
      json['id'] = 'fallback_id';
      final p = ChallengeParticipantModel.fromJson(json);
      expect(p.id, 'fallback_id');
    });

    test('可选字段 null 时使用默认值', () {
      final json = baseParticipantJson();
      json.remove('progress_value');
      json.remove('check_in_count');
      json.remove('rank');
      json.remove('nickname');
      final p = ChallengeParticipantModel.fromJson(json);

      expect(p.progressValue, 0);
      expect(p.checkInCount, 0);
      expect(p.rank, isNull);
      expect(p.nickname, isNull);
    });
  });

  group('ChallengeParticipantModel - toJson', () {
    test('包含 id / challenge_id / user_id', () {
      final p = ChallengeParticipantModel.fromJson(baseParticipantJson());
      final json = p.toJson();

      expect(json['id'], 'p1');
      expect(json['challenge_id'], 'c1');
      expect(json['user_id'], 'u1');
      expect(json.length, 3);
    });
  });

  group('ChallengeParticipantModel - copyWith', () {
    test('正确覆盖指定字段', () {
      final p = ChallengeParticipantModel.fromJson(baseParticipantJson());
      final updated = p.copyWith(
        progressValue: 20,
        checkInCount: 18,
        rank: 2,
      );

      expect(updated.progressValue, 20);
      expect(updated.checkInCount, 18);
      expect(updated.rank, 2);
      expect(updated.id, p.id);
    });
  });

  group('ChallengeParticipantModel - 计算属性', () {
    test('progressDisplay 有 goalValue', () {
      final p = ChallengeParticipantModel.fromJson(
        baseParticipantJson(progressValue: 12, goalValue: 30),
      );
      expect(p.progressDisplay, '12/30');
    });

    test('progressDisplay 无 goalValue', () {
      final p = ChallengeParticipantModel.fromJson(
        baseParticipantJson(progressValue: 12),
      );
      expect(p.progressDisplay, '12');
    });

    test('progressRatio 使用 progressPct', () {
      final p = ChallengeParticipantModel.fromJson(
        baseParticipantJson(progressPct: 75.0),
      );
      expect(p.progressRatio, 0.75);
    });

    test('progressRatio 使用 progressValue/goalValue', () {
      final p = ChallengeParticipantModel.fromJson(
        baseParticipantJson(progressValue: 15, goalValue: 30),
      );
      expect(p.progressRatio, 0.5);
    });

    test('progressRatio 超过 100% 限制为 1.0', () {
      final p = ChallengeParticipantModel.fromJson(
        baseParticipantJson(progressPct: 150.0),
      );
      expect(p.progressRatio, 1.0);
    });

    test('progressRatio 无数据返回 0.0', () {
      final p = ChallengeParticipantModel.fromJson(
        baseParticipantJson(),
      );
      expect(p.progressRatio, 0.0);
    });

    test('rankDisplay', () {
      final ranked = ChallengeParticipantModel.fromJson(
        baseParticipantJson(rank: 3),
      );
      expect(ranked.rankDisplay, '#3');

      final json = baseParticipantJson();
      json.remove('rank');
      final unranked = ChallengeParticipantModel.fromJson(json);
      expect(unranked.rankDisplay, '--');
    });

    test('isCurrentUser', () {
      final p = ChallengeParticipantModel.fromJson(
        baseParticipantJson(userId: 'u1'),
      );
      expect(p.isCurrentUser('u1'), true);
      expect(p.isCurrentUser('u2'), false);
    });
  });

  // -------------------------------------------------------
  // ChallengeCheckInModel
  // -------------------------------------------------------

  group('ChallengeCheckInModel - fromJson', () {
    test('基础字段正确解析', () {
      final json = baseCheckInJson();
      final ci = ChallengeCheckInModel.fromJson(json);

      expect(ci.id, 'ci1');
      expect(ci.challengeId, 'c1');
      expect(ci.participantId, 'p1');
      expect(ci.workoutLogId, 'w1');
      expect(ci.value, 1);
    });

    test('value 默认为 1', () {
      final json = baseCheckInJson();
      json.remove('value');
      final ci = ChallengeCheckInModel.fromJson(json);
      expect(ci.value, 1);
    });

    test('自定义 value', () {
      final json = baseCheckInJson(value: 5);
      final ci = ChallengeCheckInModel.fromJson(json);
      expect(ci.value, 5);
    });
  });

  group('ChallengeCheckInModel - toJson', () {
    test('包含必要字段且不含 created_at', () {
      final ci = ChallengeCheckInModel.fromJson(baseCheckInJson());
      final json = ci.toJson();

      expect(json['id'], 'ci1');
      expect(json['challenge_id'], 'c1');
      expect(json['participant_id'], 'p1');
      expect(json['workout_log_id'], 'w1');
      expect(json['value'], 1);
      expect(json.containsKey('created_at'), false);
    });
  });

  // -------------------------------------------------------
  // ChallengeModel fromJson/toJson 往返一致性
  // -------------------------------------------------------

  group('ChallengeModel - 往返一致性', () {
    test('fromJson → toJson → fromJson 关键字段一致', () {
      final original = ChallengeModel.fromJson(baseChallengeJson(
        city: '上海',
        metricsRules: {'min_duration': 20},
      ));
      final json = original.toJson();
      // 补充 toJson 不含的只读字段
      json['created_at'] = original.createdAt.toIso8601String();
      json['updated_at'] = original.updatedAt.toIso8601String();
      json['participant_count'] = original.participantCount;

      final restored = ChallengeModel.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.sportType, original.sportType);
      expect(restored.goalType, original.goalType);
      expect(restored.goalValue, original.goalValue);
      expect(restored.city, original.city);
      expect(restored.metricsRules, original.metricsRules);
    });
  });
}
