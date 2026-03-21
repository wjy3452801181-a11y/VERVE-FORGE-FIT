import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../core/network/supabase_client.dart';
import '../../../core/constants/supabase_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/image_utils.dart';
import '../domain/profile_model.dart';

/// 用户档案数据仓库
class ProfileRepository {
  final _log = Logger();

  /// 获取当前用户档案
  Future<ProfileModel?> getCurrentProfile() async {
    final userId = SupabaseClientHelper.currentUserId;
    if (userId == null) return null;
    return getProfile(userId);
  }

  /// 根据 ID 获取用户档案
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

  /// 创建用户档案（注册引导流完成后调用）
  Future<ProfileModel> createProfile({
    required String nickname,
    required String city,
    required List<String> sportTypes,
    String? avatarUrl,
    String? gender,
    int? birthYear,
    String? experienceLevel,
  }) async {
    final userId = SupabaseClientHelper.currentUserId;
    if (userId == null) {
      throw const AppAuthException(message: '未登录，无法创建档案');
    }

    try {
      final profileData = {
        'id': userId,
        'nickname': nickname,
        'city': city,
        'sport_types': sportTypes,
        'avatar_url': avatarUrl,
        'gender': gender,
        'birth_year': birthYear,
        'experience_level': experienceLevel,
        'privacy_agreed_at': DateTime.now().toIso8601String(),
      };

      final data = await SupabaseClientHelper.from(SupabaseConstants.profiles)
          .upsert(profileData)
          .select()
          .single();

      _log.i('档案创建成功: $userId');
      return ProfileModel.fromJson(data);
    } catch (e, stack) {
      _log.e('创建档案失败: $e', error: e, stackTrace: stack);
      throw AppException(message: '创建档案失败: $e');
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

  /// 上传头像并更新档案
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

      // 更新档案中的头像 URL
      await SupabaseClientHelper.from(SupabaseConstants.profiles)
          .update({'avatar_url': url}).eq('id', userId);

      _log.i('头像上传成功: $url');
      return url;
    } catch (e) {
      _log.e('头像上传失败', error: e);
      throw const StorageException(message: '头像上传失败，请重试');
    }
  }

  /// 记录隐私政策同意时间（PIPL 合规）
  Future<void> recordPrivacyConsent() async {
    final userId = SupabaseClientHelper.currentUserId;
    if (userId == null) return;

    await SupabaseClientHelper.from(SupabaseConstants.profiles).update({
      'privacy_agreed_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  /// 请求数据导出（PIPL 合规）
  Future<Map<String, dynamic>> exportUserData() async {
    final userId = SupabaseClientHelper.currentUserId;
    if (userId == null) {
      throw const AppAuthException(message: '未登录');
    }

    // 标记导出请求时间
    await SupabaseClientHelper.from(SupabaseConstants.profiles).update({
      'data_export_requested_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);

    // 收集所有用户数据
    final profile = await SupabaseClientHelper.from(SupabaseConstants.profiles)
        .select()
        .eq('id', userId)
        .single();

    final workouts =
        await SupabaseClientHelper.from(SupabaseConstants.workoutLogs)
            .select()
            .eq('user_id', userId);

    final posts = await SupabaseClientHelper.from(SupabaseConstants.posts)
        .select()
        .eq('user_id', userId);

    return {
      'exported_at': DateTime.now().toIso8601String(),
      'profile': profile,
      'workout_logs': workouts,
      'posts': posts,
    };
  }

  /// 按城市和运动类型发现附近用户
  Future<List<ProfileModel>> discoverNearbyUsers({
    required String city,
    String? sportType,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = SupabaseClientHelper.from(SupabaseConstants.profiles)
          .select()
          .eq('city', city)
          .eq('is_discoverable', true)
          .isFilter('deleted_at', null)
          .neq('id', SupabaseClientHelper.currentUserId ?? '');

      if (sportType != null) {
        query = query.contains('sport_types', [sportType]);
      }

      final data = await query
          .order('updated_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (data as List).map((e) => ProfileModel.fromJson(e)).toList();
    } catch (e) {
      _log.e('发现用户失败', error: e);
      return [];
    }
  }
}

/// Profile Repository Provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});
