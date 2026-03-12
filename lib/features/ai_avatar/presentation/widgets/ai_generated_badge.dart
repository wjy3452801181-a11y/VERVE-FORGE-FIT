import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';

/// AI 生成消息标记组件（可复用）
///
/// 两种模式：
/// - compact（默认）：小标签，适合气泡下方
/// - expanded：带图标 + 背景，适合消息列表显眼提示
///
/// AI 消息特征色使用 AppColors.info（蓝色）与用户消息区分
class AiGeneratedBadge extends StatelessWidget {
  /// 是否使用展开模式（带背景 + 图标更大）
  final bool expanded;

  /// 可选的分身名称（展开模式下显示）
  final String? avatarName;

  const AiGeneratedBadge({
    super.key,
    this.expanded = false,
    this.avatarName,
  });

  @override
  Widget build(BuildContext context) {
    if (expanded) return _buildExpanded(context);
    return _buildCompact(context);
  }

  /// 紧凑模式 — 气泡下方小标签
  Widget _buildCompact(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.smart_toy_outlined,
            size: 10,
            color: AppColors.info.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 3),
          Text(
            context.l10n.aiGeneratedLabel,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.info.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 展开模式 — 消息列表中的显眼提示
  Widget _buildExpanded(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.info.withValues(alpha: 0.12),
            AppColors.info.withValues(alpha: 0.06),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.info.withValues(alpha: 0.15),
            ),
            child: const Center(
              child: Icon(
                Icons.smart_toy_outlined,
                size: 12,
                color: AppColors.info,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.aiGeneratedLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (avatarName != null)
                Text(
                  avatarName!,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.info.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
