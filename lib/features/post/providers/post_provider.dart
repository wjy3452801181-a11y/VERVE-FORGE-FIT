import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../data/post_repository.dart';
import '../domain/post_model.dart';
import '../domain/post_comment_model.dart';

// -------------------------------------------------------
// Feed Tab 状态
// -------------------------------------------------------

/// Feed 当前 Tab 索引（0=关注, 1=最新, 2=推荐）
final feedTabProvider = StateProvider<int>((ref) => 1);

/// 是否有新动态（Realtime 推送标记）
final feedHasNewPostsProvider = StateProvider<bool>((ref) => false);

// -------------------------------------------------------
// Realtime 订阅 — 全局动态流监听
// -------------------------------------------------------

/// 动态流 Realtime 订阅 Provider
/// 监听 posts 表 INSERT 事件，标记 feedHasNewPostsProvider = true
final feedRealtimeProvider = Provider<void>((ref) {
  final repo = ref.read(postRepositoryProvider);

  final channel = repo.subscribeFeed(
    onNewPost: () {
      // 收到新动态通知，设置标记（UI 层显示"有新动态"横幅）
      ref.read(feedHasNewPostsProvider.notifier).state = true;
    },
  );

  // Provider 被销毁时取消订阅
  ref.onDispose(() {
    repo.unsubscribeFeed(channel);
  });
});

// -------------------------------------------------------
// 关注 Tab — 关注用户的动态
// -------------------------------------------------------

final feedFollowingProvider =
    AsyncNotifierProvider<FeedFollowingNotifier, List<PostModel>>(
  FeedFollowingNotifier.new,
);

class FeedFollowingNotifier extends AsyncNotifier<List<PostModel>> {
  int _page = 0;
  bool _hasMore = true;
  /// 【性能优化】是否正在加载更多（防止重复触发）
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;

  @override
  Future<List<PostModel>> build() async {
    // 【性能优化】keepAlive 防止 Tab 切换时丢弃已加载数据
    // 用户切回该 Tab 时直接展示缓存，无需重新请求
    ref.keepAlive();

    _page = 0;
    _hasMore = true;
    _isLoadingMore = false;
    return _fetch();
  }

  Future<List<PostModel>> _fetch() async {
    final repo = ref.read(postRepositoryProvider);
    final data = await repo.listByFollowing(page: _page);
    if (data.length < AppConstants.defaultPageSize) {
      _hasMore = false;
    }
    return data;
  }

  /// 加载更多（带防重复锁）
  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    _isLoadingMore = true;
    try {
      _page++;
      final current = state.valueOrNull ?? [];
      final more = await _fetch();
      state = AsyncValue.data([...current, ...more]);
    } finally {
      _isLoadingMore = false;
    }
  }

  /// 手动刷新（清除 hasNewPosts 标记）
  Future<void> refresh() async {
    _page = 0;
    _hasMore = true;
    _isLoadingMore = false;
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetch());
  }
}

// -------------------------------------------------------
// 最新 Tab — 按时间倒序的动态
// -------------------------------------------------------

final feedNearbyProvider =
    AsyncNotifierProvider<FeedNearbyNotifier, List<PostModel>>(
  FeedNearbyNotifier.new,
);

class FeedNearbyNotifier extends AsyncNotifier<List<PostModel>> {
  int _page = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;

  @override
  Future<List<PostModel>> build() async {
    // 【性能优化】keepAlive 缓存已加载数据
    ref.keepAlive();

    _page = 0;
    _hasMore = true;
    _isLoadingMore = false;
    return _fetch();
  }

  Future<List<PostModel>> _fetch() async {
    final repo = ref.read(postRepositoryProvider);
    final data = await repo.listPosts(page: _page);
    if (data.length < AppConstants.defaultPageSize) {
      _hasMore = false;
    }
    return data;
  }

  /// 加载更多（带防重复锁）
  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    _isLoadingMore = true;
    try {
      _page++;
      final current = state.valueOrNull ?? [];
      final more = await _fetch();
      state = AsyncValue.data([...current, ...more]);
    } finally {
      _isLoadingMore = false;
    }
  }

  /// 手动刷新
  Future<void> refresh() async {
    _page = 0;
    _hasMore = true;
    _isLoadingMore = false;
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetch());
  }
}

// -------------------------------------------------------
// 推荐 Tab — 全局热门动态（独立数据源）
// -------------------------------------------------------

final feedRecommendProvider =
    AsyncNotifierProvider<FeedRecommendNotifier, List<PostModel>>(
  FeedRecommendNotifier.new,
);

class FeedRecommendNotifier extends AsyncNotifier<List<PostModel>> {
  int _page = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;

  @override
  Future<List<PostModel>> build() async {
    // 【性能优化】keepAlive 缓存已加载数据
    ref.keepAlive();

    _page = 0;
    _hasMore = true;
    _isLoadingMore = false;
    return _fetch();
  }

  Future<List<PostModel>> _fetch() async {
    final repo = ref.read(postRepositoryProvider);
    final data = await repo.listRecommend(page: _page);
    if (data.length < AppConstants.defaultPageSize) {
      _hasMore = false;
    }
    return data;
  }

  /// 加载更多（带防重复锁）
  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    _isLoadingMore = true;
    try {
      _page++;
      final current = state.valueOrNull ?? [];
      final more = await _fetch();
      state = AsyncValue.data([...current, ...more]);
    } finally {
      _isLoadingMore = false;
    }
  }

  /// 手动刷新
  Future<void> refresh() async {
    _page = 0;
    _hasMore = true;
    _isLoadingMore = false;
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetch());
  }
}

// -------------------------------------------------------
// 动态详情
// -------------------------------------------------------

final postDetailProvider =
    FutureProvider.family<PostModel?, String>((ref, id) async {
  final repo = ref.watch(postRepositoryProvider);
  return repo.getDetail(id);
});

// -------------------------------------------------------
// 点赞
// -------------------------------------------------------

final postLikeStatusProvider =
    FutureProvider.family<bool, String>((ref, postId) async {
  final repo = ref.watch(postRepositoryProvider);
  return repo.isLiked(postId);
});

// -------------------------------------------------------
// 评论列表
// -------------------------------------------------------

final postCommentsProvider = AsyncNotifierProviderFamily<
    PostCommentsNotifier, List<PostCommentModel>, String>(
  PostCommentsNotifier.new,
);

class PostCommentsNotifier
    extends FamilyAsyncNotifier<List<PostCommentModel>, String> {
  int _page = 0;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  @override
  Future<List<PostCommentModel>> build(String arg) async {
    _page = 0;
    _hasMore = true;
    return _fetch();
  }

  Future<List<PostCommentModel>> _fetch() async {
    final repo = ref.read(postRepositoryProvider);
    final data = await repo.getComments(postId: arg, page: _page);
    if (data.length < AppConstants.defaultPageSize) {
      _hasMore = false;
    }
    return data;
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;
    _page++;
    final current = state.valueOrNull ?? [];
    final more = await _fetch();
    state = AsyncValue.data([...current, ...more]);
  }
}

// -------------------------------------------------------
// 操作（发布 / 点赞 / 评论 / 删除）
// -------------------------------------------------------

final postActionProvider = Provider<PostAction>((ref) {
  return PostAction(ref);
});

class PostAction {
  final Ref _ref;

  PostAction(this._ref);

  /// 发布动态
  Future<PostModel> publish({
    required String content,
    List<String> imageUrls = const [],
    String? workoutId,
  }) async {
    final repo = _ref.read(postRepositoryProvider);
    final post = await repo.create(
      content: content,
      imageUrls: imageUrls,
      workoutId: workoutId,
    );
    _ref.invalidate(feedNearbyProvider);
    _ref.invalidate(feedFollowingProvider);
    _ref.invalidate(feedRecommendProvider);
    return post;
  }

  /// 切换点赞
  Future<bool> toggleLike(String postId) async {
    final repo = _ref.read(postRepositoryProvider);
    final result = await repo.toggleLike(postId);
    _ref.invalidate(postLikeStatusProvider(postId));
    _ref.invalidate(postDetailProvider(postId));
    return result;
  }

  /// 添加评论
  Future<PostCommentModel> addComment({
    required String postId,
    required String content,
    String? parentId,
  }) async {
    final repo = _ref.read(postRepositoryProvider);
    final comment = await repo.addComment(
      postId: postId,
      content: content,
      parentId: parentId,
    );
    _ref.invalidate(postCommentsProvider(postId));
    _ref.invalidate(postDetailProvider(postId));
    return comment;
  }

  /// 删除动态
  Future<void> delete(String postId) async {
    final repo = _ref.read(postRepositoryProvider);
    await repo.delete(postId);
    _ref.invalidate(feedNearbyProvider);
    _ref.invalidate(feedFollowingProvider);
    _ref.invalidate(feedRecommendProvider);
  }
}
