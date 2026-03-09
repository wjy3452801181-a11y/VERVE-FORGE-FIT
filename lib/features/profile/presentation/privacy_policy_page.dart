import 'package:flutter/material.dart';

import '../../../app/theme/app_text_styles.dart';
import '../../../core/extensions/context_extensions.dart';

/// 隐私政策全文页（独立路由，可从启动弹窗 / 设置页进入）
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.privacyTitle),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('VerveForge 隐私政策', style: AppTextStyles.h2),
            SizedBox(height: 8),
            Text('最后更新：2026年3月', style: AppTextStyles.caption),
            SizedBox(height: 24),
            Text(
              '1. 信息收集\n\n'
              '我们收集您在使用 VerveForge 时提供的信息，包括：\n'
              '• 注册信息：手机号码、Apple ID\n'
              '• 个人资料：昵称、头像、性别、出生年份、城市、运动偏好\n'
              '• 训练数据：训练日志、Apple Health 同步数据\n'
              '• 社交数据：聊天消息、动态内容、评价\n'
              '• 位置信息：用于发现附近训练馆和伙伴\n\n'
              '2. 信息使用\n\n'
              '我们使用收集的信息用于：\n'
              '• 提供、维护和改善我们的服务\n'
              '• 推荐附近的训练馆和训练伙伴\n'
              '• 发送通知（约练请求、消息提醒等）\n'
              '• 训练数据统计和挑战赛排行\n\n'
              '3. 信息共享\n\n'
              '我们不会向第三方出售您的个人信息。以下情况可能共享：\n'
              '• 其他用户可看到您的公开档案信息\n'
              '• 法律要求时配合有关部门\n\n'
              '4. 数据安全\n\n'
              '• 全程 HTTPS/TLS 加密传输\n'
              '• 数据存储使用行级安全策略\n'
              '• 定期安全审查和更新\n\n'
              '5. 您的权利\n\n'
              '根据《个人信息保护法》和《个人资料（私隐）条例》，您有权：\n'
              '• 查阅您的个人信息\n'
              '• 更正不准确的信息\n'
              '• 删除您的个人信息\n'
              '• 导出您的数据\n'
              '• 撤回同意\n\n'
              '6. 联系我们\n\n'
              '如有隐私相关问题，请通过 App 内设置页联系我们。',
              style: AppTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }
}
