import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/sport_type_icon.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/profile_provider.dart';

/// 他人档案页
class UserProfilePage extends ConsumerWidget {
  final String userId;

  const UserProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider(userId));

    return Scaffold(
      appBar: AppBar(),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyStateWidget(
          icon: Icons.error_outline,
          title: context.l10n.commonError,
        ),
        data: (profile) {
          if (profile == null) {
            return EmptyStateWidget(
              icon: Icons.person_off_outlined,
              title: context.l10n.profileUserNotFound,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // 头像 + 昵称
              Center(
                child: Column(
                  children: [
                    AvatarWidget(
                      size: 80,
                      imageUrl: profile.avatarUrl,
                      fallbackText: profile.nickname,
                    ),
                    const SizedBox(height: 12),
                    Text(profile.nickname, style: AppTextStyles.h2),
                    if (profile.bio.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        profile.bio,
                        style: AppTextStyles.body.copyWith(
                          color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 信息卡片
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildInfoRow(Icons.location_city, context.l10n.profileCity,
                          profile.city),
                      const Divider(height: 24),
                      _buildInfoRow(Icons.trending_up, context.l10n.profileExperienceLevel,
                          profile.experienceLevelDisplay),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 运动偏好
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.l10n.profileSportPreference, style: AppTextStyles.subtitle),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: profile.sportTypes
                            .map((s) => SportTypeIcon(
                                  sportType: s,
                                  size: 36,
                                  showLabel: true,
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 约练按钮
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: W5 实现发送约练请求
                },
                icon: const Icon(Icons.sports_martial_arts),
                label: Text(context.l10n.sendBuddyRequest),
              ),
              const SizedBox(height: 12),

              // 屏蔽/举报
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // TODO: W6 实现屏蔽
                    },
                    icon: const Icon(Icons.block, size: 16),
                    label: Text(context.l10n.commonBlock),
                    style: TextButton.styleFrom(
                      foregroundColor: context.colorScheme.error,
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: () {
                      // TODO: W6 实现举报
                    },
                    icon: const Icon(Icons.flag_outlined, size: 16),
                    label: Text(context.l10n.commonReport),
                    style: TextButton.styleFrom(
                      foregroundColor: context.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(label, style: AppTextStyles.caption),
        const Spacer(),
        Text(value, style: AppTextStyles.body),
      ],
    );
  }
}
