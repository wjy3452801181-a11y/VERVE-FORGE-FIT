import 'package:flutter_test/flutter_test.dart';

import 'package:verveforge/features/profile/domain/profile_model.dart';
import 'package:verveforge/core/errors/app_exception.dart';

void main() {
  // ===========================================
  // ProfileModel 测试
  // ===========================================
  group('ProfileModel', () {
    final now = DateTime.now();
    final sampleJson = {
      'id': 'user-123',
      'nickname': '健身达人',
      'avatar_url': 'https://example.com/avatar.jpg',
      'bio': '热爱运动',
      'gender': 'male',
      'birth_year': 1990,
      'city': 'beijing',
      'country': 'CN',
      'sport_types': ['HYROX', 'CrossFit'],
      'experience_level': 'intermediate',
      'health_sync_enabled': true,
      'is_discoverable': true,
      'show_workout_stats': false,
      'fitness_score': 85,
      'privacy_agreed_at': now.toIso8601String(),
      'data_export_requested_at': null,
      'account_deletion_requested_at': null,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    test('fromJson 正确解析所有字段', () {
      final profile = ProfileModel.fromJson(sampleJson);
      expect(profile.id, 'user-123');
      expect(profile.nickname, '健身达人');
      expect(profile.avatarUrl, 'https://example.com/avatar.jpg');
      expect(profile.bio, '热爱运动');
      expect(profile.gender, 'male');
      expect(profile.birthYear, 1990);
      expect(profile.city, 'beijing');
      expect(profile.country, 'CN');
      expect(profile.sportTypes, ['HYROX', 'CrossFit']);
      expect(profile.experienceLevel, 'intermediate');
      expect(profile.healthSyncEnabled, isTrue);
      expect(profile.isDiscoverable, isTrue);
      expect(profile.showWorkoutStats, isFalse);
      expect(profile.fitnessScore, 85);
      expect(profile.privacyAgreedAt, isNotNull);
    });

    test('fromJson 缺失字段使用默认值', () {
      final minimalJson = {
        'id': 'user-456',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };
      final profile = ProfileModel.fromJson(minimalJson);
      expect(profile.nickname, '');
      expect(profile.avatarUrl, isNull);
      expect(profile.bio, '');
      expect(profile.city, '');
      expect(profile.country, 'CN');
      expect(profile.sportTypes, isEmpty);
      expect(profile.isDiscoverable, isTrue);
      expect(profile.showWorkoutStats, isTrue);
      expect(profile.healthSyncEnabled, isFalse);
    });

    test('toJson 输出正确结构', () {
      final profile = ProfileModel.fromJson(sampleJson);
      final json = profile.toJson();
      expect(json['id'], 'user-123');
      expect(json['nickname'], '健身达人');
      expect(json['avatar_url'], 'https://example.com/avatar.jpg');
      expect(json['sport_types'], ['HYROX', 'CrossFit']);
      expect(json['is_discoverable'], isTrue);
      // toJson 不输出时间戳字段
      expect(json.containsKey('created_at'), isFalse);
      expect(json.containsKey('updated_at'), isFalse);
    });

    test('copyWith 正确覆盖字段', () {
      final profile = ProfileModel.fromJson(sampleJson);
      final updated = profile.copyWith(
        nickname: '新昵称',
        city: 'shanghai',
        sportTypes: ['Yoga'],
      );
      expect(updated.nickname, '新昵称');
      expect(updated.city, 'shanghai');
      expect(updated.sportTypes, ['Yoga']);
      // 未修改字段保持不变
      expect(updated.id, 'user-123');
      expect(updated.bio, '热爱运动');
      expect(updated.gender, 'male');
    });

    test('isOnboardingComplete 完整时返回 true', () {
      final profile = ProfileModel.fromJson(sampleJson);
      expect(profile.isOnboardingComplete, isTrue);
    });

    test('isOnboardingComplete 缺少昵称返回 false', () {
      final json = Map<String, dynamic>.from(sampleJson);
      json['nickname'] = '';
      final profile = ProfileModel.fromJson(json);
      expect(profile.isOnboardingComplete, isFalse);
    });

    test('isOnboardingComplete 缺少城市返回 false', () {
      final json = Map<String, dynamic>.from(sampleJson);
      json['city'] = '';
      final profile = ProfileModel.fromJson(json);
      expect(profile.isOnboardingComplete, isFalse);
    });

    test('isOnboardingComplete 缺少运动偏好返回 false', () {
      final json = Map<String, dynamic>.from(sampleJson);
      json['sport_types'] = [];
      final profile = ProfileModel.fromJson(json);
      expect(profile.isOnboardingComplete, isFalse);
    });

    test('experienceLevelDisplay 正确映射', () {
      final levels = {
        'beginner': '入门',
        'intermediate': '进阶',
        'advanced': '高级',
        'elite': '精英',
        null: '未设置',
      };
      for (final entry in levels.entries) {
        final json = Map<String, dynamic>.from(sampleJson);
        json['experience_level'] = entry.key;
        final profile = ProfileModel.fromJson(json);
        expect(profile.experienceLevelDisplay, entry.value);
      }
    });
  });

  // ===========================================
  // AppException 测试
  // ===========================================
  group('AppException', () {
    test('AppException 包含消息', () {
      const error = AppException(message: '操作失败');
      expect(error.message, '操作失败');
      expect(error.code, isNull);
      expect(error.toString(), contains('操作失败'));
    });

    test('AppAuthException 是 AppException 子类', () {
      const error = AppAuthException(message: '未登录');
      expect(error, isA<AppException>());
      expect(error.message, '未登录');
    });

    test('NetworkException 是 AppException 子类', () {
      const error = NetworkException(message: '网络错误');
      expect(error, isA<AppException>());
      expect(error.message, '网络错误');
    });

    test('StorageException 是 AppException 子类', () {
      const error = StorageException(message: '上传失败');
      expect(error, isA<AppException>());
      expect(error.message, '上传失败');
    });

    test('ValidationException 包含字段错误', () {
      const error = ValidationException(
        message: '验证失败',
        fieldErrors: {'nickname': '太长'},
      );
      expect(error, isA<AppException>());
      expect(error.fieldErrors?['nickname'], '太长');
    });
  });
}
