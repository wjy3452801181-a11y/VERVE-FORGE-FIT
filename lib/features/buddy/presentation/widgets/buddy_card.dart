import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/avatar_widget.dart';
import '../../../../shared/widgets/sport_type_icon.dart';
import '../../domain/buddy_model.dart';

/// 附近伙伴卡片组件
class BuddyCard extends StatelessWidget {
  final BuddyModel buddy;
  final VoidCallback? onTap;
  final VoidCallback? onBuddyUp;

  const BuddyCard({
    super.key,
    required this.buddy,
    this.onTap,
    this.onBuddyUp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 头像
              AvatarWidget(
                size: 52,
                imageUrl: buddy.avatarUrl,
                fallbackText: buddy.nickname,
              ),
              const SizedBox(width: 12),

              // 信息区域
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 昵称 + 距离
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            buddy.nickname,
                            style: AppTextStyles.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (buddy.distanceKm != null) ...[
                          Icon(Icons.location_on_outlined,
                              size: 13,
                              color: context.colorScheme.onSurface
                                  .withValues(alpha: 0.5)),
                          const SizedBox(width: 2),
                          Text(
                            buddy.distanceDisplay,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),

                    // 简介
                    if (buddy.bio.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          buddy.bio,
                          style: AppTextStyles.caption.copyWith(
                            color: context.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    // 运动类型图标 + 等级
                    Row(
                      children: [
                        ...buddy.sportTypes.take(4).map(
                              (s) => Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: SportTypeIcon(sportType: s, size: 20),
                              ),
                            ),
                        if (buddy.sportTypes.length > 4)
                          Text(
                            '+${buddy.sportTypes.length - 4}',
                            style: AppTextStyles.caption,
                          ),
                        const Spacer(),
                        if (buddy.experienceLevel != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              buddy.experienceLevelDisplay,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // 约练按钮
              _buildBuddyUpButton(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 约练按钮
  Widget _buildBuddyUpButton(BuildContext context) {
    return GestureDetector(
      onTap: onBuddyUp,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          context.l10n.sendBuddyRequest,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
