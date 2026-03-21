import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

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

// -------------------------------------------------------
// 【性能优化】聚合标记组件 — 显示聚合数量的圆形徽标
// 用于 marker clustering：多个相邻训练馆合并为一个圆圈 + 数字
// -------------------------------------------------------

class GymClusterMarker extends StatelessWidget {
  final int count;
  final bool isSelected;

  const GymClusterMarker({
    super.key,
    required this.count,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    // 根据聚合数量动态调整大小：2-5 小，6-20 中，20+ 大
    final double size;
    final double fontSize;
    if (count <= 5) {
      size = isSelected ? 44 : 36;
      fontSize = 13;
    } else if (count <= 20) {
      size = isSelected ? 52 : 44;
      fontSize = 14;
    } else {
      size = isSelected ? 60 : 52;
      fontSize = 15;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
        border: Border.all(
          color: Colors.white,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: isSelected ? 10 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          count > 99 ? '99+' : '$count',
          style: AppTextStyles.label.copyWith(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
