import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/empty_state.dart';

/// 挑战赛列表页 — Tab 4（W7 完整实现）
class ChallengesPage extends StatelessWidget {
  const ChallengesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.challengeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: W7 导航到创建挑战页
            },
          ),
        ],
      ),
      body: EmptyStateWidget(
        icon: Icons.emoji_events_outlined,
        title: context.l10n.commonEmpty,
        subtitle: '创建或参加运动挑战，与伙伴一起进步',
        actionText: context.l10n.challengeCreate,
        onAction: () {
          // TODO: W7 创建挑战
        },
      ),
    );
  }
}
