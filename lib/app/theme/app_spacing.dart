import 'package:flutter/material.dart';

/// VerveForge 间距常量
///
/// 基于 4px 基础单元的间距系统
/// xs=4, sm=8, md=16, lg=24, xl=32, xxl=48, xxxl=64
///
/// 使用原则：
/// - 组件内部 padding → 使用 inset* 系列
/// - 同级组件之间 gap → 使用 gap* 系列
/// - 页面级外边距 → pagePadding / pageHorizontal
/// - 列表项之间 → itemGap
class AppSpacing {
  AppSpacing._();

  // ========================
  // 基础单元（4px 网格）
  // ========================
  static const double xs    = 4;
  static const double sm    = 8;
  static const double md    = 16;
  static const double lg    = 24;
  static const double xl    = 32;
  static const double xxl   = 48;
  static const double xxxl  = 64;

  // 补充细粒度值（与现有代码对齐）
  static const double x3    = 3;   // divider gap
  static const double x6    = 6;   // card vertical margin
  static const double x10   = 10;  // tight spacing
  static const double x12   = 12;  // list item internal
  static const double x14   = 14;  // icon-label gap
  static const double x20   = 20;  // card padding default

  // ========================
  // 语义化间距
  // ========================

  /// 页面水平内边距（左右各 16px）
  static const double pageHorizontal = 16;

  /// 页面垂直内边距（上下各 24px）
  static const double pageVertical = 24;

  /// 页面整体 padding（用于 SingleChildScrollView / Column）
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: pageHorizontal,
    vertical: pageVertical,
  );

  /// 页面仅水平 padding
  static const EdgeInsets pageHorizontalPadding = EdgeInsets.symmetric(
    horizontal: pageHorizontal,
  );

  // ========================
  // 卡片 inset（内边距）
  // ========================

  /// 卡片默认内边距（20px 四周）
  static const EdgeInsets cardPadding = EdgeInsets.all(x20);

  /// 卡片紧凑内边距（16px 四周，列表场景）
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(md);

  /// 卡片外边距（水平 16 + 垂直 6，与主题 cardTheme.margin 一致）
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(
    horizontal: pageHorizontal,
    vertical: x6,
  );

  // ========================
  // 输入框 inset
  // ========================

  /// 输入框内边距（与 inputDecorationTheme 一致）
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: 14,
  );

  // ========================
  // 按钮 inset
  // ========================

  /// 主按钮内边距
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: md,
  );

  /// 紧凑按钮内边距
  static const EdgeInsets buttonPaddingCompact = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: sm,
  );

  // ========================
  // 列表 / 网格间距
  // ========================

  /// 列表项之间的垂直间距
  static const double itemGap = sm;

  /// 卡片列表中卡片之间的垂直间距
  static const double cardGap = x6;

  /// 图标与标签之间的间距
  static const double iconGap = sm;

  /// Section 标题与内容之间的间距
  static const double sectionGap = x12;

  // ========================
  // SizedBox 快捷方式
  // ========================

  static const Widget gapXS   = SizedBox(width: xs, height: xs);
  static const Widget gapSM   = SizedBox(width: sm, height: sm);
  static const Widget gapMD   = SizedBox(width: md, height: md);
  static const Widget gapLG   = SizedBox(width: lg, height: lg);
  static const Widget gapXL   = SizedBox(width: xl, height: xl);

  static const Widget hGapXS  = SizedBox(width: xs);
  static const Widget hGapSM  = SizedBox(width: sm);
  static const Widget hGapMD  = SizedBox(width: md);
  static const Widget hGapLG  = SizedBox(width: lg);

  static const Widget vGapXS  = SizedBox(height: xs);
  static const Widget vGapSM  = SizedBox(height: sm);
  static const Widget vGapMD  = SizedBox(height: md);
  static const Widget vGapLG  = SizedBox(height: lg);
  static const Widget vGapXL  = SizedBox(height: xl);
  static const Widget vGapXXL = SizedBox(height: xxl);

  // 常用非标准高度
  static const Widget vGap6   = SizedBox(height: x6);
  static const Widget vGap12  = SizedBox(height: x12);
  static const Widget vGap14  = SizedBox(height: x14);
  static const Widget vGap20  = SizedBox(height: x20);
  static const Widget hGap12  = SizedBox(width: x12);
  static const Widget hGap14  = SizedBox(width: x14);
}
