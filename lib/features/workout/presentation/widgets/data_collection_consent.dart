import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';

/// 训练数据采集专项授权弹窗（PIPL 合规）
/// 首次记录训练时弹出，区别于登录时的通用隐私弹窗
class DataCollectionConsent {
  static const _key = 'data_collection_consent_granted';

  /// 检查是否已授权
  static Future<bool> isGranted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  /// 确保已授权（未授权时弹窗，返回是否同意）
  static Future<bool> ensureConsent(BuildContext context) async {
    if (await isGranted()) return true;
    if (!context.mounted) return false;
    final agreed = await _showDialog(context);
    if (agreed) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, true);
    }
    return agreed;
  }

  static Future<bool> _showDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _DataCollectionConsentDialog(),
    );
    return result ?? false;
  }
}

class _DataCollectionConsentDialog extends StatelessWidget {
  const _DataCollectionConsentDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.dataCollectionConsent),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.dataCollectionDesc,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 16),
            _buildItem(Icons.emoji_events_outlined, '运动成绩数据',
                'HYROX 分站计时、CrossFit WOD 成绩、配速等'),
            _buildItem(Icons.favorite_outline, 'Apple Health 数据',
                '心率、卡路里消耗、步数等健康指标'),
            _buildItem(Icons.photo_camera_outlined, '训练媒体',
                '训练照片和视频记录'),
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
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(context.l10n.privacyAgree),
        ),
      ],
    );
  }

  Widget _buildItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                )),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
