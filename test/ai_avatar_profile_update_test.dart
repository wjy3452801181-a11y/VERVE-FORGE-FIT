import 'package:flutter_test/flutter_test.dart';

import 'package:verveforge/features/ai_avatar/domain/ai_avatar_model.dart';


void main() {
  // ===========================================
  // AiAvatarModel 新增字段测试
  // ===========================================
  group('AiAvatarModel 画像字段', () {
    test('fitnessHabits 默认为空 Map', () {
      final avatar = AiAvatarModel(
        id: 'a1',
        userId: 'u1',
        name: '测试分身',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(avatar.fitnessHabits, isEmpty);
      expect(avatar.profileUpdatedAt, isNull);
    });

    test('fitnessHabits 可通过构造器赋值', () {
      final habits = {
        'preferred_sports': ['running', 'crossfit'],
        'avg_intensity': 7,
        'workout_frequency': '每周3-4次',
        'active_time': '早晨',
        'fitness_level': 'intermediate',
        'summary': '热爱晨跑的中级运动者',
      };
      final avatar = AiAvatarModel(
        id: 'a1',
        userId: 'u1',
        name: '测试分身',
        fitnessHabits: habits,
        profileUpdatedAt: DateTime(2026, 3, 9, 2, 0),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(avatar.fitnessHabits['preferred_sports'], ['running', 'crossfit']);
      expect(avatar.fitnessHabits['avg_intensity'], 7);
      expect(avatar.fitnessHabits['summary'], '热爱晨跑的中级运动者');
      expect(avatar.profileUpdatedAt, isNotNull);
    });

    test('fromJson 解析 fitness_habits 和 profile_updated_at', () {
      final json = {
        'id': 'a1',
        'user_id': 'u1',
        'name': '测试分身',
        'personality_traits': ['earlyRunner', 'gymRat'],
        'speaking_style': 'lively',
        'custom_prompt': '',
        'auto_reply_enabled': false,
        'ai_consent_at': '2026-03-01T10:00:00Z',
        'fitness_habits': {
          'preferred_sports': ['running'],
          'avg_intensity': 6,
          'workout_frequency': '每周5次',
          'active_time': '早晨',
          'fitness_level': 'advanced',
          'summary': '资深晨跑爱好者',
        },
        'profile_updated_at': '2026-03-09T02:00:00Z',
        'created_at': '2026-03-01T10:00:00Z',
        'updated_at': '2026-03-09T02:00:00Z',
      };
      final avatar = AiAvatarModel.fromJson(json);
      expect(avatar.fitnessHabits['preferred_sports'], ['running']);
      expect(avatar.fitnessHabits['avg_intensity'], 6);
      expect(avatar.fitnessHabits['summary'], '资深晨跑爱好者');
      expect(avatar.profileUpdatedAt, isNotNull);
      expect(avatar.profileUpdatedAt!.year, 2026);
      expect(avatar.profileUpdatedAt!.month, 3);
      expect(avatar.profileUpdatedAt!.day, 9);
    });

    test('fromJson fitness_habits 为 null 时默认空 Map', () {
      final json = {
        'id': 'a1',
        'user_id': 'u1',
        'name': '测试分身',
        'fitness_habits': null,
        'profile_updated_at': null,
        'created_at': '2026-03-01T10:00:00Z',
        'updated_at': '2026-03-01T10:00:00Z',
      };
      final avatar = AiAvatarModel.fromJson(json);
      expect(avatar.fitnessHabits, isEmpty);
      expect(avatar.profileUpdatedAt, isNull);
    });

    test('fromJson 缺少 fitness_habits 字段时默认空 Map', () {
      final json = {
        'id': 'a1',
        'user_id': 'u1',
        'name': '测试分身',
        'created_at': '2026-03-01T10:00:00Z',
        'updated_at': '2026-03-01T10:00:00Z',
      };
      final avatar = AiAvatarModel.fromJson(json);
      expect(avatar.fitnessHabits, isEmpty);
      expect(avatar.profileUpdatedAt, isNull);
    });
  });

  // ===========================================
  // copyWith 画像字段测试
  // ===========================================
  group('AiAvatarModel copyWith 画像字段', () {
    late AiAvatarModel baseAvatar;

    setUp(() {
      baseAvatar = AiAvatarModel(
        id: 'a1',
        userId: 'u1',
        name: '原始分身',
        personalityTraits: const ['earlyRunner'],
        speakingStyle: 'friendly',
        createdAt: DateTime(2026, 3, 1),
        updatedAt: DateTime(2026, 3, 1),
      );
    });

    test('copyWith 更新 fitnessHabits', () {
      final habits = {'summary': '新习惯摘要', 'avg_intensity': 8};
      final updated = baseAvatar.copyWith(fitnessHabits: habits);
      expect(updated.fitnessHabits['summary'], '新习惯摘要');
      expect(updated.fitnessHabits['avg_intensity'], 8);
      // 其余字段不变
      expect(updated.name, '原始分身');
      expect(updated.personalityTraits, ['earlyRunner']);
    });

    test('copyWith 更新 profileUpdatedAt', () {
      final newTime = DateTime(2026, 3, 9, 2, 0);
      final updated = baseAvatar.copyWith(profileUpdatedAt: newTime);
      expect(updated.profileUpdatedAt, newTime);
      expect(updated.name, '原始分身');
    });

    test('copyWith 不传 fitnessHabits 保持原值', () {
      final withHabits = baseAvatar.copyWith(
        fitnessHabits: {'summary': '已有习惯'},
      );
      final updated = withHabits.copyWith(name: '新名称');
      expect(updated.name, '新名称');
      expect(updated.fitnessHabits['summary'], '已有习惯');
    });

    test('copyWith 同时更新 traits + style + habits', () {
      final updated = baseAvatar.copyWith(
        personalityTraits: ['gymRat', 'marathoner'],
        speakingStyle: 'humorous',
        fitnessHabits: {
          'preferred_sports': ['running', 'swimming'],
          'fitness_level': 'elite',
        },
        profileUpdatedAt: DateTime(2026, 3, 10),
      );
      expect(updated.personalityTraits, ['gymRat', 'marathoner']);
      expect(updated.speakingStyle, 'humorous');
      expect(updated.fitnessHabits['preferred_sports'],
          ['running', 'swimming']);
      expect(updated.fitnessHabits['fitness_level'], 'elite');
      expect(updated.profileUpdatedAt!.day, 10);
    });
  });

  // ===========================================
  // 画像更新 PIPL 合规测试
  // ===========================================
  group('画像更新 PIPL 合规条件', () {
    test('ai_consent_at=null 时不应允许画像更新', () {
      final avatar = AiAvatarModel(
        id: 'a1',
        userId: 'u1',
        name: '未授权分身',
        autoReplyEnabled: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      // 模拟 refreshAvatarProfile 的 PIPL 检查逻辑
      final canRefresh = avatar.aiConsentAt != null;
      expect(canRefresh, isFalse);
    });

    test('ai_consent_at 有值时允许画像更新', () {
      final avatar = AiAvatarModel(
        id: 'a1',
        userId: 'u1',
        name: '已授权分身',
        aiConsentAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final canRefresh = avatar.aiConsentAt != null;
      expect(canRefresh, isTrue);
    });
  });

  // ===========================================
  // 训练模式消息计数触发阈值测试
  // ===========================================
  group('训练模式消息计数触发', () {
    // 模拟 chat_page 中 _sessionMessageCount 和 _profileRefreshThreshold 逻辑
    const profileRefreshThreshold = 5;

    test('发送不足阈值条数不触发更新', () {
      int sessionMessageCount = 0;
      bool triggered = false;

      for (int i = 0; i < 4; i++) {
        sessionMessageCount++;
        if (sessionMessageCount >= profileRefreshThreshold) {
          sessionMessageCount = 0;
          triggered = true;
        }
      }
      expect(triggered, isFalse);
      expect(sessionMessageCount, 4);
    });

    test('发送恰好阈值条数触发一次更新', () {
      int sessionMessageCount = 0;
      int triggerCount = 0;

      for (int i = 0; i < 5; i++) {
        sessionMessageCount++;
        if (sessionMessageCount >= profileRefreshThreshold) {
          sessionMessageCount = 0;
          triggerCount++;
        }
      }
      expect(triggerCount, 1);
      expect(sessionMessageCount, 0); // 计数器已重置
    });

    test('发送 12 条触发两次更新', () {
      int sessionMessageCount = 0;
      int triggerCount = 0;

      for (int i = 0; i < 12; i++) {
        sessionMessageCount++;
        if (sessionMessageCount >= profileRefreshThreshold) {
          sessionMessageCount = 0;
          triggerCount++;
        }
      }
      expect(triggerCount, 2);
      expect(sessionMessageCount, 2); // 12 = 5+5+2，剩余 2
    });

    test('发送 25 条触发五次更新', () {
      int sessionMessageCount = 0;
      int triggerCount = 0;

      for (int i = 0; i < 25; i++) {
        sessionMessageCount++;
        if (sessionMessageCount >= profileRefreshThreshold) {
          sessionMessageCount = 0;
          triggerCount++;
        }
      }
      expect(triggerCount, 5);
      expect(sessionMessageCount, 0); // 25 = 5*5，恰好整除
    });

    test('计数器在触发后正确重置', () {
      int sessionMessageCount = 0;

      // 第一轮：发 5 条触发
      for (int i = 0; i < 5; i++) {
        sessionMessageCount++;
      }
      expect(sessionMessageCount >= profileRefreshThreshold, isTrue);
      sessionMessageCount = 0;
      expect(sessionMessageCount, 0);

      // 第二轮：再发 3 条不触发
      for (int i = 0; i < 3; i++) {
        sessionMessageCount++;
      }
      expect(sessionMessageCount >= profileRefreshThreshold, isFalse);
      expect(sessionMessageCount, 3);
    });
  });

  // ===========================================
  // fitness_habits 数据结构校验测试
  // ===========================================
  group('fitness_habits 数据结构校验', () {
    test('完整 fitness_habits 结构包含所有预期字段', () {
      final habits = <String, dynamic>{
        'preferred_sports': ['running', 'crossfit', 'swimming'],
        'avg_intensity': 7,
        'workout_frequency': '每周3-4次',
        'active_time': '早晨',
        'fitness_level': 'intermediate',
        'summary': '热爱晨跑和CrossFit的中级运动者',
      };

      expect(habits['preferred_sports'], isList);
      expect((habits['preferred_sports'] as List).length, 3);
      expect(habits['avg_intensity'], isA<int>());
      expect((habits['avg_intensity'] as int) >= 1, isTrue);
      expect((habits['avg_intensity'] as int) <= 10, isTrue);
      expect(habits['workout_frequency'], isA<String>());
      expect(habits['active_time'], isA<String>());
      expect(habits['fitness_level'], isA<String>());
      expect(
        ['beginner', 'intermediate', 'advanced', 'elite']
            .contains(habits['fitness_level']),
        isTrue,
      );
      expect(habits['summary'], isA<String>());
      expect((habits['summary'] as String).length, lessThanOrEqualTo(50));
    });

    test('空 fitness_habits 不影响模型构建', () {
      final avatar = AiAvatarModel(
        id: 'a1',
        userId: 'u1',
        name: '分身',
        fitnessHabits: const {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(avatar.fitnessHabits, isEmpty);
      // summary 不存在时安全访问
      expect(avatar.fitnessHabits['summary'], isNull);
    });

    test('fitness_habits 仅含 summary 时其他字段可选', () {
      final habits = <String, dynamic>{
        'summary': '刚开始运动的新手',
      };
      final avatar = AiAvatarModel(
        id: 'a1',
        userId: 'u1',
        name: '分身',
        fitnessHabits: habits,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(avatar.fitnessHabits['summary'], '刚开始运动的新手');
      expect(avatar.fitnessHabits['preferred_sports'], isNull);
      expect(avatar.fitnessHabits['avg_intensity'], isNull);
    });

    test('fitness_level 枚举校验', () {
      const validLevels = ['beginner', 'intermediate', 'advanced', 'elite'];
      for (final level in validLevels) {
        expect(validLevels.contains(level), isTrue);
      }
      expect(validLevels.contains('master'), isFalse);
      expect(validLevels.contains(''), isFalse);
    });

    test('avg_intensity 范围校验 (1-10)', () {
      for (int i = 1; i <= 10; i++) {
        expect(i >= 1 && i <= 10, isTrue);
      }
      expect(0 >= 1, isFalse);
      expect(11 <= 10, isFalse);
    });
  });

  // ===========================================
  // Edge Function 有效 traits/style 白名单校验测试
  // ===========================================
  group('AI 分析结果白名单校验', () {
    // 模拟 Edge Function 中的白名单过滤逻辑
    const validTraits = AiAvatarModel.availableTraits;
    final validStyles = [
      'lively', 'steady', 'humorous',
      'friendly', 'professional', 'encouraging',
    ];

    test('有效 traits 全部通过白名单', () {
      final aiResult = ['earlyRunner', 'gymRat', 'marathoner'];
      final filtered =
          aiResult.where((t) => validTraits.contains(t)).toList();
      expect(filtered, aiResult);
    });

    test('无效 traits 被过滤', () {
      final aiResult = ['earlyRunner', 'invalidTrait', 'gymRat', 'fakeTrait'];
      final filtered =
          aiResult.where((t) => validTraits.contains(t)).toList();
      expect(filtered, ['earlyRunner', 'gymRat']);
      expect(filtered.length, 2);
    });

    test('全部无效 traits 返回空列表', () {
      final aiResult = ['fake1', 'fake2', 'fake3'];
      final filtered =
          aiResult.where((t) => validTraits.contains(t)).toList();
      expect(filtered, isEmpty);
    });

    test('超过 5 个 traits 截断为 5', () {
      final aiResult = [
        'earlyRunner', 'gymRat', 'marathoner',
        'yogaMaster', 'ironAddict', 'crossfitFanatic', 'techGeek',
      ];
      final filtered = aiResult
          .where((t) => validTraits.contains(t))
          .take(5)
          .toList();
      expect(filtered.length, 5);
    });

    test('有效 style 通过白名单', () {
      for (final style in validStyles) {
        expect(validStyles.contains(style), isTrue);
      }
    });

    test('无效 style 回退为原值', () {
      const currentStyle = 'friendly';
      const aiStyle = 'aggressive'; // 不在白名单
      final result =
          validStyles.contains(aiStyle) ? aiStyle : currentStyle;
      expect(result, 'friendly'); // 保持原值
    });

    test('有效 style 替换原值', () {
      const currentStyle = 'friendly';
      const aiStyle = 'humorous'; // 在白名单
      final result =
          validStyles.contains(aiStyle) ? aiStyle : currentStyle;
      expect(result, 'humorous'); // 更新为新值
    });
  });

  // ===========================================
  // profileUpdatedAt 时间戳逻辑测试
  // ===========================================
  group('profileUpdatedAt 时间戳', () {
    test('新建分身 profileUpdatedAt 为 null', () {
      final avatar = AiAvatarModel(
        id: 'a1',
        userId: 'u1',
        name: '新分身',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(avatar.profileUpdatedAt, isNull);
    });

    test('更新后 profileUpdatedAt 有值', () {
      final now = DateTime(2026, 3, 9, 2, 0);
      final avatar = AiAvatarModel(
        id: 'a1',
        userId: 'u1',
        name: '已更新分身',
        profileUpdatedAt: now,
        createdAt: DateTime(2026, 3, 1),
        updatedAt: DateTime(2026, 3, 9),
      );
      expect(avatar.profileUpdatedAt, now);
      expect(avatar.profileUpdatedAt!.hour, 2);
      expect(avatar.profileUpdatedAt!.minute, 0);
    });

    test('profileUpdatedAt 可通过 copyWith 设置', () {
      final avatar = AiAvatarModel(
        id: 'a1',
        userId: 'u1',
        name: '分身',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(avatar.profileUpdatedAt, isNull);

      final time = DateTime(2026, 3, 9, 14, 30);
      final updated = avatar.copyWith(profileUpdatedAt: time);
      expect(updated.profileUpdatedAt, time);
    });

    test('profileUpdatedAt 从 JSON 正确解析时区', () {
      final json = {
        'id': 'a1',
        'user_id': 'u1',
        'name': '分身',
        'profile_updated_at': '2026-03-09T18:00:00Z', // UTC 18:00 = 北京时间 02:00
        'created_at': '2026-03-01T10:00:00Z',
        'updated_at': '2026-03-09T18:00:00Z',
      };
      final avatar = AiAvatarModel.fromJson(json);
      expect(avatar.profileUpdatedAt, isNotNull);
      expect(avatar.profileUpdatedAt!.isUtc, isTrue);
      expect(avatar.profileUpdatedAt!.hour, 18); // UTC
    });
  });
}
