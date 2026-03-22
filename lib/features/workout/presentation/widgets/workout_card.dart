import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../shared/widgets/sport_type_icon.dart';
import '../../domain/workout_model.dart';

/// 训练卡片（列表/日历中使用）
class WorkoutCard extends StatelessWidget {
  final WorkoutModel workout;
  final VoidCallback? onTap;

  const WorkoutCard({
    super.key,
    required this.workout,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final intensityColor = AppColors.intensityGradient[workout.intensity - 1];

    return Container(
      margin: AppSpacing.cardMargin,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: AppRadius.bMD,
        border: Border(
          left: BorderSide(color: _sportColor(workout.sportType), width: 3),
          top: BorderSide(
            color: isDark
                ? AppColors.darkBorder.withValues(alpha: 0.5)
                : AppColors.lightBorder.withValues(alpha: 0.6),
            width: 0.5,
          ),
          right: BorderSide(
            color: isDark
                ? AppColors.darkBorder.withValues(alpha: 0.5)
                : AppColors.lightBorder.withValues(alpha: 0.6),
            width: 0.5,
          ),
          bottom: BorderSide(
            color: isDark
                ? AppColors.darkBorder.withValues(alpha: 0.5)
                : AppColors.lightBorder.withValues(alpha: 0.6),
            width: 0.5,
          ),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.bMD,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.x12),
          child: Row(
            children: [
              // 运动类型图标
              SportTypeIcon(sportType: workout.sportType, size: 44),
              AppSpacing.hGap12,

              // 信息区
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _sportLabel(workout.sportType),
                            style:
                                AppTextStyles.subtitle.copyWith(fontSize: 15),
                          ),
                        ),
                        if (workout.isDraft)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.x6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.15),
                              borderRadius: AppRadius.bXS,
                            ),
                            child: const Text(
                              '草稿',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    AppSpacing.vGapXS,
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                        AppSpacing.hGapXS,
                        Text(workout.durationDisplay,
                            style: AppTextStyles.caption),
                        AppSpacing.hGap12,
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: intensityColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        AppSpacing.hGapXS,
                        Text('${workout.intensity}/10',
                            style: AppTextStyles.caption),
                        if (workout.caloriesBurned != null) ...[
                          AppSpacing.hGap12,
                          Icon(
                            Icons.local_fire_department_outlined,
                            size: 14,
                            color: AppColors.primary.withValues(alpha: 0.7),
                          ),
                          AppSpacing.hGapXS,
                          Text('${workout.caloriesBurned}kcal',
                              style: AppTextStyles.caption),
                        ],
                        if (workout.hasMetrics &&
                            workout.metricsDisplay.isNotEmpty) ...[
                          AppSpacing.hGap12,
                          Icon(
                            Icons.emoji_events_outlined,
                            size: 14,
                            color: _sportColor(workout.sportType)
                                .withValues(alpha: 0.7),
                          ),
                          AppSpacing.hGapXS,
                          Flexible(
                            child: Text(
                              workout.metricsDisplay,
                              style: AppTextStyles.caption.copyWith(
                                color: _sportColor(workout.sportType),
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    AppSpacing.vGapXS,
                    Text(
                      workout.workoutDate.smart,
                      style: AppTextStyles.caption.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.4),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // 照片指示器
              if (workout.photoUrls.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.sm),
                  child: Icon(
                    Icons.photo_library_outlined,
                    size: 18,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3),
                  ),
                ),

              Icon(
                Icons.chevron_right,
                size: 20,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ],
          ),
        ),
      ),
    );
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
