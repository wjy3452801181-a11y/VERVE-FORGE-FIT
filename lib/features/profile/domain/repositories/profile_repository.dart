import 'dart:io';

import '../profile_model.dart';

/// 个人档案仓库接口（Domain 层）
abstract class ProfileRepositoryInterface {
  /// 获取当前用户档案
  Future<ProfileModel?> getCurrentProfile();

  /// 根据 ID 获取用户档案
  Future<ProfileModel?> getProfile(String userId);

  /// 更新用户档案
  Future<ProfileModel> updateProfile(ProfileModel profile);

  /// 上传头像并返回公开 URL
  Future<String> uploadAvatar(File imageFile);
}
