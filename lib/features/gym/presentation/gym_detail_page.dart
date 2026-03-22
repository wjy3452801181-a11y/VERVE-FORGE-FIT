import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_radius.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/errors/error_handler.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton.dart';
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
          _buildFavoriteAppBarButton(ref, favAsync),
        ],
      ),
      body: gymAsync.when(
        loading: () => ListView(
          padding: AppSpacing.pagePadding,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            SkeletonCard(),
            SizedBox(height: AppSpacing.x12),
            SkeletonCard(),
          ],
        ),
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

          final isDark =
              Theme.of(context).brightness == Brightness.dark;

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
                        errorBuilder: (_, __, ___) => _PhotoPlaceholder(
                            isDark: isDark),
                      );
                    },
                  ),
                )
              else
                _PhotoPlaceholder(isDark: isDark, height: 160),

              Padding(
                padding: AppSpacing.pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 名称 + 验证标记
                    Row(
                      children: [
                        Expanded(
                          child: Text(gym.name,
                              style: AppTextStyles.h2),
                        ),
                        if (gym.isVerified) ...[
                          AppSpacing.hGapSM,
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary
                                  .withValues(alpha: 0.12),
                              borderRadius: AppRadius.bXS,
                              border: Border.all(
                                color: AppColors.secondary
                                    .withValues(alpha: 0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified,
                                    size: 13,
                                    color: AppColors.secondary),
                                AppSpacing.hGapXS,
                                Text(
                                  context.l10n.gymVerified,
                                  style: AppTextStyles.label.copyWith(
                                    color: AppColors.secondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    AppSpacing.vGapXS,

                    // 评分
                    if (gym.reviewCount > 0) ...[
                      Row(
                        children: [
                          RatingBar(
                              rating: gym.rating.round(), size: 18),
                          AppSpacing.hGapSM,
                          Text(
                            '${gym.ratingDisplay} (${gym.reviewCount})',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ],
                    AppSpacing.vGapMD,

                    // 信息行
                    _buildInfoRow(context, Icons.location_on_outlined,
                        context.l10n.gymAddress, gym.address,
                        isDark: isDark),
                    if (gym.phone != null)
                      _buildInfoRow(
                        context,
                        Icons.phone_outlined,
                        context.l10n.gymPhone,
                        gym.phone!,
                        onTap: () =>
                            launchUrl(Uri.parse('tel:${gym.phone}')),
                        isDark: isDark,
                      ),
                    if (gym.website != null)
                      _buildInfoRow(
                        context,
                        Icons.language_outlined,
                        context.l10n.gymWebsite,
                        gym.website!,
                        onTap: () =>
                            launchUrl(Uri.parse(gym.website!)),
                        isDark: isDark,
                      ),
                    if (gym.openingHours != null)
                      _buildInfoRow(
                        context,
                        Icons.access_time_outlined,
                        context.l10n.gymOpeningHours,
                        gym.openingHours!,
                        isDark: isDark,
                      ),
                    AppSpacing.vGapMD,

                    // 运动类型
                    _SectionLabel(label: context.l10n.gymSportTypes),
                    AppSpacing.vGapSM,
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: gym.sportTypes
                          .map((s) => SportTypeIcon(
                                sportType: s,
                                size: 32,
                                showLabel: true,
                              ))
                          .toList(),
                    ),
                    AppSpacing.vGapLG,

                    // 馆主认领区域
                    _buildClaimSection(context, ref, gym, claimAsync),

                    // 评价区标题 + 写评价按钮
                    Row(
                      children: [
                        _SectionLabel(
                            label: context.l10n.gymReviews),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () => context.push(
                            '${AppRoutes.gymReview}/$gymId',
                          ),
                          icon: const Icon(
                              Icons.rate_review_outlined,
                              size: 18),
                          label: Text(context.l10n.gymWriteReview),
                        ),
                      ],
                    ),
                    AppSpacing.vGapSM,

                    // 评价列表
                    reviewsAsync.when(
                      loading: () => const SkeletonAvatarRow(),
                      error: (_, __) =>
                          Text(context.l10n.commonError),
                      data: (reviews) {
                        if (reviews.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md),
                            child: Center(
                              child: Text(
                                context.l10n.gymNoReviews,
                                style: AppTextStyles.caption.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: reviews
                              .map((r) => _buildReviewItem(
                                  context, r, isDark))
                              .toList(),
                        );
                      },
                    ),
                    AppSpacing.vGapLG,
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFavoriteAppBarButton(
      WidgetRef ref, AsyncValue<bool> favAsync) {
    final isFav = favAsync.valueOrNull ?? false;
    return IconButton(
      onPressed: () =>
          ref.read(gymFavoriteActionProvider).toggle(gymId),
      icon: Icon(
        isFav ? Icons.favorite : Icons.favorite_border,
        color: isFav ? AppColors.crossfit : null,
      ),
    );
  }

  Widget _buildClaimSection(
    BuildContext context,
    WidgetRef ref,
    dynamic gym,
    AsyncValue claimAsync,
  ) {
    if (gym.isVerified) return const SizedBox.shrink();

    final claim = claimAsync.valueOrNull;

    if (claim != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.x12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: AppRadius.bMD,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.store_outlined,
                  size: 20, color: AppColors.primary),
              AppSpacing.hGapSM,
              Expanded(
                child: Text(
                  '${context.l10n.gymClaimStatus}: ${claim.statusDisplay}',
                  style: AppTextStyles.body,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
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
        ErrorHandler.showSuccess(context, context.l10n.gymClaimSuccess);
      }
    } catch (e) {
      if (context.mounted) ErrorHandler.showError(context, e);
    }
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.x6),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.bXS,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            AppSpacing.hGapSM,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  Text(
                    value,
                    style: AppTextStyles.body.copyWith(
                      color: onTap != null ? AppColors.primary : null,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                size: 16,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(
      BuildContext context, GymReviewModel review, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.x12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardHover : AppColors.lightCardHover,
        borderRadius: AppRadius.bMD,
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.4)
              : AppColors.lightBorder.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RatingBar(rating: review.rating, size: 14),
              const Spacer(),
              Text(
                _formatDate(review.createdAt),
                style: AppTextStyles.caption.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          if (review.content != null &&
              review.content!.isNotEmpty) ...[
            AppSpacing.vGapSM,
            Text(review.content!, style: AppTextStyles.body),
          ],
          if (review.photoUrls.isNotEmpty) ...[
            AppSpacing.vGapSM,
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.photoUrls.length,
                separatorBuilder: (_, __) => AppSpacing.hGapSM,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: AppRadius.bXS,
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
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// -------------------------------------------------------
// Section 标签（复用跨页面统一风格）
// -------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      label.toUpperCase(),
      style: AppTextStyles.label.copyWith(
        color: isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// -------------------------------------------------------
// 图片占位（无图时 + 加载失败）
// -------------------------------------------------------

class _PhotoPlaceholder extends StatelessWidget {
  final bool isDark;
  final double height;

  const _PhotoPlaceholder({required this.isDark, this.height = 200});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: isDark
          ? AppColors.darkCard
          : AppColors.primary.withValues(alpha: 0.08),
      child: Center(
        child: Icon(
          Icons.fitness_center,
          size: 48,
          color: AppColors.primary.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
