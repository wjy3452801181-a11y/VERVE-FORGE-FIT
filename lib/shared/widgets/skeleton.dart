import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_animations.dart';

/// 骨架屏占位组件（Loading shimmer）
///
/// 统一加载状态视觉，避免布局跳动（CLS）。
/// 自动适配深/浅色模式。
///
/// ```dart
/// // 单行文字骨架
/// SkeletonLine(width: 120, height: 14)
///
/// // 卡片骨架
/// SkeletonCard()
///
/// // 头像 + 两行文字组合
/// SkeletonAvatar()
/// ```
class SkeletonLine extends StatefulWidget {
  const SkeletonLine({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final BorderRadiusGeometry? borderRadius;

  @override
  State<SkeletonLine> createState() => _SkeletonLineState();
}

class _SkeletonLineState extends State<SkeletonLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.shimmer,
      vsync: this,
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: AppAnimations.shimmerMinOpacity,
      end: AppAnimations.shimmerMaxOpacity,
    ).animate(CurvedAnimation(parent: _controller, curve: AppAnimations.smooth));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? AppColors.darkCard
        : AppColors.lightCard;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: baseColor.withValues(alpha: _anim.value),
          borderRadius: widget.borderRadius ?? AppRadius.bXS,
        ),
      ),
    );
  }
}

/// 文字行骨架（适合列表标题 + 副标题组合）
class SkeletonTextBlock extends StatelessWidget {
  const SkeletonTextBlock({super.key, this.lines = 2});

  final int lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(lines, (i) {
        final isLast = i == lines - 1;
        return Padding(
          padding: EdgeInsets.only(
            bottom: isLast ? 0 : AppSpacing.sm,
          ),
          child: SkeletonLine(
            width: isLast ? 120 : double.infinity,
            height: i == 0 ? 16 : 13,
          ),
        );
      }),
    );
  }
}

/// 卡片骨架（完整 CapCard 大小）
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: AppSpacing.cardMargin,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: AppRadius.bLG,
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.5)
              : AppColors.lightBorder.withValues(alpha: 0.6),
          width: 0.5,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 头部：头像 + 用户名
          Row(
            children: [
              SkeletonLine(
                width: 36,
                height: 36,
                borderRadius: AppRadius.bFull,
              ),
              AppSpacing.hGapSM,
              Expanded(child: SkeletonTextBlock(lines: 2)),
            ],
          ),
          AppSpacing.vGapMD,
          // 正文两行
          SkeletonLine(height: 15),
          AppSpacing.vGap6,
          SkeletonLine(width: 200, height: 15),
          AppSpacing.vGapMD,
          // 操作行
          Row(
            children: [
              SkeletonLine(width: 48, height: 12),
              AppSpacing.hGapMD,
              SkeletonLine(width: 48, height: 12),
              AppSpacing.hGapMD,
              SkeletonLine(width: 48, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}

/// 头像 + 文字骨架（用于 Profile / Leaderboard 行）
class SkeletonAvatarRow extends StatelessWidget {
  const SkeletonAvatarRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SkeletonLine(
          width: 44,
          height: 44,
          borderRadius: AppRadius.bFull,
        ),
        AppSpacing.hGapSM,
        Expanded(child: SkeletonTextBlock(lines: 2)),
      ],
    );
  }
}

/// 统计数字骨架（用于 Profile stats bar）
class SkeletonStatBar extends StatelessWidget {
  const SkeletonStatBar({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IntrinsicHeight(
      child: Row(
        children: List.generate(count * 2 - 1, (i) {
          if (i.isOdd) {
            return VerticalDivider(
              width: 1,
              thickness: 0.5,
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            );
          }
          return const Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SkeletonLine(width: 48, height: 22),
                AppSpacing.vGapXS,
                SkeletonLine(width: 40, height: 11),
              ],
            ),
          );
        }),
      ),
    );
  }
}
