import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// 地图标记组件（运动类型着色 + 名称气泡）
class GymMapMarker extends StatelessWidget {
  final String name;
  final String? primarySportType;
  final bool isSelected;

  const GymMapMarker({
    super.key,
    required this.name,
    this.primarySportType,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _sportColor(primarySportType);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 名称气泡
        if (isSelected)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (isSelected) const SizedBox(height: 4),
        // 标记点
        Container(
          width: isSelected ? 36 : 28,
          height: isSelected ? 36 : 28,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.fitness_center,
            color: Colors.white,
            size: 14,
          ),
        ),
      ],
    );
  }

  Color _sportColor(String? sportType) {
    switch (sportType) {
      case 'hyrox':
        return AppColors.hyrox;
      case 'crossfit':
        return AppColors.crossfit;
      case 'yoga':
        return AppColors.yoga;
      case 'pilates':
        return AppColors.pilates;
      case 'running':
        return AppColors.running;
      case 'swimming':
        return AppColors.swimming;
      case 'strength':
        return AppColors.strength;
      default:
        return AppColors.primary;
    }
  }
}
