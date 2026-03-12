import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/errors/error_handler.dart';
import '../domain/ai_avatar_model.dart';
import '../providers/ai_avatar_provider.dart';

/// AI 分身分享底部弹窗
/// 支持三种分享目标：Feed / 挑战赛 / 群聊
/// 流程：选择目标 → PIPL 二次确认 → 调用 Edge Function → 显示链接 + 复制
class AiAvatarShareSheet extends ConsumerStatefulWidget {
  final AiAvatarModel avatar;

  const AiAvatarShareSheet({super.key, required this.avatar});

  /// 显示分享弹窗
  static Future<void> show(BuildContext context, AiAvatarModel avatar) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AiAvatarShareSheet(avatar: avatar),
    );
  }

  @override
  ConsumerState<AiAvatarShareSheet> createState() =>
      _AiAvatarShareSheetState();
}

class _AiAvatarShareSheetState extends ConsumerState<AiAvatarShareSheet> {
  bool _isSharing = false;

  /// 分享成功后保存链接，切换到成功视图
  String? _shareLink;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.9),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 拖动指示条
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // 根据状态显示不同内容
              if (_shareLink != null)
                _buildSuccessView()
              else
                _buildShareOptions(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 分享选项视图（初始状态）
  // ============================================================

  Widget _buildShareOptions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 标题
        Text(
          context.l10n.aiShareTitle,
          style: AppTextStyles.subtitle,
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.aiShareSubtitle,
          style: AppTextStyles.caption.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),

        // 分享目标列表
        _buildShareOption(
          icon: Icons.dynamic_feed_outlined,
          color: AppColors.primary,
          title: context.l10n.aiShareToFeed,
          subtitle: context.l10n.aiShareToFeedDesc,
          onTap: () => _confirmAndShare('feed'),
        ),
        const SizedBox(height: 10),
        _buildShareOption(
          icon: Icons.emoji_events_outlined,
          color: AppColors.secondary,
          title: context.l10n.aiShareToChallenge,
          subtitle: context.l10n.aiShareToChallengeDesc,
          onTap: () => _confirmAndShare('challenge'),
        ),
        const SizedBox(height: 10),
        _buildShareOption(
          icon: Icons.group_outlined,
          color: AppColors.info,
          title: context.l10n.aiShareToGroup,
          subtitle: context.l10n.aiShareToGroupDesc,
          onTap: () => _confirmAndShare('group'),
        ),
        const SizedBox(height: 16),

        // 复制链接按钮
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isSharing ? null : _copyShareLink,
            icon: _isSharing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.link, size: 18),
            label: Text(context.l10n.aiShareCopyLink),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 分享成功视图（显示链接 + 复制按钮）
  // ============================================================

  Widget _buildSuccessView() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 成功图标
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.success.withValues(alpha: 0.12),
          ),
          child: const Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.success,
            size: 32,
          ),
        ),
        const SizedBox(height: 12),

        Text(
          context.l10n.aiShareSuccess,
          style: AppTextStyles.subtitle,
        ),
        const SizedBox(height: 20),

        // 分享链接卡片
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.grey.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.15),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.link_rounded,
                size: 18,
                color: context.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _shareLink!,
                  style: AppTextStyles.body.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              // 复制按钮
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _shareLink!));
                  ErrorHandler.showSuccess(
                      context, context.l10n.aiShareLinkCopied);
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.info.withValues(alpha: 0.1),
                  foregroundColor: AppColors.info,
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(36, 36),
                ),
                tooltip: context.l10n.aiShareCopyLink,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 关闭按钮
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.info,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(context.l10n.commonDone),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 分享选项卡片组件
  // ============================================================

  Widget _buildShareOption({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isSharing ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedOpacity(
          opacity: _isSharing ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.08 : 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.15),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.subtitle),
                      Text(
                        subtitle,
                        style: AppTextStyles.caption.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isSharing)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.grey.withValues(alpha: 0.4),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 分享逻辑
  // ============================================================

  /// PIPL 二次确认后执行分享
  void _confirmAndShare(String targetType) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.share_outlined, color: AppColors.info, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.l10n.aiShareConfirmTitle,
                style: AppTextStyles.subtitle,
              ),
            ),
          ],
        ),
        content: Text(
          context.l10n.aiShareConfirmDesc,
          style: AppTextStyles.body.copyWith(
            color: context.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _executeShare(targetType);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.info),
            child: Text(context.l10n.aiShareConfirmBtn),
          ),
        ],
      ),
    );
  }

  /// 调用 Edge Function 执行分享
  Future<void> _executeShare(String targetType) async {
    setState(() => _isSharing = true);

    try {
      final shareLink = await ref
          .read(aiAvatarShareProvider.notifier)
          .shareAvatar(
            avatarId: widget.avatar.id,
            targetType: targetType,
          );

      if (mounted && shareLink != null) {
        // 自动复制到剪贴板
        Clipboard.setData(ClipboardData(text: shareLink));
        // 切换到成功视图，显示链接
        setState(() {
          _shareLink = shareLink;
          _isSharing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final message = e.toString().contains('429')
            ? context.l10n.aiShareLimitReached
            : context.l10n.aiShareFailed;
        ErrorHandler.showError(context, message);
        setState(() => _isSharing = false);
      }
    }
  }

  /// 仅复制分享链接（走 feed 类型生成链接）
  Future<void> _copyShareLink() async {
    // 复制链接也需要 PIPL 二次确认
    _confirmAndShare('feed');
  }
}
