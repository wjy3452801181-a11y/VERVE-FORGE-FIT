// ignore: dangling_library_doc_comments
/// VerveForge Design System
///
/// 统一导出所有设计 token，业务代码只需引入此文件：
///   import 'package:verve_forge/app/theme/design_system.dart';
///
/// 包含：
/// - AppColors   — 完整颜色体系（品牌色、语义色、深浅色主题）
/// - AppTextStyles — 完整排版体系（h1–number，Inter 字体）
/// - AppSpacing  — 间距系统（4px 网格，语义化 EdgeInsets）
/// - AppRadius   — 圆角系统（xs/sm/md/lg/pill/full）
/// - AppShadows  — 阴影系统（level0–level4 + 专项发光）
/// - AppAnimations — 动效系统（时长 + Curve + Tween 工厂）
/// - AppTheme    — Material 3 主题配置（dark + light）

export 'app_colors.dart';
export 'app_text_styles.dart';
export 'app_spacing.dart';
export 'app_radius.dart';
export 'app_shadows.dart';
export 'app_animations.dart';
export 'app_theme.dart';
