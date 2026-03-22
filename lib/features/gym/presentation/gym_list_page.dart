import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_radius.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/gym_provider.dart';
import 'widgets/gym_card.dart';
import 'widgets/gym_filter_bar.dart';

/// 训练馆列表页 — 搜索框 + 运动类型筛选 + 距离排序
class GymListPage extends ConsumerStatefulWidget {
  const GymListPage({super.key});

  @override
  ConsumerState<GymListPage> createState() => _GymListPageState();
}

class _GymListPageState extends ConsumerState<GymListPage> {
  final _searchController = TextEditingController();
  bool _isSearchMode = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gymsAsync = _isSearchMode
        ? ref.watch(gymSearchProvider)
        : ref.watch(gymListProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearchMode
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: context.l10n.gymSearch,
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  ref.read(gymSearchKeywordProvider.notifier).state = value;
                },
              )
            : Text(context.l10n.gymTitle),
        actions: [
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
        ],
      ),
      body: Column(
        children: [
          if (!_isSearchMode) const GymFilterBar(),
          Expanded(
            child: gymsAsync.when(
              loading: () => const _GymListSkeleton(),
              error: (e, _) => EmptyStateWidget(
                icon: Icons.error_outline,
                title: context.l10n.commonError,
                actionText: context.l10n.commonRetry,
                onAction: () {
                  if (_isSearchMode) {
                    ref.invalidate(gymSearchProvider);
                  } else {
                    ref.invalidate(gymListProvider);
                  }
                },
              ),
              data: (gyms) {
                if (gyms.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.fitness_center_outlined,
                    title: context.l10n.commonEmpty,
                    subtitle:
                        _isSearchMode ? null : context.l10n.gymNearby,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    if (_isSearchMode) {
                      ref.invalidate(gymSearchProvider);
                    } else {
                      await ref.read(gymListProvider.notifier).refresh();
                    }
                  },
                  color: AppColors.primary,
                  child: ListView.builder(
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------
// 列表页骨架屏 — Shimmer + AppColors tokens
// -------------------------------------------------------

class _GymListSkeleton extends StatelessWidget {
  const _GymListSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      highlightColor:
          isDark ? AppColors.darkCardHover : AppColors.lightCardHover,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        itemBuilder: (context, index) => Container(
          margin: AppSpacing.cardMargin,
          padding: AppSpacing.cardPaddingCompact,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.bLG,
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.bSM,
                ),
              ),
              AppSpacing.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 140,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.bXS,
                      ),
                    ),
                    AppSpacing.vGapSM,
                    Container(
                      width: 200,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.bXS,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
