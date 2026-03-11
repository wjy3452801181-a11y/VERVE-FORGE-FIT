import 'package:flutter/material.dart';

import '../../../../shared/widgets/sport_type_icon.dart';

/// 运动类型标签组件 — 以 Wrap 形式展示用户的运动偏好
class SportChipsWidget extends StatelessWidget {
  final List<String> sportTypes;
  final double iconSize;

  const SportChipsWidget({
    super.key,
    required this.sportTypes,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (sportTypes.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: sportTypes
          .map((s) => SportTypeIcon(sportType: s, size: iconSize))
          .toList(),
    );
  }
}
