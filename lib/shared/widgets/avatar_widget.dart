import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../app/theme/app_colors.dart';

/// 通用头像组件
class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final String? fallbackText; // 无头像时显示的文字（取首字符）
  final VoidCallback? onTap;
  final bool showBorder;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    this.size = 48,
    this.fallbackText,
    this.onTap,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: showBorder
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: ClipOval(
          child: imageUrl != null && imageUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: imageUrl!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _buildPlaceholder(),
                  errorWidget: (_, __, ___) => _buildPlaceholder(),
                )
              : _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      color: AppColors.primary.withValues(alpha: 0.2),
      child: Center(
        child: fallbackText != null && fallbackText!.isNotEmpty
            ? Text(
                fallbackText![0].toUpperCase(),
                style: TextStyle(
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              )
            : Icon(
                Icons.person,
                size: size * 0.5,
                color: AppColors.primary,
              ),
      ),
    );
  }
}
