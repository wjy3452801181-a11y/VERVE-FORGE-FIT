import 'package:flutter/material.dart';

/// VerveForge 圆角常量
///
/// 圆角体系遵循「层级越高，圆角越大」原则：
/// - 微小元素（进度条、标签点）→ xs/sm
/// - 输入框、按钮 → md (14px)
/// - 卡片、对话框 → lg (24px)
/// - Chip、标签 → pill (20px，近全圆角)
/// - 圆形 → full (9999px)
class AppRadius {
  AppRadius._();

  // ========================
  // 基础数值
  // ========================
  static const double xs    = 4;   // 进度条、细节装饰
  static const double sm    = 8;   // 小型 Badge、小卡片
  static const double md    = 14;  // 输入框、按钮（与主题一致）
  static const double lg    = 24;  // 卡片、对话框、BottomSheet（与主题一致）
  static const double pill  = 20;  // Chip、Tag（接近全圆角）
  static const double full  = 9999; // 完全圆形

  // 补充值（CapCard 内部使用）
  static const double x2    = 2;   // 竖线装饰
  static const double x10   = 10;  // 步骤编号圆角
  static const double x12   = 12;  // 中等容器

  // ========================
  // BorderRadius 快捷方式
  // ========================

  /// 进度条 / 细节 (4px)
  static const BorderRadius bXS   = BorderRadius.all(Radius.circular(xs));

  /// 小型容器 (8px)
  static const BorderRadius bSM   = BorderRadius.all(Radius.circular(sm));

  /// 输入框 / 按钮 (14px)
  static const BorderRadius bMD   = BorderRadius.all(Radius.circular(md));

  /// 卡片 / 对话框 (24px)
  static const BorderRadius bLG   = BorderRadius.all(Radius.circular(lg));

  /// Chip / Tag (20px)
  static const BorderRadius bPill = BorderRadius.all(Radius.circular(pill));

  /// 完全圆形
  static const BorderRadius bFull = BorderRadius.all(Radius.circular(full));

  // ========================
  // 特定场景 BorderRadius
  // ========================

  /// BottomSheet 顶部圆角
  static const BorderRadius bottomSheet = BorderRadius.vertical(
    top: Radius.circular(lg),
  );

  /// CapCard 图标容器 (14px)
  static const BorderRadius iconContainer = BorderRadius.all(
    Radius.circular(md),
  );

  /// 步骤编号徽章 (10px)
  static const BorderRadius stepBadge = BorderRadius.all(
    Radius.circular(x10),
  );

  /// 引用竖线 (2px)
  static const BorderRadius quoteLine = BorderRadius.all(
    Radius.circular(x2),
  );

  // ========================
  // RoundedRectangleBorder 快捷方式
  // ========================

  /// 标准卡片 Shape（无边框，用于 ClipRRect）
  static const RoundedRectangleBorder cardShape = RoundedRectangleBorder(
    borderRadius: bLG,
  );

  static const RoundedRectangleBorder buttonShape = RoundedRectangleBorder(
    borderRadius: bMD,
  );

  static const RoundedRectangleBorder inputShape = RoundedRectangleBorder(
    borderRadius: bMD,
  );
}
