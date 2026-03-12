import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// 动态卡片组件 — 街头涂鸦风格
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
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black87, width: 2.5),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 左侧彩色条
              Container(
                width: 4,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5.5),
                    bottomLeft: Radius.circular(5.5),
                  ),
                ),
              ),
              // 主体内容
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              ),
            ],
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
        // 城市标签 — 涂鸦贴纸风格
        if (post.city != null)
          Transform.rotate(
            angle: -2 * math.pi / 180, // -2°
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(4),
              ),
              child: _GlowHighlight(
                child: Text(
                  post.city!,
                  style: AppTextStyles.label.copyWith(
                    color: _kGraffitiNeon,
                    fontWeight: FontWeight.w800,
                  ),
                ),
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
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.black87, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240),
            child: CachedNetworkImage(
              imageUrl: photos[0],
              width: double.infinity,
              fit: BoxFit.cover,
            ),
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
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.black87, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: CachedNetworkImage(
              imageUrl: photos[index],
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  /// 互动行：点赞 + 评论 — 药丸贴纸风格
  Widget _buildActionRow(BuildContext context, WidgetRef ref) {
    final likeStatus = ref.watch(postLikeStatusProvider(post.id));
    final isLiked = likeStatus.valueOrNull ?? false;

    return Row(
      children: [
        // 点赞按钮 — 橙色药丸
        _GraffitiPillButton(
          icon: isLiked ? Icons.favorite : Icons.favorite_border,
          label: post.likeCount > 0 ? '${post.likeCount}' : '',
          backgroundColor: isLiked ? AppColors.primary : AppColors.primary,
          onTap: () {
            ref.read(postActionProvider).toggleLike(post.id);
          },
        ),
        const SizedBox(width: 12),

        // 评论按钮 — 深灰药丸
        _GraffitiPillButton(
          icon: Icons.chat_bubble_outline,
          label: post.commentCount > 0 ? '${post.commentCount}' : '',
          backgroundColor: Colors.grey.shade800,
          onTap: onTap,
        ),
      ],
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
