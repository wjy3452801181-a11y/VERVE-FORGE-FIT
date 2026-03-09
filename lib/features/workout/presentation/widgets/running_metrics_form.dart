import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/workout_metrics.dart';

/// 跑步成绩输入表单
class RunningMetricsForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const RunningMetricsForm({
    super.key,
    this.initialData,
    required this.onChanged,
  });

  @override
  State<RunningMetricsForm> createState() => _RunningMetricsFormState();
}

class _RunningMetricsFormState extends State<RunningMetricsForm> {
  final _distanceController = TextEditingController();
  final _paceController = TextEditingController();
  final _elevationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final initial = RunningMetrics.fromJson(widget.initialData!);
      if (initial.distanceKm != null) {
        _distanceController.text = initial.distanceKm.toString();
      }
      if (initial.paceMinPerKm != null) {
        // 转为 mm:ss 显示
        final totalSec = (initial.paceMinPerKm! * 60).round();
        final min = totalSec ~/ 60;
        final sec = totalSec % 60;
        _paceController.text =
            '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
      }
      if (initial.elevationM != null) {
        _elevationController.text = initial.elevationM.toString();
      }
    }
    _distanceController.addListener(_emitChange);
    _paceController.addListener(_emitChange);
    _elevationController.addListener(_emitChange);
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _paceController.dispose();
    _elevationController.dispose();
    super.dispose();
  }

  void _emitChange() {
    final distance = double.tryParse(_distanceController.text);
    final elevation = int.tryParse(_elevationController.text);

    // 解析配速 mm:ss → double
    double? pace;
    final paceParts = _paceController.text.split(':');
    if (paceParts.length == 2) {
      final min = int.tryParse(paceParts[0]);
      final sec = int.tryParse(paceParts[1]);
      if (min != null && sec != null) {
        pace = min + sec / 60.0;
      }
    }

    widget.onChanged({
      'distance_km': distance,
      'pace_min_per_km': pace,
      'elevation_m': elevation,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 距离
        TextFormField(
          controller: _distanceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: context.l10n.metricsDistance,
            hintText: 'e.g. 10.5',
            suffixText: 'km',
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 配速
        TextFormField(
          controller: _paceController,
          keyboardType: TextInputType.datetime,
          decoration: InputDecoration(
            labelText: context.l10n.metricsPace,
            hintText: 'mm:ss',
            suffixText: '/km',
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.speed, size: 18, color: AppColors.running),
          ),
        ),
        const SizedBox(height: 12),

        // 爬升
        TextFormField(
          controller: _elevationController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: context.l10n.metricsElevation,
            hintText: 'e.g. 120',
            suffixText: 'm',
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon:
                const Icon(Icons.terrain, size: 18, color: AppColors.running),
          ),
        ),
      ],
    );
  }
}
