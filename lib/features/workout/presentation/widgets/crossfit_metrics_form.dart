import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/workout_metrics.dart';

/// CrossFit WOD 成绩输入表单
class CrossFitMetricsForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const CrossFitMetricsForm({
    super.key,
    this.initialData,
    required this.onChanged,
  });

  @override
  State<CrossFitMetricsForm> createState() => _CrossFitMetricsFormState();
}

class _CrossFitMetricsFormState extends State<CrossFitMetricsForm> {
  final _wodNameController = TextEditingController();
  final _scoreController = TextEditingController();
  final _movementController = TextEditingController();
  String _wodType = 'for_time';
  final List<String> _movements = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final initial = CrossFitMetrics.fromJson(widget.initialData!);
      _wodNameController.text = initial.wodName ?? '';
      _scoreController.text = initial.score ?? '';
      _wodType = initial.wodType ?? 'for_time';
      _movements.addAll(initial.movements);
    }
    _wodNameController.addListener(_emitChange);
    _scoreController.addListener(_emitChange);
  }

  @override
  void dispose() {
    _wodNameController.dispose();
    _scoreController.dispose();
    _movementController.dispose();
    super.dispose();
  }

  void _emitChange() {
    widget.onChanged({
      'wod_name': _wodNameController.text,
      'wod_type': _wodType,
      'score': _scoreController.text,
      'movements': _movements,
    });
  }

  void _addMovement() {
    final text = _movementController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _movements.add(text);
      _movementController.clear();
    });
    _emitChange();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // WOD 名称
        TextFormField(
          controller: _wodNameController,
          decoration: InputDecoration(
            labelText: context.l10n.metricsWod,
            hintText: 'e.g. Fran, Murph, Grace',
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // WOD 类型
        Text(context.l10n.metricsWodType,
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        SegmentedButton<String>(
          segments: CrossFitMetrics.wodTypeLabels.entries
              .map((e) => ButtonSegment(
                    value: e.key,
                    label: Text(e.value),
                  ))
              .toList(),
          selected: {_wodType},
          onSelectionChanged: (set) {
            setState(() => _wodType = set.isNotEmpty ? set.first : _wodType);
            _emitChange();
          },
          style: SegmentedButton.styleFrom(
            selectedBackgroundColor: AppColors.crossfit.withValues(alpha: 0.15),
            selectedForegroundColor: AppColors.crossfit,
          ),
        ),
        const SizedBox(height: 12),

        // 成绩
        TextFormField(
          controller: _scoreController,
          decoration: InputDecoration(
            labelText: context.l10n.metricsScore,
            hintText: _wodType == 'for_time'
                ? 'e.g. 3:45'
                : _wodType == 'amrap'
                    ? 'e.g. 8 rounds + 5 reps'
                    : 'e.g. completed',
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 动作列表
        Text(context.l10n.metricsMovement,
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _movementController,
                decoration: InputDecoration(
                  hintText: 'e.g. Thrusters',
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onFieldSubmitted: (_) => _addMovement(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _addMovement,
              icon: const Icon(Icons.add_circle_outline),
              color: AppColors.crossfit,
            ),
          ],
        ),
        if (_movements.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: _movements.asMap().entries.map((entry) {
              return Chip(
                label: Text(entry.value, style: const TextStyle(fontSize: 12)),
                deleteIcon: const Icon(Icons.close, size: 14),
                onDeleted: () {
                  setState(() => _movements.removeAt(entry.key));
                  _emitChange();
                },
                backgroundColor: AppColors.crossfit.withValues(alpha: 0.08),
                side: BorderSide.none,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
