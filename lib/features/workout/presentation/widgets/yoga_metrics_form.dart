import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/workout_metrics.dart';

/// 瑜伽 / 普拉提课程成绩表单（共用）
class YogaMetricsForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final ValueChanged<Map<String, dynamic>> onChanged;
  final String sportType; // 'yoga' or 'pilates'

  const YogaMetricsForm({
    super.key,
    this.initialData,
    required this.onChanged,
    this.sportType = 'yoga',
  });

  @override
  State<YogaMetricsForm> createState() => _YogaMetricsFormState();
}

class _YogaMetricsFormState extends State<YogaMetricsForm> {
  final _classNameController = TextEditingController();
  final Set<String> _focusAreas = {};
  String? _difficulty;

  Color get _themeColor =>
      widget.sportType == 'pilates' ? AppColors.pilates : AppColors.yoga;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final initial = YogaPilatesMetrics.fromJson(widget.initialData!);
      _classNameController.text = initial.className ?? '';
      _focusAreas.addAll(initial.focusAreas);
      _difficulty = initial.difficulty;
    }
    _classNameController.addListener(_emitChange);
  }

  @override
  void dispose() {
    _classNameController.dispose();
    super.dispose();
  }

  void _emitChange() {
    widget.onChanged({
      'class_name': _classNameController.text,
      'focus_areas': _focusAreas.toList(),
      'difficulty': _difficulty,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 课程名称
        TextFormField(
          controller: _classNameController,
          decoration: InputDecoration(
            labelText: context.l10n.metricsClassName,
            hintText: widget.sportType == 'yoga'
                ? 'e.g. Flow Yoga, Yin Yoga'
                : 'e.g. Reformer, Mat Pilates',
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 专注区域（多选）
        Text(context.l10n.metricsFocusArea,
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: YogaPilatesMetrics.allFocusAreas.map((area) {
            final selected = _focusAreas.contains(area);
            return FilterChip(
              label: Text(
                YogaPilatesMetrics.focusAreaLabels[area] ?? area,
                style: const TextStyle(fontSize: 13),
              ),
              selected: selected,
              onSelected: (v) {
                setState(() {
                  if (v) {
                    _focusAreas.add(area);
                  } else {
                    _focusAreas.remove(area);
                  }
                });
                _emitChange();
              },
              selectedColor: _themeColor.withValues(alpha: 0.15),
              checkmarkColor: _themeColor,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // 难度
        Text(context.l10n.metricsDifficulty,
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        SegmentedButton<String>(
          segments: YogaPilatesMetrics.difficultyLabels.entries
              .map((e) => ButtonSegment(
                    value: e.key,
                    label: Text(e.value),
                  ))
              .toList(),
          selected: _difficulty != null ? {_difficulty!} : {},
          emptySelectionAllowed: true,
          onSelectionChanged: (set) {
            setState(() => _difficulty = set.isNotEmpty ? set.first : null);
            _emitChange();
          },
          style: SegmentedButton.styleFrom(
            selectedBackgroundColor: _themeColor.withValues(alpha: 0.15),
            selectedForegroundColor: _themeColor,
          ),
        ),
      ],
    );
  }
}
