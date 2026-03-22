import 'package:flutter/material.dart';

/// VerveForge 动效常量
///
/// 动效原则：
/// - 快速响应（输入、按压）→ fast (150ms)
/// - 状态过渡（展开、折叠）→ normal (250ms)
/// - 高端卡片动效（hover 发光）→ premium (300ms)
/// - 页面进入 / 离开 → page (400ms)
///
/// Curve 哲学：
/// - 进入用 easeOut（快入慢收，感觉迅捷）
/// - 离开用 easeIn（慢起快离，感觉干净）
/// - 弹性 UI 用 easeOutCubic / easeOutQuart
class AppAnimations {
  AppAnimations._();

  // ========================
  // 时长
  // ========================

  /// 即时反馈（按钮按下、Ripple）
  static const Duration instant = Duration(milliseconds: 100);

  /// 快速（输入框聚焦、图标切换）
  static const Duration fast = Duration(milliseconds: 150);

  /// 标准（Chip 选中、列表 item 出现）
  static const Duration normal = Duration(milliseconds: 250);

  /// 高端卡片 hover（与 CapCard 保持一致）
  static const Duration premium = Duration(milliseconds: 300);

  /// 页面切换 / 底部弹窗
  static const Duration page = Duration(milliseconds: 400);

  /// 骨架屏闪烁周期
  static const Duration shimmer = Duration(milliseconds: 1200);

  // ========================
  // Curve 常量
  // ========================

  /// 进入动效（快入慢收）— 最常用
  static const Curve enter  = Curves.easeOutCubic;

  /// 离开动效（慢起快离）
  static const Curve exit   = Curves.easeInCubic;

  /// 通用过渡（进出对称）
  static const Curve smooth = Curves.easeInOutCubic;

  /// 弹性收尾（用于 scale/card hover）
  static const Curve spring = Curves.easeOutQuart;

  /// 线性（进度条等需要恒速的场景）
  static const Curve linear = Curves.linear;

  // ========================
  // 完整 CurvedAnimation 配置（便于直接传入 AnimationController）
  // ========================

  /// 快速进入配置
  static CurvedAnimation fastEnter(AnimationController controller) =>
      CurvedAnimation(parent: controller, curve: enter, reverseCurve: exit);

  /// 标准进出配置
  static CurvedAnimation normalSmooth(AnimationController controller) =>
      CurvedAnimation(parent: controller, curve: smooth);

  /// CapCard 专用 hover 配置
  static CurvedAnimation premiumHover(AnimationController controller) =>
      CurvedAnimation(parent: controller, curve: enter);

  // ========================
  // 常用 Tween 工厂
  // ========================

  /// 淡入淡出
  static Tween<double> fadeInOut = Tween(begin: 0.0, end: 1.0);

  /// 标准卡片 hover 缩放
  static Tween<double> cardHoverScale = Tween(begin: 1.0, end: 1.015);

  /// 按钮按下缩放（mobile tap feedback）
  static Tween<double> tapScale = Tween(begin: 1.0, end: 0.97);

  /// 向上滑入偏移（列表 item 进入）
  static Tween<Offset> slideUp = Tween(
    begin: const Offset(0, 0.15),
    end: Offset.zero,
  );

  // ========================
  // 骨架屏动效配置
  // ========================

  /// 骨架屏闪烁起始颜色透明度
  static const double shimmerMinOpacity = 0.3;
  static const double shimmerMaxOpacity = 0.8;
}
