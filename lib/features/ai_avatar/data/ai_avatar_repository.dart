import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../core/network/supabase_client.dart';
import '../../../core/constants/supabase_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/image_utils.dart';
import '../domain/ai_avatar_model.dart';

/// AI 分身数据仓库
class AiAvatarRepository {
  final _log = Logger();

  /// 获取当前用户的 AI 分身
  Future<AiAvatarModel?> getMyAvatar() async {
    final userId = SupabaseClientHelper.currentUserId;
    if (userId == null) return null;

    try {
      final data =
          await SupabaseClientHelper.from(SupabaseConstants.aiAvatars)
              .select()
              .eq('user_id', userId)
              .maybeSingle();

      if (data == null) return null;
      return AiAvatarModel.fromJson(data);
    } catch (e) {
      _log.e('获取 AI 分身失败', error: e);
      return null;
    }
  }

  /// 创建 AI 分身
  Future<AiAvatarModel> createAvatar({
    required String name,
    String? avatarUrl,
    required List<String> personalityTraits,
    required String speakingStyle,
    String customPrompt = '',
  }) async {
    final userId = SupabaseClientHelper.currentUserId;
    if (userId == null) {
      throw const AppAuthException(message: '未登录，无法创建 AI 分身');
    }

    try {
      final avatarData = {
        'user_id': userId,
        'name': name,
        'avatar_url': avatarUrl,
        'personality_traits': personalityTraits,
        'speaking_style': speakingStyle,
        'custom_prompt': customPrompt,
        'ai_consent_at': DateTime.now().toIso8601String(),
      };

      final data =
          await SupabaseClientHelper.from(SupabaseConstants.aiAvatars)
              .insert(avatarData)
              .select()
              .single();

      _log.i('AI 分身创建成功: $userId');
      return AiAvatarModel.fromJson(data);
    } catch (e) {
      _log.e('创建 AI 分身失败', error: e);
      throw const AppException(message: '创建 AI 分身失败，请重试');
    }
  }

  /// 更新 AI 分身
  Future<AiAvatarModel> updateAvatar(AiAvatarModel avatar) async {
    try {
      final data =
          await SupabaseClientHelper.from(SupabaseConstants.aiAvatars)
              .update(avatar.toJson())
              .eq('id', avatar.id)
              .select()
              .single();

      _log.i('AI 分身更新成功: ${avatar.id}');
      return AiAvatarModel.fromJson(data);
    } catch (e) {
      _log.e('更新 AI 分身失败', error: e);
      throw const AppException(message: '更新 AI 分身失败，请重试');
    }
  }

  /// 切换自动回复开关
  Future<AiAvatarModel> toggleAutoReply(String avatarId, bool enabled) async {
    try {
      final data =
          await SupabaseClientHelper.from(SupabaseConstants.aiAvatars)
              .update({'auto_reply_enabled': enabled})
              .eq('id', avatarId)
              .select()
              .single();

      _log.i('自动回复${enabled ? '开启' : '关闭'}: $avatarId');
      return AiAvatarModel.fromJson(data);
    } catch (e) {
      _log.e('切换自动回复失败', error: e);
      throw const AppException(message: '操作失败，请重试');
    }
  }

  /// 删除 AI 分身
  Future<void> deleteAvatar(String avatarId) async {
    try {
      await SupabaseClientHelper.from(SupabaseConstants.aiAvatars)
          .delete()
          .eq('id', avatarId);

      _log.i('AI 分身已删除: $avatarId');
    } catch (e) {
      _log.e('删除 AI 分身失败', error: e);
      throw const AppException(message: '删除失败，请重试');
    }
  }

  /// 上传分身头像
  Future<String> uploadAvatarImage(File imageFile) async {
    final userId = SupabaseClientHelper.currentUserId;
    if (userId == null) {
      throw const AppAuthException(message: '未登录');
    }

    try {
      final url = await ImageUtils.uploadImage(
        file: imageFile,
        bucket: SupabaseConstants.avatarsBucket,
        folder: 'ai-avatar/$userId',
      );

      _log.i('分身头像上传成功: $url');
      return url;
    } catch (e) {
      _log.e('分身头像上传失败', error: e);
      throw const StorageException(message: '头像上传失败，请重试');
    }
  }

  /// 与分身聊天（调用 Edge Function）
  Future<String> chatWithAvatar({
    required String avatarId,
    required String message,
    List<Map<String, String>> history = const [],
  }) async {
    try {
      final response = await SupabaseClientHelper.client.functions.invoke(
        'ai-avatar-chat',
        body: {
          'avatar_id': avatarId,
          'message': message,
          'history': history,
        },
      );

      if (response.status != 200) {
        throw AppException(message: '聊天请求失败: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;
      return data['reply'] as String? ?? '抱歉，我暂时无法回复。';
    } catch (e) {
      _log.e('与分身聊天失败', error: e);
      throw const AppException(message: '聊天失败，请重试');
    }
  }

  /// 更新 last_seen_at（心跳）
  Future<void> updateLastSeen() async {
    final userId = SupabaseClientHelper.currentUserId;
    if (userId == null) return;

    try {
      await SupabaseClientHelper.from(SupabaseConstants.profiles).update({
        'last_seen_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      _log.w('更新 last_seen_at 失败', error: e);
    }
  }

  /// 刷新分身画像（调用 Edge Function 进行 AI 分析更新）
  /// 返回更新后的分身数据
  Future<AiAvatarModel> refreshAvatarProfile(String avatarId) async {
    try {
      final response = await SupabaseClientHelper.client.functions.invoke(
        'ai-avatar-profile-update',
        body: {'avatar_id': avatarId},
      );

      if (response.status != 200) {
        throw AppException(message: '画像更新失败: ${response.status}');
      }

      _log.i('分身画像更新请求成功: $avatarId');

      // 重新从数据库获取最新数据（Edge Function 已更新字段）
      final data =
          await SupabaseClientHelper.from(SupabaseConstants.aiAvatars)
              .select()
              .eq('id', avatarId)
              .single();

      return AiAvatarModel.fromJson(data);
    } catch (e) {
      _log.e('刷新分身画像失败', error: e);
      throw const AppException(message: '画像更新失败，请稍后重试');
    }
  }

  /// 分享分身（调用 Edge Function），返回分享链接
  Future<String?> shareAvatar({
    required String avatarId,
    required String targetType,
    String? targetId,
  }) async {
    try {
      final response = await SupabaseClientHelper.client.functions.invoke(
        'ai-avatar-share',
        body: {
          'avatar_id': avatarId,
          'target_type': targetType,
          if (targetId != null) 'target_id': targetId,
        },
      );

      if (response.status == 429) {
        throw const AppException(message: '429');
      }

      if (response.status != 200) {
        throw AppException(message: '分享失败: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;
      _log.i('分身分享成功: $avatarId → $targetType');
      return data['share_link'] as String?;
    } catch (e) {
      _log.e('分身分享失败', error: e);
      rethrow;
    }
  }

  /// 通过 share_token 获取分身公开信息
  Future<Map<String, dynamic>?> getSharedAvatar(String shareToken) async {
    try {
      final data = await SupabaseClientHelper.from(
              SupabaseConstants.aiAvatarPublicView)
          .select()
          .eq('share_token', shareToken)
          .maybeSingle();

      return data;
    } catch (e) {
      _log.e('获取分享分身失败', error: e);
      return null;
    }
  }
}

/// AI Avatar Repository Provider
final aiAvatarRepositoryProvider = Provider<AiAvatarRepository>((ref) {
  return AiAvatarRepository();
});
