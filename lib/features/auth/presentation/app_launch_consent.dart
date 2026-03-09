import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../profile/presentation/privacy_policy_page.dart';

/// App 冷启动隐私弹窗（PIPL 合规）
/// 首次安装启动时弹出，用户必须同意才能继续使用
class AppLaunchConsent {
  /// 检查是否已同意
  static Future<bool> isAgreed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(StorageKeys.privacyAgreed) ?? false;
  }

  /// 确保已同意（未同意时弹窗，返回是否同意）
  static Future<bool> ensureConsent(BuildContext context) async {
    if (await isAgreed()) return true;
    if (!context.mounted) return false;
    final agreed = await _showDialog(context);
    if (agreed) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(StorageKeys.privacyAgreed, true);
    }
    return agreed;
  }

  static Future<bool> _showDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _AppLaunchConsentDialog(),
    );
    return result ?? false;
  }
}

class _AppLaunchConsentDialog extends StatelessWidget {
  const _AppLaunchConsentDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.appLaunchConsentTitle),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.appLaunchConsentDesc,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 16),
            _buildItem(
              Icons.person_outline,
              context.l10n.appLaunchConsentItem1,
            ),
            _buildItem(
              Icons.fitness_center,
              context.l10n.appLaunchConsentItem2,
            ),
            _buildItem(
              Icons.location_on_outlined,
              context.l10n.appLaunchConsentItem3,
            ),
            _buildItem(
              Icons.lock_outline,
              context.l10n.appLaunchConsentItem4,
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyPage(),
                  ),
                );
              },
              child: Text(
                context.l10n.appLaunchConsentReadFull,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                ),
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
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(context.l10n.privacyAgree),
        ),
      ],
    );
  }

  Widget _buildItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: AppTextStyles.caption),
          ),
        ],
      ),
    );
  }
}
