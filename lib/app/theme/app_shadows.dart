import 'package:flutter/material.dart';

import 'app_colors.dart';

/// VerveForge 阴影常量
///
/// 阴影层级体系（0 = 无阴影，4 = 强悬浮）：
/// - level0: 无阴影（扁平化场景）
/// - level1: 微妙底色阴影（静止卡片）
/// - level2: 标准卡片阴影（默认）
/// - level3: 悬浮阴影（hover / 选中状态）
/// - level4: 强悬浮 + 发光（能力卡 / 交互高峰）
///
/// 所有阴影均提供 dark / light 两套，通过 isDark 参数选取
class AppShadows {
  AppShadows._();

  // ========================
  // 无阴影
  // ========================
  static const List<BoxShadow> none = [];

  // ========================
  // Level 1 — 微妙（表面感知）
  // ========================
  static List<BoxShadow> level1({bool isDark = false}) => [
        BoxShadow(
          color: isDark ? AppColors.cardShadowDark : AppColors.cardShadow,
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  // ========================
  // Level 2 — 标准（默认卡片）
  // ========================
  static List<BoxShadow> level2({bool isDark = false}) => [
        BoxShadow(
          color: isDark ? AppColors.cardShadowDark : AppColors.cardShadow,
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  // ========================
  // Level 3 — 悬浮（hover / 按下）
  // ========================
  static List<BoxShadow> level3({bool isDark = false}) => [
        BoxShadow(
          color: isDark ? AppColors.cardShadowDark : AppColors.cardShadow,
          blurRadius: 12,
          offset: const Offset(0, 8),
          spreadRadius: 2,
        ),
        BoxShadow(
          color: isDark
              ? AppColors.cardGlowDark.withValues(alpha: 0.12)
              : AppColors.cardGlow.withValues(alpha: 0.12),
          blurRadius: 24,
          spreadRadius: 1,
        ),
      ];

  // ========================
  // Level 4 — 强悬浮 + 发光（能力卡 / 精选内容）
  // ========================
  static List<BoxShadow> level4({bool isDark = false}) => [
        BoxShadow(
          color: isDark ? AppColors.cardShadowDark : AppColors.cardShadow,
          blurRadius: 16,
          offset: const Offset(0, 12),
          spreadRadius: 4,
        ),
        BoxShadow(
          color: isDark
              ? AppColors.cardGlowDarkStrong.withValues(alpha: 0.20)
              : AppColors.cardGlowStrong.withValues(alpha: 0.20),
          blurRadius: 30,
          spreadRadius: 3,
        ),
      ];

  // ========================
  // 图标容器发光（Capability Card 专用）
  // ========================
  static List<BoxShadow> iconGlow({bool isDark = false}) => [
        BoxShadow(
          color: isDark
              ? AppColors.cardGlowDark.withValues(alpha: 0.15)
              : AppColors.cardGlow.withValues(alpha: 0.15),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ];

  // ========================
  // BottomSheet / Dialog 后景阴影
  // ========================
  static List<BoxShadow> overlay({bool isDark = false}) => [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.60)
              : Colors.black.withValues(alpha: 0.30),
          blurRadius: 40,
          spreadRadius: 10,
        ),
      ];

  // ========================
  // 文字阴影（高对比度场景下的文字可读性）
  // ========================
  static const List<Shadow> textSubtle = [
    Shadow(
      color: Color(0x33000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];
}
