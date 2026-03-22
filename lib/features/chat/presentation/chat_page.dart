import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_radius.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/network/supabase_client.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/skeleton.dart';
import '../domain/message_model.dart';
import '../providers/chat_provider.dart';

/// 聊天页 — 与某用户的私信
class ChatPage extends ConsumerStatefulWidget {
  final String otherUserId;
  final String? otherNickname;

  const ChatPage({
    super.key,
    required this.otherUserId,
    this.otherNickname,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // 滚动到底部（列表反转，所以是顶部）加载更多
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(messagesProvider(widget.otherUserId).notifier).loadMore();
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _controller.clear();

    try {
      await ref
          .read(messagesProvider(widget.otherUserId).notifier)
          .send(text);
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e);
        _controller.text = text; // 恢复文本
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.otherUserId));
    final currentUserId = SupabaseClientHelper.currentUserId ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherNickname ?? context.l10n.chatTitle),
      ),
      body: Column(
        children: [
          // 消息列表
          Expanded(
            child: messagesAsync.when(
              loading: () => ListView(
                padding: AppSpacing.pagePadding,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  SkeletonAvatarRow(),
                  SizedBox(height: AppSpacing.md),
                  SkeletonAvatarRow(),
                  SizedBox(height: AppSpacing.md),
                  SkeletonAvatarRow(),
                ],
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(context.l10n.commonError),
                    AppSpacing.vGapSM,
                    TextButton(
                      onPressed: () => ref.invalidate(
                          messagesProvider(widget.otherUserId)),
                      child: Text(context.l10n.commonRetry),
                    ),
                  ],
                ),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: isDark
                              ? AppColors.darkTextSecondary
                                  .withValues(alpha: 0.4)
                              : AppColors.lightTextSecondary
                                  .withValues(alpha: 0.4),
                        ),
                        AppSpacing.vGapSM,
                        Text(
                          context.l10n.chatEmpty,
                          style: AppTextStyles.caption.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // 最新消息在底部
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.x12, vertical: AppSpacing.sm),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMine = msg.isMine(currentUserId);
                    final showAvatar = !isMine &&
                        (index == messages.length - 1 ||
                            messages[index + 1].senderId != msg.senderId);

                    return _MessageBubble(
                      message: msg,
                      isMine: isMine,
                      showAvatar: showAvatar,
                    );
                  },
                );
              },
            ),
          ),

          // 输入栏
          _buildInputBar(context, isDark),
        ],
      ),
    );
  }

  /// 底部输入栏
  Widget _buildInputBar(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.x12,
        right: AppSpacing.sm,
        top: AppSpacing.sm,
        bottom: context.padding.bottom + AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.darkDivider
                : AppColors.lightDivider,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: context.l10n.chatInputHint,
                filled: true,
                fillColor: isDark
                    ? AppColors.darkCardHover
                    : AppColors.lightCardHover,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.x10),
                border: const OutlineInputBorder(
                  borderRadius: AppRadius.bPill,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          AppSpacing.hGapSM,
          IconButton(
            onPressed: _isSending ? null : _send,
            icon: Icon(
              Icons.send_rounded,
              color: _isSending
                  ? (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary)
                  : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 消息气泡
class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMine;
  final bool showAvatar;

  const _MessageBubble({
    required this.message,
    required this.isMine,
    this.showAvatar = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 对方头像
          if (!isMine)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: showAvatar
                  ? AvatarWidget(
                      size: 32,
                      imageUrl: message.senderAvatarUrl,
                      fallbackText: message.senderNickname,
                    )
                  : const SizedBox(width: 32),
            ),

          // 气泡
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x14, vertical: AppSpacing.x10),
              decoration: BoxDecoration(
                color: isMine
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.darkCardHover
                        : AppColors.lightCardHover),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft:
                      isMine ? const Radius.circular(16) : Radius.zero,
                  bottomRight:
                      isMine ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Text(
                message.content,
                style: AppTextStyles.body.copyWith(
                  color: isMine
                      ? Colors.white
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ),
          ),

          // 自己的消息右边留空
          if (isMine) AppSpacing.hGapSM,
        ],
      ),
    );
  }
}
