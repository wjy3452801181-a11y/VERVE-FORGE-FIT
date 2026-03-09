import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/sport_type_icon.dart';
import '../domain/user_gym_favorite_model.dart';
import '../providers/gym_provider.dart';

/// 我的收藏训练馆页面
class GymFavoritesPage extends ConsumerWidget {
  const GymFavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favAsync = ref.watch(gymFavoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.gymMyFavorites),
      ),
      body: favAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyStateWidget(
          icon: Icons.error_outline,
          title: context.l10n.commonError,
          actionText: context.l10n.commonRetry,
          onAction: () => ref.invalidate(gymFavoritesProvider),
        ),
        data: (favorites) {
          if (favorites.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.favorite_border,
              title: context.l10n.gymNoFavorites,
              subtitle: context.l10n.gymNearby,
              actionText: context.l10n.gymTitle,
              onAction: () => context.push(AppRoutes.gymList),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(gymFavoritesProvider);
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollEndNotification &&
                    notification.metrics.extentAfter < 200) {
                  ref.read(gymFavoritesProvider.notifier).loadMore();
                }
                return false;
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  return _FavoriteGymCard(
                    favorite: favorites[index],
                    onTap: () {
                      context.push(
                        '${AppRoutes.gymDetail}/${favorites[index].gymId}',
                      );
                    },
                    onRemove: () async {
                      await ref
                          .read(gymFavoriteActionProvider)
                          .toggle(favorites[index].gymId);
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 收藏训练馆卡片
class _FavoriteGymCard extends StatelessWidget {
  final UserGymFavoriteModel favorite;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const _FavoriteGymCard({
    required this.favorite,
    this.onTap,
    this.onRemove,
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
              // 缩略图
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: favorite.gymPhotoUrls.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          favorite.gymPhotoUrls.first,
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

              // 信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      favorite.gymName ?? '',
                      style: AppTextStyles.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (favorite.gymAddress != null)
                      Text(
                        favorite.gymAddress!,
                        style: AppTextStyles.caption.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),
                    // 运动类型 + 评分
                    Row(
                      children: [
                        ...favorite.gymSportTypes.take(3).map(
                              (s) => Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: SportTypeIcon(sportType: s, size: 18),
                              ),
                            ),
                        if (favorite.gymSportTypes.length > 3)
                          Text(
                            '+${favorite.gymSportTypes.length - 3}',
                            style: AppTextStyles.caption,
                          ),
                        const Spacer(),
                        if (favorite.gymRating != null &&
                            favorite.gymReviewCount != null &&
                            favorite.gymReviewCount! > 0) ...[
                          const Icon(Icons.star,
                              size: 14, color: AppColors.accent),
                          const SizedBox(width: 2),
                          Text(
                            favorite.gymRating!.toStringAsFixed(1),
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),

              // 取消收藏按钮
              GestureDetector(
                onTap: onRemove,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.favorite,
                    size: 22,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
