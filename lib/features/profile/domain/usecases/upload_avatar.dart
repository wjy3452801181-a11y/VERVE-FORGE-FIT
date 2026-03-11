import 'dart:io';

import '../repositories/profile_repository.dart';

/// 上传头像
class UploadAvatar {
  final ProfileRepositoryInterface _repository;

  UploadAvatar(this._repository);

  /// 上传头像文件，返回公开 URL
  Future<String> call(File imageFile) => _repository.uploadAvatar(imageFile);
}
