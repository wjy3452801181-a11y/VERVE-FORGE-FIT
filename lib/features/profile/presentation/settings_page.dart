import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/errors/error_handler.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../auth/data/auth_repository.dart';
import '../../workout/providers/health_sync_provider.dart';
import 'privacy_settings_page.dart';

/// 设置页
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsTitle),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // 语言设置
          _buildSectionTitle(context.l10n.settingsLanguage),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                _buildLanguageTile(
                  context,
                  ref,
                  '简体中文',
                  const Locale('zh', 'CN'),
                  locale,
                ),
                const Divider(height: 1, indent: 16),
                _buildLanguageTile(
                  context,
                  ref,
                  '繁體中文',
                  const Locale('zh', 'TW'),
                  locale,
                ),
                const Divider(height: 1, indent: 16),
                _buildLanguageTile(
                  context,
                  ref,
                  'English',
                  const Locale('en'),
                  locale,
                ),
                const Divider(height: 1, indent: 16),
                ListTile(
                  title: Text(context.l10n.settingsFollowSystem),
                  trailing: locale == null
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () =>
                      ref.read(localeProvider.notifier).clearLocale(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 主题设置
          _buildSectionTitle(context.l10n.settingsTheme),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                _buildThemeTile(
                  context,
                  ref,
                  context.l10n.settingsThemeDark,
                  Icons.dark_mode,
                  ThemeMode.dark,
                  themeMode,
                ),
                const Divider(height: 1, indent: 16),
                _buildThemeTile(
                  context,
                  ref,
                  context.l10n.settingsThemeLight,
                  Icons.light_mode,
                  ThemeMode.light,
                  themeMode,
                ),
                const Divider(height: 1, indent: 16),
                _buildThemeTile(
                  context,
                  ref,
                  context.l10n.settingsThemeSystem,
                  Icons.brightness_auto,
                  ThemeMode.system,
                  themeMode,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Apple Health 同步（仅 iOS）
          if (Platform.isIOS) ...[
            _buildSectionTitle(context.l10n.healthSync),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  Consumer(
                    builder: (context, ref, _) {
                      final syncState = ref.watch(healthSyncProvider);
                      return SwitchListTile(
                        secondary: const Icon(Icons.favorite, color: AppColors.crossfit),
                        title: Text(context.l10n.healthSync),
                        subtitle: Text(context.l10n.healthSyncDescription),
                        value: syncState.isEnabled,
                        activeTrackColor: AppColors.primary,
                        onChanged: (_) {
                          ref.read(healthSyncProvider.notifier).toggleSync();
                        },
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 16),
                  Consumer(
                    builder: (context, ref, _) {
                      final syncState = ref.watch(healthSyncProvider);
                      return ListTile(
                        leading: const Icon(Icons.sync),
                        title: Text(context.l10n.healthSyncNow),
                        subtitle: syncState.status == HealthSyncStatus.syncing
                            ? Text(context.l10n.healthSyncing)
                            : syncState.status == HealthSyncStatus.success
                                ? Text('${context.l10n.healthSyncSuccess} (${syncState.lastSyncedCount})')
                                : syncState.status == HealthSyncStatus.error
                                    ? Text(context.l10n.healthSyncError,
                                        style: TextStyle(color: context.colorScheme.error))
                                    : null,
                        trailing: syncState.status == HealthSyncStatus.syncing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : null,
                        enabled: syncState.isEnabled &&
                            syncState.status != HealthSyncStatus.syncing,
                        onTap: () {
                          ref.read(healthSyncProvider.notifier).syncNow();
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 隐私设置
          _buildSectionTitle(context.l10n.settingsPrivacy),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text(context.l10n.settingsPrivacy),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PrivacySettingsPage()),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // 关于
          _buildSectionTitle(context.l10n.settingsAbout),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('VerveForge'),
                  subtitle: Text('v1.0.0'),
                ),
                const Divider(height: 1, indent: 16),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: Text(context.l10n.settingsOpenSource),
                  subtitle: const Text('MIT License'),
                  onTap: () {
                    // TODO: 显示开源协议
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 退出登录
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () => _handleLogout(context, ref),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                foregroundColor: context.colorScheme.error,
                side: BorderSide(color: context.colorScheme.error),
              ),
              child: Text(context.l10n.settingsLogout),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    WidgetRef ref,
    String title,
    Locale locale,
    Locale? currentLocale,
  ) {
    final isSelected = currentLocale?.languageCode == locale.languageCode &&
        currentLocale?.countryCode == locale.countryCode;
    return ListTile(
      title: Text(title),
      trailing:
          isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () =>
          ref.read(localeProvider.notifier).setLocale(locale),
    );
  }

  Widget _buildThemeTile(
    BuildContext context,
    WidgetRef ref,
    String title,
    IconData icon,
    ThemeMode mode,
    ThemeMode currentMode,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: currentMode == mode
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: () =>
          ref.read(themeModeProvider.notifier).setThemeMode(mode),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: context.l10n.settingsLogoutConfirm,
      content: context.l10n.settingsLogoutDesc,
      confirmText: context.l10n.settingsLogout,
      isDestructive: true,
    );

    if (!confirmed) return;

    try {
      await ref.read(authRepositoryProvider).signOut();
      if (context.mounted) {
        GoRouter.of(context).go(AppRoutes.login);
      }
    } catch (e) {
      if (context.mounted) ErrorHandler.showError(context, e);
    }
  }
}
