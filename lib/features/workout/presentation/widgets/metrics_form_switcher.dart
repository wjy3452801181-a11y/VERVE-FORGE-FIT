import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import 'hyrox_metrics_form.dart';
import 'crossfit_metrics_form.dart';
import 'yoga_metrics_form.dart';
import 'running_metrics_form.dart';

/// 根据 sportType 自动切换对应的 metrics 表单
class MetricsFormSwitcher extends StatelessWidget {
  final String sportType;
  final Map<String, dynamic>? initialData;
  final ValueChanged<Map<String, dynamic>> onMetricsChanged;

  const MetricsFormSwitcher({
    super.key,
    required this.sportType,
    this.initialData,
    required this.onMetricsChanged,
  });

  /// 是否有对应的 metrics 表单
  static bool hasMetricsForm(String sportType) {
    return const ['hyrox', 'crossfit', 'yoga', 'pilates', 'running']
        .contains(sportType);
  }

  @override
  Widget build(BuildContext context) {
    if (!hasMetricsForm(sportType)) {
      return const SizedBox.shrink();
    }

    final Color themeColor;
    switch (sportType) {
      case 'hyrox':
        themeColor = AppColors.hyrox;
      case 'crossfit':
        themeColor = AppColors.crossfit;
      case 'yoga':
        themeColor = AppColors.yoga;
      case 'pilates':
        themeColor = AppColors.pilates;
      case 'running':
        themeColor = AppColors.running;
      default:
        themeColor = AppColors.primary;
    }

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: themeColor,
            ),
      ),
      child: ExpansionTile(
        title: Text(
          context.l10n.metricsTitle,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: themeColor,
              ),
        ),
        leading: Icon(Icons.emoji_events_outlined, color: themeColor, size: 20),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 16),
        children: [
          _buildForm(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    switch (sportType) {
      case 'hyrox':
        return HyroxMetricsForm(
          initialData: initialData,
          onChanged: onMetricsChanged,
        );
      case 'crossfit':
        return CrossFitMetricsForm(
          initialData: initialData,
          onChanged: onMetricsChanged,
        );
      case 'yoga':
      case 'pilates':
        return YogaMetricsForm(
          initialData: initialData,
          onChanged: onMetricsChanged,
          sportType: sportType,
        );
      case 'running':
        return RunningMetricsForm(
          initialData: initialData,
          onChanged: onMetricsChanged,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
