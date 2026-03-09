import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/avatar_widget.dart';
import '../../domain/post_model.dart';
import '../../providers/post_provider.dart';

/// 动态卡片组件
class PostCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: context.theme.dividerColor.withValues(alpha: 0.1),
            ),
          ),
        ),
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

            // 互动行（点赞、评论）
            _buildActionRow(context, ref),
          ],
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
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.authorNickname ?? context.l10n.commonEmpty,
                style: AppTextStyles.subtitle,
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
        if (post.city != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              post.city!,
              style: AppTextStyles.label.copyWith(
                color: AppColors.secondary,
              ),
            ),
          ),
      ],
    );
  }

  /// 照片网格（1 张全宽，2-3 张一行，4+ 九宫格）
  Widget _buildPhotoGrid(BuildContext context) {
    final photos = post.photos;
    final count = photos.length;

    if (count == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240),
          child: CachedNetworkImage(
            imageUrl: photos[0],
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // 多张照片 — 网格
    final crossAxisCount = count <= 3 ? count : 3;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: count > 9 ? 9 : count,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: CachedNetworkImage(
            imageUrl: photos[index],
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  /// 互动行：点赞 + 评论
  Widget _buildActionRow(BuildContext context, WidgetRef ref) {
    final likeStatus = ref.watch(postLikeStatusProvider(post.id));
    final isLiked = likeStatus.valueOrNull ?? false;

    return Row(
      children: [
        // 点赞按钮
        _ActionButton(
          icon: isLiked ? Icons.favorite : Icons.favorite_border,
          label: post.likeCount > 0 ? '${post.likeCount}' : '',
          color: isLiked ? Colors.red : null,
          onTap: () {
            ref.read(postActionProvider).toggleLike(post.id);
          },
        ),
        const SizedBox(width: 24),

        // 评论按钮
        _ActionButton(
          icon: Icons.chat_bubble_outline,
          label: post.commentCount > 0 ? '${post.commentCount}' : '',
          onTap: onTap,
        ),
      ],
    );
  }
}

/// 互动按钮
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final defaultColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? defaultColor),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color ?? defaultColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
