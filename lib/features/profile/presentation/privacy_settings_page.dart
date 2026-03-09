import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/errors/error_handler.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../auth/data/auth_repository.dart';
import '../data/profile_repository.dart';
import '../providers/profile_provider.dart';
import 'privacy_policy_page.dart';

/// 隐私设置页（PIPL / PDPO 合规）
class PrivacySettingsPage extends ConsumerStatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  ConsumerState<PrivacySettingsPage> createState() =>
      _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends ConsumerState<PrivacySettingsPage> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);
    final profile = profileAsync.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsPrivacy),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 可见性设置
          _buildSectionTitle('个人资料可见性'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('出现在「发现」列表'),
                  subtitle: const Text('关闭后其他用户无法在附近发现你'),
                  value: profile?.isDiscoverable ?? true,
                  onChanged: (v) => _updateVisibility(isDiscoverable: v),
                  activeColor: AppColors.primary,
                ),
                const Divider(height: 1, indent: 16),
                SwitchListTile(
                  title: const Text('公开训练统计'),
                  subtitle: const Text('关闭后其他用户无法查看你的训练数据'),
                  value: profile?.showWorkoutStats ?? true,
                  onChanged: (v) => _updateVisibility(showWorkoutStats: v),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 数据管理
          _buildSectionTitle('数据管理'),
          Card(
            child: Column(
              children: [
                // 隐私政策
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(context.l10n.privacyTitle),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyPage()),
                    );
                  },
                ),
                const Divider(height: 1, indent: 56),

                // 导出数据
                ListTile(
                  leading: _isExporting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_outlined),
                  title: Text(context.l10n.settingsExportData),
                  subtitle: const Text('导出所有个人数据（JSON 格式）'),
                  onTap: _isExporting ? null : _exportData,
                ),
                const Divider(height: 1, indent: 56),

                // 注销账号
                ListTile(
                  leading: Icon(Icons.delete_forever,
                      color: context.colorScheme.error),
                  title: Text(
                    context.l10n.settingsDeleteAccount,
                    style: TextStyle(color: context.colorScheme.error),
                  ),
                  subtitle: const Text('永久删除账号和所有数据'),
                  onTap: _deleteAccount,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 合规声明
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '本应用遵循中国《个人信息保护法》(PIPL) 和香港《个人资料（私隐）条例》(PDPO)。'
              '您可随时导出或删除您的个人数据。如有疑问，请通过设置页联系我们。',
              style: AppTextStyles.caption.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 更新可见性设置
  Future<void> _updateVisibility({
    bool? isDiscoverable,
    bool? showWorkoutStats,
  }) async {
    final profile = ref.read(currentProfileProvider).valueOrNull;
    if (profile == null) return;

    try {
      final updated = profile.copyWith(
        isDiscoverable: isDiscoverable,
        showWorkoutStats: showWorkoutStats,
      );
      await ref.read(currentProfileProvider.notifier).updateProfile(updated);
    } catch (e) {
      if (mounted) ErrorHandler.showError(context, e);
    }
  }

  /// 导出数据（PIPL 合规）
  Future<void> _exportData() async {
    setState(() => _isExporting = true);
    try {
      final repo = ref.read(profileRepositoryProvider);
      final data = await repo.exportUserData();

      // 保存到临时文件并分享
      final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/verveforge_data_export.json');
      await file.writeAsString(jsonStr);

      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)]),
      );

      if (mounted) ErrorHandler.showSuccess(context, '数据导出成功');
    } catch (e) {
      if (mounted) ErrorHandler.showError(context, e);
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  /// 注销账号（PIPL 合规）
  Future<void> _deleteAccount() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: '确认注销账号？',
      content: '注销后您的所有数据将被永久删除，此操作不可撤销。\n\n'
          '请注意：\n'
          '• 个人资料将被删除\n'
          '• 训练日志将被删除\n'
          '• 聊天记录将被删除\n'
          '• 此操作不可撤销',
      confirmText: '确认注销',
      isDestructive: true,
    );

    if (!confirmed) return;
    if (!mounted) return;

    // 二次确认
    final reconfirmed = await ConfirmDialog.show(
      context,
      title: '最后确认',
      content: '您即将永久注销账号，是否继续？',
      confirmText: '永久注销',
      isDestructive: true,
    );

    if (!reconfirmed) return;
    if (!mounted) return;

    try {
      await ref.read(authRepositoryProvider).requestAccountDeletion();
      if (mounted) {
        ErrorHandler.showSuccess(context, '账号注销请求已提交');
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) ErrorHandler.showError(context, e);
    }
  }
}
