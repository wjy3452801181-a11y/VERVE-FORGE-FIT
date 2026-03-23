import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/errors/error_handler.dart';
import '../domain/ai_avatar_model.dart';
import '../providers/ai_avatar_provider.dart';
import 'ai_avatar_share_sheet.dart';
import 'widgets/ai_glass_card.dart';
import 'widgets/personality_chip.dart';

/// AI 分身详情/管理页 — 玻璃拟态 + 显眼聊天入口
class AiAvatarDetailPage extends ConsumerWidget {
  const AiAvatarDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarAsync = ref.watch(currentAiAvatarProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(context.l10n.aiAvatarTitle),
        actions: [
          // 分享按钮（仅有分身时显示）
          if (avatarAsync.valueOrNull != null)
            IconButton(
              icon: const Icon(Icons.share_outlined, size: 22),
              tooltip: context.l10n.aiShareTitle,
              onPressed: () {
                final avatar = avatarAsync.valueOrNull;
                if (avatar != null) {
                  AiAvatarShareSheet.show(context, avatar);
                }
              },
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteDialog(context, ref);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  context.l10n.aiAvatarDelete,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
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
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                  ]
                : [
                    const Color(0xFFF8F9FA),
                    const Color(0xFFE8EAF6),
                    const Color(0xFFF3E5F5),
                  ],
          ),
        ),
        child: SafeArea(
          child: avatarAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off_rounded,
                        size: 48, color: Colors.grey.shade400),
                    AppSpacing.vGapMD,
                    Text(context.l10n.commonError,
                        style: AppTextStyles.subtitle,
                        textAlign: TextAlign.center),
                    AppSpacing.vGapLG,
                    FilledButton.icon(
                      onPressed: () =>
                          ref.refresh(currentAiAvatarProvider),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(context.l10n.commonRetry),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.info,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            data: (avatar) {
              if (avatar == null) {
                return _buildEmptyState(context);
              }
              return _buildAvatarDetail(context, ref, avatar);
            },
          ),
        ),
      ),
    );
  }

  /// 空状态 — 引导创建分身
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.smart_toy_outlined, size: 64, color: Colors.grey.shade400),
          AppSpacing.vGapMD,
          Text(context.l10n.aiAvatarEmpty, style: AppTextStyles.subtitle),
          AppSpacing.vGapSM,
          Text(context.l10n.aiAvatarEmptyTip, style: AppTextStyles.caption),
          AppSpacing.vGapLG,
          FilledButton.icon(
            onPressed: () => context.push(AppRoutes.aiAvatarCreate),
            icon: const Icon(Icons.add),
            label: Text(context.l10n.aiAvatarCreate),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.info,
            ),
          ),
        ],
      ),
    );
  }

  /// 分身详情内容
  Widget _buildAvatarDetail(
      BuildContext context, WidgetRef ref, AiAvatarModel avatar) {
    // 解析预设 emoji 头像
    final avatarEmoji = _resolveAvatarEmoji(avatar);

    return ListView(
      padding: AppSpacing.cardPaddingCompact,
      children: [
        // ===== 头像 + 名称卡片 =====
        AiGlassCard(
          child: Row(
            children: [
              // 分身头像
              Container(
                width: 64,
                height: 64,
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
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    avatarEmoji ?? '🤖',
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),
              AppSpacing.hGapMD,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(avatar.name, style: AppTextStyles.subtitle),
                    AppSpacing.vGapXS,
                    Text(
                      context.l10n.aiGeneratedLabel,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () {
                  // TODO: 跳转编辑页
                },
              ),
            ],
          ),
        ),
        AppSpacing.vGap12,

        // ===== 立即聊天 — 显眼的 CTA 按钮 =====
        AiGlassCard(
          child: InkWell(
            onTap: () => context.push(
              '${AppRoutes.aiAvatarChat}/${avatar.id}',
            ),
            borderRadius: BorderRadius.circular(AppSpacing.x12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.x6),
              child: Row(
                children: [
                  // 蓝色发光图标
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.info, Color(0xFF64B5F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.info.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.chat_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ),
                  AppSpacing.hGap14,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.aiChatStartChat,
                          style: AppTextStyles.subtitle.copyWith(
                            color: AppColors.info,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          context.l10n.aiAvatarChatIntro,
                          style: AppTextStyles.caption.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.info.withValues(alpha: 0.7),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        AppSpacing.vGap12,

        // ===== 性格标签 =====
        if (avatar.personalityTraits.isNotEmpty) ...[
          AiGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.aiAvatarStepPersonality,
                    style: AppTextStyles.caption),
                AppSpacing.vGapSM,
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: avatar.personalityTraits.map((trait) {
                    return PersonalityChip(
                      trait: trait,
                      isSelected: true,
                      onTap: null,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          AppSpacing.vGap12,
        ],

        // ===== AI 画像信息卡片（只读展示，更新由底部按钮触发） =====
        AiGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 画像图标
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary.withValues(alpha: 0.1),
                    ),
                    child: const Center(
                      child: Icon(Icons.psychology_outlined,
                          size: 20, color: AppColors.secondary),
                    ),
                  ),
                  AppSpacing.hGap12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.aiProfileUpdate,
                          style: AppTextStyles.subtitle,
                        ),
                        AppSpacing.vGapXS,
                        Text(
                          _formatLastUpdated(
                              context, avatar.profileUpdatedAt),
                          style: AppTextStyles.caption.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // 运动习惯摘要（如果有）
              if (avatar.fitnessHabits.isNotEmpty &&
                  avatar.fitnessHabits['summary'] != null) ...[
                AppSpacing.vGap10,
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.x12, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.fitness_center_rounded,
                        size: 14,
                        color: AppColors.secondary.withValues(alpha: 0.7),
                      ),
                      AppSpacing.hGapXS,
                      Expanded(
                        child: Text(
                          avatar.fitnessHabits['summary'].toString(),
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11,
                            color:
                                AppColors.secondary.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        AppSpacing.vGap12,

        // ===== 自动回复开关（增强版） =====
        AiGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 状态指示灯（纯装饰，排除语义树）
                  ExcludeSemantics(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: avatar.autoReplyEnabled
                            ? AppColors.info
                            : Colors.grey.shade400,
                        boxShadow: avatar.autoReplyEnabled
                            ? [
                                BoxShadow(
                                  color:
                                      AppColors.info.withValues(alpha: 0.4),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                  AppSpacing.hGap10,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.aiAutoReply,
                          style: AppTextStyles.subtitle,
                        ),
                        AppSpacing.vGapXS,
                        Text(
                          avatar.autoReplyEnabled
                              ? context.l10n.aiAutoReplyStatusOn
                              : context.l10n.aiAutoReplyDesc,
                          style: AppTextStyles.caption.copyWith(
                            color: avatar.autoReplyEnabled
                                ? AppColors.info
                                : context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: avatar.autoReplyEnabled,
                    activeTrackColor: AppColors.info,
                    onChanged: (value) async {
                      // PIPL 合规：开启前检查是否已授权
                      if (value && avatar.aiConsentAt == null) {
                        if (context.mounted) {
                          ErrorHandler.showError(
                            context,
                            context.l10n.aiAutoReplyConsentRequired,
                          );
                        }
                        return;
                      }
                      try {
                        await ref
                            .read(currentAiAvatarProvider.notifier)
                            .toggleAutoReply(value);
                        if (context.mounted) {
                          ErrorHandler.showSuccess(
                            context,
                            value
                                ? context.l10n.aiAutoReplyEnabled
                                : context.l10n.aiAutoReplyDisabled,
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ErrorHandler.showError(context, e.toString());
                        }
                      }
                    },
                  ),
                ],
              ),
              // 自动回复开启时显示额外提示
              if (avatar.autoReplyEnabled) ...[
                AppSpacing.vGapSM,
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.x12, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppSpacing.sm),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.12),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: AppColors.info.withValues(alpha: 0.7),
                      ),
                      AppSpacing.hGapXS,
                      Expanded(
                        child: Text(
                          context.l10n.aiAutoReplyDesc,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11,
                            color: AppColors.info.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        AppSpacing.vGap12,

        // ===== 分享我的分身 — 蓝色渐变 CTA =====
        _buildShareCTA(context, avatar),
        AppSpacing.vGap20,

        // ===== 底部 CTA：更新我的画像 — 蓝色渐变按钮 =====
        _buildUpdateProfileCTA(context, ref, avatar),
        AppSpacing.vGapLG,
      ],
    );
  }

  /// "分享我的分身"CTA — 轮廓玻璃按钮（次要操作）
  Widget _buildShareCTA(BuildContext context, AiAvatarModel avatar) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.md),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.md),
            color: isDark
                ? AppColors.info.withValues(alpha: 0.06)
                : AppColors.info.withValues(alpha: 0.04),
            border: Border.all(
              color: AppColors.info.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.md),
              onTap: () => AiAvatarShareSheet.show(context, avatar),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.x20, vertical: AppSpacing.x14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.share_rounded,
                        color: AppColors.info, size: 20),
                    AppSpacing.hGap10,
                    Text(
                      context.l10n.aiShareBtn,
                      style: const TextStyle(
                        color: AppColors.info,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 底部"更新我的画像"CTA 按钮 — 蓝色渐变 + 加载状态
  Widget _buildUpdateProfileCTA(
      BuildContext context, WidgetRef ref, AiAvatarModel avatar) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUpdating = ref.watch(isUpdatingProfileProvider);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.md),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.md),
            color: isUpdating
                ? Colors.grey.shade400.withValues(alpha: 0.12)
                : isDark
                    ? AppColors.info.withValues(alpha: 0.06)
                    : AppColors.info.withValues(alpha: 0.04),
            border: Border.all(
              color: isUpdating
                  ? Colors.grey.shade400.withValues(alpha: 0.4)
                  : AppColors.info.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.md),
              onTap: isUpdating
                  ? null
                  : () => _showUpdateConfirmDialog(context, ref, avatar),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.x20, vertical: AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isUpdating) ...[
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      AppSpacing.hGap10,
                      Text(
                        context.l10n.aiProfileUpdating,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ] else ...[
                      const Icon(Icons.auto_awesome_rounded,
                          color: AppColors.info, size: 20),
                      AppSpacing.hGap10,
                      Text(
                        context.l10n.aiProfileManualUpdateBtn,
                        style: const TextStyle(
                          color: AppColors.info,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 画像更新确认弹窗 — PIPL 合规：用户明确同意后才触发更新
  void _showUpdateConfirmDialog(
      BuildContext context, WidgetRef ref, AiAvatarModel avatar) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.md)),
        title: Row(
          children: [
            const Icon(Icons.psychology_outlined,
                color: AppColors.info, size: 24),
            AppSpacing.hGap10,
            Expanded(
              child: Text(
                context.l10n.aiProfileUpdateConfirmTitle,
                style: AppTextStyles.subtitle,
              ),
            ),
          ],
        ),
        content: Text(
          context.l10n.aiProfileUpdateConfirmDesc,
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
              _requestProfileUpdate(context, ref);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.info,
            ),
            child: Text(context.l10n.aiProfileUpdateConfirmBtn),
          ),
        ],
      ),
    );
  }

  /// 用户确认后执行画像更新
  Future<void> _requestProfileUpdate(
      BuildContext context, WidgetRef ref) async {
    ref.read(isUpdatingProfileProvider.notifier).state = true;
    try {
      await ref
          .read(currentAiAvatarProvider.notifier)
          .requestProfileUpdate();
      if (context.mounted) {
        ErrorHandler.showSuccess(
            context, context.l10n.aiProfileUpdateSuccess);
      }
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.showError(
            context, context.l10n.aiProfileUpdateFailed);
      }
    } finally {
      ref.read(isUpdatingProfileProvider.notifier).state = false;
    }
  }


  /// 从 avatarUrl (preset:xxx) 解析 emoji
  String? _resolveAvatarEmoji(AiAvatarModel avatar) {
    if (avatar.avatarUrl == null) return null;
    final url = avatar.avatarUrl!;
    if (!url.startsWith('preset:')) return null;
    final key = url.substring(7);
    final preset = AiAvatarModel.presetAvatars
        .where((p) => p.key == key)
        .firstOrNull;
    return preset?.emoji;
  }

  /// 格式化最后更新时间
  String _formatLastUpdated(BuildContext context, DateTime? updatedAt) {
    if (updatedAt == null) {
      return context.l10n.aiProfileNeverUpdated;
    }
    final formatter = DateFormat('MM/dd HH:mm');
    return '${context.l10n.aiProfileLastUpdated} ${formatter.format(updatedAt.toLocal())}';
  }

  /// 确认删除弹窗
  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.aiAvatarDelete),
        content: Text(context.l10n.aiAvatarDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () async {
              // 先关闭对话框（用 ctx，生命周期确定）
              Navigator.pop(ctx);
              try {
                await ref
                    .read(currentAiAvatarProvider.notifier)
                    .deleteAvatar();
                // 用 context（page 级），async 结束后再次守卫
                if (context.mounted) {
                  ErrorHandler.showSuccess(
                      context, context.l10n.aiAvatarDeleted);
                  // 使用 post-frame 确保当前帧完成后再 pop，
                  // 消除 mounted 检查与 pop 之间的一帧窗口
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) Navigator.pop(context);
                  });
                }
              } catch (e) {
                if (context.mounted) {
                  ErrorHandler.showError(context, e.toString());
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(context.l10n.commonDelete),
          ),
        ],
      ),
    );
  }
}
