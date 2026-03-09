import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/sport_type_icon.dart';
import '../domain/challenge_model.dart';
import '../providers/challenge_provider.dart';

/// 挑战赛列表页 — Tab 3
/// 支持城市 / 运动类型筛选、Supabase Realtime 更新提示、排行榜快捷入口
class ChallengesPage extends ConsumerWidget {
  const ChallengesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 激活 Realtime 订阅
    ref.watch(challengeRealtimeProvider);

    final filter = ref.watch(challengeFilterProvider);
    final challengesAsync = ref.watch(challengeListProvider);
    final hasUpdates = ref.watch(challengeHasUpdatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.challengeTitle),
        actions: [
          // 实时状态指示灯
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  context.l10n.challengeRealtime,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // 创建挑战入口
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
          const SizedBox(height: 4),

          // 运动类型筛选器
          _buildSportTypeFilter(context, ref, filter),
          const SizedBox(height: 8),

          // 列表
          Expanded(
            child: challengesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
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
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
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
                padding: const EdgeInsets.only(right: 8),
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
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
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
                padding: const EdgeInsets.only(right: 8),
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

  /// 使用 l10n 获取运动类型标签
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
// 更新提示横幅
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.1),
          border: Border(
            bottom: BorderSide(
              color: AppColors.secondary.withValues(alpha: 0.2),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.refresh, size: 16, color: AppColors.secondary),
            const SizedBox(width: 6),
            Text(
              context.l10n.challengeNewAvailable,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.secondary,
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
// 挑战赛卡片（增加排行榜快捷入口）
// -------------------------------------------------------

class _ChallengeCard extends StatelessWidget {
  final ChallengeModel challenge;
  final VoidCallback? onTap;

  const _ChallengeCard({required this.challenge, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题行
              Row(
                children: [
                  SportTypeIcon(
                      sportType: challenge.sportType, size: 36),
                  const SizedBox(width: 12),
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
                        const SizedBox(height: 2),
                        Text(
                          '${challenge.sportTypeDisplay} · ${challenge.goalTypeDisplay} ${challenge.goalValue}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(context),
                ],
              ),
              const SizedBox(height: 12),

              // 进度条
              if (challenge.isActive) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: challenge.remainingDays > 0
                        ? 1.0 -
                            (challenge.remainingDays / challenge.totalDays)
                                .clamp(0.0, 1.0)
                        : 1.0,
                    minHeight: 4,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.08),
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // 信息行
              Row(
                children: [
                  Icon(Icons.people_outline,
                      size: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5)),
                  const SizedBox(width: 4),
                  Text(
                    context.l10n.challengeParticipants(
                        challenge.participantCount),
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.schedule,
                      size: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5)),
                  const SizedBox(width: 4),
                  Text(
                    challenge.remainingDays > 0
                        ? context.l10n
                            .challengeRemainingDays(challenge.remainingDays)
                        : context.l10n.challengeStatusCompleted,
                    style: AppTextStyles.caption,
                  ),
                  if (challenge.city != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.location_on_outlined,
                        size: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5)),
                    const SizedBox(width: 2),
                    Text(challenge.city!, style: AppTextStyles.caption),
                  ],
                ],
              ),

              // 创建者 + 排行榜入口 + 已参加标记
              if (challenge.creatorNickname != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.4)),
                    const SizedBox(width: 4),
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
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.leaderboard,
                                size: 12, color: AppColors.primary),
                            const SizedBox(width: 3),
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
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          context.l10n.challengeJoin,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.secondary,
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

  Widget _buildStatusBadge(BuildContext context) {
    if (challenge.isFull) {
      return Chip(
        label: Text(context.l10n.challengeFull,
            style: const TextStyle(fontSize: 10)),
        backgroundColor: AppColors.warning.withValues(alpha: 0.15),
        side: BorderSide.none,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      );
    }
    if (challenge.isActive) {
      return Chip(
        label: Text(context.l10n.challengeStatusActive,
            style: const TextStyle(fontSize: 10)),
        backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
        side: BorderSide.none,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      );
    }
    return const SizedBox.shrink();
  }
}
