import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';

/// 训练等级徽章（Bronze / Silver / Gold / Elite）
///
/// 显示用户的竞技等级，配合积分系统使用。
///
/// ```dart
/// RankChip(rank: RankTier.gold)
/// RankChip(rank: RankTier.silver, showIcon: true)
/// ```
enum RankTier {
  /// 入门级
  rookie,

  /// 铜牌
  bronze,

  /// 银牌
  silver,

  /// 金牌
  gold,

  /// 精英
  elite,
}

extension RankTierExtension on RankTier {
  String get label {
    switch (this) {
      case RankTier.rookie:  return 'ROOKIE';
      case RankTier.bronze:  return 'BRONZE';
      case RankTier.silver:  return 'SILVER';
      case RankTier.gold:    return 'GOLD';
      case RankTier.elite:   return 'ELITE';
    }
  }

  /// 等级主色（背景色）
  Color get bgColor {
    switch (this) {
      case RankTier.rookie:  return const Color(0xFF2A2A2A);
      case RankTier.bronze:  return const Color(0xFF3D2B1F);
      case RankTier.silver:  return const Color(0xFF252525);
      case RankTier.gold:    return AppColors.voltSurface;   // volt 半透明
      case RankTier.elite:   return AppColors.volt;          // 实心 volt
    }
  }

  /// 等级文字色
  Color get textColor {
    switch (this) {
      case RankTier.rookie:  return const Color(0xFF888888);
      case RankTier.bronze:  return const Color(0xFFCD7F32);
      case RankTier.silver:  return const Color(0xFFBCBCBC);
      case RankTier.gold:    return AppColors.volt;          // volt 文字
      case RankTier.elite:   return AppColors.primary;       // 黑字在 volt 底上
    }
  }

  /// 是否使用 volt 发光
  bool get hasVoltGlow => this == RankTier.gold || this == RankTier.elite;

  String get emoji {
    switch (this) {
      case RankTier.rookie:  return '';
      case RankTier.bronze:  return '🥉';
      case RankTier.silver:  return '🥈';
      case RankTier.gold:    return '🥇';
      case RankTier.elite:   return '👑';
    }
  }
}

class RankChip extends StatelessWidget {
  const RankChip({
    super.key,
    required this.rank,
    this.showIcon = true,
    this.compact = false,
  });

  final RankTier rank;
  final bool showIcon;

  /// compact=true 时显示仅图标（无文字），用于小空间
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final emoji = rank.emoji;

    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xs,
            )
          : const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.x3,
            ),
      decoration: BoxDecoration(
        color: rank.bgColor,
        borderRadius: AppRadius.bPill,
        border: Border.all(
          color: rank.textColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
        boxShadow: rank.hasVoltGlow
            ? AppShadows.voltGlow(intensity: 0.6)
            : null,
      ),
      child: compact
          ? Text(emoji.isEmpty ? rank.label[0] : emoji,
              style: AppTextStyles.label.copyWith(color: rank.textColor))
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showIcon && emoji.isNotEmpty) ...[
                  Text(emoji, style: const TextStyle(fontSize: 12)),
                  AppSpacing.hGapXS,
                ],
                Text(
                  rank.label,
                  style: AppTextStyles.label.copyWith(
                    color: rank.textColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
    );
  }
}
