import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_radius.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/network/supabase_client.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton.dart';
import '../../workout/providers/workout_provider.dart';
import '../../workout/presentation/widgets/workout_stats_card.dart';
import '../providers/profile_provider.dart';
import 'widgets/profile_header_widget.dart';
import 'widgets/profile_info_card.dart';
import 'widgets/sport_chips_widget.dart';

/// 个人主页 — Tab 4
/// 头像+昵称+邮箱+运动偏好+训练信息+功能入口，支持下拉刷新
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final email = SupabaseClientHelper.currentUser?.email;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.profileTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const _ProfileSkeleton(),
        error: (e, _) => EmptyStateWidget(
          icon: Icons.error_outline,
          title: context.l10n.commonError,
          actionText: context.l10n.commonRetry,
          onAction: () => ref.invalidate(currentProfileProvider),
        ),
        data: (profile) {
          if (profile == null) {
            return EmptyStateWidget(
              icon: Icons.person_outline,
              title: context.l10n.profileRegisterFirst,
              actionText: context.l10n.profileGoRegister,
              onAction: () => context.go(AppRoutes.onboarding),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(currentProfileProvider.notifier).refresh(),
            color: AppColors.primary,
            child: ListView(
              padding: AppSpacing.pagePadding,
              children: [
                // 用户信息卡片（头像+昵称+邮箱+简介）
                ProfileHeaderWidget(
                  avatarUrl: profile.avatarUrl,
                  nickname: profile.nickname,
                  email: email,
                  bio: profile.bio,
                  onEditTap: () => context.push(
                    AppRoutes.profileEdit,
                    extra: profile,
                  ),
                ),
                AppSpacing.vGapSM,

                // 运动标签
                if (profile.sportTypes.isNotEmpty) ...[
                  _ProfileCard(
                    child: SportChipsWidget(
                      sportTypes: profile.sportTypes,
                      iconSize: 28,
                    ),
                  ),
                  AppSpacing.vGapSM,
                ],

                // 城市 + 等级
                ProfileInfoCard(
                  city: profile.city,
                  experienceLevel: profile.experienceLevelDisplay,
                ),
                AppSpacing.vGap12,

                // 训练统计卡片
                Consumer(
                  builder: (context, ref, _) {
                    final statsAsync = ref.watch(workoutStatsProvider);
                    return statsAsync.when(
                      loading: () => const _ProfileCard(
                        child: SkeletonStatBar(count: 3),
                      ),
                      error: (_, __) => _ProfileCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(value: '0', label: context.l10n.workoutThisWeek),
                            _StatDivider(),
                            _StatItem(value: '0', label: context.l10n.workoutThisMonth),
                            _StatDivider(),
                            _StatItem(value: '0h', label: context.l10n.workoutTotalHours),
                          ],
                        ),
                      ),
                      data: (stats) => WorkoutStatsCard(stats: stats),
                    );
                  },
                ),
                AppSpacing.vGap12,

                // 功能入口 — 训练
                _SectionHeader(title: context.l10n.profileSectionTraining),
                _MenuCard(
                  items: [
                    _MenuItem(
                      icon: Icons.calendar_month_outlined,
                      title: context.l10n.workoutCalendar,
                      onTap: () => context.push(AppRoutes.workoutCalendar),
                    ),
                    _MenuItem(
                      icon: Icons.list_alt_outlined,
                      title: context.l10n.profileWorkoutLog,
                      onTap: () => context.push(AppRoutes.workoutHistory),
                    ),
                    _MenuItem(
                      icon: Icons.fitness_center_outlined,
                      title: context.l10n.gymNearby,
                      onTap: () => context.push(AppRoutes.gymMap),
                    ),
                    _MenuItem(
                      icon: Icons.favorite_outlined,
                      title: context.l10n.gymMyFavorites,
                      onTap: () => context.push(AppRoutes.gymFavorites),
                    ),
                    _MenuItem(
                      icon: Icons.smart_toy_outlined,
                      title: context.l10n.aiAvatarTitle,
                      onTap: () => context.push(AppRoutes.aiAvatar),
                    ),
                  ],
                ),
                AppSpacing.vGapSM,

                // 功能入口 — 社交
                _SectionHeader(title: context.l10n.profileSectionSocial),
                _MenuCard(
                  items: [
                    _MenuItem(
                      icon: Icons.emoji_events_outlined,
                      title: context.l10n.profileMyChallenges,
                      onTap: () => context.go(AppRoutes.challenges),
                    ),
                    _MenuItem(
                      icon: Icons.people_outlined,
                      title: context.l10n.profileMyBuddies,
                      onTap: () => context.push(AppRoutes.buddyList),
                    ),
                    _MenuItem(
                      icon: Icons.chat_outlined,
                      title: context.l10n.chatTitle,
                      onTap: () => context.push(AppRoutes.conversations),
                    ),
                  ],
                ),
                AppSpacing.vGapSM,

                // 功能入口 — 账户
                _SectionHeader(title: context.l10n.profileSectionAccount),
                _MenuCard(
                  items: [
                    _MenuItem(
                      icon: Icons.privacy_tip_outlined,
                      title: context.l10n.profilePrivacy,
                      onTap: () => context.push(AppRoutes.settings),
                    ),
                  ],
                ),
                AppSpacing.vGapLG,
              ],
            ),
          );
        },
      ),
    );
  }
}

// -------------------------------------------------------
// 页面骨架屏
// -------------------------------------------------------

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: AppSpacing.pagePadding,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        SkeletonCard(),
        SizedBox(height: AppSpacing.sm),
        SkeletonCard(),
        SizedBox(height: AppSpacing.x12),
        SkeletonStatBar(count: 3),
      ],
    );
  }
}

// -------------------------------------------------------
// 通用卡片容器 — 与 challenge_rank_page 保持一致
// -------------------------------------------------------

class _ProfileCard extends StatelessWidget {
  final Widget child;

  const _ProfileCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x20,
        vertical: AppSpacing.md,
      ),
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
      child: child,
    );
  }
}

// -------------------------------------------------------
// Section 标题
// -------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        bottom: AppSpacing.x6,
        top: AppSpacing.xs,
      ),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.label.copyWith(
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// -------------------------------------------------------
// 菜单卡片 — 统一卡片包裹 + 分割线
// -------------------------------------------------------

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;

  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
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
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _buildTile(context, items[i], isDark),
            if (i < items.length - 1)
              Divider(
                height: 1,
                indent: AppSpacing.md + 40 + AppSpacing.sm, // align with text
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, _MenuItem item, bool isDark) {
    return InkWell(
      borderRadius: AppRadius.bLG,
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkCardHover
                    : AppColors.lightCardHover,
                borderRadius: AppRadius.bSM,
              ),
              child: Icon(
                item.icon,
                size: 20,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            AppSpacing.hGapMD,
            Expanded(
              child: Text(item.title, style: AppTextStyles.body),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------
// 统计数字 + 垂直分割线（用于错误态兜底）
// -------------------------------------------------------

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.number.copyWith(color: AppColors.primary)),
        AppSpacing.vGapXS,
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 1,
      height: 32,
      color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
    );
  }
}
