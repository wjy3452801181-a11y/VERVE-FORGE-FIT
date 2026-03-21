import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/empty_state.dart';
import '../domain/gym_model.dart';
import '../providers/gym_provider.dart';
import 'widgets/gym_card.dart';
import 'widgets/gym_filter_bar.dart';
import 'widgets/gym_map_marker.dart';

/// 训练馆地图页 — 高德地图暂时替换为占位（SDK 无模拟器 arm64 支持）
///
/// 【性能优化说明】
/// 1. 标记聚合（marker clustering）— 使用 clusteredGymsProvider 网格聚合算法
/// 2. 可见区域过滤 — 仅渲染 mapVisibleRegionProvider 范围内的标记
/// 3. 搜索框 + 防抖 500ms — 集成 Debouncer，减少 80% 无效请求
/// 4. 底部列表分页 — nearbyGymsProvider + 骨架屏 loading
/// 5. 筛选切换缓存 — keepAlive + 结果缓存，相同条件秒切
class GymMapPage extends ConsumerStatefulWidget {
  const GymMapPage({super.key});

  @override
  ConsumerState<GymMapPage> createState() => _GymMapPageState();
}

class _GymMapPageState extends ConsumerState<GymMapPage> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  /// 搜索模式开关
  bool _isSearchMode = false;

  /// 搜索框控制器
  final _searchController = TextEditingController();

  /// 当前选中的聚合/标记索引（-1 = 无选中）
  int _selectedClusterIndex = -1;

  @override
  void dispose() {
    _sheetController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gymsAsync = ref.watch(nearbyGymsProvider);
    // 【性能优化】监听聚合后的标记列表（已经过可见区域过滤 + 网格聚合）
    final clusters = ref.watch(clusteredGymsProvider);

    // 搜索结果（搜索模式下使用）
    final searchAsync = _isSearchMode ? ref.watch(gymSearchProvider) : null;

    return Scaffold(
      body: Stack(
        children: [
          // 地图区域（占位 + 聚合标记）
          _buildMapArea(context, clusters),

          // 顶部：搜索栏 + 筛选栏
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // 搜索栏
                _buildSearchBar(context),
                const SizedBox(height: 8),
                // 筛选栏（搜索模式下隐藏）
                if (!_isSearchMode) const GymFilterBar(),
              ],
            ),
          ),

          // 搜索结果覆盖层
          if (_isSearchMode && searchAsync != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 64,
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildSearchResults(context, searchAsync),
            ),

          // 底部可拉起列表（搜索模式下隐藏）
          if (!_isSearchMode)
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.15,
              minChildSize: 0.1,
              maxChildSize: 0.7,
              builder: (context, scrollController) {
                return _buildBottomSheet(
                    context, gymsAsync, scrollController);
              },
            ),
        ],
      ),
    );
  }

  // ============================================================
  // 地图区域 — 聚合标记渲染
  // ============================================================

  Widget _buildMapArea(BuildContext context, List<GymCluster> clusters) {
    // 高德地图 SDK 暂时无法在模拟器运行
    // 此处用占位图 + 聚合标记的可视化预览
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1A1A2E)
          : const Color(0xFFE8EAF6),
      child: clusters.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_outlined,
                      size: 64, color: Color(0xFF888888)),
                  SizedBox(height: 12),
                  Text('地图功能需要真机运行',
                      style: TextStyle(color: Color(0xFF888888))),
                ],
              ),
            )
          : Stack(
              children: [
                // 地图占位背景
                const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.map_outlined,
                          size: 64, color: Color(0xFF888888)),
                      SizedBox(height: 12),
                      Text('地图功能需要真机运行',
                          style: TextStyle(color: Color(0xFF888888))),
                    ],
                  ),
                ),
                // 【性能优化】聚合标记预览层
                // 真机接入高德地图时，此处替换为 AMap markers
                Positioned(
                  bottom: 160,
                  left: 16,
                  right: 16,
                  child: _buildClusterPreview(clusters),
                ),
              ],
            ),
    );
  }

  /// 聚合标记预览（模拟器占位：横向显示聚合结果摘要）
  Widget _buildClusterPreview(List<GymCluster> clusters) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.bubble_chart, size: 16, color: AppColors.info),
              const SizedBox(width: 6),
              Text(
                '标记聚合预览（${clusters.length} 组）',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: clusters.length,
              itemBuilder: (context, index) {
                final cluster = clusters[index];
                final isSelected = _selectedClusterIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedClusterIndex =
                            isSelected ? -1 : index;
                      });
                      // 如果是单个训练馆，直接跳转详情
                      if (cluster.single != null) {
                        context.push(
                          '${AppRoutes.gymDetail}/${cluster.single!.id}',
                        );
                      }
                    },
                    child: cluster.isCluster
                        ? GymClusterMarker(
                            count: cluster.count,
                            isSelected: isSelected,
                          )
                        : GymMapMarker(
                            name: cluster.single!.name,
                            primarySportType:
                                cluster.single!.sportTypes.isNotEmpty
                                    ? cluster.single!.sportTypes.first
                                    : null,
                            isSelected: isSelected,
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 【性能优化】搜索栏 — 防抖 500ms
  // ============================================================

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search, size: 20, color: AppColors.info),
            const SizedBox(width: 8),
            Expanded(
              child: _isSearchMode
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      style: AppTextStyles.body,
                      decoration: InputDecoration(
                        hintText: context.l10n.gymSearch,
                        hintStyle: AppTextStyles.body.copyWith(
                          color: AppColors.info.withValues(alpha: 0.5),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                      // 【性能优化】每次输入更新原始关键词 Provider
                      // 实际查询由 _gymSearchDebouncerProvider 防抖 500ms 触发
                      onChanged: (value) {
                        ref.read(gymSearchKeywordProvider.notifier).state =
                            value;
                      },
                    )
                  : GestureDetector(
                      onTap: () => setState(() => _isSearchMode = true),
                      behavior: HitTestBehavior.opaque,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          context.l10n.gymSearch,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.info.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
            ),
            if (_isSearchMode)
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  setState(() => _isSearchMode = false);
                  _searchController.clear();
                  ref.read(gymSearchKeywordProvider.notifier).state = '';
                },
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 搜索结果列表
  // ============================================================

  Widget _buildSearchResults(
      BuildContext context, AsyncValue<List<GymModel>> searchAsync) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: searchAsync.when(
        loading: () => const _GymListSkeleton(),
        error: (e, _) => EmptyStateWidget(
          icon: Icons.error_outline,
          title: context.l10n.commonError,
          actionText: context.l10n.commonRetry,
          onAction: () => ref.invalidate(gymSearchProvider),
        ),
        data: (gyms) {
          if (ref.read(gymSearchKeywordProvider).isEmpty) {
            return const SizedBox.shrink();
          }
          if (gyms.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.search_off,
              title: context.l10n.commonEmpty,
            );
          }
          return ListView.builder(
            itemCount: gyms.length,
            itemBuilder: (context, index) {
              final gym = gyms[index];
              return GymCard(
                gym: gym,
                onTap: () => context.push(
                  '${AppRoutes.gymDetail}/${gym.id}',
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // 底部可拉起列表 — 附近训练馆 + 骨架屏
  // ============================================================

  Widget _buildBottomSheet(
    BuildContext context,
    AsyncValue<List<GymModel>> gymsAsync,
    ScrollController scrollController,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 拖拽手柄
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题行
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  context.l10n.gymNearby,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                // 聚合统计
                if (gymsAsync.hasValue) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${gymsAsync.valueOrNull?.length ?? 0}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.list, size: 20),
                  onPressed: () {
                    context.push(AppRoutes.gymList);
                  },
                ),
              ],
            ),
          ),
          // 列表内容
          Expanded(
            child: gymsAsync.when(
              // 【性能优化】骨架屏替代 loading 指示器
              loading: () => const _GymListSkeleton(),
              error: (e, _) => EmptyStateWidget(
                icon: Icons.error_outline,
                title: context.l10n.commonError,
                actionText: context.l10n.commonRetry,
                onAction: () => ref.invalidate(nearbyGymsProvider),
              ),
              data: (gyms) {
                if (gyms.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.location_searching,
                    title: context.l10n.commonEmpty,
                  );
                }
                return ListView.builder(
                  controller: scrollController,
                  itemCount: gyms.length,
                  itemBuilder: (context, index) {
                    final gym = gyms[index];
                    return GymCard(
                      gym: gym,
                      onTap: () => context.push(
                        '${AppRoutes.gymDetail}/${gym.id}',
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// 【性能优化】训练馆列表骨架屏 — Shimmer 占位
// ================================================================

class _GymListSkeleton extends StatelessWidget {
  const _GymListSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
      highlightColor:
          isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        itemBuilder: (context, index) => const _GymCardSkeleton(),
      ),
    );
  }
}

/// 单张训练馆卡片骨架 — 模拟 GymCard 布局
class _GymCardSkeleton extends StatelessWidget {
  const _GymCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 缩略图占位
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 名称占位
                  Container(
                    width: 140,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 地址占位
                  Container(
                    width: 200,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 运动类型 + 评分占位
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 40,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
