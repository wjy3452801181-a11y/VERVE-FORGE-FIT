import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/network/supabase_client.dart';
import '../../../core/utils/image_utils.dart';
import '../domain/gym_review_model.dart';

const _uuid = Uuid();

/// 训练馆评价 Repository
class GymReviewRepository {
  /// 获取评价列表（按 gym_id 分页）
  Future<List<GymReviewModel>> list({
    required String gymId,
    int page = 0,
    int pageSize = 20,
  }) async {
    final data = await SupabaseClientHelper.from(SupabaseConstants.gymReviews)
        .select()
        .eq('gym_id', gymId)
        .order('created_at', ascending: false)
        .range(page * pageSize, (page + 1) * pageSize - 1);

    return (data as List).map((e) => GymReviewModel.fromJson(e)).toList();
  }

  /// 创建评价
  Future<GymReviewModel> create({
    required String gymId,
    required int rating,
    String? content,
    List<String> photoUrls = const [],
  }) async {
    final userId = SupabaseClientHelper.currentUserId!;
    final id = _uuid.v4();
    final now = DateTime.now();

    final data = {
      'id': id,
      'gym_id': gymId,
      'user_id': userId,
      'rating': rating,
      'content': content,
      'photo_urls': photoUrls,
    };

    await SupabaseClientHelper.from(SupabaseConstants.gymReviews).insert(data);

    return GymReviewModel(
      id: id,
      gymId: gymId,
      userId: userId,
      rating: rating,
      content: content,
      photoUrls: photoUrls,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 删除评价（仅作者可删）
  Future<void> delete(String id) async {
    await SupabaseClientHelper.from(SupabaseConstants.gymReviews)
        .delete()
        .eq('id', id)
        .eq('user_id', SupabaseClientHelper.currentUserId!);
  }

  /// 上传评价照片
  Future<List<String>> uploadPhotos(List<File> files) async {
    return ImageUtils.uploadImages(
      files: files,
      bucket: SupabaseConstants.gymPhotosBucket,
      folder: '${SupabaseClientHelper.currentUserId}/reviews',
    );
  }
}

/// Provider
final gymReviewRepositoryProvider = Provider<GymReviewRepository>((ref) {
  return GymReviewRepository();
});
