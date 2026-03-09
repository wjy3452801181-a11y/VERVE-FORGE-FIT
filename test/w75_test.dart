import 'package:flutter_test/flutter_test.dart';
import 'package:verveforge/features/gym/domain/user_gym_favorite_model.dart';
import 'package:verveforge/features/gym/domain/gym_claim_model.dart';

// ---------------------------------------------------------------------------
// 辅助工厂
// ---------------------------------------------------------------------------

Map<String, dynamic> baseFavoriteJson({
  String id = 'fav1',
  String userId = 'u1',
  String gymId = 'g1',
  Map<String, dynamic>? gymData,
}) {
  final json = <String, dynamic>{
    'id': id,
    'user_id': userId,
    'gym_id': gymId,
    'created_at': DateTime.now().toIso8601String(),
  };
  if (gymData != null) {
    json['gyms'] = gymData;
  }
  return json;
}

Map<String, dynamic> baseGymJoin({
  String name = '上海 CrossFit Box',
  String city = 'shanghai',
  String address = '上海市静安区南京西路1234号',
  List<String> photos = const ['https://example.com/p1.jpg'],
  List<String> sportTypes = const ['crossfit', 'strength'],
  double avgRating = 4.5,
  int reviewCount = 12,
}) {
  return {
    'name': name,
    'city': city,
    'address': address,
    'photos': photos,
    'sport_types': sportTypes,
    'avg_rating': avgRating,
    'review_count': reviewCount,
  };
}

Map<String, dynamic> baseClaimJson({
  String id = 'cl1',
  String gymId = 'g1',
  String claimantUserId = 'u1',
  String status = 'pending',
  String reason = '我是馆主',
  List<String> evidenceUrls = const [],
  String? reviewedBy,
  DateTime? reviewedAt,
}) {
  return {
    'id': id,
    'gym_id': gymId,
    'claimant_user_id': claimantUserId,
    'status': status,
    'reason': reason,
    'evidence_urls': evidenceUrls,
    'applied_at': DateTime.now().toIso8601String(),
    'reviewed_at': reviewedAt?.toIso8601String(),
    'reviewed_by': reviewedBy,
  };
}

// ---------------------------------------------------------------------------
// 测试
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------
  // UserGymFavoriteModel
  // -------------------------------------------------------

  group('UserGymFavoriteModel - fromJson', () {
    test('基础字段正确解析', () {
      final json = baseFavoriteJson();
      final f = UserGymFavoriteModel.fromJson(json);

      expect(f.id, 'fav1');
      expect(f.userId, 'u1');
      expect(f.gymId, 'g1');
      expect(f.createdAt, isA<DateTime>());
    });

    test('无 gyms JOIN 时扩展字段为空', () {
      final json = baseFavoriteJson();
      final f = UserGymFavoriteModel.fromJson(json);

      expect(f.gymName, isNull);
      expect(f.gymCity, isNull);
      expect(f.gymAddress, isNull);
      expect(f.gymPhotoUrls, isEmpty);
      expect(f.gymSportTypes, isEmpty);
      expect(f.gymRating, isNull);
      expect(f.gymReviewCount, isNull);
      expect(f.hasGymDetail, false);
    });

    test('带 gyms JOIN 时扩展字段正确填充', () {
      final json = baseFavoriteJson(gymData: baseGymJoin());
      final f = UserGymFavoriteModel.fromJson(json);

      expect(f.gymName, '上海 CrossFit Box');
      expect(f.gymCity, 'shanghai');
      expect(f.gymAddress, '上海市静安区南京西路1234号');
      expect(f.gymPhotoUrls, ['https://example.com/p1.jpg']);
      expect(f.gymSportTypes, ['crossfit', 'strength']);
      expect(f.gymRating, 4.5);
      expect(f.gymReviewCount, 12);
      expect(f.hasGymDetail, true);
    });

    test('gyms JOIN 中部分字段为 null', () {
      final json = baseFavoriteJson(gymData: {
        'name': '测试馆',
        'city': 'beijing',
        'address': '北京市朝阳区',
      });
      final f = UserGymFavoriteModel.fromJson(json);

      expect(f.gymName, '测试馆');
      expect(f.gymPhotoUrls, isEmpty);
      expect(f.gymSportTypes, isEmpty);
      expect(f.gymRating, isNull);
      expect(f.hasGymDetail, true);
    });
  });

  group('UserGymFavoriteModel - toJson', () {
    test('仅包含 user_id 和 gym_id', () {
      final f = UserGymFavoriteModel.fromJson(
        baseFavoriteJson(gymData: baseGymJoin()),
      );
      final json = f.toJson();

      expect(json['user_id'], 'u1');
      expect(json['gym_id'], 'g1');
      expect(json.length, 2);
      // 不应包含 JOIN 字段
      expect(json.containsKey('gyms'), false);
      expect(json.containsKey('id'), false);
    });
  });

  // -------------------------------------------------------
  // GymClaimModel
  // -------------------------------------------------------

  group('GymClaimModel - fromJson', () {
    test('基础字段正确解析', () {
      final json = baseClaimJson();
      final c = GymClaimModel.fromJson(json);

      expect(c.id, 'cl1');
      expect(c.gymId, 'g1');
      expect(c.claimantUserId, 'u1');
      expect(c.status, 'pending');
      expect(c.reason, '我是馆主');
      expect(c.evidenceUrls, isEmpty);
      expect(c.appliedAt, isA<DateTime>());
      expect(c.reviewedAt, isNull);
      expect(c.reviewedBy, isNull);
    });

    test('可选字段缺失时使用默认值', () {
      final json = baseClaimJson();
      json.remove('reason');
      json.remove('evidence_urls');
      json.remove('status');
      final c = GymClaimModel.fromJson(json);

      expect(c.reason, '');
      expect(c.evidenceUrls, isEmpty);
      expect(c.status, 'pending');
    });

    test('审核字段正确解析', () {
      final now = DateTime.now();
      final json = baseClaimJson(
        status: 'approved',
        reviewedBy: 'admin1',
        reviewedAt: now,
      );
      final c = GymClaimModel.fromJson(json);

      expect(c.status, 'approved');
      expect(c.reviewedBy, 'admin1');
      expect(c.reviewedAt, isNotNull);
    });

    test('evidence_urls 正确解析', () {
      final json = baseClaimJson(
        evidenceUrls: ['https://example.com/license.jpg'],
      );
      final c = GymClaimModel.fromJson(json);

      expect(c.evidenceUrls, ['https://example.com/license.jpg']);
    });
  });

  group('GymClaimModel - toJson', () {
    test('包含提交所需字段', () {
      final c = GymClaimModel.fromJson(baseClaimJson());
      final json = c.toJson();

      expect(json['gym_id'], 'g1');
      expect(json['claimant_user_id'], 'u1');
      expect(json['reason'], '我是馆主');
      expect(json['evidence_urls'], isEmpty);
      // 不应包含服务端字段
      expect(json.containsKey('id'), false);
      expect(json.containsKey('status'), false);
      expect(json.containsKey('applied_at'), false);
    });
  });

  group('GymClaimModel - copyWith', () {
    test('正确覆盖指定字段', () {
      final c = GymClaimModel.fromJson(baseClaimJson());
      final updated = c.copyWith(
        status: 'approved',
        reason: '更新理由',
        reviewedBy: 'admin1',
      );

      expect(updated.status, 'approved');
      expect(updated.reason, '更新理由');
      expect(updated.reviewedBy, 'admin1');
      // 未修改的字段保持不变
      expect(updated.id, c.id);
      expect(updated.gymId, c.gymId);
      expect(updated.claimantUserId, c.claimantUserId);
    });
  });

  group('GymClaimModel - 计算属性', () {
    test('isPending / isApproved / isRejected', () {
      final pending = GymClaimModel.fromJson(baseClaimJson(status: 'pending'));
      expect(pending.isPending, true);
      expect(pending.isApproved, false);
      expect(pending.isRejected, false);

      final approved =
          GymClaimModel.fromJson(baseClaimJson(status: 'approved'));
      expect(approved.isPending, false);
      expect(approved.isApproved, true);
      expect(approved.isRejected, false);

      final rejected =
          GymClaimModel.fromJson(baseClaimJson(status: 'rejected'));
      expect(rejected.isPending, false);
      expect(rejected.isApproved, false);
      expect(rejected.isRejected, true);
    });

    test('statusDisplay', () {
      expect(
        GymClaimModel.fromJson(baseClaimJson(status: 'pending')).statusDisplay,
        '审核中',
      );
      expect(
        GymClaimModel.fromJson(baseClaimJson(status: 'approved'))
            .statusDisplay,
        '已通过',
      );
      expect(
        GymClaimModel.fromJson(baseClaimJson(status: 'rejected'))
            .statusDisplay,
        '已拒绝',
      );
    });
  });

  // -------------------------------------------------------
  // 往返一致性
  // -------------------------------------------------------

  group('往返一致性', () {
    test('UserGymFavoriteModel toJson 包含正确插入字段', () {
      final original = UserGymFavoriteModel.fromJson(
        baseFavoriteJson(userId: 'u99', gymId: 'g99'),
      );
      final json = original.toJson();

      expect(json['user_id'], 'u99');
      expect(json['gym_id'], 'g99');
    });

    test('GymClaimModel fromJson → toJson → 补充字段 → fromJson 关键字段一致', () {
      final original = GymClaimModel.fromJson(baseClaimJson(
        reason: '我是创始人',
        evidenceUrls: ['https://example.com/a.jpg', 'https://example.com/b.jpg'],
      ));
      final json = original.toJson();
      // 补充 toJson 不含的只读字段
      json['id'] = original.id;
      json['status'] = original.status;
      json['applied_at'] = original.appliedAt.toIso8601String();

      final restored = GymClaimModel.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.gymId, original.gymId);
      expect(restored.claimantUserId, original.claimantUserId);
      expect(restored.reason, original.reason);
      expect(restored.evidenceUrls, original.evidenceUrls);
    });
  });
}
