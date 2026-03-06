import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/sport_type_icon.dart';

/// 横向滚动运动类型选择器
class SportTypeSelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;
  final bool showAll;

  const SportTypeSelector({
    super.key,
    this.selected,
    required this.onSelected,
    this.showAll = false,
  });

  @override
  Widget build(BuildContext context) {
    final types = showAll ? ['all', ...AppConstants.sportTypes] : AppConstants.sportTypes;

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final type = types[index];
          final isSelected = showAll
              ? (type == 'all' ? selected == null : selected == type)
              : selected == type;

          if (type == 'all') {
            return _buildAllItem(context, isSelected);
          }

          return GestureDetector(
            onTap: () => onSelected(type),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: SportTypeIcon(sportType: type, size: 44),
                ),
                const SizedBox(height: 4),
                Text(
                  _sportLabel(type),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? AppColors.primary : null,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAllItem(BuildContext context, bool isSelected) {
    return GestureDetector(
      onTap: () => onSelected('all'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: AppColors.primary, width: 2)
                  : null,
            ),
            padding: const EdgeInsets.all(2),
            child: Icon(
              Icons.grid_view_rounded,
              size: 24,
              color: isSelected ? AppColors.primary : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '全部',
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? AppColors.primary : null,
            ),
          ),
        ],
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
      'strength': '力量',
      'other': '其他',
    };
    return labels[type] ?? type;
  }
}
