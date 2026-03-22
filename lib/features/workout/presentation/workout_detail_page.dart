import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_radius.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/datetime_extensions.dart';
import '../../../core/errors/error_handler.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/skeleton.dart';
import '../../../shared/widgets/sport_type_icon.dart';
import '../../../shared/widgets/workout_bar.dart';
import '../data/workout_repository.dart';
import '../domain/workout_model.dart';
import '../domain/workout_metrics.dart';
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
        loading: () => ListView(
          padding: AppSpacing.pagePadding,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            SkeletonCard(),
            SizedBox(height: AppSpacing.x12),
            SkeletonStatBar(count: 3),
          ],
        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final intensityColor = AppColors.intensityGradient[workout.intensity - 1];
    final sportColor = _sportColor(workout.sportType);

    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        // 运动类型 + 时间
        _DetailCard(
          child: Row(
            children: [
              SportTypeIcon(sportType: workout.sportType, size: 56),
              AppSpacing.hGapMD,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _sportLabel(workout.sportType),
                      style: AppTextStyles.subtitle,
                    ),
                    AppSpacing.vGapXS,
                    Text(workout.workoutDate.fullDate,
                        style: AppTextStyles.caption),
                    Text(workout.workoutDate.hm,
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
              if (workout.isDraft)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: AppRadius.bXS,
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.4),
                      width: 0.5,
                    ),
                  ),
                  child: const Text(
                    '草稿',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        AppSpacing.vGap12,

        // 数据卡片：时长 + 强度 + 卡路里 + 心率
        _DetailCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetric(
                    Icons.timer_outlined,
                    workout.durationDisplay,
                    '时长',
                    isDark: isDark,
                  ),
                  _VerticalDivider(isDark: isDark),
                  _buildMetric(
                    Icons.speed,
                    '${workout.intensity}/10',
                    workout.intensityLabel,
                    color: intensityColor,
                    isDark: isDark,
                  ),
                  if (workout.caloriesBurned != null) ...[
                    _VerticalDivider(isDark: isDark),
                    _buildMetric(
                      Icons.local_fire_department_outlined,
                      '${workout.caloriesBurned}',
                      'kcal',
                      color: AppColors.primary,
                      isDark: isDark,
                    ),
                  ],
                  if (workout.avgHeartRate != null) ...[
                    _VerticalDivider(isDark: isDark),
                    _buildMetric(
                      Icons.favorite_outline,
                      '${workout.avgHeartRate}',
                      'bpm',
                      color: AppColors.crossfit,
                      isDark: isDark,
                    ),
                  ],
                ],
              ),
              AppSpacing.vGap12,
              // 强度进度条
              WorkoutBar(
                value: workout.intensity / 10,
                intensity: workout.intensity,
                showLabel: false,
                height: 5,
              ),
            ],
          ),
        ),

        // 备注
        if (workout.notes != null && workout.notes!.isNotEmpty) ...[
          AppSpacing.vGap12,
          _DetailCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionLabel(label: '备注'),
                AppSpacing.vGapSM,
                Text(workout.notes!, style: AppTextStyles.body),
              ],
            ),
          ),
        ],

        // 运动专项成绩
        if (workout.hasMetrics) ...[
          AppSpacing.vGap12,
          _DetailCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.emoji_events_outlined,
                        size: 16,
                        color: sportColor),
                    AppSpacing.hGapXS,
                    const _SectionLabel(label: '运动专项成绩'),
                  ],
                ),
                AppSpacing.vGap12,
                _buildMetricsContent(context, workout, isDark),
              ],
            ),
          ),
        ],

        // 照片
        if (workout.photoUrls.isNotEmpty) ...[
          AppSpacing.vGap12,
          _DetailCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionLabel(label: '训练照片'),
                AppSpacing.vGapSM,
                PhotoGrid(
                  photoUrls: workout.photoUrls,
                  readOnly: true,
                ),
              ],
            ),
          ),
        ],

        // HealthKit 标记
        if (workout.healthKitId != null) ...[
          AppSpacing.vGap12,
          _DetailCard(
            child: Row(
              children: [
                const Icon(Icons.favorite, color: AppColors.crossfit, size: 20),
                AppSpacing.hGapMD,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('来自 Apple Health', style: AppTextStyles.body),
                    AppSpacing.vGapXS,
                    Text(
                      '此记录从 HealthKit 自动同步',
                      style: AppTextStyles.caption.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],

        AppSpacing.vGapLG,
      ],
    );
  }

  Widget _buildMetric(
    IconData icon,
    String value,
    String label, {
    Color? color,
    required bool isDark,
  }) {
    final c = color ??
        (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);
    return Column(
      children: [
        Icon(icon, size: 20, color: c),
        AppSpacing.vGap6,
        Text(
          value,
          style: AppTextStyles.number.copyWith(color: c, fontSize: 18),
        ),
        AppSpacing.vGapXS,
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildMetricsContent(
      BuildContext context, WorkoutModel workout, bool isDark) {
    switch (workout.sportType) {
      case 'hyrox':
        final m = HyroxMetrics.fromJson(workout.metrics);
        return Column(
          children: [
            ...m.stations.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.x6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s.name, style: AppTextStyles.caption),
                      Text(s.timeDisplay,
                          style: AppTextStyles.number.copyWith(fontSize: 14)),
                    ],
                  ),
                )),
            Divider(
              height: AppSpacing.md,
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('总成绩',
                    style:
                        AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                Text(m.totalTimeDisplay,
                    style: AppTextStyles.number
                        .copyWith(fontSize: 18, color: AppColors.hyrox)),
              ],
            ),
          ],
        );
      case 'crossfit':
        final m = CrossFitMetrics.fromJson(workout.metrics);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (m.wodName != null && m.wodName!.isNotEmpty)
              _buildInfoRow('WOD', m.wodName!, isDark),
            if (m.wodType != null)
              _buildInfoRow('类型', m.wodTypeDisplay, isDark),
            if (m.score != null && m.score!.isNotEmpty)
              _buildInfoRow('成绩', m.score!, isDark),
            if (m.movements.isNotEmpty) ...[
              AppSpacing.vGapSM,
              Wrap(
                spacing: AppSpacing.x6,
                runSpacing: AppSpacing.xs,
                children: m.movements
                    .map((mov) => Chip(
                          label: Text(mov,
                              style: const TextStyle(fontSize: 11)),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          side: BorderSide.none,
                          backgroundColor:
                              AppColors.crossfit.withValues(alpha: 0.08),
                        ))
                    .toList(),
              ),
            ],
          ],
        );
      case 'yoga':
      case 'pilates':
        final m = YogaPilatesMetrics.fromJson(workout.metrics);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (m.className != null && m.className!.isNotEmpty)
              _buildInfoRow('课程', m.className!, isDark),
            if (m.difficulty != null)
              _buildInfoRow('难度', m.difficultyDisplay, isDark),
            if (m.focusAreas.isNotEmpty) ...[
              AppSpacing.vGapSM,
              Wrap(
                spacing: AppSpacing.x6,
                runSpacing: AppSpacing.xs,
                children: m.focusAreas
                    .map((area) => Chip(
                          label: Text(
                              YogaPilatesMetrics.focusAreaLabels[area] ?? area,
                              style: const TextStyle(fontSize: 11)),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          side: BorderSide.none,
                          backgroundColor:
                              (workout.sportType == 'pilates'
                                      ? AppColors.pilates
                                      : AppColors.yoga)
                                  .withValues(alpha: 0.08),
                        ))
                    .toList(),
              ),
            ],
          ],
        );
      case 'running':
        final m = RunningMetrics.fromJson(workout.metrics);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (m.distanceKm != null)
              _buildInfoRow('距离', '${m.distanceKm} km', isDark),
            if (m.paceMinPerKm != null)
              _buildInfoRow('配速', m.paceDisplay, isDark),
            if (m.elevationM != null)
              _buildInfoRow('爬升', '${m.elevationM} m', isDark),
          ],
        );
      default:
        return Text(workout.metricsDisplay, style: AppTextStyles.body);
    }
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.x6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.caption.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              )),
          Text(
            value,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
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

  Color _sportColor(String type) {
    const colors = {
      'hyrox': AppColors.hyrox,
      'crossfit': AppColors.crossfit,
      'yoga': AppColors.yoga,
      'pilates': AppColors.pilates,
      'running': AppColors.running,
      'swimming': AppColors.swimming,
      'strength': AppColors.strength,
      'other': AppColors.other,
    };
    return colors[type] ?? AppColors.primary;
  }
}

// -------------------------------------------------------
// 通用卡片容器
// -------------------------------------------------------

class _DetailCard extends StatelessWidget {
  final Widget child;

  const _DetailCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
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
      child: child,
    );
  }
}

// -------------------------------------------------------
// Section 标签
// -------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      label.toUpperCase(),
      style: AppTextStyles.label.copyWith(
        color: isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// -------------------------------------------------------
// 垂直分割线
// -------------------------------------------------------

class _VerticalDivider extends StatelessWidget {
  final bool isDark;

  const _VerticalDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 44,
      color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
    );
  }
}
