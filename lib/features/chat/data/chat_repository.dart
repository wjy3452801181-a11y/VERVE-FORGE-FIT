import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/conversation_model.dart';
import '../domain/message_model.dart';

/// 聊天 Repository — 私信消息管理
class ChatRepository {
  static const _table = SupabaseConstants.messages;

  /// 获取会话列表（按最新消息排序，每个对话取最后一条）
  Future<List<ConversationModel>> getConversations() async {
    final userId = SupabaseClientHelper.currentUserId!;

    // 使用 RPC 或直接查询获取每个会话的最新消息
    // 这里采用查询所有消息按时间排序，在客户端去重的方式
    final data = await SupabaseClientHelper.from(_table)
        .select('*, sender:profiles!messages_sender_id_fkey(nickname, avatar_url), receiver:profiles!messages_receiver_id_fkey(nickname, avatar_url)')
        .or('sender_id.eq.$userId,receiver_id.eq.$userId')
        .order('created_at', ascending: false)
        .limit(200);

    // 按对话对象去重，保留最新消息
    final Map<String, Map<String, dynamic>> latestByUser = {};
    final Map<String, int> unreadCounts = {};

    for (final msg in data as List) {
      final map = msg as Map<String, dynamic>;
      final senderId = map['sender_id'] as String;
      final receiverId = map['receiver_id'] as String;
      final otherUserId = senderId == userId ? receiverId : senderId;

      // 计算未读数
      if (senderId != userId && !(map['is_read'] as bool? ?? false)) {
        unreadCounts[otherUserId] = (unreadCounts[otherUserId] ?? 0) + 1;
      }

      // 只保留最新一条
      if (!latestByUser.containsKey(otherUserId)) {
        // 附加对方的 profile 信息
        final otherProfile = senderId == userId
            ? map['receiver'] as Map<String, dynamic>?
            : map['sender'] as Map<String, dynamic>?;
        map['other_profile'] = otherProfile ?? {};
        map['unread_count'] = 0; // 稍后赋值
        latestByUser[otherUserId] = map;
      }
    }

    // 设置未读数
    for (final entry in latestByUser.entries) {
      entry.value['unread_count'] = unreadCounts[entry.key] ?? 0;
    }

    return latestByUser.values
        .map((e) => ConversationModel.fromJson(e, userId))
        .toList();
  }

  /// 获取与某用户的消息列表（分页）
  Future<List<MessageModel>> getMessages({
    required String otherUserId,
    int page = 0,
    int pageSize = 30,
  }) async {
    final userId = SupabaseClientHelper.currentUserId!;

    final data = await SupabaseClientHelper.from(_table)
        .select('*, sender:profiles!messages_sender_id_fkey(nickname, avatar_url)')
        .or('and(sender_id.eq.$userId,receiver_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,receiver_id.eq.$userId)')
        .order('created_at', ascending: false)
        .range(page * pageSize, (page + 1) * pageSize - 1);

    return (data as List)
        .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 发送消息
  Future<MessageModel> sendMessage({
    required String receiverId,
    required String content,
    String messageType = 'text',
  }) async {
    final userId = SupabaseClientHelper.currentUserId!;

    final data = await SupabaseClientHelper.from(_table)
        .insert({
          'sender_id': userId,
          'receiver_id': receiverId,
          'content': content,
          'message_type': messageType,
        })
        .select('*, sender:profiles!messages_sender_id_fkey(nickname, avatar_url)')
        .single();

    return MessageModel.fromJson(data);
  }

  /// 标记对方消息为已读
  Future<void> markAsRead(String otherUserId) async {
    final userId = SupabaseClientHelper.currentUserId!;

    await SupabaseClientHelper.from(_table)
        .update({'is_read': true})
        .eq('sender_id', otherUserId)
        .eq('receiver_id', userId)
        .eq('is_read', false);
  }

  /// 订阅实时消息（当前用户收到的新消息）
  RealtimeChannel subscribeMessages({
    required void Function(MessageModel message) onNewMessage,
  }) {
    final userId = SupabaseClientHelper.currentUserId!;

    return SupabaseClientHelper.client
        .channel('messages:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: _table,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'receiver_id',
            value: userId,
          ),
          callback: (payload) {
            final newMsg = MessageModel.fromJson(payload.newRecord);
            onNewMessage(newMsg);
          },
        )
        .subscribe();
  }
}

/// Provider
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});
