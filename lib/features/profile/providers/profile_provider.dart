import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/profile_repository.dart';
import '../domain/profile_model.dart';
import '../../auth/providers/auth_provider.dart';

/// 当前用户档案 Provider（自动跟随 Auth 状态刷新）
final currentProfileProvider =
    AsyncNotifierProvider<CurrentProfileNotifier, ProfileModel?>(
  CurrentProfileNotifier.new,
);

class CurrentProfileNotifier extends AsyncNotifier<ProfileModel?> {
  @override
  Future<ProfileModel?> build() async {
    // 监听 Auth 状态变化，自动刷新
    ref.watch(authStateProvider);
    final repo = ref.read(profileRepositoryProvider);
    return repo.getCurrentProfile();
  }

  /// 手动刷新档案
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref.read(profileRepositoryProvider).getCurrentProfile();
    });
  }

  /// 更新档案
  Future<void> updateProfile(ProfileModel profile) async {
    final repo = ref.read(profileRepositoryProvider);
    final updated = await repo.updateProfile(profile);
    state = AsyncData(updated);
  }

  /// 上传头像
  Future<String> uploadAvatar(File imageFile) async {
    final repo = ref.read(profileRepositoryProvider);
    final url = await repo.uploadAvatar(imageFile);
    await refresh();
    return url;
  }
}

/// 是否已完成引导流
final isOnboardingCompleteProvider = Provider<bool>((ref) {
  final profileAsync = ref.watch(currentProfileProvider);
  return profileAsync.valueOrNull?.isOnboardingComplete ?? false;
});

/// 其他用户档案 Provider（按 ID 获取）
final userProfileProvider =
    FutureProvider.family<ProfileModel?, String>((ref, userId) async {
  final repo = ref.read(profileRepositoryProvider);
  return repo.getProfile(userId);
});
