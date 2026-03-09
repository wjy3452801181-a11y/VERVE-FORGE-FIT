import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
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
    final intensityColor = AppColors.intensityGradient[workout.intensity - 1];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 运动类型图标
              SportTypeIcon(sportType: workout.sportType, size: 44),
              const SizedBox(width: 12),

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
                            style: AppTextStyles.subtitle.copyWith(fontSize: 15),
                          ),
                        ),
                        if (workout.isDraft)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 14,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                        const SizedBox(width: 4),
                        Text(
                          workout.durationDisplay,
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: intensityColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${workout.intensity}/10',
                          style: AppTextStyles.caption,
                        ),
                        if (workout.caloriesBurned != null) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.local_fire_department_outlined, size: 14,
                              color: AppColors.primary.withValues(alpha: 0.7)),
                          const SizedBox(width: 2),
                          Text(
                            '${workout.caloriesBurned}kcal',
                            style: AppTextStyles.caption,
                          ),
                        ],
                        if (workout.hasMetrics && workout.metricsDisplay.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.emoji_events_outlined, size: 14,
                              color: _sportColor(workout.sportType).withValues(alpha: 0.7)),
                          const SizedBox(width: 2),
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
                    const SizedBox(height: 2),
                    Text(
                      workout.workoutDate.smart,
                      style: AppTextStyles.caption.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // 照片指示器
              if (workout.photoUrls.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.photo_library_outlined,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),

              const Icon(Icons.chevron_right, size: 20),
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
