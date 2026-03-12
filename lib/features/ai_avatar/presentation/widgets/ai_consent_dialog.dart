import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';

/// AI 数据处理授权同意弹窗
class AiConsentDialog extends StatelessWidget {
  const AiConsentDialog({super.key});

  /// 显示同意弹窗，返回 true 表示用户同意
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AiConsentDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.smart_toy_outlined, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(context.l10n.aiConsentTitle),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.aiConsentDesc),
            const SizedBox(height: 16),
            _buildConsentItem(context, Icons.person_outline,
                context.l10n.aiConsentItem1),
            _buildConsentItem(context, Icons.chat_outlined,
                context.l10n.aiConsentItem2),
            _buildConsentItem(context, Icons.article_outlined,
                context.l10n.aiConsentItem3),
            _buildConsentItem(context, Icons.security_outlined,
                context.l10n.aiConsentItem4),
            _buildConsentItem(context, Icons.label_outlined,
                context.l10n.aiConsentItem5),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.l10n.aiConsentDisagree),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(context.l10n.aiConsentAgree),
        ),
      ],
    );
  }

  Widget _buildConsentItem(
      BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
