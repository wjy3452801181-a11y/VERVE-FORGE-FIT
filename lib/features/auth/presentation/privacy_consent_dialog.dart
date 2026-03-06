import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/extensions/context_extensions.dart';

/// 隐私政策同意弹窗（PIPL / PDPO 合规）
class PrivacyConsentDialog extends StatelessWidget {
  const PrivacyConsentDialog({super.key});

  /// 显示隐私弹窗，返回是否同意
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 不可点外部关闭
      builder: (context) => const PrivacyConsentDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.privacyTitle),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '欢迎使用 VerveForge！',
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 12),
            const Text(
              '在您使用我们的服务前，请仔细阅读以下内容：',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 16),

            // 数据收集说明
            _buildSection(
              '我们收集的信息',
              '• 手机号码（用于注册和登录）\n'
                  '• 个人资料（昵称、头像、运动偏好、城市）\n'
                  '• 训练数据（训练日志、Apple Health 数据）\n'
                  '• 位置信息（用于发现附近训练馆和伙伴）\n'
                  '• 聊天消息（用于与训练伙伴沟通）',
            ),

            _buildSection(
              '数据用途',
              '• 提供运动社交服务\n'
                  '• 推荐附近训练馆和训练伙伴\n'
                  '• 训练数据统计和挑战赛排行\n'
                  '• 改善产品体验',
            ),

            _buildSection(
              '您的权利',
              '• 随时查看、修改您的个人信息\n'
                  '• 导出您的全部数据（JSON 格式）\n'
                  '• 注销账号并删除所有数据\n'
                  '• 控制个人资料的可见范围',
            ),

            _buildSection(
              '数据安全',
              '• 全程 HTTPS 加密传输\n'
                  '• 数据存储在安全的云服务器\n'
                  '• 不会向第三方出售您的数据',
            ),

            const SizedBox(height: 8),
            Text(
              '如需了解完整隐私政策，请在设置中查看。',
              style: AppTextStyles.caption.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.l10n.privacyDisagree),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(context.l10n.privacyAgree),
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(content, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
