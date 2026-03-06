import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/sport_type_icon.dart';
import '../../domain/gym_model.dart';

/// 训练馆卡片组件
class GymCard extends StatelessWidget {
  final GymModel gym;
  final VoidCallback? onTap;

  const GymCard({
    super.key,
    required this.gym,
    this.onTap,
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
              // 照片缩略图或默认图标
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: gym.photoUrls.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          gym.photoUrls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.fitness_center,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.fitness_center,
                        color: AppColors.primary,
                      ),
              ),
              const SizedBox(width: 12),
              // 信息区域
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 名称 + 认证标记
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            gym.name,
                            style: AppTextStyles.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (gym.isVerified)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.verified,
                              size: 16,
                              color: AppColors.secondary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // 地址
                    Text(
                      gym.address,
                      style: AppTextStyles.caption.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // 运动类型 + 评分 + 距离
                    Row(
                      children: [
                        // 运动类型图标
                        ...gym.sportTypes.take(3).map(
                              (s) => Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: SportTypeIcon(sportType: s, size: 20),
                              ),
                            ),
                        if (gym.sportTypes.length > 3)
                          Text(
                            '+${gym.sportTypes.length - 3}',
                            style: AppTextStyles.caption,
                          ),
                        const Spacer(),
                        // 评分
                        if (gym.reviewCount > 0) ...[
                          const Icon(Icons.star, size: 14, color: AppColors.accent),
                          const SizedBox(width: 2),
                          Text(gym.ratingDisplay, style: AppTextStyles.caption),
                          const SizedBox(width: 8),
                        ],
                        // 距离
                        if (gym.distanceKm != null)
                          Text(
                            gym.distanceDisplay,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
