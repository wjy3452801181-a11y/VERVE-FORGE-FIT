import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/network/supabase_client.dart';
import '../../../core/utils/image_utils.dart';
import '../domain/post_model.dart';
import '../domain/post_comment_model.dart';

const _uuid = Uuid();

/// 动态 Repository
class PostRepository {
  // -------------------------------------------------------
  // 查询
  // -------------------------------------------------------

  /// 查询动态列表（按时间倒序）
  Future<List<PostModel>> listPosts({
    int page = 0,
    int pageSize = 20,
  }) async {
    final data = await SupabaseClientHelper.from(SupabaseConstants.posts)
        .select('*, profiles(nickname, avatar_url)')
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false)
        .range(page * pageSize, (page + 1) * pageSize - 1);

    return (data as List).map((e) => PostModel.fromJson(e)).toList();
  }

  /// 查询推荐动态（全局热门，按点赞数 + 时间倒序）
  Future<List<PostModel>> listRecommend({
    int page = 0,
    int pageSize = 20,
  }) async {
    final data = await SupabaseClientHelper.from(SupabaseConstants.posts)
        .select('*, profiles(nickname, avatar_url)')
        .isFilter('deleted_at', null)
        .order('likes_count', ascending: false)
        .order('created_at', ascending: false)
        .range(page * pageSize, (page + 1) * pageSize - 1);

    return (data as List).map((e) => PostModel.fromJson(e)).toList();
  }

  /// 查询关注用户的动态
  Future<List<PostModel>> listByFollowing({
    int page = 0,
    int pageSize = 20,
  }) async {
    final userId = SupabaseClientHelper.currentUserId;
    if (userId == null) return [];

    // 先获取关注列表
    final followData = await SupabaseClientHelper.from(
            SupabaseConstants.userFollows)
        .select('following_id')
        .eq('follower_id', userId);
    final followingIds =
        (followData as List).map((e) => e['following_id'] as String).toList();

    if (followingIds.isEmpty) return [];

    final data = await SupabaseClientHelper.from(SupabaseConstants.posts)
        .select('*, profiles(nickname, avatar_url)')
        .inFilter('user_id', followingIds)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: false)
        .range(page * pageSize, (page + 1) * pageSize - 1);

    return (data as List).map((e) => PostModel.fromJson(e)).toList();
  }

  // -------------------------------------------------------
  // Realtime 订阅 — 监听 posts 表新增/变更
  // -------------------------------------------------------

  /// 订阅动态流实时更新（Supabase Realtime）
  /// 监听 posts 表的 INSERT 事件，触发回调通知有新动态
  RealtimeChannel subscribeFeed({
    required void Function() onNewPost,
  }) {
    final channel = SupabaseClientHelper.client.channel('feed:realtime');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: SupabaseConstants.posts,
          callback: (payload) => onNewPost(),
        )
        .subscribe();

    return channel;
  }

  /// 取消动态流订阅
  Future<void> unsubscribeFeed(RealtimeChannel channel) async {
    await SupabaseClientHelper.client.removeChannel(channel);
  }

  /// 获取单条动态详情
  Future<PostModel?> getDetail(String id) async {
    final data = await SupabaseClientHelper.from(SupabaseConstants.posts)
        .select('*, profiles(nickname, avatar_url)')
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    return PostModel.fromJson(data);
  }

  // -------------------------------------------------------
  // 发布 / 删除
  // -------------------------------------------------------

  /// 发布动态
  Future<PostModel> create({
    required String content,
    List<String> imageUrls = const [],
    String? workoutId,
  }) async {
    final userId = SupabaseClientHelper.currentUserId!;
    final id = _uuid.v4();
    final now = DateTime.now();

    final data = {
      'id': id,
      'user_id': userId,
      'content': content,
      'image_urls': imageUrls,
      'workout_id': workoutId,
    };

    await SupabaseClientHelper.from(SupabaseConstants.posts).insert(data);

    return PostModel(
      id: id,
      userId: userId,
      content: content,
      imageUrls: imageUrls,
      workoutId: workoutId,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 删除动态（软删除）
  Future<void> delete(String id) async {
    await SupabaseClientHelper.from(SupabaseConstants.posts)
        .update({'deleted_at': DateTime.now().toIso8601String()}).eq('id', id);
  }

  /// 上传动态照片
  Future<List<String>> uploadPhotos(List<File> files) async {
    return ImageUtils.uploadImages(
      files: files,
      bucket: SupabaseConstants.postPhotosBucket,
      folder: SupabaseClientHelper.currentUserId,
    );
  }

  // -------------------------------------------------------
  // 点赞
  // -------------------------------------------------------

  /// 切换点赞状态，返回操作后状态：true = 已赞
  Future<bool> toggleLike(String postId) async {
    final userId = SupabaseClientHelper.currentUserId!;

    final existing =
        await SupabaseClientHelper.from(SupabaseConstants.postLikes)
            .select('id')
            .eq('post_id', postId)
            .eq('user_id', userId)
            .maybeSingle();

    if (existing != null) {
      await SupabaseClientHelper.from(SupabaseConstants.postLikes)
          .delete()
          .eq('post_id', postId)
          .eq('user_id', userId);
      return false;
    } else {
      await SupabaseClientHelper.from(SupabaseConstants.postLikes).insert({
        'post_id': postId,
        'user_id': userId,
      });
      return true;
    }
  }

  /// 查询当前用户是否已点赞
  Future<bool> isLiked(String postId) async {
    final userId = SupabaseClientHelper.currentUserId;
    if (userId == null) return false;

    final data =
        await SupabaseClientHelper.from(SupabaseConstants.postLikes)
            .select('id')
            .eq('post_id', postId)
            .eq('user_id', userId)
            .maybeSingle();
    return data != null;
  }

  // -------------------------------------------------------
  // 评论
  // -------------------------------------------------------

  /// 获取动态评论列表
  Future<List<PostCommentModel>> getComments({
    required String postId,
    int page = 0,
    int pageSize = 20,
  }) async {
    final data = await SupabaseClientHelper.from(SupabaseConstants.postComments)
        .select('*, profiles(nickname, avatar_url)')
        .eq('post_id', postId)
        .isFilter('deleted_at', null)
        .order('created_at', ascending: true)
        .range(page * pageSize, (page + 1) * pageSize - 1);

    return (data as List)
        .map((e) => PostCommentModel.fromJson(e))
        .toList();
  }

  /// 添加评论
  Future<PostCommentModel> addComment({
    required String postId,
    required String content,
    String? parentId,
  }) async {
    final userId = SupabaseClientHelper.currentUserId!;
    final id = _uuid.v4();
    final now = DateTime.now();

    await SupabaseClientHelper.from(SupabaseConstants.postComments).insert({
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'parent_id': parentId,
    });

    return PostCommentModel(
      id: id,
      postId: postId,
      userId: userId,
      content: content,
      parentId: parentId,
      createdAt: now,
      updatedAt: now,
    );
  }
}

/// Provider
final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository();
});
