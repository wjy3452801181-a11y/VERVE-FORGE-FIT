import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/sport_type_icon.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../profile/providers/profile_provider.dart';
import '../../workout/providers/workout_provider.dart';
import '../../workout/presentation/widgets/workout_stats_card.dart';

/// 个人主页 — Tab 4
/// 用户信息卡片、训练统计、功能入口（训练日历/日志/收藏/挑战/伙伴/隐私）
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

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
            onRefresh: () => ref.read(currentProfileProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 用户信息卡片
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        AvatarWidget(
                          size: 64,
                          imageUrl: profile.avatarUrl,
                          fallbackText: profile.nickname,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.nickname,
                                style: AppTextStyles.subtitle,
                              ),
                              const SizedBox(height: 4),
                              if (profile.bio.isNotEmpty)
                                Text(
                                  profile.bio,
                                  style: AppTextStyles.caption.copyWith(
                                    color: context.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )
                              else
                                Text(
                                  context.l10n.profileNoBio,
                                  style: AppTextStyles.caption.copyWith(
                                    color: context.colorScheme.onSurface
                                        .withValues(alpha: 0.4),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              // 运动标签
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: profile.sportTypes
                                    .map((s) => SportTypeIcon(
                                          sportType: s,
                                          size: 24,
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () => context.push(
                            AppRoutes.profileEdit,
                            extra: profile,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 信息行：城市 + 等级
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        _buildInfoChip(
                          Icons.location_city,
                          _cityName(context, profile.city),
                        ),
                        const SizedBox(width: 16),
                        _buildInfoChip(
                          Icons.trending_up,
                          profile.experienceLevelDisplay,
                        ),
                      ],
                    ),
                  ),
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
                      // 训练日历
                      _buildMenuItem(
                        icon: Icons.calendar_month_outlined,
                        title: context.l10n.workoutCalendar,
                        onTap: () => context.push(AppRoutes.workoutCalendar),
                      ),
                      const Divider(height: 1, indent: 56),

                      // 训练日志
                      _buildMenuItem(
                        icon: Icons.list_alt_outlined,
                        title: context.l10n.profileWorkoutLog,
                        onTap: () => context.push(AppRoutes.workoutHistory),
                      ),
                      const Divider(height: 1, indent: 56),

                      // 训练馆地图
                      _buildMenuItem(
                        icon: Icons.fitness_center_outlined,
                        title: context.l10n.gymNearby,
                        onTap: () => context.push(AppRoutes.gymMap),
                      ),
                      const Divider(height: 1, indent: 56),

                      // 收藏训练馆
                      _buildMenuItem(
                        icon: Icons.favorite_outlined,
                        title: context.l10n.gymMyFavorites,
                        onTap: () => context.push(AppRoutes.gymFavorites),
                      ),
                      const Divider(height: 1, indent: 56),

                      // 我的挑战 → 跳转挑战 Tab
                      _buildMenuItem(
                        icon: Icons.emoji_events_outlined,
                        title: context.l10n.profileMyChallenges,
                        onTap: () => context.go(AppRoutes.challenges),
                      ),
                      const Divider(height: 1, indent: 56),

                      // 我的伙伴 → 跳转附近 Tab
                      _buildMenuItem(
                        icon: Icons.people_outlined,
                        title: context.l10n.profileMyBuddies,
                        onTap: () => context.go(AppRoutes.nearby),
                      ),
                      const Divider(height: 1, indent: 56),

                      // 隐私设置
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

  /// 城市 key → l10n 显示名称
  String _cityName(BuildContext context, String city) {
    final names = {
      'beijing': context.l10n.cityBeijing,
      'shanghai': context.l10n.cityShanghai,
      'guangzhou': context.l10n.cityGuangzhou,
      'shenzhen': context.l10n.cityShenzhen,
      'hongkong': context.l10n.cityHongkong,
    };
    return names[city] ?? city;
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(text, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value,
            style:
                AppTextStyles.number.copyWith(color: AppColors.primary)),
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
