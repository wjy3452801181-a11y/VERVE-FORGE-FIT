import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../providers/gym_provider.dart';

/// 训练馆筛选栏（运动类型 chip + 距离排序）
class GymFilterBar extends ConsumerWidget {
  const GymFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(gymFilterProvider);

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "全部"筛选
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(context.l10n.workoutFilterAll),
              selected: filter.sportType == null,
              onSelected: (_) {
                ref.read(gymFilterProvider.notifier).state =
                    filter.copyWith(clearSportType: true);
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
            ),
          ),
          // 运动类型 chips
          ...AppConstants.sportTypes.map((type) {
            final isSelected = filter.sportType == type;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(_sportLabel(context, type)),
                selected: isSelected,
                onSelected: (_) {
                  ref.read(gymFilterProvider.notifier).state = isSelected
                      ? filter.copyWith(clearSportType: true)
                      : filter.copyWith(sportType: type);
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
              ),
            );
          }),
        ],
      ),
    );
  }

  String _sportLabel(BuildContext context, String type) {
    final l10n = context.l10n;
    switch (type) {
      case 'hyrox':
        return l10n.sportHyrox;
      case 'crossfit':
        return l10n.sportCrossfit;
      case 'yoga':
        return l10n.sportYoga;
      case 'pilates':
        return l10n.sportPilates;
      case 'running':
        return l10n.sportRunning;
      case 'swimming':
        return l10n.sportSwimming;
      case 'strength':
        return l10n.sportStrength;
      default:
        return l10n.sportOther;
    }
  }
}
