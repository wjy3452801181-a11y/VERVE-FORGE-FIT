import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton.dart';
import '../domain/conversation_model.dart';
import '../providers/chat_provider.dart';

/// 会话列表页 — 私信入口
class ConversationsPage extends ConsumerWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.chatTitle),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(conversationsProvider.notifier).refresh(),
        color: AppColors.primary,
        child: conversationsAsync.when(
          loading: () => ListView(
            padding: AppSpacing.pagePadding,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              SkeletonAvatarRow(),
              SizedBox(height: AppSpacing.md),
              SkeletonAvatarRow(),
              SizedBox(height: AppSpacing.md),
              SkeletonAvatarRow(),
              SizedBox(height: AppSpacing.md),
              SkeletonAvatarRow(),
            ],
          ),
          error: (e, _) => Center(
            child: EmptyStateWidget(
              icon: Icons.error_outline,
              title: context.l10n.commonError,
              actionText: context.l10n.commonRetry,
              onAction: () => ref.invalidate(conversationsProvider),
            ),
          ),
          data: (conversations) {
            if (conversations.isEmpty) {
              return ListView(
                children: [
                  SizedBox(height: context.screenHeight * 0.25),
                  EmptyStateWidget(
                    icon: Icons.chat_bubble_outline,
                    title: context.l10n.chatNoConversations,
                    subtitle: context.l10n.chatNoConversationsTip,
                  ),
                ],
              );
            }
            return ListView.separated(
              itemCount: conversations.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 72,
                color: isDark
                    ? AppColors.darkDivider
                    : AppColors.lightDivider,
              ),
              itemBuilder: (context, index) => _ConversationTile(
                conversation: conversations[index],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 会话列表项
class _ConversationTile extends StatelessWidget {
  final ConversationModel conversation;

  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      leading: AvatarWidget(
        size: 48,
        imageUrl: conversation.otherAvatarUrl,
        fallbackText: conversation.otherNickname,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              conversation.otherNickname,
              style: AppTextStyles.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            conversation.timeDisplay,
            style: AppTextStyles.caption.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              conversation.lastMessagePreview,
              style: AppTextStyles.caption.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (conversation.unreadCount > 0)
            Container(
              margin: const EdgeInsets.only(left: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 2),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Text(
                conversation.unreadCount > 99
                    ? '99+'
                    : '${conversation.unreadCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      onTap: () => context.push(
        '${AppRoutes.chat}/${conversation.otherUserId}',
        extra: conversation.otherNickname,
      ),
    );
  }
}
