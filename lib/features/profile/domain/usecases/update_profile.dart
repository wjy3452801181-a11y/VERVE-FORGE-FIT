import '../profile_model.dart';
import '../repositories/profile_repository.dart';

/// 更新用户档案
class UpdateProfile {
  final ProfileRepositoryInterface _repository;

  UpdateProfile(this._repository);

  Future<ProfileModel> call(ProfileModel profile) =>
      _repository.updateProfile(profile);
}
