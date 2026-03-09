import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/network/supabase_client.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/sport_type_icon.dart';
import '../domain/challenge_model.dart';
import '../domain/challenge_participant_model.dart';
import '../providers/challenge_provider.dart';

/// 挑战赛排行榜页面 — 使用 Supabase Realtime 实时更新
class ChallengeRankPage extends ConsumerWidget {
  final String challengeId;

  const ChallengeRankPage({super.key, required this.challengeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(challengeDetailProvider(challengeId));
    final leaderboardAsync =
        ref.watch(challengeLeaderboardProvider(challengeId));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.challengeLeaderboard),
        actions: [
          // 实时标记
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  context.l10n.challengeRealtime,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 挑战信息头部
          detailAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (challenge) {
              if (challenge == null) return const SizedBox.shrink();
              return _buildChallengeHeader(context, ref, challenge);
            },
          ),

          // 排行榜
          Expanded(
            child: leaderboardAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(context.l10n.commonError),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.invalidate(
                          challengeLeaderboardProvider(challengeId)),
                      child: Text(context.l10n.commonRetry),
                    ),
                  ],
                ),
              ),
              data: (participants) {
                if (participants.isEmpty) {
                  return Center(
                    child: Text(
                      context.l10n.commonEmpty,
                      style: AppTextStyles.caption,
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(
                        challengeLeaderboardProvider(challengeId));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: participants.length,
                    itemBuilder: (context, index) {
                      return _buildRankItem(
                          context, participants[index], index);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeHeader(
    BuildContext context,
    WidgetRef ref,
    ChallengeModel challenge,
  ) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题行
            Row(
              children: [
                SportTypeIcon(sportType: challenge.sportType, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(challenge.title, style: AppTextStyles.subtitle),
                      const SizedBox(height: 2),
                      Text(
                        '${challenge.sportTypeDisplay} · ${challenge.goalTypeDisplay} ${challenge.goalValue}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 进度条（整体）
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: challenge.remainingDays > 0
                    ? 1.0 -
                        (challenge.remainingDays / challenge.totalDays)
                            .clamp(0.0, 1.0)
                    : 1.0,
                minHeight: 6,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.1),
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),

            // 统计行
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n
                      .challengeParticipants(challenge.participantCount),
                  style: AppTextStyles.caption,
                ),
                Text(
                  challenge.remainingDays > 0
                      ? context.l10n
                          .challengeRemainingDays(challenge.remainingDays)
                      : context.l10n.challengeStatusCompleted,
                  style: AppTextStyles.caption.copyWith(
                    color: challenge.remainingDays > 0
                        ? AppColors.primary
                        : AppColors.other,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 加入/退出按钮
            _buildActionButton(context, ref, challenge),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    ChallengeModel challenge,
  ) {
    final currentUserId = SupabaseClientHelper.currentUserId;
    final isCreator = challenge.isCreatedBy(currentUserId ?? '');
    final isJoined = challenge.isJoined == true;

    if (!challenge.isActive) {
      return const SizedBox.shrink();
    }

    if (isJoined) {
      // 已参加 — 显示退出按钮（创建者不能退出）
      if (isCreator) return const SizedBox.shrink();
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => _handleLeave(context, ref),
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(context.l10n.challengeLeave),
        ),
      );
    }

    // 未参加 — 显示加入按钮
    if (challenge.isFull) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: null,
          child: Text(context.l10n.challengeFull),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () => _handleJoin(context, ref),
        child: Text(context.l10n.challengeJoin),
      ),
    );
  }

  Future<void> _handleJoin(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(challengeActionProvider).join(challengeId);
      if (context.mounted) {
        ErrorHandler.showSuccess(
            context, context.l10n.challengeJoinSuccess);
      }
    } catch (e) {
      if (context.mounted) ErrorHandler.showError(context, e);
    }
  }

  Future<void> _handleLeave(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: context.l10n.challengeLeaveConfirm,
      confirmText: context.l10n.challengeLeave,
      isDestructive: true,
    );
    if (!confirmed) return;

    try {
      await ref.read(challengeActionProvider).leave(challengeId);
      if (context.mounted) {
        ErrorHandler.showSuccess(
            context, context.l10n.challengeLeaveSuccess);
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) ErrorHandler.showError(context, e);
    }
  }

  Widget _buildRankItem(
    BuildContext context,
    ChallengeParticipantModel participant,
    int index,
  ) {
    final isCurrentUser =
        participant.isCurrentUser(SupabaseClientHelper.currentUserId ?? '');
    final rankColor = _getRankColor(index);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primary.withValues(alpha: 0.08)
            : null,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 排名
            SizedBox(
              width: 36,
              child: index < 3
                  ? Icon(
                      Icons.emoji_events,
                      size: 24,
                      color: rankColor,
                    )
                  : Text(
                      participant.rankDisplay,
                      style: AppTextStyles.number.copyWith(
                        fontSize: 16,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
            const SizedBox(width: 12),

            // 头像
            CircleAvatar(
              radius: 18,
              backgroundImage: participant.avatarUrl != null
                  ? NetworkImage(participant.avatarUrl!)
                  : null,
              child: participant.avatarUrl == null
                  ? const Icon(Icons.person, size: 18)
                  : null,
            ),
            const SizedBox(width: 12),

            // 名称 + 打卡
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    participant.nickname ?? '用户',
                    style: AppTextStyles.body.copyWith(
                      fontWeight:
                          isCurrentUser ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${context.l10n.challengeCheckInCount}: ${participant.checkInCount}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),

            // 进度
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  participant.progressDisplay,
                  style: AppTextStyles.number.copyWith(
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  width: 60,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: participant.progressRatio,
                      minHeight: 4,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.1),
                      color: rankColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFFD700); // 金
      case 1:
        return const Color(0xFFC0C0C0); // 银
      case 2:
        return const Color(0xFFCD7F32); // 铜
      default:
        return AppColors.primary;
    }
  }
}
