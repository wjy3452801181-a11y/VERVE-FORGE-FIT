import 'package:flutter/material.dart';

/// VerveForge 颜色常量
/// 高端运动科技感配色体系 — 纯黑白灰
class AppColors {
  AppColors._();

  // ========================
  // 品牌色
  // ========================
  static const Color primary = Color(0xFF111111);        // 纯黑 — 主色调
  static const Color secondary = Color(0xFF555555);      // 中灰 — 辅色
  static const Color accent = Color(0xFF333333);         // 深灰 — 强调色

  // ========================
  // 卡片 tint（黑色不同透明度）
  // ========================
  static Color cardTint05 = primary.withValues(alpha: 0.05);  // 极淡底色
  static Color cardTint10 = primary.withValues(alpha: 0.10);  // 淡底色
  static Color cardTint15 = primary.withValues(alpha: 0.15);  // hover 底色
  static Color cardTint20 = primary.withValues(alpha: 0.20);  // 强调底色
  static Color cardTint30 = primary.withValues(alpha: 0.30);  // 高亮底色

  // 深色模式 tint（白色不同透明度）
  static Color cardTintDark05 = Colors.white.withValues(alpha: 0.05);
  static Color cardTintDark10 = Colors.white.withValues(alpha: 0.10);
  static Color cardTintDark15 = Colors.white.withValues(alpha: 0.15);

  // ========================
  // 卡片发光 / 阴影
  // ========================
  static const Color cardGlow = Color(0x40000000);             // 黑色微光
  static const Color cardGlowStrong = Color(0x66000000);       // 强发光（hover）
  static const Color cardGlowDark = Color(0x40FFFFFF);         // 深色模式：白色微光
  static const Color cardGlowDarkStrong = Color(0x66FFFFFF);   // 深色模式：强白光
  static const Color cardShadow = Color(0x1A000000);           // 通用阴影 10%
  static const Color cardShadowDark = Color(0x33000000);       // 深色阴影 20%

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
  // 深色主题（真正暗黑模式）
  // ========================
  static const Color darkBackground = Color(0xFF0A0A0A);    // 纯黑底
  static const Color darkSurface = Color(0xFF141414);       // 深灰表面
  static const Color darkCard = Color(0xFF1A1A1A);          // 卡片底色
  static const Color darkCardHover = Color(0xFF222222);     // 卡片 hover
  static const Color darkTextPrimary = Color(0xFFF5F5F5);   // 主文字 — 白色
  static const Color darkTextSecondary = Color(0xFF999999); // 辅助文字
  static const Color darkDivider = Color(0xFF2A2A2A);       // 分割线
  static const Color darkBorder = Color(0xFF333333);        // 卡片边框

  // ========================
  // 浅色主题
  // ========================
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF8F8F8);
  static const Color lightCard = Color(0xFFF2F2F2);
  static const Color lightCardHover = Color(0xFFEAEAEA);
  static const Color lightTextPrimary = Color(0xFF111111);
  static const Color lightTextSecondary = Color(0xFF888888);
  static const Color lightDivider = Color(0xFFE0E0E0);
  static const Color lightBorder = Color(0xFFE5E5E5);

  // ========================
  // 语义色
  // ========================
  static const Color success = Color(0xFF2ECC71);  // 翠绿 — 成功/完成
  static const Color warning = Color(0xFFF39C12);  // 琥珀 — 警告/注意
  static const Color error   = Color(0xFFE74C3C);  // 朱红 — 错误/危险
  static const Color info    = Color(0xFF3498DB);  // 天蓝 — 提示/信息

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
