import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../shared/widgets/sport_type_icon.dart';
import '../../domain/gym_model.dart';
import '../../providers/gym_provider.dart';

/// 训练馆卡片组件
class GymCard extends ConsumerWidget {
  final GymModel gym;
  final VoidCallback? onTap;

  const GymCard({
    super.key,
    required this.gym,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favAsync = ref.watch(gymFavoriteStatusProvider(gym.id));

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
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.bLG,
        child: Padding(
          padding: AppSpacing.cardPaddingCompact,
          child: Row(
            children: [
              // 照片缩略图或默认图标
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: AppRadius.bSM,
                ),
                child: gym.photoUrls.isNotEmpty
                    ? ClipRRect(
                        borderRadius: AppRadius.bSM,
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
              AppSpacing.hGap12,

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
                            padding:
                                EdgeInsets.only(left: AppSpacing.xs),
                            child: Icon(
                              Icons.verified,
                              size: 16,
                              color: AppColors.secondary,
                            ),
                          ),
                      ],
                    ),
                    AppSpacing.vGapXS,

                    // 地址
                    Text(
                      gym.address,
                      style: AppTextStyles.caption.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.vGapSM,

                    // 运动类型 + 评分 + 距离
                    Row(
                      children: [
                        ...gym.sportTypes.take(3).map(
                              (s) => Padding(
                                padding:
                                    const EdgeInsets.only(right: AppSpacing.xs),
                                child: SportTypeIcon(sportType: s, size: 20),
                              ),
                            ),
                        if (gym.sportTypes.length > 3)
                          Text(
                            '+${gym.sportTypes.length - 3}',
                            style: AppTextStyles.caption,
                          ),
                        const Spacer(),
                        if (gym.reviewCount > 0) ...[
                          const Icon(Icons.star,
                              size: 14, color: AppColors.accent),
                          AppSpacing.hGapXS,
                          Text(gym.ratingDisplay,
                              style: AppTextStyles.caption),
                          AppSpacing.hGapSM,
                        ],
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
              AppSpacing.hGapXS,

              // 收藏按钮
              _buildFavoriteButton(ref, favAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(WidgetRef ref, AsyncValue<bool> favAsync) {
    final isFav = favAsync.valueOrNull ?? false;
    return GestureDetector(
      onTap: () => ref.read(gymFavoriteActionProvider).toggle(gym.id),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          size: 22,
          color: isFav
              ? AppColors.crossfit
              : AppColors.primary.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
