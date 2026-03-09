import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/errors/error_handler.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/sport_type_icon.dart';
import '../domain/gym_review_model.dart';
import '../providers/gym_provider.dart';
import '../providers/gym_review_provider.dart';
import 'widgets/rating_bar.dart';

/// 训练馆详情页
class GymDetailPage extends ConsumerWidget {
  final String gymId;

  const GymDetailPage({super.key, required this.gymId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gymAsync = ref.watch(gymDetailProvider(gymId));
    final reviewsAsync = ref.watch(gymReviewsProvider(gymId));
    final favAsync = ref.watch(gymFavoriteStatusProvider(gymId));
    final claimAsync = ref.watch(gymClaimStatusProvider(gymId));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.gymDetail),
        actions: [
          // 收藏按钮
          _buildFavoriteAppBarButton(ref, favAsync),
        ],
      ),
      body: gymAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyStateWidget(
          icon: Icons.error_outline,
          title: context.l10n.commonError,
          actionText: context.l10n.commonRetry,
          onAction: () => ref.invalidate(gymDetailProvider(gymId)),
        ),
        data: (gym) {
          if (gym == null) {
            return EmptyStateWidget(
              icon: Icons.fitness_center_outlined,
              title: context.l10n.commonEmpty,
            );
          }

          return ListView(
            children: [
              // 照片轮播
              if (gym.photoUrls.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    itemCount: gym.photoUrls.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        gym.photoUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.fitness_center,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  height: 160,
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: const Center(
                    child: Icon(
                      Icons.fitness_center,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 名称 + 验证标记
                    Row(
                      children: [
                        Expanded(
                          child: Text(gym.name, style: AppTextStyles.h2),
                        ),
                        if (gym.isVerified)
                          Chip(
                            avatar: const Icon(Icons.verified,
                                size: 16, color: AppColors.secondary),
                            label: Text(context.l10n.gymVerified),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // 评分
                    if (gym.reviewCount > 0)
                      Row(
                        children: [
                          RatingBar(
                            rating: gym.rating.round(),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${gym.ratingDisplay} (${gym.reviewCount})',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),

                    // 地址
                    _buildInfoRow(
                      Icons.location_on_outlined,
                      context.l10n.gymAddress,
                      gym.address,
                    ),

                    // 电话
                    if (gym.phone != null)
                      _buildInfoRow(
                        Icons.phone_outlined,
                        context.l10n.gymPhone,
                        gym.phone!,
                        onTap: () =>
                            launchUrl(Uri.parse('tel:${gym.phone}')),
                      ),

                    // 网站
                    if (gym.website != null)
                      _buildInfoRow(
                        Icons.language_outlined,
                        context.l10n.gymWebsite,
                        gym.website!,
                        onTap: () =>
                            launchUrl(Uri.parse(gym.website!)),
                      ),

                    // 营业时间
                    if (gym.openingHours != null)
                      _buildInfoRow(
                        Icons.access_time_outlined,
                        context.l10n.gymOpeningHours,
                        gym.openingHours!,
                      ),
                    const SizedBox(height: 16),

                    // 运动类型
                    Text(
                      context.l10n.gymSportTypes,
                      style: AppTextStyles.subtitle,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: gym.sportTypes
                          .map((s) => SportTypeIcon(
                                sportType: s,
                                size: 32,
                                showLabel: true,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),

                    // 馆主认领区域
                    _buildClaimSection(context, ref, gym, claimAsync),

                    // 评价区标题 + 写评价按钮
                    Row(
                      children: [
                        Text(
                          context.l10n.gymReviews,
                          style: AppTextStyles.subtitle,
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => context.push(
                            '${AppRoutes.gymReview}/$gymId',
                          ),
                          icon: const Icon(Icons.rate_review_outlined,
                              size: 18),
                          label: Text(context.l10n.gymWriteReview),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // 评价列表
                    reviewsAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, __) => Text(context.l10n.commonError),
                      data: (reviews) {
                        if (reviews.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                context.l10n.gymNoReviews,
                                style: AppTextStyles.caption,
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: reviews
                              .map((r) => _buildReviewItem(context, r))
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// AppBar 收藏按钮
  Widget _buildFavoriteAppBarButton(
    WidgetRef ref,
    AsyncValue<bool> favAsync,
  ) {
    final isFav = favAsync.valueOrNull ?? false;
    return IconButton(
      onPressed: () =>
          ref.read(gymFavoriteActionProvider).toggle(gymId),
      icon: Icon(
        isFav ? Icons.favorite : Icons.favorite_border,
        color: isFav ? Colors.redAccent : null,
      ),
    );
  }

  /// 馆主认领区域
  Widget _buildClaimSection(
    BuildContext context,
    WidgetRef ref,
    dynamic gym,
    AsyncValue claimAsync,
  ) {
    // 已认证的训练馆不显示认领按钮
    if (gym.isVerified) return const SizedBox.shrink();

    final claim = claimAsync.valueOrNull;

    // 已提交过认领
    if (claim != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Card(
          color: AppColors.primary.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.store_outlined,
                    size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${context.l10n.gymClaimStatus}: ${claim.statusDisplay}',
                    style: AppTextStyles.body,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 未认领 — 显示认领按钮
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _handleClaim(context, ref),
          icon: const Icon(Icons.store_outlined),
          label: Text(context.l10n.gymClaimThis),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
        ),
      ),
    );
  }

  /// 处理认领操作
  Future<void> _handleClaim(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: context.l10n.gymClaimConfirm,
      content: context.l10n.gymClaimConfirmDesc,
      confirmText: context.l10n.gymClaimSubmit,
    );
    if (!confirmed) return;

    try {
      await ref.read(gymClaimActionProvider).submit(gymId: gymId);
      if (context.mounted) {
        ErrorHandler.showSuccess(
            context, context.l10n.gymClaimSuccess);
      }
    } catch (e) {
      if (context.mounted) ErrorHandler.showError(context, e);
    }
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.caption),
                  Text(
                    value,
                    style: AppTextStyles.body.copyWith(
                      color: onTap != null ? AppColors.primary : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(BuildContext context, GymReviewModel review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                RatingBar(rating: review.rating, size: 14),
                const Spacer(),
                Text(
                  _formatDate(review.createdAt),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            if (review.content != null && review.content!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(review.content!, style: AppTextStyles.body),
            ],
            if (review.photoUrls.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.photoUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        review.photoUrls[index],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
