import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/notification_model.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (_) => NotificationRepository(),
);

/// 通知 Repository — 通知消息管理
class NotificationRepository {
  static const _table = SupabaseConstants.notifications;

  /// 获取通知列表（分页）
  Future<List<NotificationModel>> getNotifications({int page = 0}) async {
    final userId = SupabaseClientHelper.currentUserId!;
    const pageSize = 30;

    final data = await SupabaseClientHelper.from(_table)
        .select('''
          *,
          ref_user:profiles!notifications_ref_user_id_fkey(nickname, avatar_url)
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .range(page * pageSize, (page + 1) * pageSize - 1);

    return (data as List).map((e) => NotificationModel.fromJson(e)).toList();
  }

  /// 获取未读通知数量
  Future<int> getUnreadCount() async {
    final userId = SupabaseClientHelper.currentUserId!;

    final result = await SupabaseClientHelper.from(_table)
        .select()
        .eq('user_id', userId)
        .eq('is_read', false)
        .count(CountOption.exact);

    return result.count;
  }

  /// 标记单条通知为已读
  Future<void> markAsRead(String notificationId) async {
    await SupabaseClientHelper.from(_table)
        .update({
          'is_read': true,
          'read_at': DateTime.now().toIso8601String(),
        })
        .eq('id', notificationId);
  }

  /// 标记全部通知为已读
  Future<void> markAllAsRead() async {
    final userId = SupabaseClientHelper.currentUserId!;

    await SupabaseClientHelper.from(_table)
        .update({
          'is_read': true,
          'read_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  /// 订阅实时通知
  RealtimeChannel subscribeNotifications({
    required void Function(NotificationModel notification) onNew,
  }) {
    final userId = SupabaseClientHelper.currentUserId!;

    return SupabaseClientHelper.client
        .channel('notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: _table,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final json = payload.newRecord;
            if (json.isNotEmpty) {
              onNew(NotificationModel.fromJson(json));
            }
          },
        )
        .subscribe();
  }
}
