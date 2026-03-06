import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

/// 照片网格组件（最多 9 张）
class PhotoGrid extends StatelessWidget {
  final List<String> photoUrls;
  final List<File> pendingFiles;
  final VoidCallback? onAdd;
  final ValueChanged<int>? onRemoveUrl;
  final ValueChanged<int>? onRemoveFile;
  final bool readOnly;

  const PhotoGrid({
    super.key,
    this.photoUrls = const [],
    this.pendingFiles = const [],
    this.onAdd,
    this.onRemoveUrl,
    this.onRemoveFile,
    this.readOnly = false,
  });

  int get _totalCount => photoUrls.length + pendingFiles.length;
  bool get _canAdd => !readOnly && _totalCount < AppConstants.maxPhotos;

  @override
  Widget build(BuildContext context) {
    final itemCount = _totalCount + (_canAdd ? 1 : 0);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // 已上传的照片
        if (index < photoUrls.length) {
          return _buildPhotoItem(
            context,
            child: Image.network(photoUrls[index], fit: BoxFit.cover),
            onRemove: readOnly ? null : () => onRemoveUrl?.call(index),
          );
        }

        // 待上传的文件
        final fileIndex = index - photoUrls.length;
        if (fileIndex < pendingFiles.length) {
          return _buildPhotoItem(
            context,
            child: Image.file(pendingFiles[fileIndex], fit: BoxFit.cover),
            onRemove: readOnly ? null : () => onRemoveFile?.call(fileIndex),
          );
        }

        // 添加按钮
        return _buildAddButton(context);
      },
    );
  }

  Widget _buildPhotoItem(
    BuildContext context, {
    required Widget child,
    VoidCallback? onRemove,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          if (onRemove != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 28,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 4),
            Text(
              '$_totalCount/${AppConstants.maxPhotos}',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 照片选择工具方法
Future<List<File>> pickPhotos({int maxCount = 9}) async {
  final picker = ImagePicker();
  final images = await picker.pickMultiImage(
    maxWidth: 1920,
    maxHeight: 1920,
    imageQuality: 80,
  );
  final files = images.take(maxCount).map((x) => File(x.path)).toList();
  return files;
}
