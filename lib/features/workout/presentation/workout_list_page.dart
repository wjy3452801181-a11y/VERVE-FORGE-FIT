import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/workout_provider.dart';
import 'widgets/sport_type_selector.dart';
import 'widgets/workout_card.dart';
import 'widgets/workout_stats_card.dart';
import 'workout_detail_page.dart';

/// 训练历史列表页 — 分页 + 筛选 + 下拉刷新
class WorkoutListPage extends ConsumerWidget {
  const WorkoutListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(workoutFilterProvider);
    final workoutsAsync = ref.watch(workoutListProvider);
    final statsAsync = ref.watch(workoutStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.workoutHistory),
      ),
      body: Column(
        children: [
          // 筛选器
          SportTypeSelector(
            showAll: true,
            selected: filter.sportType,
            onSelected: (type) {
              if (type == 'all') {
                ref.read(workoutFilterProvider.notifier).state =
                    filter.copyWith(clearSportType: true);
              } else {
                ref.read(workoutFilterProvider.notifier).state =
                    filter.copyWith(sportType: type);
              }
            },
          ),
          const SizedBox(height: 8),

          // 统计卡片
          statsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (stats) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: WorkoutStatsCard(stats: stats),
            ),
          ),
          const SizedBox(height: 8),

          // 列表
          Expanded(
            child: workoutsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyStateWidget(
                icon: Icons.error_outline,
                title: context.l10n.commonError,
                actionText: context.l10n.commonRetry,
                onAction: () => ref.invalidate(workoutListProvider),
              ),
              data: (workouts) {
                if (workouts.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.fitness_center_outlined,
                    title: context.l10n.workoutNoRecords,
                    subtitle: context.l10n.workoutStartFirst,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(workoutListProvider);
                    ref.invalidate(workoutStatsProvider);
                  },
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollEndNotification &&
                          notification.metrics.extentAfter < 200) {
                        ref.read(workoutListProvider.notifier).loadMore();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      itemCount: workouts.length,
                      itemBuilder: (context, index) {
                        return WorkoutCard(
                          workout: workouts[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WorkoutDetailPage(
                                  workoutId: workouts[index].id,
                                ),
                              ),
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
}
