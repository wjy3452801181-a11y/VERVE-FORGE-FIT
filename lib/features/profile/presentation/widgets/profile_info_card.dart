import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/extensions/context_extensions.dart';

/// 训练信息卡片 — 城市 + 运动经验等级
class ProfileInfoCard extends StatelessWidget {
  final String city;
  final String experienceLevel;

  const ProfileInfoCard({
    super.key,
    required this.city,
    required this.experienceLevel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x20,
        vertical: AppSpacing.md,
      ),
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
        children: [
          _buildInfoChip(Icons.location_city, _cityName(context, city)),
          AppSpacing.hGapMD,
          _buildInfoChip(Icons.trending_up, experienceLevel),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        AppSpacing.hGapSM,
        Text(text, style: AppTextStyles.caption),
      ],
    );
  }

  String _cityName(BuildContext context, String city) {
    final names = {
      'beijing': context.l10n.cityBeijing,
      'shanghai': context.l10n.cityShanghai,
      'guangzhou': context.l10n.cityGuangzhou,
      'shenzhen': context.l10n.cityShenzhen,
      'hongkong': context.l10n.cityHongkong,
    };
    return names[city] ?? city;
  }
}
