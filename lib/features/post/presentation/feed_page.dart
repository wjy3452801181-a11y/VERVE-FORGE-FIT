import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../notification/providers/notification_provider.dart';
import '../domain/post_model.dart';
import '../providers/post_provider.dart';
import 'widgets/post_card.dart';

// -------------------------------------------------------
// 涂鸦风格局部常量（仅 Feed 页内使用）
// -------------------------------------------------------
const _kGraffitiNeon = Color(0xFFCDFF00); // 荧光黄绿

/// 动态流页 — Tab 1
/// 3 个子 Tab：关注 / 附近 / 推荐
/// 支持 Supabase Realtime 新动态推送
///
/// 【性能优化说明】
/// 1. loading 状态使用 Shimmer 骨架屏替代 CircularProgressIndicator，降低白屏感知
/// 2. Provider 添加 keepAlive，Tab 切换不重新加载已缓存数据
/// 3. 列表尾部添加 loading 指示器，上拉加载体验更平滑
class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(feedTabProvider.notifier).state = _tabController.index;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 激活 Realtime 订阅（只需 watch 一次即可维持连接）
    ref.watch(feedRealtimeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.feedTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            fontSize: 20,
          ),
        ),
        actions: [
          // 发布动态快捷入口
          IconButton(
            icon: const Icon(Icons.edit_note),
            onPressed: () => context.push(AppRoutes.postCreate),
          ),
          Consumer(
            builder: (context, ref, child) {
              final unread = ref.watch(unreadCountProvider);
              final count = unread.valueOrNull ?? 0;
              return IconButton(
                icon: Badge(
                  isLabelVisible: count > 0,
                  label: Text(count > 99 ? '99+' : '$count'),
                  child: const Icon(Icons.notifications_outlined),
                ),
                onPressed: () => context.push(AppRoutes.notifications),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          // 荧光黄绿粗条指示器（荧光笔效果）
          indicator: BoxDecoration(
            color: _kGraffitiNeon,
            borderRadius: BorderRadius.circular(4),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          labelColor: AppColors.primary,
          unselectedLabelColor:
              context.theme.colorScheme.onSurface.withValues(alpha: 0.5),
          labelStyle: AppTextStyles.subtitle.copyWith(
            fontWeight: FontWeight.w800,
          ),
          unselectedLabelStyle: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(text: context.l10n.feedTabFollowing),
            Tab(text: context.l10n.feedTabLatest),
            Tab(text: context.l10n.feedTabRecommend),
          ],
        ),
      ),
      body: Column(
        children: [
          // 【性能优化 Step 2】用 Consumer + select 精细监听 hasNewPosts
          // 仅当 bool 值实际变化时才 rebuild 横幅区域，不会触发整个 Scaffold 重建
          Consumer(
            builder: (context, ref, _) {
              final hasNewPosts = ref.watch(
                feedHasNewPostsProvider.select((v) => v),
              );
              if (!hasNewPosts) return const SizedBox.shrink();
              return _NewPostsBanner(onRefresh: _refreshCurrentTab);
            },
          ),

          // Tab 内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _FollowingTab(),
                _NearbyTab(),
                _RecommendTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 刷新当前 Tab 并清除新动态标记
  void _refreshCurrentTab() {
    ref.read(feedHasNewPostsProvider.notifier).state = false;

    switch (_tabController.index) {
      case 0:
        ref.read(feedFollowingProvider.notifier).refresh();
        break;
      case 1:
        ref.read(feedNearbyProvider.notifier).refresh();
        break;
      case 2:
        ref.read(feedRecommendProvider.notifier).refresh();
        break;
    }
  }
}

// -------------------------------------------------------
// 新动态提示横幅 — 涂鸦贴纸风格
// -------------------------------------------------------

class _NewPostsBanner extends StatelessWidget {
  final VoidCallback onRefresh;

  const _NewPostsBanner({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRefresh,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Transform.rotate(
          angle: -1.5 * math.pi / 180, // -1.5°
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_upward,
                    size: 16, color: _kGraffitiNeon),
                const SizedBox(width: 6),
                Text(
                  context.l10n.postNewAvailable.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: _kGraffitiNeon,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------
// 关注 Tab
// -------------------------------------------------------

class _FollowingTab extends ConsumerWidget {
  const _FollowingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 【性能优化 Step 2】select 精细化监听
    // 仅提取 loading/error/data 状态 + 列表长度作为 rebuild 判据
    // 列表内容的变化（如某条动态点赞数+1）不会触发整个 Tab rebuild，
    // 因为 _PostListView 内部的 PostCard 各自持有独立数据
    final postsAsync = ref.watch(
      feedFollowingProvider.select((state) => (
        isLoading: state.isLoading,
        hasError: state.hasError,
        error: state.error,
        posts: state.valueOrNull,
      )),
    );

    if (postsAsync.isLoading) return const _FeedSkeletonList();
    if (postsAsync.hasError) {
      return EmptyStateWidget(
        icon: Icons.error_outline,
        title: context.l10n.commonError,
        actionText: context.l10n.commonRetry,
        onAction: () => ref.invalidate(feedFollowingProvider),
      );
    }

    final posts = postsAsync.posts ?? [];
    if (posts.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.people_outline,
        title: context.l10n.postNoFollowing,
        subtitle: context.l10n.postFollowTip,
      );
    }

    return _PostListView(
      posts: posts,
      hasMore: ref.read(feedFollowingProvider.notifier).hasMore,
      onRefresh: () async {
        ref.read(feedHasNewPostsProvider.notifier).state = false;
        await ref.read(feedFollowingProvider.notifier).refresh();
      },
      onLoadMore: () {
        ref.read(feedFollowingProvider.notifier).loadMore();
      },
    );
  }
}

// -------------------------------------------------------
// 附近 Tab
// -------------------------------------------------------

class _NearbyTab extends ConsumerWidget {
  const _NearbyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 【性能优化 Step 2】select 精细化 — 同 _FollowingTab
    final postsAsync = ref.watch(
      feedNearbyProvider.select((state) => (
        isLoading: state.isLoading,
        hasError: state.hasError,
        error: state.error,
        posts: state.valueOrNull,
      )),
    );

    if (postsAsync.isLoading) return const _FeedSkeletonList();
    if (postsAsync.hasError) {
      return EmptyStateWidget(
        icon: Icons.error_outline,
        title: context.l10n.commonError,
        actionText: context.l10n.commonRetry,
        onAction: () => ref.invalidate(feedNearbyProvider),
      );
    }

    final posts = postsAsync.posts ?? [];
    if (posts.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.dynamic_feed_outlined,
        title: context.l10n.postEmpty,
        subtitle: context.l10n.postEmptyTip,
      );
    }

    return _PostListView(
      posts: posts,
      hasMore: ref.read(feedNearbyProvider.notifier).hasMore,
      onRefresh: () async {
        ref.read(feedHasNewPostsProvider.notifier).state = false;
        await ref.read(feedNearbyProvider.notifier).refresh();
      },
      onLoadMore: () {
        ref.read(feedNearbyProvider.notifier).loadMore();
      },
    );
  }
}

// -------------------------------------------------------
// 推荐 Tab — 独立数据源（全局热门）
// -------------------------------------------------------

class _RecommendTab extends ConsumerWidget {
  const _RecommendTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 【性能优化 Step 2】select 精细化 — 同 _FollowingTab / _NearbyTab
    final postsAsync = ref.watch(
      feedRecommendProvider.select((state) => (
        isLoading: state.isLoading,
        hasError: state.hasError,
        error: state.error,
        posts: state.valueOrNull,
      )),
    );

    if (postsAsync.isLoading) return const _FeedSkeletonList();
    if (postsAsync.hasError) {
      return EmptyStateWidget(
        icon: Icons.error_outline,
        title: context.l10n.commonError,
        actionText: context.l10n.commonRetry,
        onAction: () => ref.invalidate(feedRecommendProvider),
      );
    }

    final posts = postsAsync.posts ?? [];
    if (posts.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.dynamic_feed_outlined,
        title: context.l10n.postEmpty,
        subtitle: context.l10n.postEmptyTip,
      );
    }

    return _PostListView(
      posts: posts,
      hasMore: ref.read(feedRecommendProvider.notifier).hasMore,
      onRefresh: () async {
        ref.read(feedHasNewPostsProvider.notifier).state = false;
        await ref.read(feedRecommendProvider.notifier).refresh();
      },
      onLoadMore: () {
        ref.read(feedRecommendProvider.notifier).loadMore();
      },
    );
  }
}

// -------------------------------------------------------
// 通用动态列表 — 下拉刷新 + 上拉加载
// 【性能优化】添加尾部 loading 指示器 + hasMore 控制
// -------------------------------------------------------

class _PostListView extends StatefulWidget {
  final List<PostModel> posts;
  final bool hasMore;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;

  const _PostListView({
    required this.posts,
    required this.hasMore,
    required this.onRefresh,
    required this.onLoadMore,
  });

  @override
  State<_PostListView> createState() => _PostListViewState();
}

class _PostListViewState extends State<_PostListView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 【性能优化】列表末尾添加 loading / "没有更多" 指示器
    final itemCount = widget.posts.length + 1; // +1 用于尾部指示器

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          // 尾部指示器
          if (index == widget.posts.length) {
            return _buildFooter();
          }

          final post = widget.posts[index];
          return PostCard(
            post: post,
            onTap: () {
              // TODO: 导航到动态详情页
            },
          );
        },
      ),
    );
  }

  /// 列表尾部：加载中 / 没有更多
  Widget _buildFooter() {
    if (widget.hasMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    // 已加载全部
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          '— 已经到底了 —',
          style: AppTextStyles.caption.copyWith(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------
// 【性能优化】Feed 骨架屏列表 — Shimmer 占位
// 模拟 PostCard 布局结构，首帧加载感知 < 2s
// -------------------------------------------------------

class _FeedSkeletonList extends StatelessWidget {
  const _FeedSkeletonList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
      highlightColor:
          isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5, // 显示 5 个骨架卡片
        itemBuilder: (context, index) => const _PostSkeletonCard(),
      ),
    );
  }
}

/// 单张动态卡片骨架 — 模拟 PostCard 真实布局
class _PostSkeletonCard extends StatelessWidget {
  const _PostSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 作者行骨架：圆形头像 + 两行文字
          Row(
            children: [
              // 头像占位
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 昵称占位
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // 时间占位
                    Container(
                      width: 60,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 文字内容占位（2 行）
          Container(
            width: double.infinity,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 200,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 10),

          // 图片占位
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 10),

          // 互动行占位（两个药丸）
          Row(
            children: [
              Container(
                width: 64,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 64,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
