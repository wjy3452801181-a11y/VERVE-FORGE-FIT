import '../profile_model.dart';
import '../repositories/profile_repository.dart';

/// 获取当前用户档案
class GetProfile {
  final ProfileRepositoryInterface _repository;

  GetProfile(this._repository);

  /// 获取当前登录用户的档案
  Future<ProfileModel?> call() => _repository.getCurrentProfile();

  /// 根据 userId 获取指定用户档案
  Future<ProfileModel?> byId(String userId) => _repository.getProfile(userId);
}
