import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/errors/error_handler.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/sport_type_icon.dart';
import '../domain/buddy_request_model.dart';
import '../providers/buddy_provider.dart';

/// 好友列表页 — 显示所有已接受的好友
class BuddyListPage extends ConsumerWidget {
  const BuddyListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buddiesAsync = ref.watch(acceptedBuddiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.buddyListTitle),
        actions: [
          // 跳转好友请求页
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            tooltip: context.l10n.buddyRequests,
            onPressed: () => context.push(AppRoutes.buddyRequests),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(acceptedBuddiesProvider.notifier).refresh(),
        color: AppColors.primary,
        child: buddiesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: EmptyStateWidget(
              icon: Icons.error_outline,
              title: context.l10n.commonError,
              actionText: context.l10n.commonRetry,
              onAction: () => ref.invalidate(acceptedBuddiesProvider),
            ),
          ),
          data: (buddies) {
            if (buddies.isEmpty) {
              return ListView(
                children: [
                  SizedBox(height: context.screenHeight * 0.25),
                  EmptyStateWidget(
                    icon: Icons.people_outline,
                    title: context.l10n.buddyNoBuddies,
                    subtitle: context.l10n.buddyNoBuddiesTip,
                  ),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: buddies.length,
              itemBuilder: (context, index) => _BuddyListCard(
                buddy: buddies[index],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 好友卡片
class _BuddyListCard extends ConsumerWidget {
  final BuddyRequestModel buddy;

  const _BuddyListCard({required this.buddy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: 跳转到用户详情页
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              AvatarWidget(
                size: 48,
                imageUrl: buddy.otherAvatarUrl,
                fallbackText: buddy.otherNickname,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      buddy.otherNickname,
                      style: AppTextStyles.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (buddy.otherBio.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        buddy.otherBio,
                        style: AppTextStyles.caption.copyWith(
                          color: context.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (buddy.otherSportTypes.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: buddy.otherSportTypes
                            .take(4)
                            .map((s) => Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: SportTypeIcon(sportType: s, size: 18),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),

              // 更多操作
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                onSelected: (value) {
                  if (value == 'remove') {
                    _removeBuddy(context, ref);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.person_remove_outlined,
                            size: 18, color: context.colorScheme.error),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n.buddyRemove,
                          style: TextStyle(color: context.colorScheme.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _removeBuddy(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: context.l10n.buddyRemoveConfirm,
      content: context.l10n.buddyRemoveConfirmDesc,
      confirmText: context.l10n.buddyRemove,
      isDestructive: true,
    );
    if (!confirmed) return;

    try {
      await ref.read(acceptedBuddiesProvider.notifier).remove(buddy.id);
      if (context.mounted) {
        ErrorHandler.showSuccess(context, context.l10n.buddyRemoved);
      }
    } catch (e) {
      if (context.mounted) ErrorHandler.showError(context, e);
    }
  }
}
