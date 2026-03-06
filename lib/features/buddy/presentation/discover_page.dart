import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/empty_state.dart';

/// 发现页 — Tab 2（W5 完整实现）
class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.discoverTitle),
      ),
      body: EmptyStateWidget(
        icon: Icons.explore_outlined,
        title: context.l10n.commonEmpty,
        subtitle: '发现附近的运动伙伴和训练馆',
      ),
    );
  }
}
