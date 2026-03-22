import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_animations.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/network/supabase_client.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/sport_type_icon.dart';
import '../../../shared/widgets/skeleton.dart';
import '../../../shared/widgets/workout_bar.dart';
import '../domain/challenge_model.dart';
import '../domain/challenge_participant_model.dart';
import '../providers/challenge_provider.dart';

/// 挑战赛排行榜页面 — Supabase Realtime 实时更新 + Volt 成就高亮
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
          // 实时在线指示器
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _RealtimeDot(),
                AppSpacing.hGapXS,
                Text(
                  context.l10n.challengeRealtime,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.success,
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
            loading: () => const Padding(
              padding: AppSpacing.cardMargin,
              child: SkeletonCard(),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (challenge) {
              if (challenge == null) return const SizedBox.shrink();
              return _ChallengeHeader(
                challenge: challenge,
                challengeId: challengeId,
              );
            },
          ),

          // 排行榜
          Expanded(
            child: leaderboardAsync.when(
              loading: () => ListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                ),
                itemCount: 6,
                itemBuilder: (_, __) => const Padding(
                  padding: AppSpacing.cardMargin,
                  child: SkeletonAvatarRow(),
                ),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(context.l10n.commonError),
                    AppSpacing.vGapSM,
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
                  onRefresh: () async => ref.invalidate(
                      challengeLeaderboardProvider(challengeId)),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: participants.length,
                    itemBuilder: (context, index) => _RankItem(
                      participant: participants[index],
                      index: index,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 实时脉冲绿点
// ─────────────────────────────────────────────
class _RealtimeDot extends StatefulWidget {
  @override
  State<_RealtimeDot> createState() => _RealtimeDotState();
}

class _RealtimeDotState extends State<_RealtimeDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.smooth),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, __) => Transform.scale(
        scale: _scale.value,
        child: Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withValues(alpha: 0.4 * _scale.value),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 挑战头部信息卡
// ─────────────────────────────────────────────
class _ChallengeHeader extends ConsumerWidget {
  final ChallengeModel challenge;
  final String challengeId;

  const _ChallengeHeader({
    required this.challenge,
    required this.challengeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final elapsed = challenge.totalDays - challenge.remainingDays;
    final progressRatio =
        (elapsed / challenge.totalDays).clamp(0.0, 1.0);

    return Container(
      margin: AppSpacing.cardMargin,
      padding: AppSpacing.cardPadding,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              SportTypeIcon(sportType: challenge.sportType, size: 40),
              AppSpacing.hGap12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(challenge.title, style: AppTextStyles.subtitle),
                    AppSpacing.vGapXS,
                    Text(
                      '${challenge.sportTypeDisplay} · ${challenge.goalTypeDisplay} ${challenge.goalValue}',
                      style: AppTextStyles.caption.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.vGap12,

          // 赛程进度条（WorkoutBar，时间维度）
          WorkoutBar(
            value: progressRatio,
            intensity: (progressRatio * 10).round().clamp(1, 10),
            showLabel: false,
            height: 6,
          ),
          AppSpacing.vGapSM,

          // 统计行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n
                    .challengeParticipants(challenge.participantCount),
                style: AppTextStyles.caption.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              Text(
                challenge.remainingDays > 0
                    ? context.l10n
                        .challengeRemainingDays(challenge.remainingDays)
                    : context.l10n.challengeStatusCompleted,
                style: AppTextStyles.caption.copyWith(
                  color: challenge.remainingDays > 3
                      ? (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary)
                      : challenge.remainingDays > 0
                          ? AppColors.warning  // 紧迫：≤3天用警告色
                          : AppColors.secondary,
                  fontWeight: challenge.remainingDays <= 3
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ],
          ),
          AppSpacing.vGap12,

          // 操作按钮
          _ActionButton(challenge: challenge, challengeId: challengeId),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 加入 / 退出按钮
// ─────────────────────────────────────────────
class _ActionButton extends ConsumerWidget {
  final ChallengeModel challenge;
  final String challengeId;

  const _ActionButton({
    required this.challenge,
    required this.challengeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = SupabaseClientHelper.currentUserId;
    final isCreator = challenge.isCreatedBy(currentUserId ?? '');
    final isJoined = challenge.isJoined == true;

    if (!challenge.isActive) return const SizedBox.shrink();
    if (isCreator && isJoined) return const SizedBox.shrink();

    if (isJoined) {
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
        ErrorHandler.showSuccess(context, context.l10n.challengeJoinSuccess);
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
        ErrorHandler.showSuccess(context, context.l10n.challengeLeaveSuccess);
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) ErrorHandler.showError(context, e);
    }
  }
}

// ─────────────────────────────────────────────
// 排行榜单行
// ─────────────────────────────────────────────
class _RankItem extends StatelessWidget {
  final ChallengeParticipantModel participant;
  final int index;

  const _RankItem({required this.participant, required this.index});

  bool get _isFirst => index == 0;
  bool get _isPodium => index < 3; // 前三名

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCurrentUser = participant.isCurrentUser(
      SupabaseClientHelper.currentUserId ?? '',
    );

    // 颜色逻辑
    // #1: volt
    // #2: silver
    // #3: bronze
    // 当前用户: primary tint
    // 其他: 透明
    final Color? bgColor = _isFirst
        ? AppColors.voltSurface
        : isCurrentUser
            ? (isDark
                ? AppColors.darkCardHover
                : AppColors.lightCardHover)
            : null;

    final Border? border = _isFirst
        ? Border.all(
            color: AppColors.volt.withValues(alpha: 0.35),
            width: 0.8,
          )
        : isCurrentUser
            ? Border.all(
                color: isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
                width: 0.5,
              )
            : null;

    final List<BoxShadow>? shadow = _isFirst
        ? AppShadows.voltGlow(intensity: 0.4)
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.x3,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.bSM,
        border: border,
        boxShadow: shadow,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.x12,
        ),
        child: Row(
          children: [
            // 排名区（固定宽度）
            SizedBox(width: 32, child: _buildRankSlot(context)),
            AppSpacing.hGap12,

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
            AppSpacing.hGap12,

            // 名称 + 打卡次数
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    participant.nickname ?? '用户',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: isCurrentUser || _isFirst
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: _isFirst ? AppColors.volt : null,
                    ),
                  ),
                  AppSpacing.vGapXS,
                  Text(
                    '${context.l10n.challengeCheckInCount}: ${participant.checkInCount}',
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // 进度数值 + 进度条
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  participant.progressDisplay,
                  style: AppTextStyles.number.copyWith(
                    fontSize: 16,
                    color: _isFirst ? AppColors.volt : null,
                    shadows:
                        _isFirst ? AppShadows.textSubtle : null,
                  ),
                ),
                AppSpacing.vGapXS,
                WorkoutBar(
                  value: participant.progressRatio,
                  intensity: _rankIntensity,
                  showLabel: false,
                  height: 4,
                  maxWidth: 60,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankSlot(BuildContext context) {
    if (_isFirst) {
      // #1 — volt 闪电图标
      return const Icon(
        Icons.bolt_rounded,
        size: 22,
        color: AppColors.volt,
      );
    }
    if (_isPodium) {
      return Icon(
        Icons.emoji_events_rounded,
        size: 22,
        color: _podiumColor,
      );
    }
    // 4名及以后 — 数字
    return Text(
      participant.rankDisplay,
      style: AppTextStyles.number.copyWith(
        fontSize: 14,
        color: Theme.of(context)
            .colorScheme
            .onSurface
            .withValues(alpha: 0.4),
      ),
      textAlign: TextAlign.center,
    );
  }

  /// 前三名徽章颜色
  Color get _podiumColor {
    switch (index) {
      case 1:
        return const Color(0xFFB0B0B0); // 银
      case 2:
        return const Color(0xFFCD7F32); // 铜
      default:
        return AppColors.secondary;
    }
  }

  /// 进度条强度：#1最深，往后递减
  int get _rankIntensity {
    if (_isFirst) return 10;
    if (index == 1) return 7;
    if (index == 2) return 5;
    return 4;
  }
}
