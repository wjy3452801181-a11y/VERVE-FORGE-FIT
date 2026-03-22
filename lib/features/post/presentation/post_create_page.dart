import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../workout/presentation/widgets/photo_grid.dart';
import '../data/post_repository.dart';
import '../providers/post_provider.dart';

/// 发布动态页
class PostCreatePage extends ConsumerStatefulWidget {
  const PostCreatePage({super.key});

  @override
  ConsumerState<PostCreatePage> createState() => _PostCreatePageState();
}

class _PostCreatePageState extends ConsumerState<PostCreatePage> {
  final _contentController = TextEditingController();
  final List<File> _pendingPhotos = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      !_isSubmitting &&
      (_contentController.text.trim().isNotEmpty || _pendingPhotos.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.postCreate),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilledButton(
              onPressed: _canSubmit ? _submit : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor:
                    AppColors.primary.withValues(alpha: 0.3),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(context.l10n.postPublish),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 内容输入
            TextField(
              controller: _contentController,
              maxLines: 8,
              minLines: 4,
              maxLength: 500,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: context.l10n.postContentHint,
                hintStyle: AppTextStyles.body.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                border: InputBorder.none,
              ),
              style: AppTextStyles.body,
            ),

            AppSpacing.vGapMD,

            // 照片网格
            PhotoGrid(
              pendingFiles: _pendingPhotos,
              onAdd: _pickPhotos,
              onRemoveFile: (index) {
                setState(() => _pendingPhotos.removeAt(index));
              },
            ),

            AppSpacing.vGapLG,
          ],
        ),
      ),
    );
  }

  /// 选择照片
  Future<void> _pickPhotos() async {
    final remaining = AppConstants.maxPhotos - _pendingPhotos.length;
    if (remaining <= 0) return;
    final files = await pickPhotos(maxCount: remaining);
    if (files.isNotEmpty) {
      setState(() => _pendingPhotos.addAll(files));
    }
  }

  /// 提交发布
  Future<void> _submit() async {
    if (!_canSubmit) return;

    setState(() => _isSubmitting = true);

    try {
      final action = ref.read(postActionProvider);
      List<String> photoUrls = [];

      // 上传照片
      if (_pendingPhotos.isNotEmpty) {
        final repo = ref.read(postRepositoryProvider);
        photoUrls = await repo.uploadPhotos(_pendingPhotos);
      }

      // 发布动态
      await action.publish(
        content: _contentController.text.trim(),
        imageUrls: photoUrls,
      );

      if (mounted) {
        ErrorHandler.showSuccess(context, context.l10n.postPublishSuccess);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ErrorHandler.showError(context, e);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
