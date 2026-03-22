import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/avatar_widget.dart';
import '../../domain/post_model.dart';
import '../../providers/post_provider.dart';

/// 图片缩略图解码宽度上限（像素）
/// 【性能优化】限制 CachedNetworkImage 解码尺寸，降低 GPU 内存
const _kThumbDecodeWidth = 400;

/// 动态卡片组件 — 街头涂鸦风格
///
/// 【性能优化说明】
/// 1. 移除 IntrinsicHeight — 改用左侧 Border 装饰替代独立 Container，
///    避免 O(N) 的双次布局开销
/// 2. 内嵌 like 状态 — 优先使用 PostModel.isLiked 字段（服务端一次查询返回），
///    仅回退到 postLikeStatusProvider 兜底
/// 3. CachedNetworkImage 添加 placeholder（Shimmer）+ memCacheWidth 限制解码尺寸
/// 4. 互动行抽取为独立 Consumer，避免 like 状态变化导致整张卡片 rebuild
class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onTap;
  final VoidCallback? onAuthorTap;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onAuthorTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x12,
          vertical: AppSpacing.x6,
        ),
        child: ClipRRect(
          borderRadius: AppRadius.bSM,
          child: Container(
            decoration: BoxDecoration(
              color: context.theme.colorScheme.surface,
              border: const Border(
                left: BorderSide(color: AppColors.primary, width: 4),
                top: BorderSide(color: Colors.black87, width: 2.5),
                right: BorderSide(color: Colors.black87, width: 2.5),
                bottom: BorderSide(color: Colors.black87, width: 2.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x14,
                vertical: AppSpacing.x12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 作者信息行
                  _buildAuthorRow(context),
                  AppSpacing.vGapSM,

                  // 正文内容
                  if (post.content.isNotEmpty)
                    Text(post.content, style: AppTextStyles.body),

                  // 照片网格
                  if (post.hasPhotos) ...[
                    AppSpacing.vGapSM,
                    _buildPhotoGrid(),
                  ],

                  AppSpacing.vGap10,

                  // 互动行用独立 Consumer 包裹
                  _PostActionRow(
                    post: post,
                    onCommentTap: onTap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 作者行：头像 + 昵称 + 时间
  Widget _buildAuthorRow(BuildContext context) {
    return Row(
      children: [
        AvatarWidget(
          imageUrl: post.authorAvatar,
          size: 40,
          fallbackText: post.authorNickname,
          onTap: onAuthorTap,
          showBorder: true,
        ),
        AppSpacing.hGap10,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.authorNickname ?? context.l10n.commonEmpty,
                style: AppTextStyles.subtitle.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              AppSpacing.vGapXS,
              Text(
                post.timeAgo,
                style: AppTextStyles.caption.copyWith(
                  color: context.theme.colorScheme.onSurface
                      .withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 照片网格（1 张全宽，2-3 张一行，4+ 九宫格）
  Widget _buildPhotoGrid() {
    final photos = post.imageUrls;
    final count = photos.length;

    if (count == 1) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.bXS,
          border: Border.all(color: Colors.black87, width: 2),
        ),
        child: ClipRRect(
          borderRadius: AppRadius.bXS,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240),
            child: CachedNetworkImage(
              imageUrl: photos[0],
              width: double.infinity,
              fit: BoxFit.cover,
              memCacheWidth: _kThumbDecodeWidth,
              placeholder: (_, __) => const _ImageShimmer(height: 200),
              errorWidget: (_, __, ___) => const _ImageErrorPlaceholder(),
            ),
          ),
        ),
      );
    }

    // 多张照片 — 网格
    final crossAxisCount = count <= 3 ? count : 3;
    final displayCount = count > 9 ? 9 : count;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.xs,
        mainAxisSpacing: AppSpacing.xs,
      ),
      itemCount: displayCount,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.bXS,
            border: Border.all(color: Colors.black87, width: 2),
          ),
          child: ClipRRect(
            borderRadius: AppRadius.bXS,
            child: CachedNetworkImage(
              imageUrl: photos[index],
              fit: BoxFit.cover,
              memCacheWidth: _kThumbDecodeWidth,
              placeholder: (_, __) => const _ImageShimmer(),
              errorWidget: (_, __, ___) => const _ImageErrorPlaceholder(),
            ),
          ),
        );
      },
    );
  }
}

// -------------------------------------------------------
// 【性能优化】互动行 — 独立 Consumer 隔离 rebuild 范围
// 点赞状态变化只重建此组件，不影响卡片其余部分
// -------------------------------------------------------

class _PostActionRow extends ConsumerWidget {
  final PostModel post;
  final VoidCallback? onCommentTap;

  const _PostActionRow({
    required this.post,
    this.onCommentTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 优先使用 PostModel 内嵌的 isLiked 字段
    // 该字段由服务端查询时一次返回，避免每张卡片独立发起 N 次网络请求
    // 仅当 post.isLiked == null（旧数据兼容）时回退到独立 Provider
    final bool isLiked;
    if (post.isLiked != null) {
      isLiked = post.isLiked!;
    } else {
      final likeStatus = ref.watch(postLikeStatusProvider(post.id));
      isLiked = likeStatus.valueOrNull ?? false;
    }

    return Row(
      children: [
        // 点赞按钮 — 黑色药丸（主题色）
        _GraffitiPillButton(
          icon: isLiked ? Icons.favorite : Icons.favorite_border,
          label: post.likesCount > 0 ? '${post.likesCount}' : '',
          backgroundColor: AppColors.primary,
          onTap: () {
            ref.read(postActionProvider).toggleLike(post.id);
          },
        ),
        AppSpacing.hGap12,

        // 评论按钮 — 深灰药丸
        _GraffitiPillButton(
          icon: Icons.chat_bubble_outline,
          label: post.commentsCount > 0 ? '${post.commentsCount}' : '',
          backgroundColor: AppColors.accent,
          onTap: onCommentTap,
        ),
      ],
    );
  }
}

// -------------------------------------------------------
// 图片加载 Shimmer 占位
// -------------------------------------------------------

class _ImageShimmer extends StatelessWidget {
  final double? height;

  const _ImageShimmer({this.height});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      highlightColor:
          isDark ? AppColors.darkCardHover : AppColors.lightCardHover,
      child: Container(
        height: height,
        color: Colors.white,
      ),
    );
  }
}

// -------------------------------------------------------
// 图片加载失败占位
// -------------------------------------------------------

class _ImageErrorPlaceholder extends StatelessWidget {
  const _ImageErrorPlaceholder();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 32,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
      ),
    );
  }
}

// -------------------------------------------------------
// 荧光高亮 — Volt 荧光笔效果（互动数字）
// -------------------------------------------------------

class _GlowHighlight extends StatelessWidget {
  final Widget child;

  const _GlowHighlight({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x3,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: AppColors.voltSurface,
        borderRadius: AppRadius.bXS,
      ),
      child: child,
    );
  }
}

// -------------------------------------------------------
// 涂鸦药丸按钮 — 互动行专用
// -------------------------------------------------------

class _GraffitiPillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const _GraffitiPillButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x12,
          vertical: AppSpacing.x6,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppRadius.bPill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            if (label.isNotEmpty) ...[
              AppSpacing.hGapXS,
              _GlowHighlight(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
