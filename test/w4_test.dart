import 'package:flutter_test/flutter_test.dart';

import 'package:verveforge/features/gym/domain/gym_model.dart';
import 'package:verveforge/features/gym/domain/gym_review_model.dart';

void main() {
  // ===========================================
  // GymModel 测试
  // ===========================================
  group('GymModel', () {
    final now = DateTime.now();
    final sampleJson = {
      'id': 'gym-123',
      'name': 'CrossFit BOX 上海',
      'description': '上海最好的 CrossFit 训练馆',
      'address': '上海市浦东新区世纪大道 100 号',
      'city': 'shanghai',
      'latitude': 31.2304,
      'longitude': 121.4737,
      'phone': '021-12345678',
      'website': 'https://crossfitbox.sh',
      'opening_hours': '06:00-22:00',
      'sport_types': ['crossfit', 'strength', 'hyrox'],
      'photo_urls': ['https://example.com/gym1.jpg', 'https://example.com/gym2.jpg'],
      'rating': 4.5,
      'review_count': 28,
      'status': 'verified',
      'submitted_by': 'user-456',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
      'distance_km': 1.23,
    };

    test('fromJson 正确解析所有字段', () {
      final gym = GymModel.fromJson(sampleJson);
      expect(gym.id, 'gym-123');
      expect(gym.name, 'CrossFit BOX 上海');
      expect(gym.description, '上海最好的 CrossFit 训练馆');
      expect(gym.address, '上海市浦东新区世纪大道 100 号');
      expect(gym.city, 'shanghai');
      expect(gym.latitude, 31.2304);
      expect(gym.longitude, 121.4737);
      expect(gym.phone, '021-12345678');
      expect(gym.website, 'https://crossfitbox.sh');
      expect(gym.openingHours, '06:00-22:00');
      expect(gym.sportTypes, ['crossfit', 'strength', 'hyrox']);
      expect(gym.photoUrls.length, 2);
      expect(gym.rating, 4.5);
      expect(gym.reviewCount, 28);
      expect(gym.status, 'verified');
      expect(gym.submittedBy, 'user-456');
      expect(gym.distanceKm, 1.23);
      expect(gym.isVerified, isTrue);
    });

    test('fromJson 缺失字段使用默认值', () {
      final minimalJson = {
        'id': 'gym-min',
        'name': '测试馆',
        'address': '地址',
        'city': 'beijing',
        'latitude': 39.9,
        'longitude': 116.4,
        'submitted_by': 'user-1',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };
      final gym = GymModel.fromJson(minimalJson);
      expect(gym.description, isNull);
      expect(gym.phone, isNull);
      expect(gym.website, isNull);
      expect(gym.openingHours, isNull);
      expect(gym.sportTypes, isEmpty);
      expect(gym.photoUrls, isEmpty);
      expect(gym.rating, 0.0);
      expect(gym.reviewCount, 0);
      expect(gym.status, 'pending');
      expect(gym.distanceKm, isNull);
      expect(gym.isVerified, isFalse);
    });

    test('toJson 输出正确结构', () {
      final gym = GymModel.fromJson(sampleJson);
      final json = gym.toJson();
      expect(json['id'], 'gym-123');
      expect(json['name'], 'CrossFit BOX 上海');
      expect(json['address'], '上海市浦东新区世纪大道 100 号');
      expect(json['city'], 'shanghai');
      expect(json['latitude'], 31.2304);
      expect(json['longitude'], 121.4737);
      expect(json['sport_types'], hasLength(3));
      expect(json['submitted_by'], 'user-456');
      // toJson 不含时间戳和计算字段
      expect(json.containsKey('created_at'), isFalse);
      expect(json.containsKey('updated_at'), isFalse);
      expect(json.containsKey('rating'), isFalse);
      expect(json.containsKey('review_count'), isFalse);
      expect(json.containsKey('status'), isFalse);
      expect(json.containsKey('distance_km'), isFalse);
    });

    test('copyWith 正确覆盖字段', () {
      final gym = GymModel.fromJson(sampleJson);
      final updated = gym.copyWith(
        name: '新名称',
        rating: 4.8,
        reviewCount: 35,
        status: 'pending',
        distanceKm: 2.5,
      );
      expect(updated.name, '新名称');
      expect(updated.rating, 4.8);
      expect(updated.reviewCount, 35);
      expect(updated.status, 'pending');
      expect(updated.distanceKm, 2.5);
      // 未修改字段保持不变
      expect(updated.id, 'gym-123');
      expect(updated.address, '上海市浦东新区世纪大道 100 号');
      expect(updated.city, 'shanghai');
      expect(updated.sportTypes.length, 3);
    });

    test('ratingDisplay 有评价时显示分数', () {
      final gym = GymModel.fromJson(sampleJson);
      expect(gym.ratingDisplay, '4.5');
    });

    test('ratingDisplay 无评价时显示 -', () {
      final json = Map<String, dynamic>.from(sampleJson);
      json['review_count'] = 0;
      final gym = GymModel.fromJson(json);
      expect(gym.ratingDisplay, '-');
    });

    test('distanceDisplay 小于 1km 显示米', () {
      final json = Map<String, dynamic>.from(sampleJson);
      json['distance_km'] = 0.8;
      final gym = GymModel.fromJson(json);
      expect(gym.distanceDisplay, '800m');
    });

    test('distanceDisplay 大于 1km 显示公里', () {
      final gym = GymModel.fromJson(sampleJson);
      expect(gym.distanceDisplay, '1.2km');
    });

    test('distanceDisplay 无距离返回空字符串', () {
      final json = Map<String, dynamic>.from(sampleJson);
      json.remove('distance_km');
      final gym = GymModel.fromJson(json);
      expect(gym.distanceDisplay, '');
    });

    test('distanceDisplay 0.35km 显示 350m', () {
      final json = Map<String, dynamic>.from(sampleJson);
      json['distance_km'] = 0.35;
      final gym = GymModel.fromJson(json);
      expect(gym.distanceDisplay, '350m');
    });

    test('distanceDisplay 恰好 1.0km', () {
      final json = Map<String, dynamic>.from(sampleJson);
      json['distance_km'] = 1.0;
      final gym = GymModel.fromJson(json);
      expect(gym.distanceDisplay, '1.0km');
    });

    test('statusLabel 各状态映射', () {
      final statuses = {
        'verified': '已认证',
        'rejected': '已拒绝',
        'pending': '待审核',
        'unknown': '待审核', // 未知状态默认
      };
      for (final entry in statuses.entries) {
        final json = Map<String, dynamic>.from(sampleJson);
        json['status'] = entry.key;
        final gym = GymModel.fromJson(json);
        expect(gym.statusLabel, entry.value,
            reason: 'status "${entry.key}" should display "${entry.value}"');
      }
    });

    test('isVerified 反映 status', () {
      final json = Map<String, dynamic>.from(sampleJson);
      json['status'] = 'verified';
      expect(GymModel.fromJson(json).isVerified, isTrue);

      json['status'] = 'pending';
      expect(GymModel.fromJson(json).isVerified, isFalse);

      json['status'] = 'rejected';
      expect(GymModel.fromJson(json).isVerified, isFalse);
    });

    test('fromJson latitude/longitude 支持 int 类型', () {
      final json = Map<String, dynamic>.from(sampleJson);
      json['latitude'] = 31;
      json['longitude'] = 121;
      final gym = GymModel.fromJson(json);
      expect(gym.latitude, 31.0);
      expect(gym.longitude, 121.0);
    });
  });

  // ===========================================
  // GymReviewModel 测试
  // ===========================================
  group('GymReviewModel', () {
    final now = DateTime.now();
    final sampleJson = {
      'id': 'review-123',
      'gym_id': 'gym-456',
      'user_id': 'user-789',
      'rating': 4,
      'content': '环境很好，教练专业',
      'photo_urls': ['https://example.com/r1.jpg'],
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    test('fromJson 正确解析所有字段', () {
      final review = GymReviewModel.fromJson(sampleJson);
      expect(review.id, 'review-123');
      expect(review.gymId, 'gym-456');
      expect(review.userId, 'user-789');
      expect(review.rating, 4);
      expect(review.content, '环境很好，教练专业');
      expect(review.photoUrls.length, 1);
    });

    test('fromJson 缺失字段使用默认值', () {
      final minimalJson = {
        'id': 'r-min',
        'gym_id': 'g-1',
        'user_id': 'u-1',
        'rating': 3,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };
      final review = GymReviewModel.fromJson(minimalJson);
      expect(review.content, isNull);
      expect(review.photoUrls, isEmpty);
    });

    test('toJson 输出正确结构', () {
      final review = GymReviewModel.fromJson(sampleJson);
      final json = review.toJson();
      expect(json['id'], 'review-123');
      expect(json['gym_id'], 'gym-456');
      expect(json['user_id'], 'user-789');
      expect(json['rating'], 4);
      expect(json['content'], '环境很好，教练专业');
      expect(json['photo_urls'], hasLength(1));
      // toJson 不含时间戳
      expect(json.containsKey('created_at'), isFalse);
      expect(json.containsKey('updated_at'), isFalse);
    });

    test('copyWith 正确覆盖字段', () {
      final review = GymReviewModel.fromJson(sampleJson);
      final updated = review.copyWith(
        rating: 5,
        content: '更新后的评价',
      );
      expect(updated.rating, 5);
      expect(updated.content, '更新后的评价');
      // 未修改字段保持不变
      expect(updated.id, 'review-123');
      expect(updated.gymId, 'gym-456');
      expect(updated.userId, 'user-789');
      expect(updated.photoUrls.length, 1);
    });

    test('copyWith 覆盖照片列表', () {
      final review = GymReviewModel.fromJson(sampleJson);
      final updated = review.copyWith(
        photoUrls: ['https://new.jpg', 'https://new2.jpg'],
      );
      expect(updated.photoUrls.length, 2);
      expect(updated.photoUrls.first, 'https://new.jpg');
    });

    test('rating 边界值 1-5', () {
      for (final r in [1, 2, 3, 4, 5]) {
        final json = Map<String, dynamic>.from(sampleJson);
        json['rating'] = r;
        final review = GymReviewModel.fromJson(json);
        expect(review.rating, r);
      }
    });
  });
}
