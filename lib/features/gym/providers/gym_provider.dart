import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../data/gym_repository.dart';
import '../data/location_service.dart';
import '../domain/gym_model.dart';

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
