import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/errors/error_handler.dart';
import '../../workout/presentation/widgets/photo_grid.dart';
import '../data/gym_review_repository.dart';
import '../providers/gym_provider.dart';
import '../providers/gym_review_provider.dart';
import 'widgets/rating_bar.dart';

/// 写评价页面
class GymReviewPage extends ConsumerStatefulWidget {
  final String gymId;

  const GymReviewPage({super.key, required this.gymId});

  @override
  ConsumerState<GymReviewPage> createState() => _GymReviewPageState();
}

class _GymReviewPageState extends ConsumerState<GymReviewPage> {
  final _contentController = TextEditingController();
  int _rating = 5;
  final List<File> _pendingPhotos = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.gymWriteReview),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _submit,
            child: Text(context.l10n.commonSave),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 评分
          Text(
            context.l10n.gymRating,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          Center(
            child: RatingBar(
              rating: _rating,
              size: 40,
              interactive: true,
              onRatingChanged: (value) {
                setState(() => _rating = value);
              },
            ),
          ),
          const SizedBox(height: 24),

          // 评价内容
          TextFormField(
            controller: _contentController,
            maxLines: 5,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText: '分享你的训练体验...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),

          // 照片
          Text(
            context.l10n.workoutPhotos,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          PhotoGrid(
            pendingFiles: _pendingPhotos,
            onAdd: _pickPhotos,
            onRemoveFile: (index) {
              setState(() => _pendingPhotos.removeAt(index));
            },
          ),
          const SizedBox(height: 32),

          // 提交按钮
          FilledButton(
            onPressed: _isSaving ? null : _submit,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(context.l10n.commonSave),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPhotos() async {
    final remaining = AppConstants.maxPhotos - _pendingPhotos.length;
    if (remaining <= 0) return;
    final files = await pickPhotos(maxCount: remaining);
    if (files.isNotEmpty) {
      setState(() => _pendingPhotos.addAll(files));
    }
  }

  Future<void> _submit() async {
    setState(() => _isSaving = true);

    try {
      final repo = ref.read(gymReviewRepositoryProvider);

      // 上传照片
      List<String> photoUrls = [];
      if (_pendingPhotos.isNotEmpty) {
        photoUrls = await repo.uploadPhotos(_pendingPhotos);
      }

      await repo.create(
        gymId: widget.gymId,
        rating: _rating,
        content: _contentController.text.trim().isEmpty
            ? null
            : _contentController.text.trim(),
        photoUrls: photoUrls,
      );

      // 刷新评价列表和训练馆详情
      ref.invalidate(gymReviewsProvider(widget.gymId));
      ref.invalidate(gymDetailProvider(widget.gymId));

      if (mounted) {
        ErrorHandler.showSuccess(context, context.l10n.commonSuccess);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ErrorHandler.showError(context, e);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
