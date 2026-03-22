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
import '../domain/notification_model.dart';
import '../providers/notification_provider.dart';

/// 通知列表页
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.notificationTitle),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(notificationsProvider.notifier).markAllAsRead();
            },
            child: Text(context.l10n.notificationMarkAllRead),
          ),
        ],
      ),
      body: notificationsAsync.when(
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
        error: (e, _) => EmptyStateWidget(
          icon: Icons.error_outline,
          title: context.l10n.commonError,
          actionText: context.l10n.commonRetry,
          onAction: () => ref.invalidate(notificationsProvider),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.notifications_none,
              title: context.l10n.notificationEmpty,
              subtitle: context.l10n.notificationEmptyTip,
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(notificationsProvider.notifier).refresh(),
            color: AppColors.primary,
            child: NotificationList(notifications: notifications),
          );
        },
      ),
    );
  }
}

class NotificationList extends ConsumerStatefulWidget {
  final List<NotificationModel> notifications;

  const NotificationList({super.key, required this.notifications});

  @override
  ConsumerState<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends ConsumerState<NotificationList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      controller: _scrollController,
      itemCount: widget.notifications.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
      ),
      itemBuilder: (context, index) {
        final n = widget.notifications[index];
        return _NotificationTile(notification: n);
      },
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final NotificationModel notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      leading: _buildLeading(),
      title: Text(
        notification.title,
        style: notification.isRead
            ? AppTextStyles.body
            : AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: notification.body.isNotEmpty
          ? Text(
              notification.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            )
          : null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatTime(notification.createdAt),
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          if (!notification.isRead) ...[
            AppSpacing.vGapXS,
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
      tileColor: notification.isRead
          ? null
          : AppColors.primary.withValues(alpha: 0.05),
      onTap: () => _onTap(context, ref),
    );
  }

  Widget _buildLeading() {
    if (notification.refUserAvatarUrl != null ||
        notification.refUserNickname != null) {
      return AvatarWidget(
        size: 40,
        imageUrl: notification.refUserAvatarUrl,
        fallbackText: notification.refUserNickname,
      );
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      child: Icon(_iconForType(notification.type), color: AppColors.primary),
    );
  }

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.buddyRequest:
      case NotificationType.buddyAccepted:
        return Icons.people_outlined;
      case NotificationType.newMessage:
        return Icons.chat_outlined;
      case NotificationType.challengeInvite:
      case NotificationType.challengeReminder:
        return Icons.emoji_events_outlined;
      case NotificationType.postLike:
        return Icons.favorite_outlined;
      case NotificationType.postComment:
        return Icons.comment_outlined;
      case NotificationType.system:
        return Icons.info_outlined;
    }
  }

  void _onTap(BuildContext context, WidgetRef ref) {
    // 标记已读
    if (!notification.isRead) {
      ref.read(notificationsProvider.notifier).markAsRead(notification.id);
    }

    // 根据类型跳转
    switch (notification.type) {
      case NotificationType.buddyRequest:
        context.push(AppRoutes.buddyRequests);
        break;
      case NotificationType.buddyAccepted:
        context.push(AppRoutes.buddyList);
        break;
      case NotificationType.newMessage:
        if (notification.refUserId != null) {
          context.push(
            '${AppRoutes.chat}/${notification.refUserId}',
            extra: notification.refUserNickname,
          );
        }
        break;
      case NotificationType.challengeInvite:
      case NotificationType.challengeReminder:
        if (notification.refChallengeId != null) {
          context.push(
            '${AppRoutes.challengeDetail}/${notification.refChallengeId}',
          );
        }
        break;
      case NotificationType.postLike:
      case NotificationType.postComment:
        // 暂时不做跳转（帖子详情页未实现）
        break;
      case NotificationType.system:
        break;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${time.month}/${time.day}';
  }
}
