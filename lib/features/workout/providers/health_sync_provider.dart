import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/health_service.dart';
import '../data/workout_repository.dart';

/// Health 同步状态
enum HealthSyncStatus { idle, syncing, success, error }

/// Health 同步状态模型
class HealthSyncState {
  final bool isEnabled;
  final HealthSyncStatus status;
  final String? errorMessage;
  final int lastSyncedCount;

  const HealthSyncState({
    this.isEnabled = false,
    this.status = HealthSyncStatus.idle,
    this.errorMessage,
    this.lastSyncedCount = 0,
  });

  HealthSyncState copyWith({
    bool? isEnabled,
    HealthSyncStatus? status,
    String? errorMessage,
    int? lastSyncedCount,
  }) {
    return HealthSyncState(
      isEnabled: isEnabled ?? this.isEnabled,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      lastSyncedCount: lastSyncedCount ?? this.lastSyncedCount,
    );
  }
}

/// Health 同步 Provider
final healthSyncProvider =
    StateNotifierProvider<HealthSyncNotifier, HealthSyncState>((ref) {
  return HealthSyncNotifier(ref);
});

class HealthSyncNotifier extends StateNotifier<HealthSyncState> {
  final Ref _ref;

  HealthSyncNotifier(this._ref) : super(const HealthSyncState());

  /// 切换同步开关
  Future<void> toggleSync() async {
    if (!Platform.isIOS) return;

    if (!state.isEnabled) {
      final service = _ref.read(healthServiceProvider);
      final granted = await service.requestPermissions();
      if (!granted) {
        state = state.copyWith(
          status: HealthSyncStatus.error,
          errorMessage: 'healthPermissionDenied',
        );
        return;
      }
      state = state.copyWith(isEnabled: true, status: HealthSyncStatus.idle);
      await syncNow();
    } else {
      state = state.copyWith(isEnabled: false, status: HealthSyncStatus.idle);
    }
  }

  /// 立即同步
  Future<void> syncNow() async {
    if (!Platform.isIOS || !state.isEnabled) return;

    state = state.copyWith(status: HealthSyncStatus.syncing);

    try {
      final service = _ref.read(healthServiceProvider);
      final repo = _ref.read(workoutRepositoryProvider);
      final count = await service.syncToSupabase(repository: repo);
      state = state.copyWith(
        status: HealthSyncStatus.success,
        lastSyncedCount: count,
      );
    } catch (e) {
      state = state.copyWith(
        status: HealthSyncStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}
