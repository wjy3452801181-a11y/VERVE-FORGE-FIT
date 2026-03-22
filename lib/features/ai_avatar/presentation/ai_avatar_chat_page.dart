import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/extensions/context_extensions.dart';
import '../domain/ai_avatar_model.dart';
import '../providers/ai_avatar_provider.dart';
import 'widgets/ai_generated_badge.dart';

/// AI 分身聊天页 — 玻璃拟态风格（性能优化版）
///
/// 优化内容：
/// 1. 不对称圆角气泡（用户右上 24dp，AI 左上 24dp）
/// 2. 动态思考文字（随机切换 3 种提示）
/// 3. 快捷短语栏 + 智能推荐按钮
/// 4. 空状态渐变进度条 + "分身正在学习你的习惯…"
/// 5. 语音按钮 + 发送按钮圆形渐变脉冲动画
/// 6. 页面顶部 AI 免责声明提示
///
/// 【性能优化新增】
/// 7. 分页加载历史消息（limit 20 + 时间游标），滚动到顶部自动加载
/// 8. 骨架屏占位 + 顶部加载指示器
/// 9. 输入框 setState 抽取为 ValueListenableBuilder，减少整页 rebuild
/// 10. 动画仅在页面可见时运行（WidgetsBindingObserver）
class AiAvatarChatPage extends ConsumerStatefulWidget {
  const AiAvatarChatPage({super.key});

  @override
  ConsumerState<AiAvatarChatPage> createState() => _AiAvatarChatPageState();
}

class _AiAvatarChatPageState extends ConsumerState<AiAvatarChatPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;
  bool _showQuickPhrases = false;
  /// 【性能优化】_isLoadingHistory 改由 Provider state 驱动
  /// 页面仅保留 _initialLoaded 标记，用于首次进入时加载历史
  bool _initialLoaded = false;

  /// 是否显示「滚到底部」FAB（用户向上滑动超过 100px 时出现）
  bool _showScrollToBottom = false;

  /// 本次会话发送计数（用于提示用户可手动更新画像）
  int _sessionMessageCount = 0;

  /// 画像更新提示阈值：每发送 5 条消息提醒一次
  static const _profileHintThreshold = 5;

  /// AI 消息发光脉冲动画
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  /// 发送按钮渐变脉冲动画
  late final AnimationController _sendPulseController;
  late final Animation<double> _sendPulseAnimation;

  @override
  void initState() {
    super.initState();
    // 【性能优化】注册生命周期观察，页面不可见时暂停动画
    WidgetsBinding.instance.addObserver(this);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.15, end: 0.4).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // 发送按钮脉冲（持续旋转渐变光晕）
    _sendPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _sendPulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sendPulseController, curve: Curves.linear),
    );

    // 【性能优化】不再用 addListener + setState 监听输入框
    // 改用 ValueListenableBuilder 局部更新发送按钮（见 _buildInputArea）

    // 【性能优化】首次进入时加载历史消息
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialLoaded) {
        _initialLoaded = true;
        ref.read(aiAvatarChatProvider.notifier).loadHistory();
      }
    });

    // 「滚到底部」FAB：当用户离底部超过 100px 时显示
    _scrollController.addListener(_onScrollChanged);
  }

  void _onScrollChanged() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final distanceFromBottom = pos.maxScrollExtent - pos.pixels;
    final shouldShow = distanceFromBottom > 100;
    if (shouldShow != _showScrollToBottom) {
      setState(() => _showScrollToBottom = shouldShow);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    _glowController.dispose();
    _sendPulseController.dispose();
    super.dispose();
  }

  /// 【性能优化】页面不可见时暂停动画，可见时恢复
  /// 避免后台页面持续消耗 CPU
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _glowController.stop();
      _sendPulseController.stop();
    } else if (state == AppLifecycleState.resumed) {
      _glowController.repeat(reverse: true);
      _sendPulseController.repeat();
    }
  }

  /// 获取动态思考文字列表
  List<String> _thinkingTexts() => [
        context.l10n.aiChatThinkingWorkout,
        context.l10n.aiChatThinkingReply,
        context.l10n.aiChatThinkingAnalyze,
      ];

  @override
  Widget build(BuildContext context) {
    final avatar = ref.watch(currentAiAvatarProvider).valueOrNull;
    // 【性能优化】使用 select 仅监听 messages 列表引用变化
    final chatState = ref.watch(aiAvatarChatProvider);
    final messages = chatState.messages;
    final isLoadingHistory = chatState.isLoadingHistory;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 解析预设 emoji 头像
    final avatarEmoji = _resolveAvatarEmoji(avatar);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // AppBar 中的迷你头像
            _buildMiniAvatar(avatar, avatarEmoji, size: 32),
            AppSpacing.hGap10,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  avatar?.name ?? context.l10n.aiAvatarChat,
                  style: AppTextStyles.subtitle.copyWith(fontSize: 15),
                ),
                Text(
                  context.l10n.aiGeneratedLabel,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.info,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // 清空聊天
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, size: 22),
            tooltip: context.l10n.aiChatClear,
            onPressed: messages.isEmpty
                ? null
                : () => _showClearDialog(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0D0D0D),
                    const Color(0xFF0F1624),
                    const Color(0xFF0D1117),
                  ]
                : [
                    const Color(0xFFF8F9FA),
                    const Color(0xFFE8EAF6),
                    const Color(0xFFEDE7F6),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 优化 6：AI 免责声明提示条
              _buildDisclaimer(isDark),

              // 自动回复激活提示条
              if (ref.watch(autoReplyActiveProvider))
                _buildAutoReplyBanner(isDark),

              // 消息列表 + 「滚到底部」FAB
              // 【性能优化】初次加载历史时显示骨架屏
              Expanded(
                child: Stack(
                  children: [
                    messages.isEmpty && !_isSending && isLoadingHistory
                        ? const _ChatSkeletonList()
                        : messages.isEmpty && !_isSending
                            ? _buildEmptyState(context, avatarEmoji)
                            : _buildMessageList(
                                messages, avatar, avatarEmoji, isLoadingHistory),

                    // 「滚到底部」FAB — 用户向上滑超过 100px 时出现
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      bottom: _showScrollToBottom ? 12 : -56,
                      right: 12,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: _showScrollToBottom ? 1.0 : 0.0,
                        child: Tooltip(
                          message: '回到最新消息',
                          child: FloatingActionButton.small(
                            heroTag: 'chat_scroll_to_bottom',
                            backgroundColor: AppColors.info,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            onPressed: _scrollToBottom,
                            child: const Icon(Icons.keyboard_arrow_down_rounded, size: 22),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 快捷短语栏
              if (_showQuickPhrases) _buildQuickPhrases(),

              // 输入区域
              _buildInputArea(context),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 优化 6：免责声明提示条
  // ============================================================
  Widget _buildDisclaimer(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.x6),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.info.withValues(alpha: 0.08)
            : AppColors.info.withValues(alpha: 0.06),
        border: Border(
          bottom: BorderSide(
            color: AppColors.info.withValues(alpha: 0.12),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 12,
            color: AppColors.info.withValues(alpha: 0.6),
          ),
          AppSpacing.hGapXS,
          Text(
            context.l10n.aiChatDisclaimer,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.info.withValues(alpha: 0.6),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 自动回复激活提示条 — "AI 分身正在替你回复消息"
  // ============================================================
  Widget _buildAutoReplyBanner(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.info.withValues(alpha: isDark ? 0.15 : 0.1),
            AppColors.info.withValues(alpha: isDark ? 0.08 : 0.05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border(
          bottom: BorderSide(
            color: AppColors.info.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // 脉冲动画圆点
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, _) {
              return Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.info,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.info
                          .withValues(alpha: _glowAnimation.value),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              );
            },
          ),
          AppSpacing.hGapSM,
          const Icon(
            Icons.smart_toy_outlined,
            size: 14,
            color: AppColors.info,
          ),
          AppSpacing.hGapXS,
          Expanded(
            child: Text(
              context.l10n.aiAutoReplyActive,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.info,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 优化 4：空状态 — 渐变进度条 + "分身正在学习你的习惯…"
  // ============================================================
  Widget _buildEmptyState(BuildContext context, String? avatarEmoji) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 大号分身头像
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.info.withValues(alpha: 0.1),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.info.withValues(alpha: 0.15),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: Text(
                avatarEmoji ?? '🤖',
                style: const TextStyle(fontSize: 36),
              ),
            ),
          ),
          AppSpacing.vGap20,
          Text(
            context.l10n.aiChatNoMessages,
            style: AppTextStyles.subtitle,
          ),
          AppSpacing.vGapSM,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              context.l10n.aiAvatarChatIntro,
              style: AppTextStyles.caption.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          AppSpacing.vGapLG,

          // 渐变进度条 + 学习提示
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64),
            child: Column(
              children: [
                // 渐变进度条（无限循环动画）
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 4,
                    child: AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, _) {
                        return LinearProgressIndicator(
                          value: null, // 不确定模式
                          backgroundColor:
                              AppColors.info.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation(
                            AppColors.info.withValues(
                              alpha: 0.3 + _glowAnimation.value * 0.5,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                AppSpacing.vGap10,
                Text(
                  context.l10n.aiChatEmptyLearning,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.info.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 消息列表 — 包含滑动加载历史防冲突
  // 【性能优化】isLoadingHistory 改由 Provider 驱动
  // ============================================================
  Widget _buildMessageList(
    List<ChatMessage> messages,
    AiAvatarModel? avatar,
    String? avatarEmoji,
    bool isLoadingHistory,
  ) {
    return NotificationListener<ScrollNotification>(
      // 拦截滚动通知，避免手势冲突并处理上拉加载历史
      onNotification: (notification) =>
          _onScrollNotification(notification),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        itemCount: messages.length +
            (_isSending ? 1 : 0) +
            (isLoadingHistory ? 1 : 0),
        reverse: false,
        // 禁用平台默认的过度滚动手势以避免与气泡长按冲突
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          // 顶部：加载历史指示器
          if (isLoadingHistory && index == 0) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.info,
                  ),
                ),
              ),
            );
          }

          // 调整实际消息索引
          final msgIndex = isLoadingHistory ? index - 1 : index;

          // 末尾：思考中气泡
          if (msgIndex == messages.length && _isSending) {
            return _buildThinkingBubble(avatarEmoji);
          }
          if (msgIndex < 0 || msgIndex >= messages.length) {
            return const SizedBox.shrink();
          }
          final msg = messages[msgIndex];

          // 内容被审核过滤的消息显示为灰色系统提示
          if (msg.isContentFiltered) {
            return _buildFilteredMessage(msg);
          }

          return msg.isUser
              ? _buildUserBubble(msg)
              : _buildAiBubble(msg, avatar, avatarEmoji);
        },
      ),
    );
  }

  /// 处理滚动通知 — 滚动到顶部时触发加载历史
  /// 【性能优化】加载状态由 Provider 管理，不再用本地 setState
  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      // 滑动到列表顶部 50px 以内时触发加载历史
      final chatState = ref.read(aiAvatarChatProvider);
      if (notification.metrics.pixels < 50 && !chatState.isLoadingHistory) {
        ref.read(aiAvatarChatProvider.notifier).loadHistory();
      }
    }
    // 返回 false 允许通知继续传播，避免阻断 ListView 自身手势
    return false;
  }

  // _loadMoreHistory 已移除 — 逻辑统一到 Provider.loadHistory()

  // ============================================================
  // 优化 1：用户消息气泡 — 不对称圆角（右上 24dp，其余 12dp）
  //         + 长按复制消息
  // ============================================================
  Widget _buildUserBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.x6, bottom: AppSpacing.x6, left: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            // 使用 GestureDetector 而非 RawGestureDetector，避免手势超时
            child: GestureDetector(
              onLongPress: () => _copyMessage(message.content),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.x10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFFFF8A5C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(24),
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  message.content,
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 优化 1：AI 消息气泡 — 不对称圆角（左上 24dp，其余 12dp）
  //         + 蓝色发光边框 + 玻璃拟态 + AI 徽章
  //         + 长按复制消息
  // ============================================================
  Widget _buildAiBubble(
    ChatMessage message,
    AiAvatarModel? avatar,
    String? avatarEmoji,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 不对称圆角：AI 消息左上 24dp，其余 12dp
    const aiBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(24),
      topRight: Radius.circular(12),
      bottomLeft: Radius.circular(12),
      bottomRight: Radius.circular(12),
    );

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.x6, bottom: AppSpacing.x6, right: 48),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI 头像
          _buildMiniAvatar(avatar, avatarEmoji, size: 36),
          AppSpacing.hGap10,

          // 消息体
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 使用 GestureDetector 包裹整个气泡区域
                GestureDetector(
                  onLongPress: () => _copyMessage(message.content),
                  child: AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: aiBorderRadius,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.info
                                  .withValues(alpha: _glowAnimation.value),
                              blurRadius: 16,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: child,
                      );
                    },
                    child: ClipRRect(
                      borderRadius: aiBorderRadius,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.white.withValues(alpha: 0.75),
                            borderRadius: aiBorderRadius,
                            border: Border.all(
                              color: AppColors.info.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            message.content,
                            style: AppTextStyles.body.copyWith(
                              color: context.colorScheme.onSurface,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // AI 标记徽章（自动回复时显示特殊标记）
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: message.isAiGenerated
                      ? AiGeneratedBadge(
                          expanded: true,
                          avatarName: message.avatarName,
                        )
                      : const AiGeneratedBadge(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 内容审核过滤消息 — 灰色系统提示样式
  // ============================================================
  Widget _buildFilteredMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppSpacing.x12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shield_outlined,
                size: 14,
                color: Colors.grey[500],
              ),
              AppSpacing.hGapXS,
              Flexible(
                child: Text(
                  context.l10n.aiReplyFilteredHint,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 优化 2：思考中气泡 — 三个跳动圆点 + 动态文字切换
  // ============================================================
  Widget _buildThinkingBubble(String? avatarEmoji) {
    // 不对称圆角与 AI 气泡一致
    const thinkingRadius = BorderRadius.only(
      topLeft: Radius.circular(24),
      topRight: Radius.circular(12),
      bottomLeft: Radius.circular(12),
      bottomRight: Radius.circular(12),
    );

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.x6, bottom: AppSpacing.x6, right: 48),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMiniAvatar(
            ref.read(currentAiAvatarProvider).valueOrNull,
            avatarEmoji,
            size: 36,
          ),
          AppSpacing.hGap10,
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: AppSpacing.x12),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest,
              borderRadius: thinkingRadius,
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                AppSpacing.hGapXS,
                _buildDot(1),
                AppSpacing.hGapXS,
                _buildDot(2),
                AppSpacing.hGapSM,
                // 动态文字轮播
                _DynamicThinkingText(texts: _thinkingTexts()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 跳动圆点 — 复用 _glowController（repeat 动画），通过 index 错开相位
  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        // _glowController.value 从 0→1→0 循环（repeat + reverse）
        // 通过 index 错开相位，产生波浪效果
        final phase = (_glowController.value + index * 0.3) % 1.0;
        final dy = -4.0 * sin(phase * pi);
        return Transform.translate(
          offset: Offset(0, dy),
          child: child,
        );
      },
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.info.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  // ============================================================
  // 优化 3：快捷短语栏 + 智能推荐按钮
  // ============================================================
  Widget _buildQuickPhrases() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // 智能推荐按钮
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              avatar: const Icon(
                Icons.auto_awesome,
                size: 16,
                color: AppColors.info,
              ),
              label: Text(
                context.l10n.aiChatSmartRecommend,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: AppColors.info.withValues(alpha: 0.1),
              side: BorderSide(
                color: AppColors.info.withValues(alpha: 0.3),
              ),
              onPressed: _onSmartRecommend,
            ),
          ),
          // 固定快捷短语
          ..._quickPhraseList().map((phrase) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                label: Text(
                  phrase,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                backgroundColor:
                    AppColors.primary.withValues(alpha: 0.08),
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
                onPressed: () {
                  _messageController.text = phrase;
                  _messageController.selection = TextSelection.fromPosition(
                    TextPosition(offset: phrase.length),
                  );
                  setState(() => _showQuickPhrases = false);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 快捷短语列表
  List<String> _quickPhraseList() {
    return [
      context.l10n.aiChatQuickLegDay,
      context.l10n.aiChatQuickRan5k,
      context.l10n.aiChatQuickFeelSore,
      context.l10n.aiChatQuickRestDay,
      context.l10n.aiChatQuickNewPR,
    ];
  }

  /// 智能推荐 — 根据时间上下文推荐短语
  void _onSmartRecommend() {
    final hour = DateTime.now().hour;
    String recommended;
    if (hour < 10) {
      // 早晨
      recommended = context.l10n.aiChatQuickRan5k;
    } else if (hour < 14) {
      // 中午
      recommended = context.l10n.aiChatQuickLegDay;
    } else if (hour < 18) {
      // 下午
      recommended = context.l10n.aiChatQuickNewPR;
    } else {
      // 晚上
      recommended = context.l10n.aiChatQuickRestDay;
    }
    _messageController.text = recommended;
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: recommended.length),
    );
    setState(() => _showQuickPhrases = false);
  }

  // ============================================================
  // 优化 5 + 【性能优化 9】：输入区域
  // 使用 ValueListenableBuilder 局部更新发送按钮状态
  // 避免每次键入触发整页 rebuild
  // ============================================================
  Widget _buildInputArea(BuildContext context) {
    final isDark = Theme.of(this.context).brightness == Brightness.dark;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x12, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.6),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // 快捷短语开关
              IconButton(
                icon: Icon(
                  _showQuickPhrases
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.flash_on_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                tooltip: context.l10n.aiChatQuickPhrases,
                onPressed: () {
                  setState(() => _showQuickPhrases = !_showQuickPhrases);
                },
              ),

              // 语音按钮（预留 Speech-to-Text 接口）
              IconButton(
                icon: Icon(
                  Icons.mic_none_rounded,
                  color: context.colorScheme.onSurfaceVariant,
                  size: 22,
                ),
                tooltip: context.l10n.aiChatVoice,
                onPressed: () {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.aiChatVoiceComingSoon),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),

              // 文本输入
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                      hintText: context.l10n.aiAvatarChatHint,
                      hintStyle: AppTextStyles.body.copyWith(
                        color: this.context.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              AppSpacing.hGapSM,

              // 【性能优化 9】发送按钮使用 ValueListenableBuilder
              // 仅在输入内容变化时 rebuild 此按钮，不触发整页 setState
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _messageController,
                builder: (context, value, _) {
                  final hasText = value.text.trim().isNotEmpty;
                  return AnimatedBuilder(
                    animation: _sendPulseAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            startAngle:
                                _sendPulseAnimation.value * 2 * pi,
                            endAngle:
                                _sendPulseAnimation.value * 2 * pi +
                                    2 * pi,
                            colors: hasText && !_isSending
                                ? const [
                                    AppColors.primary,
                                    Color(0xFFFF8A5C),
                                    Color(0xFFFFB347),
                                    AppColors.primary,
                                  ]
                                : [
                                    Colors.grey.shade400,
                                    Colors.grey.shade300,
                                    Colors.grey.shade400,
                                    Colors.grey.shade400,
                                  ],
                          ),
                          boxShadow: hasText && !_isSending
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: IconButton(
                          onPressed: _isSending || !hasText
                              ? null
                              : _sendMessage,
                          padding: EdgeInsets.zero,
                          icon: _isSending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send_rounded,
                                  color: Colors.white, size: 20),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 辅助方法
  // ============================================================

  /// 构建迷你头像（支持预设 emoji 和网络图片）
  Widget _buildMiniAvatar(
    AiAvatarModel? avatar,
    String? emoji, {
    required double size,
  }) {
    final isPreset =
        avatar?.avatarUrl != null && avatar!.avatarUrl!.startsWith('preset:');

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.info.withValues(alpha: 0.12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Center(
        child: isPreset || avatar?.avatarUrl == null
            ? Text(
                emoji ?? '🤖',
                style: TextStyle(fontSize: size * 0.5),
              )
            : ClipOval(
                child: Image.network(
                  avatar!.avatarUrl!,
                  width: size - 3,
                  height: size - 3,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Text(
                    emoji ?? '🤖',
                    style: TextStyle(fontSize: size * 0.5),
                  ),
                ),
              ),
      ),
    );
  }

  /// 从 avatarUrl (preset:xxx) 解析 emoji
  String? _resolveAvatarEmoji(AiAvatarModel? avatar) {
    if (avatar?.avatarUrl == null) return null;
    final url = avatar!.avatarUrl!;
    if (!url.startsWith('preset:')) return null;
    final key = url.substring(7);
    final preset = AiAvatarModel.presetAvatars
        .where((p) => p.key == key)
        .firstOrNull;
    return preset?.emoji;
  }

  /// 发送消息
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    setState(() {
      _isSending = true;
      _showQuickPhrases = false;
    });

    await ref.read(aiAvatarChatProvider.notifier).sendMessage(text);

    if (mounted) {
      setState(() => _isSending = false);
      _scrollToBottom();

      // 每发送 N 条消息，提示用户可在详情页手动更新画像
      _sessionMessageCount++;
      if (_sessionMessageCount >= _profileHintThreshold) {
        _sessionMessageCount = 0;
        _showProfileUpdateHint();
      }
    }
  }

  /// 提示用户可在分身详情页手动更新画像（不自动触发，遵守 PIPL）
  void _showProfileUpdateHint() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.psychology_outlined,
                size: 16, color: Colors.white),
            AppSpacing.hGapSM,
            Expanded(
              child: Text(context.l10n.aiProfileUpdateHint),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.info.withValues(alpha: 0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.x10),
        ),
      ),
    );
  }

  /// 长按复制消息到剪贴板 — 带缩放 + 勾号反馈动画
  void _copyMessage(String content) {
    Clipboard.setData(ClipboardData(text: content));
    if (!mounted) return;

    // 使用 OverlayEntry 在气泡位置显示"缩放+勾号"动画
    // 在此处快照 overlay 和 messenger，避免 OverlayEntry 回调时 context 已失效
    final overlay = Overlay.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final copiedText = context.l10n.aiChatCopied;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _CopyFeedbackOverlay(
        onComplete: () {
          if (entry.mounted) entry.remove();
        },
      ),
    );
    overlay.insert(entry);

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, size: 16, color: Colors.white),
            AppSpacing.hGapSM,
            Text(copiedText),
          ],
        ),
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.secondary.withValues(alpha: 0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.x10),
        ),
      ),
    );
  }

  /// 滚动到底部
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// 确认清空聊天记录
  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.commonDelete),
        content: Text(context.l10n.aiAvatarDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(aiAvatarChatProvider.notifier).clearChat();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(context.l10n.commonDelete),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// 优化 2：动态思考文字组件 — 自动轮播 3 种提示
// ================================================================
class _DynamicThinkingText extends StatefulWidget {
  final List<String> texts;

  const _DynamicThinkingText({required this.texts});

  @override
  State<_DynamicThinkingText> createState() => _DynamicThinkingTextState();
}

class _DynamicThinkingTextState extends State<_DynamicThinkingText>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // 随机 3–8 秒切换思考文字，避免重复感
    _startRotation();
  }

  void _startRotation() {
    final delayMs = 3000 + _rng.nextInt(5001); // 3000–8000ms
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (!mounted) return;
      // 控制器可能在 delay 期间已被 dispose，forward() 前先检查
      if (!_fadeController.isCompleted && _fadeController.duration != null) {
        _fadeController.forward().then((_) {
          if (!mounted) return;
          // 随机选一个不同于当前的索引
          int next;
          if (widget.texts.length <= 1) {
            next = 0;
          } else {
            do {
              next = _rng.nextInt(widget.texts.length);
            } while (next == _currentIndex);
          }
          setState(() => _currentIndex = next);
          _fadeController.reverse();
          _startRotation();
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: ReverseAnimation(_fadeAnimation),
      child: Text(
        widget.texts[_currentIndex],
        style: AppTextStyles.caption.copyWith(
          fontStyle: FontStyle.italic,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ================================================================
// 复制成功反馈 Overlay — 屏幕中央缩放 + 勾号淡出动画
// ================================================================
class _CopyFeedbackOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const _CopyFeedbackOverlay({required this.onComplete});

  @override
  State<_CopyFeedbackOverlay> createState() => _CopyFeedbackOverlayState();
}

class _CopyFeedbackOverlayState extends State<_CopyFeedbackOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.85),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// 【性能优化 8】聊天骨架屏 — 首次加载历史时的 Shimmer 占位
// 模拟交替气泡布局（左侧 AI + 右侧用户）
// ================================================================

class _ChatSkeletonList extends StatelessWidget {
  const _ChatSkeletonList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
      highlightColor:
          isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Column(
          children: [
            // 模拟 5 条交替气泡
            _ChatBubbleSkeleton(isUser: false, width: 200),
            SizedBox(height: 12),
            _ChatBubbleSkeleton(isUser: true, width: 160),
            SizedBox(height: 12),
            _ChatBubbleSkeleton(isUser: false, width: 240),
            SizedBox(height: 12),
            _ChatBubbleSkeleton(isUser: true, width: 120),
            SizedBox(height: 12),
            _ChatBubbleSkeleton(isUser: false, width: 180),
          ],
        ),
      ),
    );
  }
}

/// 单条气泡骨架
class _ChatBubbleSkeleton extends StatelessWidget {
  final bool isUser;
  final double width;

  const _ChatBubbleSkeleton({required this.isUser, required this.width});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isUser) ...[
          // AI 头像占位
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          AppSpacing.hGap10,
        ],
        // 气泡占位
        Container(
          width: width,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isUser ? 12 : 24),
              topRight: Radius.circular(isUser ? 24 : 12),
              bottomLeft: const Radius.circular(12),
              bottomRight: const Radius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
