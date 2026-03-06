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
import '../../workout/presentation/workout_list_page.dart';
import '../../workout/presentation/workout_calendar_page.dart';
import 'profile_edit_page.dart';
import 'settings_page.dart';

/// 个人主页 — Tab 5
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
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
              title: '请先完成注册',
              actionText: '去注册',
              onAction: () {},
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
                                  '还没有设置简介',
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProfileEditPage(profile: profile),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 信息行
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

                // 训练统计卡片（接入真实数据）
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
                              _buildStatItem('--', '本周训练'),
                              _buildDivider(),
                              _buildStatItem('--', '本月训练'),
                              _buildDivider(),
                              _buildStatItem('--', '总时长'),
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
                              _buildStatItem('0', '本周训练'),
                              _buildDivider(),
                              _buildStatItem('0', '本月训练'),
                              _buildDivider(),
                              _buildStatItem('0h', '总时长'),
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const WorkoutCalendarPage()),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildMenuItem(
                        icon: Icons.list_alt_outlined,
                        title: context.l10n.profileWorkoutLog,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const WorkoutListPage()),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildMenuItem(
                        icon: Icons.fitness_center_outlined,
                        title: context.l10n.gymNearby,
                        onTap: () => context.push(AppRoutes.gymMap),
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildMenuItem(
                        icon: Icons.emoji_events_outlined,
                        title: '我的挑战',
                        onTap: () {},
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildMenuItem(
                        icon: Icons.people_outlined,
                        title: '我的伙伴',
                        onTap: () {},
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
