import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../gym/providers/gym_provider.dart';
import '../../gym/presentation/widgets/gym_card.dart';
import '../../gym/presentation/widgets/gym_filter_bar.dart';

/// 训练馆页 — Tab 2（原「发现」页，升级为完整训练馆入口）
/// 功能：列表浏览 / 地图切换 / 搜索 / 筛选 / 收藏入口
class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage> {
  bool _isSearchMode = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 搜索模式使用 gymSearchProvider，否则使用 nearbyGymsProvider
    final gymsAsync = _isSearchMode
        ? ref.watch(gymSearchProvider)
        : ref.watch(nearbyGymsProvider);

    return Scaffold(
      appBar: AppBar(
        // 搜索模式：内联搜索框；普通模式：标题
        title: _isSearchMode
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: context.l10n.gymSearch,
                  border: InputBorder.none,
                  hintStyle: AppTextStyles.body.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                onChanged: (value) {
                  ref.read(gymSearchKeywordProvider.notifier).state = value;
                },
              )
            : Text(context.l10n.gymTitle),
        actions: [
          // 搜索切换
          IconButton(
            icon: Icon(_isSearchMode ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearchMode = !_isSearchMode;
                if (!_isSearchMode) {
                  _searchController.clear();
                  ref.read(gymSearchKeywordProvider.notifier).state = '';
                }
              });
            },
          ),
          // 地图全屏入口
          if (!_isSearchMode)
            IconButton(
              icon: const Icon(Icons.map_outlined),
              onPressed: () => context.push(AppRoutes.gymMap),
            ),
          // 收藏列表入口
          if (!_isSearchMode)
            IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () => context.push(AppRoutes.gymFavorites),
            ),
        ],
      ),
      body: Column(
        children: [
          // 运动类型筛选栏（搜索模式下隐藏）
          if (!_isSearchMode) ...[
            const GymFilterBar(),
            const SizedBox(height: 4),
          ],

          // 训练馆列表
          Expanded(
            child: gymsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyStateWidget(
                icon: Icons.error_outline,
                title: context.l10n.commonError,
                actionText: context.l10n.commonRetry,
                onAction: () {
                  if (_isSearchMode) {
                    ref.invalidate(gymSearchProvider);
                  } else {
                    ref.invalidate(nearbyGymsProvider);
                  }
                },
              ),
              data: (gyms) {
                if (gyms.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.fitness_center_outlined,
                    title: _isSearchMode
                        ? context.l10n.commonEmpty
                        : context.l10n.nearbyNoGyms,
                    subtitle: _isSearchMode
                        ? null
                        : context.l10n.nearbyNoGymsTip,
                    actionText:
                        _isSearchMode ? null : context.l10n.gymSubmit,
                    onAction: _isSearchMode
                        ? null
                        : () => context.push(AppRoutes.gymSubmit),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    if (_isSearchMode) {
                      ref.invalidate(gymSearchProvider);
                    } else {
                      ref.invalidate(nearbyGymsProvider);
                    }
                  },
                  color: AppColors.primary,
                  child: ListView.builder(
                    itemCount: gyms.length + 1, // +1 用于底部提交训练馆提示
                    itemBuilder: (context, index) {
                      // 最后一项：提交训练馆入口
                      if (index == gyms.length) {
                        return _buildSubmitGymTile(context);
                      }

                      final gym = gyms[index];
                      return GymCard(
                        gym: gym,
                        onTap: () => context.push(
                          '${AppRoutes.gymDetail}/${gym.id}',
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // 提交训练馆 FAB
      floatingActionButton: _isSearchMode
          ? null
          : FloatingActionButton.small(
              heroTag: 'gym_submit',
              onPressed: () => context.push(AppRoutes.gymSubmit),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  /// 底部"提交训练馆"提示行
  Widget _buildSubmitGymTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: InkWell(
        onTap: () => context.push(AppRoutes.gymSubmit),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_business_outlined,
                size: 20,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.gymSubmit,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
