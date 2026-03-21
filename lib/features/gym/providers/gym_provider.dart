import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/debouncer.dart';
import '../data/gym_repository.dart';
import '../data/location_service.dart';
import '../domain/gym_model.dart';
import '../domain/user_gym_favorite_model.dart';
import '../domain/gym_claim_model.dart';

// -------------------------------------------------------
// 【性能优化】当前位置 Provider — 带缓存
// 10 分钟内复用上次定位结果，避免重复 GPS 调用
// -------------------------------------------------------

/// 位置缓存有效期
const _locationCacheDuration = Duration(minutes: 10);

/// 缓存的位置数据
({double latitude, double longitude})? _cachedLocation;
DateTime? _locationCacheTime;

final currentLocationProvider =
    FutureProvider<({double latitude, double longitude})?>(
  (ref) async {
    // 【性能优化】缓存命中：10 分钟内免重复定位
    if (_cachedLocation != null &&
        _locationCacheTime != null &&
        DateTime.now().difference(_locationCacheTime!) <
            _locationCacheDuration) {
      return _cachedLocation;
    }

    final service = LocationService();
    try {
      final result = await service.getCurrentLocation();
      if (result != null) {
        _cachedLocation = result;
        _locationCacheTime = DateTime.now();
      }
      return result;
    } finally {
      service.dispose();
    }
  },
);

// -------------------------------------------------------
// 训练馆筛选条件
// -------------------------------------------------------

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GymFilter &&
          sportType == other.sportType &&
          radiusKm == other.radiusKm;

  @override
  int get hashCode => Object.hash(sportType, radiusKm);
}

/// 筛选条件 Provider
final gymFilterProvider = StateProvider<GymFilter>((ref) {
  return const GymFilter();
});

// -------------------------------------------------------
// 附近训练馆 Provider（基于位置 + 筛选）
// 【性能优化】添加 keepAlive 缓存 + 筛选结果缓存
// -------------------------------------------------------

final nearbyGymsProvider = FutureProvider<List<GymModel>>((ref) async {
  // 【性能优化】keepAlive 保留已加载的训练馆数据
  ref.keepAlive();

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

// -------------------------------------------------------
// 【性能优化】Marker Clustering — 地图标记聚合
// 纯 Dart 实现的网格聚合算法，无需额外依赖
// -------------------------------------------------------

/// 聚合标记数据模型
class GymCluster {
  /// 聚合中心坐标
  final double latitude;
  final double longitude;

  /// 聚合内的训练馆列表
  final List<GymModel> gyms;

  const GymCluster({
    required this.latitude,
    required this.longitude,
    required this.gyms,
  });

  /// 是否为聚合（包含多个训练馆）
  bool get isCluster => gyms.length > 1;

  /// 聚合数量
  int get count => gyms.length;

  /// 单个训练馆时返回它（用于非聚合情况）
  GymModel? get single => gyms.length == 1 ? gyms.first : null;
}

/// 可见区域范围
class MapVisibleRegion {
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;

  const MapVisibleRegion({
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
  });

  /// 默认全可见（不过滤）
  static const all = MapVisibleRegion(
    minLat: -90,
    maxLat: 90,
    minLng: -180,
    maxLng: 180,
  );

  /// 检查坐标是否在可见区域内
  bool contains(double lat, double lng) {
    return lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng;
  }
}

/// 当前地图可见区域 Provider（由地图移动时更新）
final mapVisibleRegionProvider = StateProvider<MapVisibleRegion>((ref) {
  return MapVisibleRegion.all;
});

/// 当前地图缩放级别 Provider（影响聚合网格大小）
final mapZoomLevelProvider = StateProvider<double>((ref) => 14.0);

/// 【性能优化】聚合后的训练馆标记列表 Provider
/// 1. 仅保留可见区域内的训练馆（过滤）
/// 2. 按网格聚合相邻标记（减少渲染数量）
/// 3. 响应缩放级别动态调整聚合粒度
final clusteredGymsProvider = Provider<List<GymCluster>>((ref) {
  final gymsAsync = ref.watch(nearbyGymsProvider);
  final region = ref.watch(mapVisibleRegionProvider);
  final zoom = ref.watch(mapZoomLevelProvider);

  final gyms = gymsAsync.valueOrNull ?? [];
  if (gyms.isEmpty) return [];

  // 第一步：可见区域过滤（减少参与聚合的数据量）
  final visible = gyms.where(
    (g) => region.contains(g.latitude, g.longitude),
  ).toList();

  if (visible.isEmpty) return [];

  // 第二步：网格聚合
  // 网格大小随缩放级别动态调整：zoom 越大（越近），网格越小
  // zoom 14 → ~0.005°（约 500m），zoom 10 → ~0.08°（约 8km）
  final gridSize = 0.15 / (zoom.clamp(8, 20) - 6);

  final Map<String, List<GymModel>> grid = {};
  for (final gym in visible) {
    final gridKey =
        '${(gym.latitude / gridSize).floor()}_${(gym.longitude / gridSize).floor()}';
    grid.putIfAbsent(gridKey, () => []).add(gym);
  }

  // 第三步：构建聚合结果
  return grid.values.map((clusterGyms) {
    // 聚合中心 = 所有点的质心
    final lat = clusterGyms.fold<double>(
            0.0, (sum, g) => sum + g.latitude) /
        clusterGyms.length;
    final lng = clusterGyms.fold<double>(
            0.0, (sum, g) => sum + g.longitude) /
        clusterGyms.length;

    return GymCluster(
      latitude: lat,
      longitude: lng,
      gyms: clusterGyms,
    );
  }).toList();
});

// -------------------------------------------------------
// 训练馆详情 Provider
// -------------------------------------------------------

final gymDetailProvider =
    FutureProvider.family<GymModel?, String>((ref, id) async {
  final repo = ref.watch(gymRepositoryProvider);
  return repo.getDetail(id);
});

// -------------------------------------------------------
// 【性能优化】训练馆搜索 — 防抖 500ms
// 使用 Debouncer 避免每次按键触发网络请求
// -------------------------------------------------------

/// 搜索关键词（原始输入，实时更新）
final gymSearchKeywordProvider = StateProvider<String>((ref) => '');

/// 【性能优化】防抖后的搜索关键词（500ms 延迟，实际触发查询）
final _gymSearchDebouncedProvider = StateProvider<String>((ref) => '');

/// 搜索防抖控制器 Provider（管理 Timer 生命周期）
final _gymSearchDebouncerProvider = Provider<Debouncer>((ref) {
  final debouncer = Debouncer(delay: const Duration(milliseconds: 500));

  // 监听原始关键词变化，防抖后更新 debounced 值
  ref.listen(gymSearchKeywordProvider, (prev, next) {
    if (next.isEmpty) {
      // 清空时立即响应，不等防抖
      debouncer.cancel();
      ref.read(_gymSearchDebouncedProvider.notifier).state = '';
    } else {
      debouncer.run(() {
        ref.read(_gymSearchDebouncedProvider.notifier).state = next;
      });
    }
  });

  // Provider 销毁时释放 Timer
  ref.onDispose(() => debouncer.dispose());

  return debouncer;
});

/// 训练馆搜索结果 Provider（监听防抖后的关键词）
final gymSearchProvider = FutureProvider<List<GymModel>>((ref) async {
  // 激活防抖控制器（确保 listener 注册）
  ref.watch(_gymSearchDebouncerProvider);

  // 【性能优化】监听防抖后的关键词，而非原始输入
  final keyword = ref.watch(_gymSearchDebouncedProvider);
  if (keyword.isEmpty) return [];

  final repo = ref.watch(gymRepositoryProvider);
  return repo.search(keyword: keyword);
});

// -------------------------------------------------------
// 训练馆列表 Provider（分页 + 筛选）
// -------------------------------------------------------

final gymListProvider =
    AsyncNotifierProvider<GymListNotifier, List<GymModel>>(
  GymListNotifier.new,
);

class GymListNotifier extends AsyncNotifier<List<GymModel>> {
  int _page = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;

  @override
  Future<List<GymModel>> build() async {
    // 【性能优化】keepAlive 保留列表数据
    ref.keepAlive();

    _page = 0;
    _hasMore = true;
    _isLoadingMore = false;

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

  /// 加载更多（带防重复锁）
  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    _isLoadingMore = true;
    try {
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
    } finally {
      _isLoadingMore = false;
    }
  }

  /// 刷新
  Future<void> refresh() async {
    _page = 0;
    _hasMore = true;
    _isLoadingMore = false;
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
