import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/ai_avatar_repository.dart';
import '../domain/ai_avatar_model.dart';
import '../../auth/providers/auth_provider.dart';

// ============================================================
// 当前用户 AI 分身 Provider
// ============================================================

final currentAiAvatarProvider =
    AsyncNotifierProvider<CurrentAiAvatarNotifier, AiAvatarModel?>(
  CurrentAiAvatarNotifier.new,
);

class CurrentAiAvatarNotifier extends AsyncNotifier<AiAvatarModel?> {
  @override
  Future<AiAvatarModel?> build() async {
    ref.watch(authStateProvider);
    final repo = ref.read(aiAvatarRepositoryProvider);
    return repo.getMyAvatar();
  }

  /// 手动刷新
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return ref.read(aiAvatarRepositoryProvider).getMyAvatar();
    });
  }

  /// 创建分身
  Future<AiAvatarModel> createAvatar({
    required String name,
    String? avatarUrl,
    required List<String> personalityTraits,
    required String speakingStyle,
    String customPrompt = '',
  }) async {
    final repo = ref.read(aiAvatarRepositoryProvider);
    final avatar = await repo.createAvatar(
      name: name,
      avatarUrl: avatarUrl,
      personalityTraits: personalityTraits,
      speakingStyle: speakingStyle,
      customPrompt: customPrompt,
    );
    state = AsyncData(avatar);
    return avatar;
  }

  /// 更新分身
  Future<void> updateAvatar(AiAvatarModel avatar) async {
    final repo = ref.read(aiAvatarRepositoryProvider);
    final updated = await repo.updateAvatar(avatar);
    state = AsyncData(updated);
  }

  /// 切换自动回复（PIPL: 用户必须手动操作）
  ///
  /// 开启前会检查 ai_consent_at 是否已授权，未授权则抛异常。
  /// 关闭时直接关闭，不需要额外检查。
  Future<void> toggleAutoReply(bool enabled) async {
    final avatar = state.valueOrNull;
    if (avatar == null) return;

    // PIPL 合规：开启自动回复必须已完成 AI 数据授权
    if (enabled && avatar.aiConsentAt == null) {
      throw Exception('请先完成 AI 数据处理授权');
    }

    final repo = ref.read(aiAvatarRepositoryProvider);
    final updated = await repo.toggleAutoReply(avatar.id, enabled);
    state = AsyncData(updated);
  }

  /// 判断当前分身是否应该触发自动回复
  ///
  /// 条件（全部满足）：
  /// 1. 分身存在
  /// 2. auto_reply_enabled = true
  /// 3. ai_consent_at 不为空（已授权）
  bool shouldAutoReply() {
    final avatar = state.valueOrNull;
    if (avatar == null) return false;
    return avatar.autoReplyEnabled && avatar.aiConsentAt != null;
  }

  /// 删除分身
  Future<void> deleteAvatar() async {
    final avatar = state.valueOrNull;
    if (avatar == null) return;

    final repo = ref.read(aiAvatarRepositoryProvider);
    await repo.deleteAvatar(avatar.id);
    state = const AsyncData(null);
  }

  /// 用户手动请求画像更新（PIPL 合规：必须经用户确认弹窗同意后调用）
  ///
  /// 调用 Edge Function 分析用户聊天/训练数据，更新 personality_traits、
  /// speaking_style、fitness_habits。
  /// 此方法仅在用户明确点击"更新画像"并确认后调用，不会自动触发。
  Future<void> requestProfileUpdate() async {
    final avatar = state.valueOrNull;
    if (avatar == null) return;

    // PIPL 合规：必须已完成 AI 数据授权
    if (avatar.aiConsentAt == null) {
      throw Exception('请先完成 AI 数据处理授权');
    }

    final repo = ref.read(aiAvatarRepositoryProvider);
    final updated = await repo.refreshAvatarProfile(avatar.id);
    state = AsyncData(updated);
  }

  /// @deprecated 使用 requestProfileUpdate 代替。
  /// 保留是为了兼容旧测试，后续版本移除。
  Future<void> refreshAvatarProfile() => requestProfileUpdate();
}

// ============================================================
// 心跳定时器 Provider — 定期更新 last_seen_at
// ============================================================
// 每 2 分钟向 profiles.last_seen_at 写入当前时间
// 用于离线检测：如果 last_seen_at > 5 分钟前，则认为用户离线
// 触发器据此判断是否执行自动回复

final heartbeatProvider = Provider<HeartbeatService>((ref) {
  final service = HeartbeatService(ref);

  // 监听认证状态 — 登录时启动心跳，登出时停止
  ref.listen(authStateProvider, (prev, next) {
    final isLoggedIn = next.valueOrNull != null;
    if (isLoggedIn) {
      service.start();
    } else {
      service.stop();
    }
  });

  // Provider dispose 时停止心跳
  ref.onDispose(() => service.stop());

  return service;
});

class HeartbeatService {
  final Ref _ref;
  Timer? _timer;

  /// 心跳间隔（2 分钟）
  static const _interval = Duration(minutes: 2);

  HeartbeatService(this._ref);

  /// 启动心跳定时器
  /// 使用 _timer != null 作为原子守卫：cancel 后再创建，保证单例
  void start() {
    if (_timer != null) return; // 已在运行，幂等
    // 立即执行一次
    _tick();
    _timer = Timer.periodic(_interval, (_) => _tick());
  }

  /// 停止心跳
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// 单次心跳：更新 last_seen_at
  Future<void> _tick() async {
    try {
      final repo = _ref.read(aiAvatarRepositoryProvider);
      await repo.updateLastSeen();
    } catch (_) {
      // 心跳失败不中断应用，静默忽略
    }
  }

  /// 当前是否在运行
  bool get isRunning => _timer != null;
}

// ============================================================
// 自动回复状态 Provider — 追踪自动回复是否激活
// ============================================================
// 用于 UI 显示"AI 正在替你回复…"状态条
// 综合判断：分身存在 + 开启自动回复 + 已授权

final autoReplyActiveProvider = Provider<bool>((ref) {
  final avatarAsync = ref.watch(currentAiAvatarProvider);
  final avatar = avatarAsync.valueOrNull;
  if (avatar == null) return false;
  return avatar.autoReplyEnabled && avatar.aiConsentAt != null;
});

// ============================================================
// 画像更新状态 Provider — 追踪"分身正在学习"状态
// ============================================================
// 用于 UI 显示"分身正在学习你的习惯…"提示

final isUpdatingProfileProvider = StateProvider<bool>((ref) => false);

// ============================================================
// 分身聊天消息模型
// ============================================================

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  /// 是否为 AI 自动生成（离线自动回复产生）
  final bool isAiGenerated;

  /// AI 分身名称（仅 isAiGenerated=true 时有值）
  final String? avatarName;

  /// 是否被内容审核过滤（AI 回复不合规时标记）
  final bool isContentFiltered;

  ChatMessage({
    String? id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isAiGenerated = false,
    this.avatarName,
    this.isContentFiltered = false,
  }) : id = id ??
            '${DateTime.now().millisecondsSinceEpoch}_${isUser ? 'u' : 'a'}';

  /// 从 Supabase messages 行构造（用于 Realtime 接收到的自动回复消息）
  factory ChatMessage.fromSupabaseMessage(Map<String, dynamic> json,
      {required String currentUserId}) {
    final metadata = json['metadata'] as Map<String, dynamic>?;
    final isAi = metadata?['is_ai_generated'] == true;
    final String? avatarNameValue =
        isAi ? (metadata?['avatar_name'] as String?) : null;
    final isFiltered = metadata?['content_filtered'] == true;

    return ChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      isUser: json['sender_id'] == currentUserId && !isAi,
      timestamp: DateTime.parse(json['created_at'] as String),
      isAiGenerated: isAi,
      avatarName: avatarNameValue,
      isContentFiltered: isFiltered,
    );
  }
}

/// 分身聊天状态（消息列表 + 是否正在输入）
class AiAvatarChatState {
  final List<ChatMessage> messages;
  final bool isTyping;
  final bool isLoadingHistory;

  /// 上次分页加载是否失败（true 时在列表顶部显示重试提示）
  final bool historyLoadFailed;

  const AiAvatarChatState({
    this.messages = const [],
    this.isTyping = false,
    this.isLoadingHistory = false,
    this.historyLoadFailed = false,
  });

  AiAvatarChatState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    bool? isLoadingHistory,
    bool? historyLoadFailed,
  }) {
    return AiAvatarChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      historyLoadFailed: historyLoadFailed ?? this.historyLoadFailed,
    );
  }
}

// ============================================================
// 分身聊天 Provider
// 【性能优化】使用 AiAvatarChatState 管理完整聊天状态
// 支持分页加载历史消息（limit 20 + 时间游标分页）
// ============================================================

final aiAvatarChatProvider =
    StateNotifierProvider<AiAvatarChatNotifier, AiAvatarChatState>(
  (ref) => AiAvatarChatNotifier(ref),
);

class AiAvatarChatNotifier extends StateNotifier<AiAvatarChatState> {
  final Ref _ref;

  /// 每页加载条数
  static const _pageSize = 20;

  /// 是否还有更早的历史消息
  bool _hasMoreHistory = true;

  /// 是否正在加载中（防重复）
  bool _isLoadingHistory = false;

  /// 串行化发送队列：同时只允许一条消息在途，避免并发写 state.messages 丢消息
  bool _isSendingMessage = false;

  bool get hasMoreHistory => _hasMoreHistory;

  AiAvatarChatNotifier(this._ref) : super(const AiAvatarChatState());

  /// 内容审核过滤回复的固定模板（与 Edge Function 一致）
  static const _filteredReplyTemplate = '分身暂时无法回复，请稍后尝试。';

  /// 发送消息并获取 AI 回复
  Future<void> sendMessage(String message) async {
    // 串行化：上一条消息还在途时，直接返回（UI 层同样有 _isSending 守卫）
    if (_isSendingMessage) return;
    _isSendingMessage = true;

    final avatar = _ref.read(currentAiAvatarProvider).valueOrNull;
    if (avatar == null) {
      _isSendingMessage = false;
      return;
    }

    // 添加用户消息，并在 await 前快照此时的历史，防止 await 期间 state 被别处修改
    final userMsg = ChatMessage(
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    );
    final messagesBeforeSend = [...state.messages, userMsg];
    state = state.copyWith(
      messages: messagesBeforeSend,
      isTyping: true,
    );

    // history 快照：基于 await 前的消息列表，不含刚加入的 userMsg
    final history = state.messages
        .where((m) => m.id != userMsg.id) // 排除刚加的 userMsg
        .map((m) => <String, String>{
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.content,
            })
        .toList();

    try {
      final repo = _ref.read(aiAvatarRepositoryProvider);
      final reply = await repo.chatWithAvatar(
        avatarId: avatar.id,
        message: message,
        history: history,
      );

      // 检测是否为过滤模板回复
      final isFiltered = reply == _filteredReplyTemplate;

      // 追加 AI 回复：在 await 结束后取最新 state，避免覆盖 await 期间新增的消息
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(
            content: reply,
            isUser: false,
            timestamp: DateTime.now(),
            isContentFiltered: isFiltered,
          ),
        ],
        isTyping: false,
      );
    } catch (e) {
      // 网络失败时显示错误提示消息
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(
            content: '抱歉，我暂时无法回复，请稍后再试。',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ],
        isTyping: false,
      );
    } finally {
      _isSendingMessage = false;
    }
  }

  /// 添加收到的自动回复消息（由 Realtime 订阅推送）
  void addAutoReplyMessage(ChatMessage message) {
    state = state.copyWith(messages: [...state.messages, message]);
  }

  /// 【性能优化】分页加载历史消息
  /// 使用时间游标分页（取当前最早消息的 timestamp 作为游标）
  /// 每次加载 20 条，不足 20 条说明到顶
  Future<void> loadHistory({int limit = _pageSize}) async {
    if (_isLoadingHistory || !_hasMoreHistory) return;
    _isLoadingHistory = true;

    // 更新 UI 状态：仅显示 loading indicator（不在此清除失败标记，
    // 避免 avatar==null 早返回时意外清除，导致重试 UI 消失但未真正加载）
    state = state.copyWith(isLoadingHistory: true);

    try {
      final avatar = _ref.read(currentAiAvatarProvider).valueOrNull;
      if (avatar == null) {
        _isLoadingHistory = false;
        // 分身未加载时不清除 historyLoadFailed，避免重试 UI 意外消失
        state = state.copyWith(isLoadingHistory: false);
        return;
      }

      // 确认将实际发起请求后，清除上次失败标记
      state = state.copyWith(historyLoadFailed: false);

      // 时间游标：在 await 前快照，避免 await 期间 state.messages 被 sendMessage 修改
      // 导致 cursor 过期、历史消息重复或缺失
      final DateTime? cursor = state.messages.isNotEmpty
          ? state.messages.first.timestamp
          : null;

      // 同理，提前快照 currentUserId，避免 await 期间认证状态变化返回空 ID
      final currentUserId =
          _ref.read(currentAiAvatarProvider).valueOrNull?.userId ?? '';

      final repo = _ref.read(aiAvatarRepositoryProvider);
      final rows = await repo.getChatHistory(
        avatarId: avatar.id,
        limit: limit,
        beforeTimestamp: cursor,
      );

      if (rows.length < limit) {
        _hasMoreHistory = false;
      }

      if (rows.isNotEmpty) {
        // 将 DB 行转换为 ChatMessage，按时间正序排列（prepend 到列表头部）
        final historyMessages = rows
            .map((row) =>
                ChatMessage.fromSupabaseMessage(row, currentUserId: currentUserId))
            .toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

        // 去重：过滤掉已在当前 state 中存在的消息 ID，防止与 sendMessage 并发时产生重复
        final existingIds = state.messages.map((m) => m.id).toSet();
        final dedupedHistory =
            historyMessages.where((m) => !existingIds.contains(m.id)).toList();

        state = state.copyWith(
          messages: [...dedupedHistory, ...state.messages],
          isLoadingHistory: false,
        );
      } else {
        state = state.copyWith(isLoadingHistory: false);
      }
    } catch (_) {
      // 加载失败：暴露错误状态，让 UI 显示重试提示
      state = state.copyWith(
        isLoadingHistory: false,
        historyLoadFailed: true,
      );
    } finally {
      _isLoadingHistory = false;
    }
  }

  /// 重试加载历史消息（在 loadHistory 失败后调用）
  Future<void> retryLoadHistory() async {
    state = state.copyWith(historyLoadFailed: false);
    await loadHistory();
  }

  /// 清空聊天记录
  void clearChat() {
    _hasMoreHistory = true;
    _isLoadingHistory = false;
    state = const AiAvatarChatState();
  }
}

// ============================================================
// 分身分享 Provider
// ============================================================

final aiAvatarShareProvider =
    StateNotifierProvider<AiAvatarShareNotifier, AsyncValue<void>>(
  (ref) => AiAvatarShareNotifier(ref),
);

class AiAvatarShareNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  AiAvatarShareNotifier(this._ref) : super(const AsyncData(null));

  /// 分享分身，返回分享链接 URL
  Future<String?> shareAvatar({
    required String avatarId,
    required String targetType,
    String? targetId,
  }) async {
    state = const AsyncLoading();

    try {
      final repo = _ref.read(aiAvatarRepositoryProvider);
      final result = await repo.shareAvatar(
        avatarId: avatarId,
        targetType: targetType,
        targetId: targetId,
      );

      state = const AsyncData(null);
      return result;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }
}

// ============================================================
// 分享链接查看 Provider（根据 share_token 获取公开信息）
// ============================================================

final sharedAvatarProvider =
    FutureProvider.family<Map<String, dynamic>?, String>(
  (ref, shareToken) async {
    final repo = ref.read(aiAvatarRepositoryProvider);
    return repo.getSharedAvatar(shareToken);
  },
);
