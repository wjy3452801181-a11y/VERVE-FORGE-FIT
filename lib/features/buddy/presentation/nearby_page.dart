import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/errors/error_handler.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton.dart';
import '../../gym/providers/gym_provider.dart';
import '../../gym/presentation/widgets/gym_card.dart';
import '../providers/buddy_provider.dart';
import 'widgets/buddy_card.dart';

/// 附近页 — Tab 5
/// 两个区块：附近伙伴（LBS） + 推荐训练馆
class NearbyPage extends ConsumerStatefulWidget {
  const NearbyPage({super.key});

  @override
  ConsumerState<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends ConsumerState<NearbyPage> {
  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(buddyFilterProvider);
    final buddiesAsync = ref.watch(nearbyBuddiesProvider);
    final gymsAsync = ref.watch(nearbyGymsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.nearbyTitle),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(nearbyBuddiesProvider);
          ref.invalidate(nearbyGymsProvider);
        },
        color: AppColors.primary,
        child: ListView(
          children: [
            // 运动类型筛选器
            _buildSportTypeFilter(context, ref, filter),
            AppSpacing.vGapSM,

            // ═══════════════════════════════
            // 区块 1：附近伙伴
            // ═══════════════════════════════
            _buildSectionHeader(
              context,
              isDark: isDark,
              icon: Icons.people,
              title: context.l10n.nearbyBuddies,
            ),
            buddiesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.lg),
                child: Column(
                  children: [
                    SkeletonAvatarRow(),
                    SizedBox(height: AppSpacing.md),
                    SkeletonAvatarRow(),
                  ],
                ),
              ),
              error: (e, _) => Padding(
                padding: AppSpacing.pagePadding,
                child: EmptyStateWidget(
                  icon: Icons.error_outline,
                  title: context.l10n.commonError,
                  actionText: context.l10n.commonRetry,
                  onAction: () => ref.invalidate(nearbyBuddiesProvider),
                ),
              ),
              data: (buddies) {
                if (buddies.isEmpty) {
                  return _buildEmptyBuddies(context, isDark);
                }
                return Column(
                  children: buddies
                      .map((buddy) => BuddyCard(
                            buddy: buddy,
                            onBuddyUp: () =>
                                _handleBuddyUp(context, ref, buddy.id),
                          ))
                      .toList(),
                );
              },
            ),

            AppSpacing.vGapMD,

            // ═══════════════════════════════
            // 区块 2：推荐训练馆
            // ═══════════════════════════════
            _buildSectionHeader(
              context,
              isDark: isDark,
              icon: Icons.fitness_center,
              title: context.l10n.nearbyGymsRecommend,
              trailing: GestureDetector(
                onTap: () => context.push(AppRoutes.gymMap),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.map_outlined,
                        size: 14, color: AppColors.primary),
                    AppSpacing.hGapXS,
                    Text(
                      context.l10n.gymNearby,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            gymsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.lg),
                child: Column(
                  children: [
                    SkeletonCard(),
                    SkeletonCard(),
                  ],
                ),
              ),
              error: (e, _) => Padding(
                padding: AppSpacing.pagePadding,
                child: EmptyStateWidget(
                  icon: Icons.error_outline,
                  title: context.l10n.commonError,
                  actionText: context.l10n.commonRetry,
                  onAction: () => ref.invalidate(nearbyGymsProvider),
                ),
              ),
              data: (gyms) {
                if (gyms.isEmpty) {
                  return _buildEmptyGyms(context, isDark);
                }
                // 最多展示 5 个推荐训练馆
                final displayGyms = gyms.take(5).toList();
                return Column(
                  children: displayGyms
                      .map((gym) => GymCard(
                            gym: gym,
                            onTap: () => context.push(
                              '${AppRoutes.gymDetail}/${gym.id}',
                            ),
                          ))
                      .toList(),
                );
              },
            ),

            // 底部安全间距
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  /// 运动类型筛选横条
  Widget _buildSportTypeFilter(
    BuildContext context,
    WidgetRef ref,
    BuddyFilter filter,
  ) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x12, vertical: AppSpacing.xs),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(context.l10n.workoutFilterAll),
              selected: filter.sportType == null,
              onSelected: (_) {
                ref.read(buddyFilterProvider.notifier).state =
                    filter.copyWith(clearSportType: true);
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          ...AppConstants.sportTypes.map((type) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: ChoiceChip(
                  label: Text(_sportLabel(context, type)),
                  selected: filter.sportType == type,
                  onSelected: (_) {
                    ref.read(buddyFilterProvider.notifier).state =
                        filter.copyWith(sportType: type);
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                ),
              )),
        ],
      ),
    );
  }

  /// 区块标题 — _SectionLabel 风格（UPPERCASE + secondary color）
  Widget _buildSectionHeader(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required String title,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          AppSpacing.hGapSM,
          Text(
            title.toUpperCase(),
            style: AppTextStyles.label.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  /// 伙伴为空的提示
  Widget _buildEmptyBuddies(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg, horizontal: AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 48,
            color: isDark
                ? AppColors.darkTextSecondary.withValues(alpha: 0.4)
                : AppColors.lightTextSecondary.withValues(alpha: 0.4),
          ),
          AppSpacing.vGapSM,
          Text(
            context.l10n.nearbyNoBuddies,
            style: AppTextStyles.body.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          AppSpacing.vGapXS,
          Text(
            context.l10n.nearbyNoBuddiesTip,
            style: AppTextStyles.caption.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary.withValues(alpha: 0.6)
                  : AppColors.lightTextSecondary.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// 训练馆为空的提示
  Widget _buildEmptyGyms(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg, horizontal: AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center_outlined,
            size: 48,
            color: isDark
                ? AppColors.darkTextSecondary.withValues(alpha: 0.4)
                : AppColors.lightTextSecondary.withValues(alpha: 0.4),
          ),
          AppSpacing.vGapSM,
          Text(
            context.l10n.nearbyNoGyms,
            style: AppTextStyles.body.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          AppSpacing.vGapXS,
          Text(
            context.l10n.nearbyNoGymsTip,
            style: AppTextStyles.caption.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary.withValues(alpha: 0.6)
                  : AppColors.lightTextSecondary.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// 约练请求处理
  Future<void> _handleBuddyUp(
    BuildContext context,
    WidgetRef ref,
    String targetUserId,
  ) async {
    try {
      await ref.read(buddyRequestActionProvider).send(targetUserId);
      if (context.mounted) {
        ErrorHandler.showSuccess(context, context.l10n.commonSuccess);
      }
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.showError(context, e);
      }
    }
  }

  /// 运动类型 l10n 标签
  String _sportLabel(BuildContext context, String type) {
    final l10n = context.l10n;
    switch (type) {
      case 'hyrox':
        return l10n.sportHyrox;
      case 'crossfit':
        return l10n.sportCrossfit;
      case 'yoga':
        return l10n.sportYoga;
      case 'pilates':
        return l10n.sportPilates;
      case 'running':
        return l10n.sportRunning;
      case 'swimming':
        return l10n.sportSwimming;
      case 'strength':
        return l10n.sportStrength;
      default:
        return l10n.sportOther;
    }
  }
}
