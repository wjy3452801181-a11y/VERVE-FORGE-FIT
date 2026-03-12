import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../gym/providers/gym_provider.dart';
import '../data/buddy_repository.dart';
import '../domain/buddy_model.dart';
import '../domain/buddy_request_model.dart';

/// 伙伴筛选条件
class BuddyFilter {
  final String? sportType;
  final double radiusKm;

  const BuddyFilter({this.sportType, this.radiusKm = 10.0});

  BuddyFilter copyWith({
    String? sportType,
    double? radiusKm,
    bool clearSportType = false,
  }) {
    return BuddyFilter(
      sportType: clearSportType ? null : (sportType ?? this.sportType),
      radiusKm: radiusKm ?? this.radiusKm,
    );
  }
}

/// 筛选条件 Provider
final buddyFilterProvider = StateProvider<BuddyFilter>((ref) {
  return const BuddyFilter();
});

/// 附近伙伴 Provider（基于位置 + 筛选）
final nearbyBuddiesProvider = FutureProvider<List<BuddyModel>>((ref) async {
  final location = await ref.watch(currentLocationProvider.future);
  final filter = ref.watch(buddyFilterProvider);
  final repo = ref.watch(buddyRepositoryProvider);

  if (location != null) {
    return repo.getNearbyBuddies(
      latitude: location.latitude,
      longitude: location.longitude,
      radiusKm: filter.radiusKm,
      sportType: filter.sportType,
    );
  }

  return repo.listByCity(
    city: 'shanghai',
    sportType: filter.sportType,
  );
});

/// 伙伴列表 Provider（分页 — 用于按城市降级场景）
final buddyListProvider =
    AsyncNotifierProvider<BuddyListNotifier, List<BuddyModel>>(
  BuddyListNotifier.new,
);

class BuddyListNotifier extends AsyncNotifier<List<BuddyModel>> {
  int _page = 0;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  @override
  Future<List<BuddyModel>> build() async {
    _page = 0;
    _hasMore = true;

    final location = await ref.watch(currentLocationProvider.future);
    final filter = ref.watch(buddyFilterProvider);
    final repo = ref.read(buddyRepositoryProvider);

    if (location != null) {
      final data = await repo.getNearbyBuddies(
        latitude: location.latitude,
        longitude: location.longitude,
        radiusKm: filter.radiusKm,
        sportType: filter.sportType,
      );
      _hasMore = data.length >= AppConstants.defaultPageSize;
      return data;
    }

    return _fetchByCity(filter);
  }

  Future<List<BuddyModel>> _fetchByCity(BuddyFilter filter) async {
    final repo = ref.read(buddyRepositoryProvider);
    final data = await repo.listByCity(
      city: 'shanghai',
      sportType: filter.sportType,
      page: _page,
    );
    if (data.length < AppConstants.defaultPageSize) {
      _hasMore = false;
    }
    return data;
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;
    _page++;
    final filter = ref.read(buddyFilterProvider);
    final current = state.valueOrNull ?? [];
    final more = await _fetchByCity(filter);
    state = AsyncValue.data([...current, ...more]);
  }

  Future<void> refresh() async {
    _page = 0;
    _hasMore = true;
    ref.invalidateSelf();
  }
}

/// 约练请求操作
final buddyRequestActionProvider = Provider<BuddyRequestAction>((ref) {
  return BuddyRequestAction(ref);
});

class BuddyRequestAction {
  final Ref _ref;

  BuddyRequestAction(this._ref);

  Future<void> send(String targetUserId) async {
    final repo = _ref.read(buddyRepositoryProvider);
    await repo.sendBuddyRequest(targetUserId);
  }
}

// ═══════════════════════════════════════
// 好友请求列表 Providers
// ═══════════════════════════════════════

/// 收到的好友请求
final receivedRequestsProvider =
    AsyncNotifierProvider<ReceivedRequestsNotifier, List<BuddyRequestModel>>(
  ReceivedRequestsNotifier.new,
);

class ReceivedRequestsNotifier extends AsyncNotifier<List<BuddyRequestModel>> {
  @override
  Future<List<BuddyRequestModel>> build() {
    return ref.read(buddyRepositoryProvider).getReceivedRequests();
  }

  Future<void> accept(String requestId) async {
    await ref.read(buddyRepositoryProvider).acceptRequest(requestId);
    ref.invalidateSelf();
    ref.invalidate(acceptedBuddiesProvider);
  }

  Future<void> reject(String requestId) async {
    await ref.read(buddyRepositoryProvider).rejectRequest(requestId);
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// 发出的好友请求
final sentRequestsProvider =
    AsyncNotifierProvider<SentRequestsNotifier, List<BuddyRequestModel>>(
  SentRequestsNotifier.new,
);

class SentRequestsNotifier extends AsyncNotifier<List<BuddyRequestModel>> {
  @override
  Future<List<BuddyRequestModel>> build() {
    return ref.read(buddyRepositoryProvider).getSentRequests();
  }

  Future<void> cancel(String requestId) async {
    await ref.read(buddyRepositoryProvider).cancelRequest(requestId);
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// 好友列表（已接受）
final acceptedBuddiesProvider =
    AsyncNotifierProvider<AcceptedBuddiesNotifier, List<BuddyRequestModel>>(
  AcceptedBuddiesNotifier.new,
);

class AcceptedBuddiesNotifier extends AsyncNotifier<List<BuddyRequestModel>> {
  @override
  Future<List<BuddyRequestModel>> build() {
    return ref.read(buddyRepositoryProvider).getAcceptedBuddies();
  }

  Future<void> remove(String requestId) async {
    await ref.read(buddyRepositoryProvider).removeBuddy(requestId);
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
