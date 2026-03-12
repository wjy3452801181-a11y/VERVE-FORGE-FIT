import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

    // 监听"有新动态"标记
    final hasNewPosts = ref.watch(feedHasNewPostsProvider);

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
            Tab(text: context.l10n.feedTabNearby),
            Tab(text: context.l10n.feedTabRecommend),
          ],
        ),
      ),
      body: Column(
        children: [
          // 新动态提示横幅
          if (hasNewPosts) _NewPostsBanner(onRefresh: _refreshCurrentTab),

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
    final postsAsync = ref.watch(feedFollowingProvider);

    return postsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyStateWidget(
        icon: Icons.error_outline,
        title: context.l10n.commonError,
        actionText: context.l10n.commonRetry,
        onAction: () => ref.invalidate(feedFollowingProvider),
      ),
      data: (posts) {
        if (posts.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.people_outline,
            title: context.l10n.postNoFollowing,
            subtitle: context.l10n.postFollowTip,
          );
        }

        return _PostListView(
          posts: posts,
          onRefresh: () async {
            ref.read(feedHasNewPostsProvider.notifier).state = false;
            await ref.read(feedFollowingProvider.notifier).refresh();
          },
          onLoadMore: () {
            final notifier = ref.read(feedFollowingProvider.notifier);
            if (notifier.hasMore) {
              notifier.loadMore();
            }
          },
        );
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
    final postsAsync = ref.watch(feedNearbyProvider);

    return postsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyStateWidget(
        icon: Icons.error_outline,
        title: context.l10n.commonError,
        actionText: context.l10n.commonRetry,
        onAction: () => ref.invalidate(feedNearbyProvider),
      ),
      data: (posts) {
        if (posts.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.dynamic_feed_outlined,
            title: context.l10n.postEmpty,
            subtitle: context.l10n.postEmptyTip,
          );
        }

        return _PostListView(
          posts: posts,
          onRefresh: () async {
            ref.read(feedHasNewPostsProvider.notifier).state = false;
            await ref.read(feedNearbyProvider.notifier).refresh();
          },
          onLoadMore: () {
            final notifier = ref.read(feedNearbyProvider.notifier);
            if (notifier.hasMore) {
              notifier.loadMore();
            }
          },
        );
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
    final postsAsync = ref.watch(feedRecommendProvider);

    return postsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => EmptyStateWidget(
        icon: Icons.error_outline,
        title: context.l10n.commonError,
        actionText: context.l10n.commonRetry,
        onAction: () => ref.invalidate(feedRecommendProvider),
      ),
      data: (posts) {
        if (posts.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.dynamic_feed_outlined,
            title: context.l10n.postEmpty,
            subtitle: context.l10n.postEmptyTip,
          );
        }

        return _PostListView(
          posts: posts,
          onRefresh: () async {
            ref.read(feedHasNewPostsProvider.notifier).state = false;
            await ref.read(feedRecommendProvider.notifier).refresh();
          },
          onLoadMore: () {
            final notifier = ref.read(feedRecommendProvider.notifier);
            if (notifier.hasMore) {
              notifier.loadMore();
            }
          },
        );
      },
    );
  }
}

// -------------------------------------------------------
// 通用动态列表 — 下拉刷新 + 上拉加载
// -------------------------------------------------------

class _PostListView extends StatefulWidget {
  final List<PostModel> posts;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;

  const _PostListView({
    required this.posts,
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
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.posts.length,
        itemBuilder: (context, index) {
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
}
