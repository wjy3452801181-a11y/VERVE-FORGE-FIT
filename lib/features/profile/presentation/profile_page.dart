import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/network/supabase_client.dart';
import '../../../shared/widgets/empty_state.dart';
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
        loading: () => const Center(child: CircularProgressIndicator()),
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
            child: ListView(
              padding: const EdgeInsets.all(16),
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
                const SizedBox(height: 8),

                // 运动标签
                if (profile.sportTypes.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      child: SportChipsWidget(
                        sportTypes: profile.sportTypes,
                        iconSize: 28,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),

                // 城市 + 等级
                ProfileInfoCard(
                  city: profile.city,
                  experienceLevel: profile.experienceLevelDisplay,
                ),
                const SizedBox(height: 12),

                // 训练统计卡片
                Consumer(
                  builder: (context, ref, _) {
                    final statsAsync = ref.watch(workoutStatsProvider);
                    return statsAsync.when(
                      loading: () => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                  '--', context.l10n.workoutThisWeek),
                              _buildDivider(),
                              _buildStatItem(
                                  '--', context.l10n.workoutThisMonth),
                              _buildDivider(),
                              _buildStatItem(
                                  '--', context.l10n.workoutTotalHours),
                            ],
                          ),
                        ),
                      ),
                      error: (_, __) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                  '0', context.l10n.workoutThisWeek),
                              _buildDivider(),
                              _buildStatItem(
                                  '0', context.l10n.workoutThisMonth),
                              _buildDivider(),
                              _buildStatItem(
                                  '0h', context.l10n.workoutTotalHours),
                            ],
                          ),
                        ),
                      ),
                      data: (stats) => WorkoutStatsCard(stats: stats),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // 功能入口
                Card(
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.calendar_month_outlined,
                        title: context.l10n.workoutCalendar,
                        onTap: () => context.push(AppRoutes.workoutCalendar),
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildMenuItem(
                        icon: Icons.list_alt_outlined,
                        title: context.l10n.profileWorkoutLog,
                        onTap: () => context.push(AppRoutes.workoutHistory),
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildMenuItem(
                        icon: Icons.fitness_center_outlined,
                        title: context.l10n.gymNearby,
                        onTap: () => context.push(AppRoutes.gymMap),
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildMenuItem(
                        icon: Icons.favorite_outlined,
                        title: context.l10n.gymMyFavorites,
                        onTap: () => context.push(AppRoutes.gymFavorites),
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildMenuItem(
                        icon: Icons.smart_toy_outlined,
                        title: context.l10n.aiAvatarTitle,
                        onTap: () => context.push(AppRoutes.aiAvatar),
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildMenuItem(
                        icon: Icons.emoji_events_outlined,
                        title: context.l10n.profileMyChallenges,
                        onTap: () => context.go(AppRoutes.challenges),
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildMenuItem(
                        icon: Icons.people_outlined,
                        title: context.l10n.profileMyBuddies,
                        onTap: () => context.push(AppRoutes.buddyList),
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildMenuItem(
                        icon: Icons.chat_outlined,
                        title: context.l10n.chatTitle,
                        onTap: () => context.push(AppRoutes.conversations),
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildMenuItem(
                        icon: Icons.privacy_tip_outlined,
                        title: context.l10n.profilePrivacy,
                        onTap: () => context.push(AppRoutes.settings),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.number.copyWith(color: AppColors.primary)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 32,
      color: Colors.grey.withValues(alpha: 0.2),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
