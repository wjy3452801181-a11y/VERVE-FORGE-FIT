import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_animations.dart';

/// PR（个人最佳）展示组件
///
/// Verve Volt 的核心使用场景 — 运动员超越自己时出现的成就时刻。
/// 在深色背景上，电光黄的发光效果让这一刻无法被忽视。
///
/// ```dart
/// // 在 Workout Detail 页面展示 PR
/// PrBadge(
///   label: 'BACK SQUAT',
///   value: '185 kg',
///   previousBest: '180 kg',
/// )
///
/// // 排行榜第一名
/// PrBadge.rank1(value: '34,200 pts')
/// ```
class PrBadge extends StatefulWidget {
  const PrBadge({
    super.key,
    required this.label,
    required this.value,
    this.previousBest,
    this.animate = true,
  });

  /// 工厂：排行榜第一名样式
  factory PrBadge.rank1({
    required String value,
    bool animate = true,
  }) {
    return PrBadge(
      label: '#1',
      value: value,
      animate: animate,
    );
  }

  /// 指标名称（全大写，如 "BACK SQUAT"）
  final String label;

  /// 当前最佳值（如 "185 kg"）
  final String value;

  /// 前一个最佳（如 "180 kg"），显示进步幅度
  final String? previousBest;

  /// 是否播放入场动画
  final bool animate;

  @override
  State<PrBadge> createState() => _PrBadgeState();
}

class _PrBadgeState extends State<PrBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.page,
      vsync: this,
    );

    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _glow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    if (widget.animate) {
      // 微延迟后启动，让页面先稳定
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                // 深色模式：volt 半透明背景；浅色模式：更淡的 volt 底
                color: isDark
                    ? Color.lerp(
                        AppColors.darkCard,
                        const Color(0xFFE8FF00),
                        0.08 * _glow.value,
                      )
                    : const Color(0xFFE8FF00).withValues(alpha: 0.06 * _glow.value + 0.04),
                borderRadius: AppRadius.bMD,
                border: Border.all(
                  color: AppColors.volt.withValues(
                    alpha: (0.4 + 0.3 * _glow.value).clamp(0.0, 1.0),
                  ),
                  width: 1.0,
                ),
                boxShadow: [
                  // volt 外发光，随动画增强
                  BoxShadow(
                    color: AppColors.voltGlow.withValues(
                      alpha: (0.15 * _glow.value).clamp(0.0, 1.0),
                    ),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: AppColors.voltGlowStrong.withValues(
                      alpha: (0.08 * _glow.value).clamp(0.0, 1.0),
                    ),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // PR 闪电图标
                  const Icon(
                    Icons.bolt_rounded,
                    color: AppColors.volt,
                    size: 18,
                  ),
                  AppSpacing.hGapXS,
                  // 指标名称 + 值
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.label,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.volt.withValues(alpha: 0.75),
                          letterSpacing: 1.2,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        widget.value,
                        style: AppTextStyles.number.copyWith(
                          color: AppColors.volt,
                          height: 1.1,
                          shadows: AppShadows.textSubtle,
                        ),
                      ),
                    ],
                  ),
                  // 进步幅度（如有）
                  if (widget.previousBest != null) ...[
                    AppSpacing.hGapSM,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.voltSurface,
                        borderRadius: AppRadius.bXS,
                      ),
                      child: Text(
                        '↑ prev ${widget.previousBest}',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.volt.withValues(alpha: 0.6),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
