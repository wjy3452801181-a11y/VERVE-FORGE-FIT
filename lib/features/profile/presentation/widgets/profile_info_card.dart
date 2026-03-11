import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            _buildInfoChip(Icons.location_city, _cityName(context, city)),
            const SizedBox(width: 16),
            _buildInfoChip(Icons.trending_up, experienceLevel),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
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
