import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/empty_state.dart';

/// 动态流页 — Tab 1（W8 完整实现）
class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.feedTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: 导航到通知页
            },
          ),
        ],
      ),
      body: EmptyStateWidget(
        icon: Icons.dynamic_feed_outlined,
        title: context.l10n.commonEmpty,
        subtitle: '关注运动伙伴，查看他们的训练动态',
      ),
    );
  }
}
