import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/supabase_client.dart';
import '../data/notification_repository.dart';
import '../domain/notification_model.dart';

// ═══════════════════════════════════════
// 通知列表
// ═══════════════════════════════════════

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<NotificationModel>>(
  NotificationsNotifier.new,
);

class NotificationsNotifier extends AsyncNotifier<List<NotificationModel>> {
  int _page = 0;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  @override
  Future<List<NotificationModel>> build() async {
    _page = 0;
    _hasMore = true;

    final repo = ref.read(notificationRepositoryProvider);
    final list = await repo.getNotifications();
    _hasMore = list.length >= 30;
    return list;
  }

  /// 加载更多
  Future<void> loadMore() async {
    if (!_hasMore) return;
    _page++;
    final repo = ref.read(notificationRepositoryProvider);
    final current = state.valueOrNull ?? [];
    final older = await repo.getNotifications(page: _page);
    if (older.length < 30) _hasMore = false;
    state = AsyncValue.data([...current, ...older]);
  }

  /// 标记单条已读
  Future<void> markAsRead(String notificationId) async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.markAsRead(notificationId);

    // 更新本地状态
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(
      current.map((n) {
        if (n.id == notificationId) {
          return n.copyWith(isRead: true, readAt: DateTime.now());
        }
        return n;
      }).toList(),
    );

    // 刷新未读数
    ref.invalidate(unreadCountProvider);
  }

  /// 标记全部已读
  Future<void> markAllAsRead() async {
    final repo = ref.read(notificationRepositoryProvider);
    await repo.markAllAsRead();

    // 更新本地状态
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(
      current
          .map((n) => n.copyWith(isRead: true, readAt: DateTime.now()))
          .toList(),
    );

    // 刷新未读数
    ref.invalidate(unreadCountProvider);
  }

  /// 刷新
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

// ═══════════════════════════════════════
// 未读通知数量（用于 Badge 显示）
// ═══════════════════════════════════════

final unreadCountProvider = FutureProvider<int>((ref) {
  return ref.read(notificationRepositoryProvider).getUnreadCount();
});

// ═══════════════════════════════════════
// 实时通知订阅
// ═══════════════════════════════════════

final notificationRealtimeProvider = Provider<void>((ref) {
  final userId = SupabaseClientHelper.currentUserId;
  if (userId == null) return;

  final repo = ref.read(notificationRepositoryProvider);
  final channel = repo.subscribeNotifications(
    onNew: (notification) {
      // 收到新通知，刷新列表和未读数
      ref.invalidate(notificationsProvider);
      ref.invalidate(unreadCountProvider);
    },
  );

  ref.onDispose(() {
    channel.unsubscribe();
  });
});
