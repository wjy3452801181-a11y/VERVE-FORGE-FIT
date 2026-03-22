import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_radius.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton.dart';
import '../../../shared/widgets/sport_type_icon.dart';
import '../../../shared/widgets/workout_bar.dart';
import '../domain/challenge_model.dart';
import '../providers/challenge_provider.dart';

/// 挑战赛列表页 — Tab 3
/// 支持城市 / 运动类型筛选、Supabase Realtime 更新提示、排行榜快捷入口
class ChallengesPage extends ConsumerWidget {
  const ChallengesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(challengeRealtimeProvider);

    final filter = ref.watch(challengeFilterProvider);
    final challengesAsync = ref.watch(challengeListProvider);
    final hasUpdates = ref.watch(challengeHasUpdatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.challengeTitle),
        actions: [
          // 实时状态指示灯（复用 _RealtimeDot 风格的简单绿点）
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                AppSpacing.hGapXS,
                Text(
                  context.l10n.challengeRealtime,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.success,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(AppRoutes.challengeCreate),
          ),
        ],
      ),
      body: Column(
        children: [
          // 有更新提示横幅
          if (hasUpdates)
            _ChallengeUpdatesBanner(
              onRefresh: () {
                ref.read(challengeHasUpdatesProvider.notifier).state = false;
                ref.read(challengeListProvider.notifier).refresh();
              },
            ),

          // 城市筛选器
          _buildCityFilter(context, ref, filter),
          AppSpacing.vGapXS,

          // 运动类型筛选器
          _buildSportTypeFilter(context, ref, filter),
          AppSpacing.vGapSM,

          // 列表
          Expanded(
            child: challengesAsync.when(
              loading: () => ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (_, __) => const Padding(
                  padding: AppSpacing.cardMargin,
                  child: SkeletonCard(),
                ),
              ),
              error: (e, _) => EmptyStateWidget(
                icon: Icons.error_outline,
                title: context.l10n.commonError,
                actionText: context.l10n.commonRetry,
                onAction: () => ref.invalidate(challengeListProvider),
              ),
              data: (challenges) {
                if (challenges.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.emoji_events_outlined,
                    title: context.l10n.challengeNoRecords,
                    subtitle: context.l10n.challengeStartFirst,
                    actionText: context.l10n.challengeCreate,
                    onAction: () => context.push(AppRoutes.challengeCreate),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.read(challengeHasUpdatesProvider.notifier).state =
                        false;
                    await ref.read(challengeListProvider.notifier).refresh();
                  },
                  color: AppColors.primary,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollEndNotification &&
                          notification.metrics.extentAfter < 200) {
                        ref.read(challengeListProvider.notifier).loadMore();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      itemCount: challenges.length,
                      itemBuilder: (context, index) {
                        return _ChallengeCard(
                          challenge: challenges[index],
                          onTap: () {
                            context.push(
                              '${AppRoutes.challengeDetail}/${challenges[index].id}',
                            );
                          },
                        );
                      },
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

  Widget _buildCityFilter(
    BuildContext context,
    WidgetRef ref,
    ChallengeFilter filter,
  ) {
    const cities = AppConstants.supportedCities;

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x12),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(context.l10n.challengeCityAll),
              selected: filter.city == null,
              onSelected: (_) {
                ref.read(challengeFilterProvider.notifier).state =
                    filter.copyWith(clearCity: true);
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          ...cities.map((city) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: ChoiceChip(
                  label: Text(city),
                  selected: filter.city == city,
                  onSelected: (_) {
                    ref.read(challengeFilterProvider.notifier).state =
                        filter.copyWith(city: city);
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.15),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSportTypeFilter(
    BuildContext context,
    WidgetRef ref,
    ChallengeFilter filter,
  ) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x12),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(context.l10n.workoutFilterAll),
              selected: filter.sportType == null,
              onSelected: (_) {
                ref.read(challengeFilterProvider.notifier).state =
                    filter.copyWith(clearSportType: true);
              },
              selectedColor: AppColors.secondary.withValues(alpha: 0.15),
            ),
          ),
          ...AppConstants.sportTypes.map((type) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: ChoiceChip(
                  label: Text(_sportLabel(context, type)),
                  selected: filter.sportType == type,
                  onSelected: (_) {
                    ref.read(challengeFilterProvider.notifier).state =
                        filter.copyWith(sportType: type);
                  },
                  selectedColor: AppColors.secondary.withValues(alpha: 0.15),
                ),
              )),
        ],
      ),
    );
  }

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

// -------------------------------------------------------
// 更新提示横幅 — 与 feed_page _NewPostsBanner 风格对齐
// -------------------------------------------------------

class _ChallengeUpdatesBanner extends StatelessWidget {
  final VoidCallback onRefresh;

  const _ChallengeUpdatesBanner({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRefresh,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.x10,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.08),
          border: Border(
            bottom: BorderSide(
              color: AppColors.success.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.refresh, size: 16, color: AppColors.success),
            AppSpacing.hGapXS,
            Text(
              context.l10n.challengeNewAvailable,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------
// 挑战赛卡片
// -------------------------------------------------------

class _ChallengeCard extends StatelessWidget {
  final ChallengeModel challenge;
  final VoidCallback? onTap;

  const _ChallengeCard({required this.challenge, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 进度值（已过时间 / 总天数）
    final elapsed = challenge.totalDays - challenge.remainingDays;
    final progressRatio = challenge.totalDays > 0
        ? (elapsed / challenge.totalDays).clamp(0.0, 1.0)
        : 1.0;
    final intensity = (progressRatio * 10).round().clamp(1, 10);

    return Container(
      margin: AppSpacing.cardMargin,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: AppRadius.bLG,
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.5)
              : AppColors.lightBorder.withValues(alpha: 0.6),
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.bLG,
        child: Padding(
          padding: AppSpacing.cardPaddingCompact,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题行
              Row(
                children: [
                  SportTypeIcon(sportType: challenge.sportType, size: 36),
                  AppSpacing.hGap12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title,
                          style: AppTextStyles.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppSpacing.vGapXS,
                        Text(
                          '${challenge.sportTypeDisplay} · ${challenge.goalTypeDisplay} ${challenge.goalValue}',
                          style: AppTextStyles.caption.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.hGapSM,
                  _buildStatusBadge(context, isDark),
                ],
              ),
              AppSpacing.vGap12,

              // 进度条 — WorkoutBar 替换 LinearProgressIndicator
              if (challenge.isActive) ...[
                WorkoutBar(
                  value: progressRatio,
                  intensity: intensity,
                  showLabel: false,
                  height: 5,
                ),
                AppSpacing.vGap10,
              ],

              // 信息行：参与人数 + 剩余天数 + 城市
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 14,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  AppSpacing.hGapXS,
                  Text(
                    context.l10n
                        .challengeParticipants(challenge.participantCount),
                    style: AppTextStyles.caption,
                  ),
                  AppSpacing.hGapMD,
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: challenge.remainingDays > 0 &&
                            challenge.remainingDays <= 3
                        ? AppColors.warning
                        : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                  ),
                  AppSpacing.hGapXS,
                  Text(
                    challenge.remainingDays > 0
                        ? context.l10n
                            .challengeRemainingDays(challenge.remainingDays)
                        : context.l10n.challengeStatusCompleted,
                    style: AppTextStyles.caption.copyWith(
                      color: challenge.remainingDays > 0 &&
                              challenge.remainingDays <= 3
                          ? AppColors.warning
                          : null,
                      fontWeight: challenge.remainingDays <= 3
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  if (challenge.city != null) ...[
                    AppSpacing.hGapMD,
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    AppSpacing.hGapXS,
                    Text(challenge.city!, style: AppTextStyles.caption),
                  ],
                ],
              ),

              // 创建者行 + 排行榜入口 + 已参加标记
              if (challenge.creatorNickname != null) ...[
                AppSpacing.vGapSM,
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 13,
                      color: isDark
                          ? AppColors.darkTextSecondary.withValues(alpha: 0.6)
                          : AppColors.lightTextSecondary.withValues(alpha: 0.6),
                    ),
                    AppSpacing.hGapXS,
                    Text(
                      challenge.creatorNickname!,
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                    ),
                    const Spacer(),

                    // 排行榜快捷入口
                    GestureDetector(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: AppRadius.bXS,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.leaderboard,
                                size: 12, color: AppColors.primary),
                            AppSpacing.hGapXS,
                            Text(
                              context.l10n.challengeLeaderboard,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (challenge.isJoined == true) ...[
                      AppSpacing.hGapSM,
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: AppRadius.bXS,
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.25),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          context.l10n.challengeJoin,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, bool isDark) {
    if (challenge.isFull) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.12),
          borderRadius: AppRadius.bXS,
          border: Border.all(
            color: AppColors.warning.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Text(
          context.l10n.challengeFull,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.warning,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    if (challenge.isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.12),
          borderRadius: AppRadius.bXS,
          border: Border.all(
            color: AppColors.success.withValues(alpha: 0.25),
            width: 0.5,
          ),
        ),
        child: Text(
          context.l10n.challengeStatusActive,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.success,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
