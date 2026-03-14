import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/avatar_widget.dart';
import '../../domain/post_model.dart';
import '../../providers/post_provider.dart';

// -------------------------------------------------------
// 涂鸦风格局部常量（仅 post_card 内使用）
// -------------------------------------------------------
const _kGraffitiNeon = Color(0xFFCDFF00); // 荧光黄绿

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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 作者信息行
                  _buildAuthorRow(context),
                  const SizedBox(height: 8),

                  // 正文内容
                  if (post.content.isNotEmpty)
                    Text(post.content, style: AppTextStyles.body),

                  // 照片网格
                  if (post.hasPhotos) ...[
                    const SizedBox(height: 8),
                    _buildPhotoGrid(context),
                  ],

                  const SizedBox(height: 10),

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
        // 头像 — 橙色描边
        AvatarWidget(
          imageUrl: post.authorAvatar,
          size: 40,
          fallbackText: post.authorNickname,
          onTap: onAuthorTap,
          showBorder: true,
        ),
        const SizedBox(width: 10),
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
              const SizedBox(height: 2),
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
        // 城市标签已移除（数据库无 city 列）
      ],
    );
  }

  /// 照片网格（1 张全宽，2-3 张一行，4+ 九宫格）
  Widget _buildPhotoGrid(BuildContext context) {
    final photos = post.imageUrls;
    final count = photos.length;

    if (count == 1) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.black87, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240),
            // 【性能优化】添加 Shimmer placeholder + memCacheWidth 限制解码尺寸
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
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: displayCount,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.black87, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            // 【性能优化】memCacheWidth 限制网格图解码宽度，大幅减少 GPU 纹理内存
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
    // 【性能优化】优先使用 PostModel 内嵌的 isLiked 字段
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
        // 点赞按钮 — 橙色药丸
        _GraffitiPillButton(
          icon: isLiked ? Icons.favorite : Icons.favorite_border,
          label: post.likesCount > 0 ? '${post.likesCount}' : '',
          backgroundColor: AppColors.primary,
          onTap: () {
            ref.read(postActionProvider).toggleLike(post.id);
          },
        ),
        const SizedBox(width: 12),

        // 评论按钮 — 深灰药丸
        _GraffitiPillButton(
          icon: Icons.chat_bubble_outline,
          label: post.commentsCount > 0 ? '${post.commentsCount}' : '',
          backgroundColor: Colors.grey.shade800,
          onTap: onCommentTap,
        ),
      ],
    );
  }
}

// -------------------------------------------------------
// 【性能优化】图片加载 Shimmer 占位 — 替代空白等待
// -------------------------------------------------------

class _ImageShimmer extends StatelessWidget {
  final double? height;

  const _ImageShimmer({this.height});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
      highlightColor:
          isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5),
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
    return Container(
      color: context.theme.colorScheme.surfaceContainerHighest,
      child: const Center(
        child: Icon(Icons.broken_image_outlined, size: 32, color: Colors.grey),
      ),
    );
  }
}

// -------------------------------------------------------
// 荧光高亮 Widget — 模拟荧光笔效果
// -------------------------------------------------------

class _GlowHighlight extends StatelessWidget {
  final Widget child;

  const _GlowHighlight({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      decoration: BoxDecoration(
        color: _kGraffitiNeon.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(2),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
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
