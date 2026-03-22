import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/avatar_widget.dart';

/// 个人主页头部组件 — 头像 + 昵称 + 邮箱
class ProfileHeaderWidget extends StatelessWidget {
  final String? avatarUrl;
  final String nickname;
  final String? email;
  final String? bio;
  final File? localAvatarFile;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onEditTap;

  const ProfileHeaderWidget({
    super.key,
    this.avatarUrl,
    required this.nickname,
    this.email,
    this.bio,
    this.localAvatarFile,
    this.onAvatarTap,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: AppSpacing.cardPadding,
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
      child: Row(
        children: [
          // 头像（支持本地文件预览）
          GestureDetector(
            onTap: onAvatarTap,
            child: Stack(
              children: [
                localAvatarFile != null
                    ? CircleAvatar(
                        radius: 36,
                        backgroundImage: FileImage(localAvatarFile!),
                      )
                    : AvatarWidget(
                        size: 72,
                        imageUrl: avatarUrl,
                        fallbackText: nickname,
                      ),
                if (onAvatarTap != null)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 14, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          AppSpacing.hGapMD,

          // 昵称 + 邮箱 + 简介
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nickname,
                  style: AppTextStyles.subtitle,
                ),
                if (email != null && email!.isNotEmpty) ...[
                  AppSpacing.vGapXS,
                  Text(
                    email!,
                    style: AppTextStyles.caption.copyWith(
                      color: context.colorScheme.onSurface
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ],
                AppSpacing.vGapXS,
                if (bio != null && bio!.isNotEmpty)
                  Text(
                    bio!,
                    style: AppTextStyles.caption.copyWith(
                      color: context.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  Text(
                    context.l10n.profileNoBio,
                    style: AppTextStyles.caption.copyWith(
                      color: context.colorScheme.onSurface
                          .withValues(alpha: 0.4),
                    ),
                  ),
              ],
            ),
          ),

          // 编辑按钮
          if (onEditTap != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: onEditTap,
            ),
        ],
      ),
    );
  }
}
