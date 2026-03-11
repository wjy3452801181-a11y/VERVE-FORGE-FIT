import 'dart:io';

import '../../domain/profile_model.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

/// ProfileRepository 实现 — 委托 ProfileRemoteDataSource 执行实际操作
class ProfileRepositoryImpl implements ProfileRepositoryInterface {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<ProfileModel?> getCurrentProfile() =>
      _remoteDataSource.getCurrentProfile();

  @override
  Future<ProfileModel?> getProfile(String userId) =>
      _remoteDataSource.getProfile(userId);

  @override
  Future<ProfileModel> updateProfile(ProfileModel profile) =>
      _remoteDataSource.updateProfile(profile);

  @override
  Future<String> uploadAvatar(File imageFile) =>
      _remoteDataSource.uploadAvatar(imageFile);
}
