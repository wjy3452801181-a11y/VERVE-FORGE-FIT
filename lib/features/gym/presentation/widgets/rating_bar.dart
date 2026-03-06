import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// 1-5 星评分选择/展示组件
class RatingBar extends StatelessWidget {
  final int rating;
  final int maxRating;
  final double size;
  final bool interactive;
  final ValueChanged<int>? onRatingChanged;

  const RatingBar({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 24,
    this.interactive = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final starIndex = index + 1;
        final isFilled = starIndex <= rating;

        return GestureDetector(
          onTap: interactive ? () => onRatingChanged?.call(starIndex) : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(
              isFilled ? Icons.star : Icons.star_border,
              size: size,
              color: isFilled ? AppColors.accent : Colors.grey.withValues(alpha: 0.4),
            ),
          ),
        );
      }),
    );
  }
}
