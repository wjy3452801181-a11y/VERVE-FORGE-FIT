import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_radius.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/errors/error_handler.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton.dart';
import '../../../shared/widgets/sport_type_icon.dart';
import '../domain/buddy_request_model.dart';
import '../providers/buddy_provider.dart';

/// 好友请求页 — 收到的 / 发出的
class BuddyRequestsPage extends ConsumerWidget {
  const BuddyRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.buddyRequests),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            tabs: [
              Tab(text: context.l10n.buddyReceived),
              Tab(text: context.l10n.buddySent),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ReceivedTab(),
            _SentTab(),
          ],
        ),
      ),
    );
  }
}

/// 收到的请求 Tab
class _ReceivedTab extends ConsumerWidget {
  const _ReceivedTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(receivedRequestsProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(receivedRequestsProvider.notifier).refresh(),
      color: AppColors.primary,
      child: requestsAsync.when(
        loading: () => ListView(
          padding: AppSpacing.pagePadding,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
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
            onAction: () => ref.invalidate(receivedRequestsProvider),
          ),
        ),
        data: (requests) {
          if (requests.isEmpty) {
            return ListView(
              children: [
                SizedBox(height: context.screenHeight * 0.25),
                EmptyStateWidget(
                  icon: Icons.inbox_outlined,
                  title: context.l10n.buddyNoRequests,
                  subtitle: context.l10n.buddyNoRequestsTip,
                ),
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            itemCount: requests.length,
            itemBuilder: (context, index) => _ReceivedRequestCard(
              request: requests[index],
            ),
          );
        },
      ),
    );
  }
}

/// 收到的请求卡片
class _ReceivedRequestCard extends ConsumerWidget {
  final BuddyRequestModel request;

  const _ReceivedRequestCard({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: AppSpacing.cardMargin,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: AppRadius.bLG,
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.5)
              : AppColors.lightBorder.withValues(alpha: 0.6),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: AppSpacing.cardPaddingCompact,
        child: Row(
          children: [
            AvatarWidget(
              size: 48,
              imageUrl: request.otherAvatarUrl,
              fallbackText: request.otherNickname,
            ),
            AppSpacing.hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.otherNickname,
                    style: AppTextStyles.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (request.otherBio.isNotEmpty) ...[
                    AppSpacing.vGapXS,
                    Text(
                      request.otherBio,
                      style: AppTextStyles.caption.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (request.otherSportTypes.isNotEmpty) ...[
                    AppSpacing.vGapSM,
                    Row(
                      children: request.otherSportTypes
                          .take(4)
                          .map((s) => Padding(
                                padding: const EdgeInsets.only(
                                    right: AppSpacing.xs),
                                child: SportTypeIcon(sportType: s, size: 18),
                              ))
                          .toList(),
                    ),
                  ],
                  if (request.message.isNotEmpty) ...[
                    AppSpacing.vGapSM,
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkCardHover
                            : AppColors.lightCardHover,
                        borderRadius: AppRadius.bXS,
                      ),
                      child: Text(
                        request.message,
                        style: AppTextStyles.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AppSpacing.hGapSM,

            // 操作按钮
            Column(
              children: [
                // 接受
                SizedBox(
                  width: 64,
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () => _accept(context, ref),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: Text(context.l10n.buddyAccept),
                  ),
                ),
                AppSpacing.vGapSM,
                // 拒绝
                SizedBox(
                  width: 64,
                  height: 32,
                  child: OutlinedButton(
                    onPressed: () => _reject(context, ref),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: Text(context.l10n.buddyReject),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _accept(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(receivedRequestsProvider.notifier).accept(request.id);
      if (context.mounted) {
        ErrorHandler.showSuccess(context, context.l10n.buddyAccepted);
      }
    } catch (e) {
      if (context.mounted) ErrorHandler.showError(context, e);
    }
  }

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(receivedRequestsProvider.notifier).reject(request.id);
    } catch (e) {
      if (context.mounted) ErrorHandler.showError(context, e);
    }
  }
}

/// 发出的请求 Tab
class _SentTab extends ConsumerWidget {
  const _SentTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(sentRequestsProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(sentRequestsProvider.notifier).refresh(),
      color: AppColors.primary,
      child: requestsAsync.when(
        loading: () => ListView(
          padding: AppSpacing.pagePadding,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
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
            onAction: () => ref.invalidate(sentRequestsProvider),
          ),
        ),
        data: (requests) {
          if (requests.isEmpty) {
            return ListView(
              children: [
                SizedBox(height: context.screenHeight * 0.25),
                EmptyStateWidget(
                  icon: Icons.send_outlined,
                  title: context.l10n.buddyNoSentRequests,
                ),
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            itemCount: requests.length,
            itemBuilder: (context, index) => _SentRequestCard(
              request: requests[index],
            ),
          );
        },
      ),
    );
  }
}

/// 发出的请求卡片
class _SentRequestCard extends ConsumerWidget {
  final BuddyRequestModel request;

  const _SentRequestCard({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: AppSpacing.cardMargin,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: AppRadius.bLG,
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.5)
              : AppColors.lightBorder.withValues(alpha: 0.6),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: AppSpacing.cardPaddingCompact,
        child: Row(
          children: [
            AvatarWidget(
              size: 48,
              imageUrl: request.otherAvatarUrl,
              fallbackText: request.otherNickname,
            ),
            AppSpacing.hGap12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.otherNickname,
                    style: AppTextStyles.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.vGapXS,
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      borderRadius: AppRadius.bXS,
                    ),
                    child: Text(
                      context.l10n.buddyPending,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.strength,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 取消按钮
            OutlinedButton(
              onPressed: () => _cancel(context, ref),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.colorScheme.error,
                side: BorderSide(color: context.colorScheme.error),
                textStyle: const TextStyle(fontSize: 12),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x12, vertical: AppSpacing.sm),
              ),
              child: Text(context.l10n.buddyCancel),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(sentRequestsProvider.notifier).cancel(request.id);
    } catch (e) {
      if (context.mounted) ErrorHandler.showError(context, e);
    }
  }
}
