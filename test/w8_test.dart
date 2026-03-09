import 'package:flutter_test/flutter_test.dart';
import 'package:verveforge/features/post/domain/post_model.dart';
import 'package:verveforge/features/post/domain/post_comment_model.dart';

// ---------------------------------------------------------------------------
// 辅助工厂
// ---------------------------------------------------------------------------

Map<String, dynamic> basePostJson({
  String id = 'p1',
  String userId = 'u1',
  String content = '今天练了 HYROX 模拟赛，感觉很好！',
  List<String> photos = const ['https://example.com/photo1.jpg'],
  String? workoutLogId,
  String? gymId,
  String? challengeId,
  String? city = 'shanghai',
  int likeCount = 5,
  int commentCount = 2,
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? deletedAt,
  Map<String, dynamic>? profile,
  bool? isLiked,
}) {
  final now = DateTime.now();
  final json = <String, dynamic>{
    'id': id,
    'user_id': userId,
    'content': content,
    'photos': photos,
    'workout_log_id': workoutLogId,
    'gym_id': gymId,
    'challenge_id': challengeId,
    'city': city,
    'like_count': likeCount,
    'comment_count': commentCount,
    'created_at': (createdAt ?? now).toIso8601String(),
    'updated_at': (updatedAt ?? now).toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
    'is_liked': isLiked,
  };
  if (profile != null) {
    json['profiles'] = profile;
  }
  return json;
}

Map<String, dynamic> baseCommentJson({
  String id = 'c1',
  String postId = 'p1',
  String userId = 'u2',
  String content = '太厉害了！',
  String? parentId,
  DateTime? createdAt,
  DateTime? updatedAt,
  Map<String, dynamic>? profile,
}) {
  final now = DateTime.now();
  final json = <String, dynamic>{
    'id': id,
    'post_id': postId,
    'user_id': userId,
    'content': content,
    'parent_id': parentId,
    'created_at': (createdAt ?? now).toIso8601String(),
    'updated_at': (updatedAt ?? now).toIso8601String(),
  };
  if (profile != null) {
    json['profiles'] = profile;
  }
  return json;
}

// ---------------------------------------------------------------------------
// 测试
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------
  // PostModel - fromJson
  // -------------------------------------------------------

  group('PostModel - fromJson', () {
    test('基础字段正确解析', () {
      final json = basePostJson();
      final p = PostModel.fromJson(json);

      expect(p.id, 'p1');
      expect(p.userId, 'u1');
      expect(p.content, '今天练了 HYROX 模拟赛，感觉很好！');
      expect(p.photos, ['https://example.com/photo1.jpg']);
      expect(p.city, 'shanghai');
      expect(p.likeCount, 5);
      expect(p.commentCount, 2);
      expect(p.createdAt, isA<DateTime>());
      expect(p.updatedAt, isA<DateTime>());
    });

    test('可选关联字段缺失时为 null', () {
      final json = basePostJson();
      final p = PostModel.fromJson(json);

      expect(p.workoutLogId, isNull);
      expect(p.gymId, isNull);
      expect(p.challengeId, isNull);
      expect(p.deletedAt, isNull);
    });

    test('可选关联字段正确解析', () {
      final json = basePostJson(
        workoutLogId: 'wl1',
        gymId: 'g1',
        challengeId: 'ch1',
      );
      final p = PostModel.fromJson(json);

      expect(p.workoutLogId, 'wl1');
      expect(p.gymId, 'g1');
      expect(p.challengeId, 'ch1');
    });

    test('profiles JOIN 正确填充作者信息', () {
      final json = basePostJson(profile: {
        'nickname': '健身达人',
        'avatar_url': 'https://example.com/avatar.jpg',
      });
      final p = PostModel.fromJson(json);

      expect(p.authorNickname, '健身达人');
      expect(p.authorAvatar, 'https://example.com/avatar.jpg');
    });

    test('无 profiles JOIN 时作者信息为 null', () {
      final json = basePostJson();
      final p = PostModel.fromJson(json);

      expect(p.authorNickname, isNull);
      expect(p.authorAvatar, isNull);
    });

    test('photos 为 null 时默认空列表', () {
      final json = basePostJson();
      json['photos'] = null;
      final p = PostModel.fromJson(json);

      expect(p.photos, isEmpty);
    });

    test('content 为 null 时默认空字符串', () {
      final json = basePostJson();
      json['content'] = null;
      final p = PostModel.fromJson(json);

      expect(p.content, '');
    });

    test('like_count / comment_count 为 null 时默认 0', () {
      final json = basePostJson();
      json['like_count'] = null;
      json['comment_count'] = null;
      final p = PostModel.fromJson(json);

      expect(p.likeCount, 0);
      expect(p.commentCount, 0);
    });

    test('isLiked 字段正确解析', () {
      final liked = PostModel.fromJson(basePostJson(isLiked: true));
      expect(liked.isLiked, true);

      final notLiked = PostModel.fromJson(basePostJson(isLiked: false));
      expect(notLiked.isLiked, false);

      final unknown = PostModel.fromJson(basePostJson());
      expect(unknown.isLiked, isNull);
    });

    test('deletedAt 正确解析', () {
      final now = DateTime.now();
      final json = basePostJson(deletedAt: now);
      final p = PostModel.fromJson(json);

      expect(p.deletedAt, isNotNull);
    });
  });

  // -------------------------------------------------------
  // PostModel - toJson
  // -------------------------------------------------------

  group('PostModel - toJson', () {
    test('包含创建所需字段', () {
      final p = PostModel.fromJson(basePostJson(
        profile: {'nickname': '测试', 'avatar_url': 'https://x.com/a.jpg'},
      ));
      final json = p.toJson();

      expect(json['user_id'], 'u1');
      expect(json['content'], '今天练了 HYROX 模拟赛，感觉很好！');
      expect(json['photos'], ['https://example.com/photo1.jpg']);
      expect(json['city'], 'shanghai');
      // 不应包含只读字段
      expect(json.containsKey('id'), false);
      expect(json.containsKey('created_at'), false);
      expect(json.containsKey('like_count'), false);
      expect(json.containsKey('profiles'), false);
      expect(json.containsKey('is_liked'), false);
    });
  });

  // -------------------------------------------------------
  // PostModel - copyWith
  // -------------------------------------------------------

  group('PostModel - copyWith', () {
    test('正确覆盖指定字段', () {
      final p = PostModel.fromJson(basePostJson());
      final updated = p.copyWith(
        content: '修改后的内容',
        likeCount: 10,
        isLiked: true,
      );

      expect(updated.content, '修改后的内容');
      expect(updated.likeCount, 10);
      expect(updated.isLiked, true);
      // 未修改的字段保持不变
      expect(updated.id, p.id);
      expect(updated.userId, p.userId);
      expect(updated.photos, p.photos);
      expect(updated.city, p.city);
    });

    test('copyWith photos', () {
      final p = PostModel.fromJson(basePostJson());
      final updated = p.copyWith(photos: ['a.jpg', 'b.jpg']);

      expect(updated.photos, ['a.jpg', 'b.jpg']);
      expect(updated.content, p.content);
    });
  });

  // -------------------------------------------------------
  // PostModel - 计算属性
  // -------------------------------------------------------

  group('PostModel - 计算属性', () {
    test('hasPhotos', () {
      final with_ = PostModel.fromJson(basePostJson());
      expect(with_.hasPhotos, true);

      final json = basePostJson();
      json['photos'] = <String>[];
      final without = PostModel.fromJson(json);
      expect(without.hasPhotos, false);
    });

    test('hasWorkoutLog / hasGym / hasChallenge', () {
      final p = PostModel.fromJson(basePostJson(
        workoutLogId: 'wl1',
        gymId: 'g1',
        challengeId: 'ch1',
      ));

      expect(p.hasWorkoutLog, true);
      expect(p.hasGym, true);
      expect(p.hasChallenge, true);

      final empty = PostModel.fromJson(basePostJson());
      expect(empty.hasWorkoutLog, false);
      expect(empty.hasGym, false);
      expect(empty.hasChallenge, false);
    });

    test('timeAgo — 刚刚', () {
      final now = DateTime.now();
      final p = PostModel.fromJson(basePostJson(createdAt: now));
      expect(p.timeAgo, '刚刚');
    });

    test('timeAgo — 分钟前', () {
      final p = PostModel.fromJson(basePostJson(
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ));
      expect(p.timeAgo, '15分钟前');
    });

    test('timeAgo — 小时前', () {
      final p = PostModel.fromJson(basePostJson(
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ));
      expect(p.timeAgo, '3小时前');
    });

    test('timeAgo — 天前', () {
      final p = PostModel.fromJson(basePostJson(
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ));
      expect(p.timeAgo, '2天前');
    });

    test('timeAgo — 超过7天显示日期', () {
      final date = DateTime.now().subtract(const Duration(days: 10));
      final p = PostModel.fromJson(basePostJson(createdAt: date));
      expect(p.timeAgo, '${date.month}-${date.day.toString().padLeft(2, '0')}');
    });
  });

  // -------------------------------------------------------
  // PostCommentModel - fromJson
  // -------------------------------------------------------

  group('PostCommentModel - fromJson', () {
    test('基础字段正确解析', () {
      final json = baseCommentJson();
      final c = PostCommentModel.fromJson(json);

      expect(c.id, 'c1');
      expect(c.postId, 'p1');
      expect(c.userId, 'u2');
      expect(c.content, '太厉害了！');
      expect(c.parentId, isNull);
      expect(c.createdAt, isA<DateTime>());
      expect(c.updatedAt, isA<DateTime>());
    });

    test('回复评论 parentId 正确解析', () {
      final json = baseCommentJson(parentId: 'c0');
      final c = PostCommentModel.fromJson(json);

      expect(c.parentId, 'c0');
      expect(c.isReply, true);
    });

    test('非回复评论 isReply 为 false', () {
      final json = baseCommentJson();
      final c = PostCommentModel.fromJson(json);

      expect(c.isReply, false);
    });

    test('profiles JOIN 正确填充', () {
      final json = baseCommentJson(profile: {
        'nickname': '评论者',
        'avatar_url': 'https://example.com/commenter.jpg',
      });
      final c = PostCommentModel.fromJson(json);

      expect(c.authorNickname, '评论者');
      expect(c.authorAvatar, 'https://example.com/commenter.jpg');
    });

    test('无 profiles JOIN 时为 null', () {
      final json = baseCommentJson();
      final c = PostCommentModel.fromJson(json);

      expect(c.authorNickname, isNull);
      expect(c.authorAvatar, isNull);
    });
  });

  // -------------------------------------------------------
  // PostCommentModel - toJson
  // -------------------------------------------------------

  group('PostCommentModel - toJson', () {
    test('包含创建所需字段', () {
      final c = PostCommentModel.fromJson(baseCommentJson(
        parentId: 'c0',
        profile: {'nickname': '测试', 'avatar_url': null},
      ));
      final json = c.toJson();

      expect(json['post_id'], 'p1');
      expect(json['user_id'], 'u2');
      expect(json['content'], '太厉害了！');
      expect(json['parent_id'], 'c0');
      // 不应包含只读字段
      expect(json.containsKey('id'), false);
      expect(json.containsKey('created_at'), false);
      expect(json.containsKey('profiles'), false);
    });
  });

  // -------------------------------------------------------
  // 往返一致性
  // -------------------------------------------------------

  group('往返一致性', () {
    test('PostModel fromJson → toJson 关键字段一致', () {
      final original = PostModel.fromJson(basePostJson(
        content: '测试内容',
        city: 'beijing',
        workoutLogId: 'wl99',
      ));
      final json = original.toJson();

      expect(json['user_id'], original.userId);
      expect(json['content'], original.content);
      expect(json['city'], original.city);
      expect(json['workout_log_id'], original.workoutLogId);
      expect(json['photos'], original.photos);
    });

    test('PostCommentModel fromJson → toJson 关键字段一致', () {
      final original = PostCommentModel.fromJson(baseCommentJson(
        content: '好文',
        parentId: 'c5',
      ));
      final json = original.toJson();

      expect(json['post_id'], original.postId);
      expect(json['user_id'], original.userId);
      expect(json['content'], original.content);
      expect(json['parent_id'], original.parentId);
    });
  });
}
