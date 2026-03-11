import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                        padding: const EdgeInsets.all(4),
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
            const SizedBox(width: 16),

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
                    const SizedBox(height: 2),
                    Text(
                      email!,
                      style: AppTextStyles.caption.copyWith(
                        color: context.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
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
      ),
    );
  }
}
