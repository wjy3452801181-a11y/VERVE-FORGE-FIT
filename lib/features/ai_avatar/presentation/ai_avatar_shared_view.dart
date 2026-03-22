import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/extensions/context_extensions.dart';
import '../domain/ai_avatar_model.dart';
import '../providers/ai_avatar_provider.dart';
import 'widgets/personality_chip.dart';

/// AI 分身公开展示页 — 通过分享链接打开
///
/// 仅展示公开信息：头像、名称、个性标签、说话风格
/// PIPL 合规：不暴露 userId、aiConsentAt、customPrompt 等隐私字段
class AiAvatarSharedView extends ConsumerWidget {
  final String shareToken;

  const AiAvatarSharedView({super.key, required this.shareToken});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sharedAsync = ref.watch(sharedAvatarProvider(shareToken));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(context.l10n.aiShareViewTitle),
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
          child: sharedAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _buildErrorState(context),
            data: (data) {
              if (data == null) {
                return _buildErrorState(context);
              }
              return _buildSharedContent(context, ref, data);
            },
          ),
        ),
      ),
    );
  }

  /// 错误/不存在状态
  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.link_off_rounded,
              size: 56, color: Colors.grey.shade400),
          AppSpacing.vGapMD,
          Text(
            context.l10n.aiShareNotFound,
            style: AppTextStyles.subtitle,
          ),
          AppSpacing.vGapSM,
          Text(
            context.l10n.aiShareNotFoundDesc,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 分身公开信息展示
  Widget _buildSharedContent(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> data,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = data['name'] as String? ?? '';
    final avatarId = data['id'] as String?;
    final avatarUrl = data['avatar_url'] as String?;
    final traits = (data['personality_traits'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [];
    final style = data['speaking_style'] as String? ?? 'friendly';
    final ownerNickname = data['owner_nickname'] as String? ?? '';
    final ownerCity = data['owner_city'] as String?;

    // 解析 emoji 头像
    String avatarEmoji = '🤖';
    if (avatarUrl != null && avatarUrl.startsWith('preset:')) {
      final key = avatarUrl.substring(7);
      final preset = AiAvatarModel.presetAvatars
          .where((p) => p.key == key)
          .firstOrNull;
      avatarEmoji = preset?.emoji ?? '🤖';
    }

    // 说话风格映射
    final styleMap = {
      'lively': context.l10n.aiStyleLively,
      'steady': context.l10n.aiStyleSteady,
      'humorous': context.l10n.aiStyleHumorous,
      'friendly': context.l10n.aiStyleFriendly,
      'professional': context.l10n.aiStyleProfessional,
      'encouraging': context.l10n.aiStyleEncouraging,
    };

    return ListView(
      padding: AppSpacing.cardPadding,
      children: [
        AppSpacing.vGap20,

        // 分身头像（大尺寸居中）
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.info.withValues(alpha: 0.1),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.info.withValues(alpha: 0.2),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: Text(avatarEmoji, style: const TextStyle(fontSize: 48)),
            ),
          ),
        ),
        AppSpacing.vGapMD,

        // 分身名称
        Center(
          child: Text(
            name,
            style: AppTextStyles.subtitle.copyWith(fontSize: 22),
          ),
        ),
        AppSpacing.vGap6,

        // 主人信息
        Center(
          child: Text(
            ownerCity != null
                ? '$ownerNickname · $ownerCity'
                : ownerNickname,
            style: AppTextStyles.caption.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        AppSpacing.vGapLG,

        // 性格标签
        if (traits.isNotEmpty)
          _buildGlassCard(
            context: context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.aiAvatarStepPersonality,
                  style: AppTextStyles.caption,
                ),
                AppSpacing.vGapSM,
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: traits.map((trait) {
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

        if (traits.isNotEmpty) AppSpacing.vGap12,

        // 说话风格
        _buildGlassCard(
          context: context,
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.info.withValues(alpha: 0.1),
                ),
                child: const Center(
                  child: Icon(Icons.chat_bubble_outline_rounded,
                      size: 18, color: AppColors.info),
                ),
              ),
              AppSpacing.hGap12,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.aiAvatarPreviewTitle,
                    style: AppTextStyles.caption,
                  ),
                  Text(
                    styleMap[style] ?? style,
                    style: AppTextStyles.subtitle,
                  ),
                ],
              ),
            ],
          ),
        ),
        AppSpacing.vGapXL,

        // 聊天入口按钮
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.md),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.md),
                gradient: const LinearGradient(
                  colors: [AppColors.info, Color(0xFF64B5F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.info.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.6),
                  width: 0.5,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                  onTap: () {
                    // 跳转到分身聊天页（携带 avatarId）
                    if (avatarId != null) {
                      context.push('${AppRoutes.aiAvatarChat}/$avatarId');
                    } else {
                      context.push(AppRoutes.aiAvatarChat);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.x20, vertical: AppSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat_rounded,
                            color: Colors.white, size: 20),
                        AppSpacing.hGap10,
                        Text(
                          context.l10n.aiChatStartChat,
                          style: const TextStyle(
                            color: Colors.white,
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
        ),
      ],
    );
  }

  /// 玻璃拟态卡片
  Widget _buildGlassCard({
    required BuildContext context,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.md),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: AppSpacing.cardPaddingCompact,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(AppSpacing.md),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.5),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
