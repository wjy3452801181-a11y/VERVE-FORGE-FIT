import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../data/workout_repository.dart';
import '../domain/workout_model.dart';
import '../domain/workout_stats.dart';

/// 训练列表筛选条件
class WorkoutFilter {
  final String? sportType;
  final DateTime? from;
  final DateTime? to;

  const WorkoutFilter({this.sportType, this.from, this.to});

  WorkoutFilter copyWith({
    String? sportType,
    DateTime? from,
    DateTime? to,
    bool clearSportType = false,
  }) {
    return WorkoutFilter(
      sportType: clearSportType ? null : (sportType ?? this.sportType),
      from: from ?? this.from,
      to: to ?? this.to,
    );
  }
}

/// 筛选条件 Provider
final workoutFilterProvider = StateProvider<WorkoutFilter>((ref) {
  return const WorkoutFilter();
});

/// 训练列表 Provider（分页+筛选）
final workoutListProvider =
    AsyncNotifierProvider<WorkoutListNotifier, List<WorkoutModel>>(
  WorkoutListNotifier.new,
);

class WorkoutListNotifier extends AsyncNotifier<List<WorkoutModel>> {
  int _page = 0;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  @override
  Future<List<WorkoutModel>> build() async {
    final filter = ref.watch(workoutFilterProvider);
    _page = 0;
    _hasMore = true;
    return _fetch(filter);
  }

  Future<List<WorkoutModel>> _fetch(WorkoutFilter filter) async {
    final repo = ref.read(workoutRepositoryProvider);
    final data = await repo.list(
      page: _page,
      pageSize: AppConstants.defaultPageSize,
      sportType: filter.sportType,
      from: filter.from,
      to: filter.to,
    );
    if (data.length < AppConstants.defaultPageSize) {
      _hasMore = false;
    }
    return data;
  }

  /// 加载更多
  Future<void> loadMore() async {
    if (!_hasMore) return;
    final filter = ref.read(workoutFilterProvider);
    _page++;
    final current = state.valueOrNull ?? [];
    final more = await _fetch(filter);
    state = AsyncValue.data([...current, ...more]);
  }

  /// 刷新
  Future<void> refresh() async {
    _page = 0;
    _hasMore = true;
    ref.invalidateSelf();
  }
}

/// 训练统计 Provider
final workoutStatsProvider = FutureProvider<WorkoutStats>((ref) async {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.getStats();
});

/// 单条训练详情 Provider
final workoutDetailProvider =
    FutureProvider.family<WorkoutModel?, String>((ref, id) async {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.get(id);
});

/// 日历数据 Provider（某月的训练记录）
final workoutCalendarProvider = FutureProvider.family<List<WorkoutModel>,
    ({DateTime start, DateTime end})>((ref, range) async {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.listByDateRange(start: range.start, end: range.end);
});

/// 草稿列表 Provider
final workoutDraftsProvider = FutureProvider<List<WorkoutModel>>((ref) async {
  final repo = ref.watch(workoutRepositoryProvider);
  return repo.getDrafts();
});
