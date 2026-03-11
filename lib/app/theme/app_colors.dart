import 'package:flutter/material.dart';

/// VerveForge 颜色常量
/// 纯黑白配色体系
class AppColors {
  AppColors._();

  // ========================
  // 品牌色
  // ========================
  static const Color primary = Color(0xFF111111);        // 纯黑 — 主色调
  static const Color secondary = Color(0xFF555555);      // 中灰 — 辅色
  static const Color accent = Color(0xFF333333);         // 深灰 — 强调色

  // ========================
  // 运动类型标识色（统一黑色，通过 icon 形状区分）
  // ========================
  static const Color hyrox = Color(0xFF111111);
  static const Color crossfit = Color(0xFF111111);
  static const Color yoga = Color(0xFF111111);
  static const Color pilates = Color(0xFF111111);
  static const Color running = Color(0xFF111111);
  static const Color swimming = Color(0xFF111111);
  static const Color strength = Color(0xFF111111);
  static const Color other = Color(0xFF111111);

  // ========================
  // 深色主题（统一为白底体系）
  // ========================
  static const Color darkBackground = Color(0xFFFFFFFF);   // 白色底
  static const Color darkSurface = Color(0xFFF5F5F5);      // 浅灰表面
  static const Color darkCard = Color(0xFFF0F0F0);         // 卡片底色
  static const Color darkTextPrimary = Color(0xFF111111);  // 主文字 — 黑色
  static const Color darkTextSecondary = Color(0xFF888888); // 辅助文字
  static const Color darkDivider = Color(0xFFE0E0E0);      // 分割线

  // ========================
  // 浅色主题（与深色统一）
  // ========================
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightCard = Color(0xFFF0F0F0);
  static const Color lightTextPrimary = Color(0xFF111111);
  static const Color lightTextSecondary = Color(0xFF888888);

  // ========================
  // 语义色
  // ========================
  static const Color success = Color(0xFF111111);
  static const Color warning = Color(0xFF666666);
  static const Color error = Color(0xFF111111);
  static const Color info = Color(0xFF888888);

  // ========================
  // 训练强度色阶（1-10）灰度渐变
  // ========================
  static const List<Color> intensityGradient = [
    Color(0xFFE0E0E0), // 1 — 极低
    Color(0xFFCCCCCC), // 2
    Color(0xFFB8B8B8), // 3
    Color(0xFFA0A0A0), // 4
    Color(0xFF888888), // 5 — 中等
    Color(0xFF707070), // 6
    Color(0xFF555555), // 7
    Color(0xFF3A3A3A), // 8
    Color(0xFF222222), // 9
    Color(0xFF111111), // 10 — 极高
  ];
}
