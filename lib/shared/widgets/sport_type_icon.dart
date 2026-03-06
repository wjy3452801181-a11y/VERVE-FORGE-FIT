import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// 运动类型图标映射组件
class SportTypeIcon extends StatelessWidget {
  final String sportType;
  final double size;
  final bool showLabel;

  const SportTypeIcon({
    super.key,
    required this.sportType,
    this.size = 40,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _sportConfig[sportType] ?? _sportConfig['other']!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: config.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(size * 0.25),
          ),
          child: Icon(
            config.icon,
            size: size * 0.55,
            color: config.color,
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          Text(
            config.label,
            style: TextStyle(fontSize: size * 0.25),
          ),
        ],
      ],
    );
  }

  static final Map<String, _SportConfig> _sportConfig = {
    'hyrox': const _SportConfig(Icons.directions_run, AppColors.hyrox, 'HYROX'),
    'crossfit': const _SportConfig(Icons.fitness_center, AppColors.crossfit, 'CrossFit'),
    'yoga': const _SportConfig(Icons.self_improvement, AppColors.yoga, '瑜伽'),
    'pilates': const _SportConfig(Icons.accessibility_new, AppColors.pilates, '普拉提'),
    'running': const _SportConfig(Icons.directions_run, AppColors.running, '跑步'),
    'swimming': const _SportConfig(Icons.pool, AppColors.swimming, '游泳'),
    'strength': const _SportConfig(Icons.fitness_center, AppColors.strength, '力量'),
    'other': const _SportConfig(Icons.sports, AppColors.other, '其他'),
  };
}

class _SportConfig {
  final IconData icon;
  final Color color;
  final String label;

  const _SportConfig(this.icon, this.color, this.label);
}
