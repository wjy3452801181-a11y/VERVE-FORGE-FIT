import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/avatar_widget.dart';

/// 头像选择与裁剪组件 — 支持从相册选图或拍照 → 裁剪 → 返回文件
class AvatarPickerWidget extends StatelessWidget {
  final String? currentAvatarUrl;
  final File? localFile;
  final String? fallbackText;
  final double size;
  final ValueChanged<File> onPicked;

  const AvatarPickerWidget({
    super.key,
    this.currentAvatarUrl,
    this.localFile,
    this.fallbackText,
    this.size = 96,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPickerSheet(context),
      child: Stack(
        children: [
          localFile != null
              ? CircleAvatar(
                  radius: size / 2,
                  backgroundImage: FileImage(localFile!),
                )
              : AvatarWidget(
                  size: size,
                  imageUrl: currentAvatarUrl,
                  fallbackText: fallbackText,
                ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.camera_alt, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// 弹出选择方式：相册 / 拍照
  void _showPickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(context.l10n.avatarPickerGallery),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(context, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(context.l10n.avatarPickerCamera),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(context, ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// 选图 → 裁剪 → 回调
  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final cropTitle = context.l10n.avatarPickerCropTitle;
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (xFile == null) return;
    // ignore: use_build_context_synchronously
    if (!context.mounted) return;

    // 裁剪
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: xFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: cropTitle,
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
          aspectRatioPresets: [CropAspectRatioPreset.square],
        ),
        IOSUiSettings(
          title: cropTitle,
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          aspectRatioPresets: [CropAspectRatioPreset.square],
        ),
        WebUiSettings(
          context: context,
          presentStyle: WebPresentStyle.dialog,
          size: const CropperSize(width: 520, height: 520),
        ),
      ],
    );

    if (croppedFile != null) {
      onPicked(File(croppedFile.path));
    }
  }
}
