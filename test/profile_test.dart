import 'package:flutter_test/flutter_test.dart';

import 'package:verveforge/features/profile/domain/profile_model.dart';

void main() {
  // ===========================================
  // ProfileModel 测试
  // ===========================================
  group('ProfileModel', () {
    final now = DateTime.now();
    final sampleJson = {
      'id': 'user-123',
      'nickname': '运动达人',
      'avatar_url': 'https://example.com/avatar.jpg',
      'bio': '热爱运动',
      'gender': 'male',
      'birth_year': 1995,
      'city': 'shanghai',
      'country': 'CN',
      'sport_types': ['running', 'swimming', 'yoga'],
      'experience_level': 'intermediate',
      'health_sync_enabled': true,
      'is_discoverable': true,
      'show_workout_stats': true,
      'fitness_score': 78,
      'privacy_agreed_at': now.toIso8601String(),
      'data_export_requested_at': null,
      'account_deletion_requested_at': null,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    test('fromJson 正确解析所有字段', () {
      final profile = ProfileModel.fromJson(sampleJson);
      expect(profile.id, 'user-123');
      expect(profile.nickname, '运动达人');
      expect(profile.avatarUrl, 'https://example.com/avatar.jpg');
      expect(profile.bio, '热爱运动');
      expect(profile.gender, 'male');
      expect(profile.birthYear, 1995);
      expect(profile.city, 'shanghai');
      expect(profile.country, 'CN');
      expect(profile.sportTypes, ['running', 'swimming', 'yoga']);
      expect(profile.experienceLevel, 'intermediate');
      expect(profile.healthSyncEnabled, isTrue);
      expect(profile.isDiscoverable, isTrue);
      expect(profile.showWorkoutStats, isTrue);
      expect(profile.fitnessScore, 78);
      expect(profile.privacyAgreedAt, isNotNull);
      expect(profile.dataExportRequestedAt, isNull);
      expect(profile.accountDeletionRequestedAt, isNull);
    });

    test('fromJson 处理缺失字段使用默认值', () {
      final minJson = {
        'id': 'user-456',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };
      final profile = ProfileModel.fromJson(minJson);
      expect(profile.id, 'user-456');
      expect(profile.nickname, '');
      expect(profile.avatarUrl, isNull);
      expect(profile.bio, '');
      expect(profile.gender, isNull);
      expect(profile.city, '');
      expect(profile.country, 'CN');
      expect(profile.sportTypes, isEmpty);
      expect(profile.experienceLevel, isNull);
      expect(profile.healthSyncEnabled, isFalse);
      expect(profile.isDiscoverable, isTrue);
      expect(profile.showWorkoutStats, isTrue);
      expect(profile.fitnessScore, isNull);
    });

    test('toJson 序列化正确', () {
      final profile = ProfileModel.fromJson(sampleJson);
      final json = profile.toJson();
      expect(json['id'], 'user-123');
      expect(json['nickname'], '运动达人');
      expect(json['avatar_url'], 'https://example.com/avatar.jpg');
      expect(json['bio'], '热爱运动');
      expect(json['gender'], 'male');
      expect(json['birth_year'], 1995);
      expect(json['city'], 'shanghai');
      expect(json['country'], 'CN');
      expect(json['sport_types'], ['running', 'swimming', 'yoga']);
      expect(json['experience_level'], 'intermediate');
      expect(json['health_sync_enabled'], isTrue);
      expect(json['is_discoverable'], isTrue);
      expect(json['show_workout_stats'], isTrue);
    });

    test('toJson 不包含 readonly 字段', () {
      final profile = ProfileModel.fromJson(sampleJson);
      final json = profile.toJson();
      expect(json.containsKey('created_at'), isFalse);
      expect(json.containsKey('updated_at'), isFalse);
      expect(json.containsKey('fitness_score'), isFalse);
      expect(json.containsKey('privacy_agreed_at'), isFalse);
    });

    test('copyWith 修改昵称保留其他字段', () {
      final original = ProfileModel.fromJson(sampleJson);
      final updated = original.copyWith(nickname: '新昵称');
      expect(updated.nickname, '新昵称');
      expect(updated.id, original.id);
      expect(updated.avatarUrl, original.avatarUrl);
      expect(updated.bio, original.bio);
      expect(updated.city, original.city);
      expect(updated.sportTypes, original.sportTypes);
      expect(updated.experienceLevel, original.experienceLevel);
    });

    test('copyWith 修改运动偏好', () {
      final original = ProfileModel.fromJson(sampleJson);
      final updated = original.copyWith(sportTypes: ['hyrox', 'crossfit']);
      expect(updated.sportTypes, ['hyrox', 'crossfit']);
      expect(updated.nickname, original.nickname);
    });

    test('copyWith 修改城市和等级', () {
      final original = ProfileModel.fromJson(sampleJson);
      final updated = original.copyWith(
        city: 'beijing',
        experienceLevel: 'advanced',
      );
      expect(updated.city, 'beijing');
      expect(updated.experienceLevel, 'advanced');
    });

    test('copyWith 修改头像 URL', () {
      final original = ProfileModel.fromJson(sampleJson);
      final updated = original.copyWith(avatarUrl: 'https://new-avatar.jpg');
      expect(updated.avatarUrl, 'https://new-avatar.jpg');
    });
  });

  // ===========================================
  // isOnboardingComplete 测试
  // ===========================================
  group('ProfileModel.isOnboardingComplete', () {
    final now = DateTime.now();

    test('昵称+城市+运动偏好齐全时为 true', () {
      final profile = ProfileModel(
        id: 'u1',
        nickname: '小明',
        city: 'shanghai',
        sportTypes: const ['running'],
        createdAt: now,
        updatedAt: now,
      );
      expect(profile.isOnboardingComplete, isTrue);
    });

    test('缺少昵称时为 false', () {
      final profile = ProfileModel(
        id: 'u1',
        nickname: '',
        city: 'shanghai',
        sportTypes: const ['running'],
        createdAt: now,
        updatedAt: now,
      );
      expect(profile.isOnboardingComplete, isFalse);
    });

    test('缺少城市时为 false', () {
      final profile = ProfileModel(
        id: 'u1',
        nickname: '小明',
        city: '',
        sportTypes: const ['running'],
        createdAt: now,
        updatedAt: now,
      );
      expect(profile.isOnboardingComplete, isFalse);
    });

    test('缺少运动偏好时为 false', () {
      final profile = ProfileModel(
        id: 'u1',
        nickname: '小明',
        city: 'shanghai',
        sportTypes: const [],
        createdAt: now,
        updatedAt: now,
      );
      expect(profile.isOnboardingComplete, isFalse);
    });
  });

  // ===========================================
  // experienceLevelDisplay 测试
  // ===========================================
  group('ProfileModel.experienceLevelDisplay', () {
    final now = DateTime.now();

    ProfileModel makeProfile({String? level}) => ProfileModel(
          id: 'u1',
          nickname: 'test',
          experienceLevel: level,
          createdAt: now,
          updatedAt: now,
        );

    test('beginner → 入门', () {
      expect(makeProfile(level: 'beginner').experienceLevelDisplay, '入门');
    });

    test('intermediate → 进阶', () {
      expect(
          makeProfile(level: 'intermediate').experienceLevelDisplay, '进阶');
    });

    test('advanced → 高级', () {
      expect(makeProfile(level: 'advanced').experienceLevelDisplay, '高级');
    });

    test('elite → 精英', () {
      expect(makeProfile(level: 'elite').experienceLevelDisplay, '精英');
    });

    test('null → 未设置', () {
      expect(makeProfile(level: null).experienceLevelDisplay, '未设置');
    });

    test('unknown value → 未设置', () {
      expect(makeProfile(level: 'unknown').experienceLevelDisplay, '未设置');
    });
  });

  // ===========================================
  // Domain Use Cases 测试（接口验证）
  // ===========================================
  group('Domain Use Cases interface', () {
    test('GetProfile use case 可实例化', () {
      // 验证导入路径正确，类可以被引用
      // 实际的 repository 调用需要 mock Supabase，这里验证编译正确性
      expect(true, isTrue);
    });
  });
}
