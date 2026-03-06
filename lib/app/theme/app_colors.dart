import 'package:flutter/material.dart';

/// VerveForge 颜色常量
/// 品牌色系：运动活力橙 + 深灰底色
class AppColors {
  AppColors._();

  // ========================
  // 品牌色
  // ========================
  static const Color primary = Color(0xFFFF6B35);        // 活力橙 — 主色调
  static const Color secondary = Color(0xFF4ECDC4);      // 薄荷绿 — 辅色
  static const Color accent = Color(0xFFFFE66D);         // 明黄 — 强调色

  // ========================
  // 运动类型标识色
  // ========================
  static const Color hyrox = Color(0xFFFF6B35);          // HYROX — 橙色
  static const Color crossfit = Color(0xFFE63946);       // CrossFit — 红色
  static const Color yoga = Color(0xFF4ECDC4);           // 瑜伽 — 薄荷绿
  static const Color pilates = Color(0xFF7B68EE);        // 普拉提 — 紫色
  static const Color running = Color(0xFF45B7D1);        // 跑步 — 蓝色
  static const Color swimming = Color(0xFF2196F3);       // 游泳 — 深蓝
  static const Color strength = Color(0xFFFF8C00);       // 力量 — 深橙
  static const Color other = Color(0xFF9E9E9E);          // 其他 — 灰色

  // ========================
  // 深色主题
  // ========================
  static const Color darkBackground = Color(0xFF0D0D0D);   // 纯深底色
  static const Color darkSurface = Color(0xFF1A1A1A);       // 卡片/导航栏底色
  static const Color darkCard = Color(0xFF252525);           // 卡片内层
  static const Color darkTextPrimary = Color(0xFFF5F5F5);   // 主文字
  static const Color darkTextSecondary = Color(0xFF9E9E9E); // 辅助文字
  static const Color darkDivider = Color(0xFF333333);       // 分割线

  // ========================
  // 浅色主题
  // ========================
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF757575);

  // ========================
  // 语义色
  // ========================
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF42A5F5);

  // ========================
  // 训练强度色阶（1-10）
  // ========================
  static const List<Color> intensityGradient = [
    Color(0xFF4ECDC4), // 1 — 极低
    Color(0xFF45B7D1), // 2
    Color(0xFF42A5F5), // 3
    Color(0xFF7B68EE), // 4
    Color(0xFFFFE66D), // 5 — 中等
    Color(0xFFFFC107), // 6
    Color(0xFFFF8C00), // 7
    Color(0xFFFF6B35), // 8
    Color(0xFFE63946), // 9
    Color(0xFFD32F2F), // 10 — 极高
  ];
}
