import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

/// 训练强度滑块（1-10 渐变色）
class IntensitySlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const IntensitySlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.intensityGradient[value - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _intensityLabel(value),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Text(
              '$value / ${AppConstants.maxIntensity}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.2),
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.1),
            trackHeight: 6,
          ),
          child: Slider(
            value: value.toDouble(),
            min: AppConstants.minIntensity.toDouble(),
            max: AppConstants.maxIntensity.toDouble(),
            divisions: AppConstants.maxIntensity - AppConstants.minIntensity,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
      ],
    );
  }

  String _intensityLabel(int intensity) {
    if (intensity <= 2) return '轻松';
    if (intensity <= 4) return '适中';
    if (intensity <= 6) return '中等';
    if (intensity <= 8) return '高强度';
    return '极限';
  }
}
