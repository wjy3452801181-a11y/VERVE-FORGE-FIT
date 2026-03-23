import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';

/// AI Avatar 玻璃拟态卡片（glassmorphism card）
///
/// AI Avatar feature 专用；用于 Create / Detail / SharedView 页面。
/// 勿在 AI Avatar 功能以外使用（glassmorphism 是 AI 子品牌视觉语言）。
class AiGlassCard extends StatelessWidget {
  final Widget child;

  const AiGlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.md),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: AppSpacing.cardPaddingCompact,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(AppSpacing.md),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.5),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
