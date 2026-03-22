import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_radius.dart';
import '../../domain/workout_stats.dart';

/// 训练统计行（本周/本月/总时长）
class WorkoutStatsCard extends StatelessWidget {
  final WorkoutStats stats;

  const WorkoutStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('${stats.weeklyCount}', '本周训练'),
          _buildDivider(isDark),
          _buildStatItem('${stats.monthlyCount}', '本月训练'),
          _buildDivider(isDark),
          _buildStatItem(stats.totalHoursDisplay, '总时长'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.number.copyWith(color: AppColors.primary),
        ),
        AppSpacing.vGapXS,
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1,
      height: 32,
      color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
    );
  }
}
