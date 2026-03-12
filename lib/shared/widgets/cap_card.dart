import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// CapCard 卡片类型
enum CapCardType {
  /// 默认通用卡片
  standard,

  /// 步骤卡 — 渐变边框 + 进度条
  step,

  /// 引用卡 — 左侧竖线 + 引用符号
  quote,

  /// 能力卡 — 图标发光 + 标题加粗
  capability,
}

/// VerveForge 高端卡片组件
///
/// 玻璃拟态 + 黑白灰微光 + hover 动画
/// 支持 4 种类型：standard / step / quote / capability
class CapCard extends StatefulWidget {
  const CapCard({
    super.key,
    required this.child,
    this.type = CapCardType.standard,
    this.onTap,
    this.padding,
    this.margin,
    this.stepIndex,
    this.totalSteps,
    this.quoteText,
    this.quoteAuthor,
    this.icon,
    this.title,
    this.enableGlassmorphism = true,
    this.enableHoverEffect = true,
  });

  final Widget child;
  final CapCardType type;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  /// 步骤卡专属
  final int? stepIndex;
  final int? totalSteps;

  /// 引用卡专属
  final String? quoteText;
  final String? quoteAuthor;

  /// 能力卡专属
  final IconData? icon;
  final String? title;

  /// 是否启用玻璃拟态效果
  final bool enableGlassmorphism;

  /// 是否启用 hover 效果（Web/Desktop）
  final bool enableHoverEffect;

  @override
  State<CapCard> createState() => _CapCardState();
}

class _CapCardState extends State<CapCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.015).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onHoverChanged(bool isHovered) {
    if (!widget.enableHoverEffect) return;
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: MouseRegion(
            onEnter: (_) => _onHoverChanged(true),
            onExit: (_) => _onHoverChanged(false),
            cursor: widget.onTap != null
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                margin: widget.margin ??
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: _buildDecoration(),
                child: widget.enableGlassmorphism
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: _buildCardContent(),
                        ),
                      )
                    : _buildCardContent(),
              ),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _buildDecoration() {
    final glowIntensity = _glowAnim.value;

    return BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      // 背景：径向渐变
      gradient: RadialGradient(
        center: Alignment.topLeft,
        radius: 1.5,
        colors: _isDark
            ? [
                Color.lerp(AppColors.darkCard,
                    AppColors.darkCardHover, glowIntensity)!,
                AppColors.darkCard,
              ]
            : [
                Color.lerp(AppColors.lightCard,
                    AppColors.lightCardHover, glowIntensity)!,
                AppColors.lightCard,
              ],
      ),
      // 边框
      border: Border.all(
        color: _isHovered
            ? (_isDark
                ? Colors.white.withValues(alpha: 0.25)
                : AppColors.primary.withValues(alpha: 0.25))
            : (_isDark
                ? AppColors.darkBorder.withValues(alpha: 0.5)
                : AppColors.lightBorder.withValues(alpha: 0.6)),
        width: _isHovered ? 1.0 : 0.5,
      ),
      // 阴影
      boxShadow: [
        BoxShadow(
          color: _isDark ? AppColors.cardShadowDark : AppColors.cardShadow,
          blurRadius: 12,
          offset: Offset(0, _isHovered ? 8 : 4),
          spreadRadius: _isHovered ? 2 : 0,
        ),
        if (_isHovered || widget.type == CapCardType.capability)
          BoxShadow(
            color: _isDark
                ? AppColors.cardGlowDark.withValues(
                    alpha: 0.08 + (glowIntensity * 0.12))
                : AppColors.cardGlow.withValues(
                    alpha: 0.08 + (glowIntensity * 0.12)),
            blurRadius: 20 + (glowIntensity * 10),
            spreadRadius: glowIntensity * 3,
          ),
      ],
    );
  }

  Widget _buildCardContent() {
    switch (widget.type) {
      case CapCardType.step:
        return _buildStepCard();
      case CapCardType.quote:
        return _buildQuoteCard();
      case CapCardType.capability:
        return _buildCapabilityCard();
      case CapCardType.standard:
        return _buildStandardCard();
    }
  }

  // ========================
  // Standard Card
  // ========================
  Widget _buildStandardCard() {
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(20),
      child: widget.child,
    );
  }

  // ========================
  // Step Card — 渐变边框 + 进度条
  // ========================
  Widget _buildStepCard() {
    final step = widget.stepIndex ?? 1;
    final total = widget.totalSteps ?? 1;
    final progress = total > 0 ? step / total : 0.0;

    return Container(
      padding: widget.padding ?? const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 步骤编号
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isDark
                        ? [Colors.white, const Color(0xFFCCCCCC)]
                        : [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '$step',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _isDark ? AppColors.primary : Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Step $step of $total',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 内容
          widget.child,
          const SizedBox(height: 16),
          // 进度条 — 浅→深渐变
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: _isDark
                    ? AppColors.darkDivider
                    : AppColors.lightDivider,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isDark
                          ? [const Color(0xFF2A2A2A), Colors.white]
                          : [AppColors.lightDivider, AppColors.primary],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================
  // Quote Card — 左侧竖线 + 引用符号
  // ========================
  Widget _buildQuoteCard() {
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(20),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 左侧黑/白渐变竖线
            Container(
              width: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isDark
                      ? [Colors.white, const Color(0xFF666666)]
                      : [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            // 引用内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 引用符号
                  Text(
                    '\u201C',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: _isDark
                          ? Colors.white.withValues(alpha: 0.4)
                          : AppColors.primary.withValues(alpha: 0.3),
                      height: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  widget.child,
                  if (widget.quoteAuthor != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      '\u2014 ${widget.quoteAuthor}',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================
  // Capability Card — 图标发光 + 标题加粗
  // ========================
  Widget _buildCapabilityCard() {
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // 发光图标区
              if (widget.icon != null)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isDark
                          ? [
                              Colors.white.withValues(alpha: 0.15),
                              Colors.white.withValues(alpha: 0.05),
                            ]
                          : [
                              AppColors.primary.withValues(alpha: 0.12),
                              AppColors.primary.withValues(alpha: 0.04),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: _isDark
                            ? AppColors.cardGlowDark.withValues(alpha: 0.15)
                            : AppColors.cardGlow.withValues(alpha: 0.15),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    color: _isDark ? Colors.white : AppColors.primary,
                    size: 24,
                  ),
                ),
              if (widget.icon != null) const SizedBox(width: 14),
              // 标题
              if (widget.title != null)
                Expanded(
                  child: Text(
                    widget.title!,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          widget.child,
        ],
      ),
    );
  }
}
