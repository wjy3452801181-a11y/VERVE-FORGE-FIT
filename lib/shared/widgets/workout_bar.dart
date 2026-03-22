import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_radius.dart';

/// 训练强度进度条
///
/// 横向条形图，颜色从灰渐变至黑（或白），
/// 用于 Challenge 排行榜、Feed 帖子训练摘要、Workout 详情。
///
/// ```dart
/// WorkoutBar(
///   value: 0.72,         // 0.0–1.0
///   label: '34,200 pts',
///   intensity: 8,        // 1–10，决定条形终止色
/// )
/// ```
class WorkoutBar extends StatelessWidget {
  const WorkoutBar({
    super.key,
    required this.value,
    this.label,
    this.intensity = 7,
    this.height = 6,
    this.maxWidth,
    this.showLabel = true,
  })  : assert(value >= 0 && value <= 1),
        assert(intensity >= 1 && intensity <= 10);

  /// 进度比例（0.0–1.0）
  final double value;

  /// 右侧标签文字（留空则不显示）
  final String? label;

  /// 强度等级 1–10，对应 AppColors.intensityGradient
  final int intensity;

  /// 条形高度，默认 6px
  final double height;

  /// 可选最大宽度（用于固定列布局）
  final double? maxWidth;

  /// 是否显示右侧标签
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final startColor = isDark
        ? AppColors.intensityGradient[2]     // 深色模式：从中灰开始
        : AppColors.intensityGradient[1];    // 浅色模式：从浅灰开始
    final endColor = AppColors.intensityGradient[(intensity - 1).clamp(0, 9)];

    return Row(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = maxWidth ?? constraints.maxWidth;
              return ClipRRect(
                borderRadius: AppRadius.bXS,
                child: Container(
                  height: height,
                  width: barWidth,
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: value.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [startColor, endColor],
                        ),
                        borderRadius: AppRadius.bXS,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (showLabel && label != null) ...[
          AppSpacing.hGapSM,
          Text(
            label!,
            style: AppTextStyles.label.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
