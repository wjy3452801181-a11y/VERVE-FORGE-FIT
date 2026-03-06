import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/datetime_extensions.dart';
import '../../../core/errors/error_handler.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/sport_type_icon.dart';
import '../data/workout_repository.dart';
import '../domain/workout_model.dart';
import '../providers/workout_provider.dart';
import 'widgets/photo_grid.dart';

/// 训练详情页 — 查看/编辑/删除
class WorkoutDetailPage extends ConsumerWidget {
  final String workoutId;

  const WorkoutDetailPage({super.key, required this.workoutId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(workoutDetailProvider(workoutId));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.workoutDetail),
        actions: [
          detailAsync.whenOrNull(
                data: (workout) {
                  if (workout == null) return const SizedBox.shrink();
                  return PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'delete') {
                        await _handleDelete(context, ref, workout);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          context.l10n.commonDelete,
                          style: TextStyle(color: context.colorScheme.error),
                        ),
                      ),
                    ],
                  );
                },
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(context.l10n.commonError)),
        data: (workout) {
          if (workout == null) {
            return Center(child: Text(context.l10n.commonEmpty));
          }
          return _buildDetail(context, workout);
        },
      ),
    );
  }

  Widget _buildDetail(BuildContext context, WorkoutModel workout) {
    final intensityColor = AppColors.intensityGradient[workout.intensity - 1];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 运动类型 + 时间
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                SportTypeIcon(sportType: workout.sportType, size: 56),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _sportLabel(workout.sportType),
                        style: AppTextStyles.subtitle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        workout.workoutDate.fullDate,
                        style: AppTextStyles.caption,
                      ),
                      Text(
                        workout.workoutDate.hm,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                if (workout.isDraft)
                  Chip(
                    label: const Text('草稿', style: TextStyle(fontSize: 12)),
                    backgroundColor: AppColors.warning.withValues(alpha: 0.15),
                    side: BorderSide.none,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 数据卡片
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetric(
                  Icons.timer_outlined,
                  workout.durationDisplay,
                  '时长',
                ),
                _buildDivider(),
                _buildMetric(
                  Icons.speed,
                  '${workout.intensity}/10',
                  workout.intensityLabel,
                  color: intensityColor,
                ),
                if (workout.caloriesBurned != null) ...[
                  _buildDivider(),
                  _buildMetric(
                    Icons.local_fire_department_outlined,
                    '${workout.caloriesBurned}',
                    'kcal',
                    color: AppColors.primary,
                  ),
                ],
                if (workout.avgHeartRate != null) ...[
                  _buildDivider(),
                  _buildMetric(
                    Icons.favorite_outline,
                    '${workout.avgHeartRate}',
                    'bpm',
                    color: AppColors.crossfit,
                  ),
                ],
              ],
            ),
          ),
        ),

        // 备注
        if (workout.notes != null && workout.notes!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('备注', style: AppTextStyles.subtitle.copyWith(fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(workout.notes!, style: AppTextStyles.body),
                ],
              ),
            ),
          ),
        ],

        // 照片
        if (workout.photoUrls.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('训练照片', style: AppTextStyles.subtitle.copyWith(fontSize: 14)),
                  const SizedBox(height: 8),
                  PhotoGrid(
                    photoUrls: workout.photoUrls,
                    readOnly: true,
                  ),
                ],
              ),
            ),
          ),
        ],

        // HealthKit 标记
        if (workout.healthKitId != null) ...[
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: Icon(Icons.favorite, color: AppColors.crossfit),
              title: Text('来自 Apple Health'),
              subtitle: Text('此记录从 HealthKit 自动同步'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMetric(
    IconData icon,
    String value,
    String label, {
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color ?? AppColors.primary),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTextStyles.number.copyWith(
            color: color ?? AppColors.primary,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.grey.withValues(alpha: 0.2),
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    WorkoutModel workout,
  ) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: context.l10n.workoutDeleteConfirm,
      confirmText: context.l10n.commonDelete,
      isDestructive: true,
    );
    if (!confirmed) return;

    try {
      await ref.read(workoutRepositoryProvider).softDelete(workout.id);
      ref.invalidate(workoutListProvider);
      ref.invalidate(workoutStatsProvider);
      if (context.mounted) {
        ErrorHandler.showSuccess(context, context.l10n.commonSuccess);
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) ErrorHandler.showError(context, e);
    }
  }

  String _sportLabel(String type) {
    const labels = {
      'hyrox': 'HYROX',
      'crossfit': 'CrossFit',
      'yoga': '瑜伽',
      'pilates': '普拉提',
      'running': '跑步',
      'swimming': '游泳',
      'strength': '力量训练',
      'other': '其他',
    };
    return labels[type] ?? type;
  }
}
