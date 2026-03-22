import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';
import '../data/chat_repository.dart';
import '../domain/conversation_model.dart';
import '../domain/message_model.dart';

// ═══════════════════════════════════════
// 会话列表
// ═══════════════════════════════════════

final conversationsProvider =
    AsyncNotifierProvider<ConversationsNotifier, List<ConversationModel>>(
  ConversationsNotifier.new,
);

class ConversationsNotifier extends AsyncNotifier<List<ConversationModel>> {
  @override
  Future<List<ConversationModel>> build() {
    return ref.read(chatRepositoryProvider).getConversations();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

// ═══════════════════════════════════════
// 聊天消息（按对话对象）
// ═══════════════════════════════════════

final messagesProvider = AsyncNotifierProvider.family<MessagesNotifier,
    List<MessageModel>, String>(
  MessagesNotifier.new,
);

class MessagesNotifier
    extends FamilyAsyncNotifier<List<MessageModel>, String> {
  int _page = 0;
  bool _hasMore = true;
  RealtimeChannel? _channel;

  bool get hasMore => _hasMore;

  @override
  Future<List<MessageModel>> build(String arg) async {
    _page = 0;
    _hasMore = true;

    final repo = ref.read(chatRepositoryProvider);

    // 在第一个 await 之前注册 dispose，确保只注册一次且不遗漏
    ref.onDispose(() {
      _channel?.unsubscribe();
      _channel = null;
    });

    // 标记对方消息为已读
    await repo.markAsRead(arg);

    // 订阅实时消息（先取消旧订阅）
    _channel?.unsubscribe();
    _channel = repo.subscribeMessages(
      onNewMessage: (msg) {
        if (msg.senderId == arg) {
          // 收到对方消息，插入列表头部
          final current = state.valueOrNull ?? [];
          state = AsyncValue.data([msg, ...current]);
          // 标记为已读
          repo.markAsRead(arg);
          // 刷新会话列表
          ref.invalidate(conversationsProvider);
        }
      },
    );

    final messages = await repo.getMessages(otherUserId: arg);
    _hasMore = messages.length >= 30;
    return messages;
  }

  /// 加载更多历史消息
  Future<void> loadMore() async {
    if (!_hasMore) return;
    _page++;
    final repo = ref.read(chatRepositoryProvider);
    final current = state.valueOrNull ?? [];
    final older = await repo.getMessages(
      otherUserId: arg,
      page: _page,
    );
    if (older.length < 30) _hasMore = false;
    state = AsyncValue.data([...current, ...older]);
  }

  /// 发送消息
  Future<void> send(String content) async {
    if (content.trim().isEmpty) return;
    final repo = ref.read(chatRepositoryProvider);
    final msg = await repo.sendMessage(
      receiverId: arg,
      content: content.trim(),
    );
    // 插入列表头部
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data([msg, ...current]);
    // 刷新会话列表
    ref.invalidate(conversationsProvider);
  }
}

// ═══════════════════════════════════════
// 实时消息通知（全局未读数）
// ═══════════════════════════════════════

final chatRealtimeProvider = Provider<void>((ref) {
  final userId = SupabaseClientHelper.currentUserId;
  if (userId == null) return;

  final repo = ref.read(chatRepositoryProvider);
  final channel = repo.subscribeMessages(
    onNewMessage: (_) {
      // 收到任何新消息，刷新会话列表
      ref.invalidate(conversationsProvider);
    },
  );

  ref.onDispose(() {
    channel.unsubscribe();
  });
});
