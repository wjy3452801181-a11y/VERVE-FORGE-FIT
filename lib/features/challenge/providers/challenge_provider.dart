import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../data/challenge_repository.dart';
import '../domain/challenge_model.dart';
import '../domain/challenge_participant_model.dart';

// -------------------------------------------------------
// 筛选条件
// -------------------------------------------------------

/// 挑战赛筛选条件
class ChallengeFilter {
  final String? city;
  final String? sportType;

  const ChallengeFilter({this.city, this.sportType});

  ChallengeFilter copyWith({
    String? city,
    String? sportType,
    bool clearCity = false,
    bool clearSportType = false,
  }) {
    return ChallengeFilter(
      city: clearCity ? null : (city ?? this.city),
      sportType: clearSportType ? null : (sportType ?? this.sportType),
    );
  }
}

final challengeFilterProvider = StateProvider<ChallengeFilter>((ref) {
  return const ChallengeFilter();
});

// -------------------------------------------------------
// Realtime 订阅 — 挑战赛列表变更监听
// -------------------------------------------------------

/// 挑战赛列表是否有更新（Realtime 推送标记）
final challengeHasUpdatesProvider = StateProvider<bool>((ref) => false);

/// 挑战赛 Realtime 订阅 Provider
/// 监听 challenges 表变更事件，标记 challengeHasUpdatesProvider = true
final challengeRealtimeProvider = Provider<void>((ref) {
  final repo = ref.read(challengeRepositoryProvider);

  final channel = repo.subscribeChallengeList(
    onUpdate: () {
      // 收到挑战赛变更通知，设置标记
      ref.read(challengeHasUpdatesProvider.notifier).state = true;
    },
  );

  // Provider 被销毁时取消订阅
  ref.onDispose(() {
    repo.unsubscribeChallengeList(channel);
  });
});

// -------------------------------------------------------
// 挑战赛列表
// -------------------------------------------------------

final challengeListProvider =
    AsyncNotifierProvider<ChallengeListNotifier, List<ChallengeModel>>(
  ChallengeListNotifier.new,
);

class ChallengeListNotifier extends AsyncNotifier<List<ChallengeModel>> {
  int _page = 0;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  @override
  Future<List<ChallengeModel>> build() async {
    final filter = ref.watch(challengeFilterProvider);
    _page = 0;
    _hasMore = true;
    return _fetch(filter);
  }

  Future<List<ChallengeModel>> _fetch(ChallengeFilter filter) async {
    final repo = ref.read(challengeRepositoryProvider);
    final data = await repo.list(
      page: _page,
      pageSize: AppConstants.defaultPageSize,
      city: filter.city,
      sportType: filter.sportType,
      status: 'active',
    );
    if (data.length < AppConstants.defaultPageSize) {
      _hasMore = false;
    }
    return data;
  }

  /// 加载更多
  Future<void> loadMore() async {
    if (!_hasMore) return;
    final filter = ref.read(challengeFilterProvider);
    _page++;
    final current = state.valueOrNull ?? [];
    final more = await _fetch(filter);
    state = AsyncValue.data([...current, ...more]);
  }

  /// 手动刷新（清除更新标记）
  Future<void> refresh() async {
    final filter = ref.read(challengeFilterProvider);
    _page = 0;
    _hasMore = true;
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetch(filter));
  }
}

// -------------------------------------------------------
// 挑战赛详情
// -------------------------------------------------------

final challengeDetailProvider =
    FutureProvider.family<ChallengeModel?, String>((ref, id) async {
  final repo = ref.watch(challengeRepositoryProvider);
  return repo.get(id);
});

// -------------------------------------------------------
// 排行榜（含 Realtime）
// -------------------------------------------------------

final challengeLeaderboardProvider = AutoDisposeAsyncNotifierProviderFamily<
    ChallengeLeaderboardNotifier,
    List<ChallengeParticipantModel>,
    String>(ChallengeLeaderboardNotifier.new);

class ChallengeLeaderboardNotifier extends AutoDisposeFamilyAsyncNotifier<
    List<ChallengeParticipantModel>, String> {
  RealtimeChannel? _channel;

  @override
  Future<List<ChallengeParticipantModel>> build(String arg) async {
    final repo = ref.read(challengeRepositoryProvider);

    // 订阅 Realtime 更新
    _channel = repo.subscribeLeaderboard(
      arg,
      onUpdate: () async {
        // 收到变更后重新拉取排行榜
        final updated = await repo.getLeaderboard(arg);
        state = AsyncValue.data(updated);
      },
    );

    // 组件销毁时取消订阅
    ref.onDispose(() {
      if (_channel != null) {
        repo.unsubscribeLeaderboard(_channel!);
        _channel = null;
      }
    });

    return repo.getLeaderboard(arg);
  }

  /// 手动刷新
  Future<void> refresh() async {
    final repo = ref.read(challengeRepositoryProvider);
    final data = await repo.getLeaderboard(arg);
    state = AsyncValue.data(data);
  }
}

// -------------------------------------------------------
// Join / Leave 操作
// -------------------------------------------------------

final challengeActionProvider = Provider<ChallengeActionNotifier>((ref) {
  return ChallengeActionNotifier(ref);
});

class ChallengeActionNotifier {
  final Ref _ref;

  ChallengeActionNotifier(this._ref);

  /// 加入挑战
  Future<void> join(String challengeId) async {
    final repo = _ref.read(challengeRepositoryProvider);
    await repo.join(challengeId);
    // 刷新详情和列表
    _ref.invalidate(challengeDetailProvider(challengeId));
    _ref.invalidate(challengeListProvider);
    _ref.invalidate(challengeLeaderboardProvider(challengeId));
  }

  /// 退出挑战
  Future<void> leave(String challengeId) async {
    final repo = _ref.read(challengeRepositoryProvider);
    await repo.leave(challengeId);
    _ref.invalidate(challengeDetailProvider(challengeId));
    _ref.invalidate(challengeListProvider);
    _ref.invalidate(challengeLeaderboardProvider(challengeId));
  }

  /// 打卡
  Future<void> checkIn({
    required String challengeId,
    required String workoutLogId,
    int value = 1,
  }) async {
    final repo = _ref.read(challengeRepositoryProvider);
    final participant = await repo.getMyParticipant(challengeId);
    if (participant == null) return;

    await repo.checkIn(
      challengeId: challengeId,
      participantId: participant.id,
      workoutLogId: workoutLogId,
      value: value,
    );

    _ref.invalidate(challengeLeaderboardProvider(challengeId));
    _ref.invalidate(challengeDetailProvider(challengeId));
  }
}
