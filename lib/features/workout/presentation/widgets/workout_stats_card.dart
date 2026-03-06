import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/workout_stats.dart';

/// 训练统计行（本周/本月/总时长）
class WorkoutStatsCard extends StatelessWidget {
  final WorkoutStats stats;

  const WorkoutStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('${stats.weeklyCount}', '本周训练'),
            _buildDivider(),
            _buildStatItem('${stats.monthlyCount}', '本月训练'),
            _buildDivider(),
            _buildStatItem(stats.totalHoursDisplay, '总时长'),
          ],
        ),
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
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 32,
      color: Colors.grey.withValues(alpha: 0.2),
    );
  }
}
