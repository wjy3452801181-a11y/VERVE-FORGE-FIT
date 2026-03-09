import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/workout_metrics.dart';

/// HYROX 8 站成绩输入表单
class HyroxMetricsForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const HyroxMetricsForm({
    super.key,
    this.initialData,
    required this.onChanged,
  });

  @override
  State<HyroxMetricsForm> createState() => _HyroxMetricsFormState();
}

class _HyroxMetricsFormState extends State<HyroxMetricsForm> {
  final List<TextEditingController> _stationControllers = [];
  final _totalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initial = widget.initialData != null
        ? HyroxMetrics.fromJson(widget.initialData!)
        : null;

    for (int i = 0; i < HyroxMetrics.stationNames.length; i++) {
      final controller = TextEditingController();
      if (initial != null && i < initial.stations.length) {
        final station = initial.stations[i];
        if (station.timeSec != null) {
          final min = station.timeSec! ~/ 60;
          final sec = station.timeSec! % 60;
          controller.text =
              '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
        }
      }
      controller.addListener(_emitChange);
      _stationControllers.add(controller);
    }

    if (initial?.totalTimeSec != null) {
      final total = initial!.totalTimeSec!;
      final h = total ~/ 3600;
      final m = (total % 3600) ~/ 60;
      final s = total % 60;
      if (h > 0) {
        _totalController.text =
            '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
      } else {
        _totalController.text =
            '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
      }
    }
    _totalController.addListener(_emitChange);
  }

  @override
  void dispose() {
    for (final c in _stationControllers) {
      c.dispose();
    }
    _totalController.dispose();
    super.dispose();
  }

  void _emitChange() {
    final stations = <Map<String, dynamic>>[];
    for (int i = 0; i < HyroxMetrics.stationNames.length; i++) {
      final sec = _parseTimeToSeconds(_stationControllers[i].text);
      stations.add({
        'name': HyroxMetrics.stationNames[i],
        'time_sec': sec,
      });
    }
    final totalSec = _parseTotalTimeToSeconds(_totalController.text);
    widget.onChanged({
      'stations': stations,
      'total_time_sec': totalSec,
    });
  }

  int? _parseTimeToSeconds(String text) {
    if (text.isEmpty) return null;
    final parts = text.split(':');
    if (parts.length == 2) {
      final min = int.tryParse(parts[0]) ?? 0;
      final sec = int.tryParse(parts[1]) ?? 0;
      return min * 60 + sec;
    }
    return null;
  }

  int? _parseTotalTimeToSeconds(String text) {
    if (text.isEmpty) return null;
    final parts = text.split(':');
    if (parts.length == 3) {
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      final s = int.tryParse(parts[2]) ?? 0;
      return h * 3600 + m * 60 + s;
    }
    if (parts.length == 2) {
      final m = int.tryParse(parts[0]) ?? 0;
      final s = int.tryParse(parts[1]) ?? 0;
      return m * 60 + s;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 8 站成绩
        ...List.generate(HyroxMetrics.stationNames.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 140,
                  child: Text(
                    HyroxMetrics.stationNames[i],
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _stationControllers[i],
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(
                      hintText: 'mm:ss',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        }),
        const Divider(height: 24),
        // 总成绩
        Row(
          children: [
            SizedBox(
              width: 140,
              child: Text(
                context.l10n.metricsTotalTime,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.hyrox,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _totalController,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  hintText: 'h:mm:ss',
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.hyrox,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
