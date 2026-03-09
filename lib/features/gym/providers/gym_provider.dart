import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../data/gym_repository.dart';
import '../data/location_service.dart';
import '../domain/gym_model.dart';
import '../domain/user_gym_favorite_model.dart';
import '../domain/gym_claim_model.dart';

/// 当前位置 Provider
final currentLocationProvider =
    FutureProvider<({double latitude, double longitude})?>(
  (ref) async {
    final service = LocationService();
    try {
      return await service.getCurrentLocation();
    } finally {
      service.dispose();
    }
  },
);

/// 训练馆筛选条件
class GymFilter {
  final String? sportType;
  final double radiusKm;

  const GymFilter({this.sportType, this.radiusKm = 10.0});

  GymFilter copyWith({
    String? sportType,
    double? radiusKm,
    bool clearSportType = false,
  }) {
    return GymFilter(
      sportType: clearSportType ? null : (sportType ?? this.sportType),
      radiusKm: radiusKm ?? this.radiusKm,
    );
  }
}

/// 筛选条件 Provider
final gymFilterProvider = StateProvider<GymFilter>((ref) {
  return const GymFilter();
});

/// 附近训练馆 Provider（基于位置 + 筛选）
final nearbyGymsProvider = FutureProvider<List<GymModel>>((ref) async {
  final location = await ref.watch(currentLocationProvider.future);
  if (location == null) return [];

  final filter = ref.watch(gymFilterProvider);
  final repo = ref.watch(gymRepositoryProvider);

  return repo.getNearbyGyms(
    latitude: location.latitude,
    longitude: location.longitude,
    radiusKm: filter.radiusKm,
    sportType: filter.sportType,
  );
});

/// 训练馆详情 Provider
final gymDetailProvider =
    FutureProvider.family<GymModel?, String>((ref, id) async {
  final repo = ref.watch(gymRepositoryProvider);
  return repo.getDetail(id);
});

/// 训练馆搜索关键词 Provider
final gymSearchKeywordProvider = StateProvider<String>((ref) => '');

/// 训练馆搜索结果 Provider
final gymSearchProvider = FutureProvider<List<GymModel>>((ref) async {
  final keyword = ref.watch(gymSearchKeywordProvider);
  if (keyword.isEmpty) return [];

  final repo = ref.watch(gymRepositoryProvider);
  return repo.search(keyword: keyword);
});

/// 训练馆列表 Provider（分页 + 筛选）
final gymListProvider =
    AsyncNotifierProvider<GymListNotifier, List<GymModel>>(
  GymListNotifier.new,
);

class GymListNotifier extends AsyncNotifier<List<GymModel>> {
  int _page = 0;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  @override
  Future<List<GymModel>> build() async {
    _page = 0;
    _hasMore = true;

    // 优先用位置查询附近，否则按城市查
    final location = await ref.watch(currentLocationProvider.future);
    final filter = ref.watch(gymFilterProvider);

    if (location != null) {
      return _fetchNearby(location, filter);
    }
    return _fetchByCity(filter);
  }

  Future<List<GymModel>> _fetchNearby(
    ({double latitude, double longitude}) location,
    GymFilter filter,
  ) async {
    final repo = ref.read(gymRepositoryProvider);
    final data = await repo.getNearbyGyms(
      latitude: location.latitude,
      longitude: location.longitude,
      radiusKm: filter.radiusKm,
      sportType: filter.sportType,
    );
    _hasMore = data.length >= AppConstants.defaultPageSize;
    return data;
  }

  Future<List<GymModel>> _fetchByCity(GymFilter filter) async {
    final repo = ref.read(gymRepositoryProvider);
    final data = await repo.listByCity(
      city: 'shanghai', // 默认城市
      sportType: filter.sportType,
      page: _page,
    );
    if (data.length < AppConstants.defaultPageSize) {
      _hasMore = false;
    }
    return data;
  }

  /// 加载更多
  Future<void> loadMore() async {
    if (!_hasMore) return;
    _page++;
    final filter = ref.read(gymFilterProvider);
    final current = state.valueOrNull ?? [];
    final repo = ref.read(gymRepositoryProvider);
    final more = await repo.listByCity(
      city: 'shanghai',
      sportType: filter.sportType,
      page: _page,
    );
    if (more.length < AppConstants.defaultPageSize) {
      _hasMore = false;
    }
    state = AsyncValue.data([...current, ...more]);
  }

  /// 刷新
  Future<void> refresh() async {
    _page = 0;
    _hasMore = true;
    ref.invalidateSelf();
  }
}

// -------------------------------------------------------
// 收藏
// -------------------------------------------------------

/// 某训练馆是否被当前用户收藏
final gymFavoriteStatusProvider =
    FutureProvider.family<bool, String>((ref, gymId) async {
  final repo = ref.watch(gymRepositoryProvider);
  return repo.isFavorited(gymId);
});

/// 当前用户收藏列表
final gymFavoritesProvider = AsyncNotifierProvider<GymFavoritesNotifier,
    List<UserGymFavoriteModel>>(GymFavoritesNotifier.new);

class GymFavoritesNotifier
    extends AsyncNotifier<List<UserGymFavoriteModel>> {
  int _page = 0;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  @override
  Future<List<UserGymFavoriteModel>> build() async {
    _page = 0;
    _hasMore = true;
    return _fetch();
  }

  Future<List<UserGymFavoriteModel>> _fetch() async {
    final repo = ref.read(gymRepositoryProvider);
    final data = await repo.getUserFavorites(page: _page);
    if (data.length < AppConstants.defaultPageSize) {
      _hasMore = false;
    }
    return data;
  }

  /// 加载更多
  Future<void> loadMore() async {
    if (!_hasMore) return;
    _page++;
    final current = state.valueOrNull ?? [];
    final more = await _fetch();
    state = AsyncValue.data([...current, ...more]);
  }
}

/// 收藏操作（切换 + 刷新相关 provider）
final gymFavoriteActionProvider = Provider<GymFavoriteAction>((ref) {
  return GymFavoriteAction(ref);
});

class GymFavoriteAction {
  final Ref _ref;

  GymFavoriteAction(this._ref);

  /// 切换收藏状态，返回操作后状态
  Future<bool> toggle(String gymId) async {
    final repo = _ref.read(gymRepositoryProvider);
    final result = await repo.toggleFavorite(gymId);
    // 刷新该训练馆的收藏状态
    _ref.invalidate(gymFavoriteStatusProvider(gymId));
    // 刷新收藏列表
    _ref.invalidate(gymFavoritesProvider);
    return result;
  }
}

// -------------------------------------------------------
// 馆主认领
// -------------------------------------------------------

/// 当前用户对某训练馆的认领状态
final gymClaimStatusProvider =
    FutureProvider.family<GymClaimModel?, String>((ref, gymId) async {
  final repo = ref.watch(gymRepositoryProvider);
  return repo.getMyClaim(gymId);
});

/// 认领操作
final gymClaimActionProvider = Provider<GymClaimAction>((ref) {
  return GymClaimAction(ref);
});

class GymClaimAction {
  final Ref _ref;

  GymClaimAction(this._ref);

  /// 提交认领申请
  Future<GymClaimModel> submit({
    required String gymId,
    String reason = '',
  }) async {
    final repo = _ref.read(gymRepositoryProvider);
    final claim = await repo.submitClaim(gymId: gymId, reason: reason);
    // 刷新认领状态
    _ref.invalidate(gymClaimStatusProvider(gymId));
    return claim;
  }
}
