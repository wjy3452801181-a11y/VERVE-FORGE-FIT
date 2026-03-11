import 'dart:io';

import 'package:logger/logger.dart';

import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/utils/image_utils.dart';
import '../../domain/profile_model.dart';

/// Profile 远程数据源 — 负责 Supabase Storage 上传 + profiles 表读写
class ProfileRemoteDataSource {
  final _log = Logger();

  /// 获取当前用户档案
  Future<ProfileModel?> getCurrentProfile() async {
    final userId = SupabaseClientHelper.currentUserId;
    if (userId == null) return null;
    return getProfile(userId);
  }

  /// 根据 ID 获取档案
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final data = await SupabaseClientHelper.from(SupabaseConstants.profiles)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) return null;
      return ProfileModel.fromJson(data);
    } catch (e) {
      _log.e('获取档案失败', error: e);
      return null;
    }
  }

  /// 更新用户档案
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    try {
      final data = await SupabaseClientHelper.from(SupabaseConstants.profiles)
          .update(profile.toJson())
          .eq('id', profile.id)
          .select()
          .single();

      _log.i('档案更新成功: ${profile.id}');
      return ProfileModel.fromJson(data);
    } catch (e) {
      _log.e('更新档案失败', error: e);
      throw const AppException(message: '更新档案失败，请重试');
    }
  }

  /// 上传头像到 Supabase Storage 并更新 profiles 表的 avatar_url
  Future<String> uploadAvatar(File imageFile) async {
    final userId = SupabaseClientHelper.currentUserId;
    if (userId == null) {
      throw const AppAuthException(message: '未登录');
    }

    try {
      final url = await ImageUtils.uploadImage(
        file: imageFile,
        bucket: SupabaseConstants.avatarsBucket,
        folder: userId,
      );

      // 同步更新 profiles 表中的 avatar_url
      await SupabaseClientHelper.from(SupabaseConstants.profiles)
          .update({'avatar_url': url}).eq('id', userId);

      _log.i('头像上传成功: $url');
      return url;
    } catch (e) {
      _log.e('头像上传失败', error: e);
      throw const StorageException(message: '头像上传失败，请重试');
    }
  }
}
