import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';

/// 说话风格选择器（3 种：活泼/沉稳/幽默）
///
/// 每种风格显示：
/// - 标题 + 简介描述
/// - 模拟聊天气泡预览（展示该风格的实际回复效果）
class StyleSelector extends StatelessWidget {
  final String selectedStyle;
  final ValueChanged<String> onChanged;

  const StyleSelector({
    super.key,
    required this.selectedStyle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final styles = [
      _StyleOption(
        key: 'lively',
        emoji: '⚡',
        label: context.l10n.aiStyleLively,
        desc: context.l10n.aiStyleLivelyDesc,
        preview: context.l10n.aiStyleLivelyPreview,
      ),
      _StyleOption(
        key: 'steady',
        emoji: '🧊',
        label: context.l10n.aiStyleSteady,
        desc: context.l10n.aiStyleSteadyDesc,
        preview: context.l10n.aiStyleSteadyPreview,
      ),
      _StyleOption(
        key: 'humorous',
        emoji: '😂',
        label: context.l10n.aiStyleHumorous,
        desc: context.l10n.aiStyleHumorousDesc,
        preview: context.l10n.aiStyleHumorousPreview,
      ),
    ];

    return Column(
      children: styles.map((style) {
        final isSelected = selectedStyle == style.key;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => onChanged(style.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : context.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isSelected ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color:
                              AppColors.primary.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题行：emoji + 名称 + 选中标记
                  Row(
                    children: [
                      Text(style.emoji,
                          style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              style.label,
                              style: AppTextStyles.subtitle.copyWith(
                                color: isSelected
                                    ? AppColors.primary
                                    : context.colorScheme.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            Text(
                              style.desc,
                              style: AppTextStyles.caption.copyWith(
                                color:
                                    context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                    ],
                  ),

                  // 模拟聊天气泡预览
                  if (isSelected) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: context.colorScheme.surfaceContainerLow,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(14),
                          topRight: Radius.circular(14),
                          bottomRight: Radius.circular(14),
                          bottomLeft: Radius.circular(4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.aiAvatarPreviewHint,
                            style: AppTextStyles.label.copyWith(
                              color:
                                  context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            style.preview,
                            style: AppTextStyles.body.copyWith(
                              color: context.colorScheme.onSurface,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StyleOption {
  final String key;
  final String emoji;
  final String label;
  final String desc;
  final String preview;

  const _StyleOption({
    required this.key,
    required this.emoji,
    required this.label,
    required this.desc,
    required this.preview,
  });
}
