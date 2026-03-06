import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../data/gym_review_repository.dart';
import '../domain/gym_review_model.dart';

/// 训练馆评价列表 Provider（按 gym_id 分页）
final gymReviewsProvider = AsyncNotifierProvider.family<GymReviewsNotifier,
    List<GymReviewModel>, String>(
  GymReviewsNotifier.new,
);

class GymReviewsNotifier
    extends FamilyAsyncNotifier<List<GymReviewModel>, String> {
  int _page = 0;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  @override
  Future<List<GymReviewModel>> build(String arg) async {
    _page = 0;
    _hasMore = true;
    return _fetch();
  }

  Future<List<GymReviewModel>> _fetch() async {
    final repo = ref.read(gymReviewRepositoryProvider);
    final data = await repo.list(
      gymId: arg,
      page: _page,
      pageSize: AppConstants.defaultPageSize,
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
    final current = state.valueOrNull ?? [];
    final more = await _fetch();
    state = AsyncValue.data([...current, ...more]);
  }

  /// 刷新
  Future<void> refresh() async {
    _page = 0;
    _hasMore = true;
    ref.invalidateSelf();
  }
}
