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
  bool _isRunning = false;

  /// 心跳间隔（2 分钟）
  static const _interval = Duration(minutes: 2);

  HeartbeatService(this._ref);

  /// 启动心跳定时器
  void start() {
    if (_isRunning) return;
    _isRunning = true;

    // 立即执行一次
    _tick();

    // 每 2 分钟执行一次
    _timer = Timer.periodic(_interval, (_) => _tick());
  }

  /// 停止心跳
  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
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
  bool get isRunning => _isRunning;
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

  const AiAvatarChatState({
    this.messages = const [],
    this.isTyping = false,
    this.isLoadingHistory = false,
  });

  AiAvatarChatState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    bool? isLoadingHistory,
  }) {
    return AiAvatarChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
    );
  }
}

// ============================================================
// 分身聊天 Provider
// ============================================================

final aiAvatarChatProvider =
    StateNotifierProvider<AiAvatarChatNotifier, List<ChatMessage>>(
  (ref) => AiAvatarChatNotifier(ref),
);

class AiAvatarChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref _ref;

  AiAvatarChatNotifier(this._ref) : super([]);

  /// 内容审核过滤回复的固定模板（与 Edge Function 一致）
  static const _filteredReplyTemplate = '分身暂时无法回复，请稍后尝试。';

  /// 发送消息并获取 AI 回复
  Future<void> sendMessage(String message) async {
    final avatar = _ref.read(currentAiAvatarProvider).valueOrNull;
    if (avatar == null) return;

    // 添加用户消息
    state = [
      ...state,
      ChatMessage(content: message, isUser: true, timestamp: DateTime.now()),
    ];

    // 构造对话历史（发送给 Edge Function）
    final history = state
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
        history: history.sublist(0, history.length - 1), // 不含最新一条
      );

      // 检测是否为过滤模板回复
      final isFiltered = reply == _filteredReplyTemplate;

      // 添加 AI 回复
      state = [
        ...state,
        ChatMessage(
          content: reply,
          isUser: false,
          timestamp: DateTime.now(),
          isContentFiltered: isFiltered,
        ),
      ];
    } catch (e) {
      // 网络失败时显示错误提示消息
      state = [
        ...state,
        ChatMessage(
          content: '抱歉，我暂时无法回复，请稍后再试。',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ];
    }
  }

  /// 添加收到的自动回复消息（由 Realtime 订阅推送）
  void addAutoReplyMessage(ChatMessage message) {
    state = [...state, message];
  }

  /// 加载历史消息（从本地缓存或远端加载，预留接口）
  Future<void> loadHistory({int limit = 20}) async {
    // 预留：从 Supabase 加载历史聊天记录
    // 目前 MVP 聊天记录仅保存在内存中
  }

  /// 清空聊天记录
  void clearChat() {
    state = [];
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
