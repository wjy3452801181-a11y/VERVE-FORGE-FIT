import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';

/// 个性标签芯片组件（运动主题）
///
/// 支持多选，带 emoji 前缀和点击动画
/// 深色模式下使用半透明玻璃拟态背景
class PersonalityChip extends StatelessWidget {
  final String trait;
  final bool isSelected;
  final VoidCallback? onTap;

  const PersonalityChip({
    super.key,
    required this.trait,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final info = _traitInfo(context, trait);

    final chip = GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : context.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // emoji 前缀
            Text(info.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            // 标签文字
            Text(
              info.label,
              style: TextStyle(
                fontSize: 13,
                color: isSelected
                    ? AppColors.primary
                    : context.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            // 选中对号
            if (isSelected) ...[
              const SizedBox(width: 4),
              const Icon(Icons.check, size: 14, color: AppColors.primary),
            ],
          ],
        ),
      ),
    );

    // 非交互模式（onTap == null）：告知屏幕阅读器这是装饰性内容，不可操作
    if (onTap == null) {
      return ExcludeSemantics(child: chip);
    }
    return chip;
  }

  /// 标签 key → emoji + l10n 显示名称
  _TraitInfo _traitInfo(BuildContext context, String trait) {
    final map = {
      // 运动主题标签（16 个）
      'earlyRunner':      _TraitInfo('🌅', context.l10n.aiTraitEarlyRunner),
      'yogaMaster':       _TraitInfo('🧘', context.l10n.aiTraitYogaMaster),
      'ironAddict':       _TraitInfo('🏋️', context.l10n.aiTraitIronAddict),
      'crossfitFanatic':  _TraitInfo('💪', context.l10n.aiTraitCrossfitFanatic),
      'marathoner':       _TraitInfo('🏃', context.l10n.aiTraitMarathoner),
      'gymRat':           _TraitInfo('🐀', context.l10n.aiTraitGymRat),
      'outdoorExplorer':  _TraitInfo('🏔️', context.l10n.aiTraitOutdoorExplorer),
      'flexibilityPro':   _TraitInfo('🤸', context.l10n.aiTraitFlexibilityPro),
      'teamPlayer':       _TraitInfo('🤝', context.l10n.aiTraitTeamPlayer),
      'soloWarrior':      _TraitInfo('🥷', context.l10n.aiTraitSoloWarrior),
      'techGeek':         _TraitInfo('📱', context.l10n.aiTraitTechGeek),
      'nutritionNerd':    _TraitInfo('🥗', context.l10n.aiTraitNutritionNerd),
      'restDayHater':     _TraitInfo('🔥', context.l10n.aiTraitRestDayHater),
      'warmupSkipper':    _TraitInfo('⏭️', context.l10n.aiTraitWarmupSkipper),
      'prBeast':          _TraitInfo('📈', context.l10n.aiTraitPrBeast),
      'cheerleader':      _TraitInfo('📣', context.l10n.aiTraitCheerleader),
      // 通用性格标签（旧版兼容）
      'enthusiastic':     _TraitInfo('🔥', context.l10n.aiTraitEnthusiastic),
      'professional':     _TraitInfo('💼', context.l10n.aiTraitProfessional),
      'humorous':         _TraitInfo('😄', context.l10n.aiTraitHumorous),
      'encouraging':      _TraitInfo('💪', context.l10n.aiTraitEncouraging),
      'calm':             _TraitInfo('🧘', context.l10n.aiTraitCalm),
      'friendly':         _TraitInfo('😊', context.l10n.aiTraitFriendly),
      'direct':           _TraitInfo('🎯', context.l10n.aiTraitDirect),
      'curious':          _TraitInfo('🔍', context.l10n.aiTraitCurious),
    };
    return map[trait] ?? _TraitInfo('🏷️', trait);
  }
}

/// 标签信息（emoji + 本地化标签名称）
class _TraitInfo {
  final String emoji;
  final String label;
  const _TraitInfo(this.emoji, this.label);
}
