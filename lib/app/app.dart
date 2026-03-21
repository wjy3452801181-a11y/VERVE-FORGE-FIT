import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:verveforge/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'router.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';
import '../shared/providers/locale_provider.dart';
import '../core/constants/storage_keys.dart';

/// VerveForge 根组件
class VerveForgeApp extends ConsumerWidget {
  final bool privacyAgreed;

  const VerveForgeApp({super.key, required this.privacyAgreed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'VerveForge',
      debugShowCheckedModeBanner: false,

      // 【性能优化 Step 3】profile/debug 模式下显示性能覆盖层
      // 实时查看 UI 线程 / Raster 线程耗时，release 模式自动关闭
      showPerformanceOverlay: kProfileMode,

      // 主题配置 — 强制浅色模式（黑白 + Inter）
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // 多语言配置
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'), // 简体中文
        Locale('zh', 'TW'), // 繁体中文（香港）
        Locale('en'),       // English
      ],

      // 路由
      routerConfig: router,

      // 启动拦截 — 隐私同意
      builder: (context, child) {
        return _PrivacyGate(
          privacyAgreed: privacyAgreed,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

/// 隐私弹窗拦截层
/// 首次安装启动时显示全屏同意页，用户必须同意才能使用 App
class _PrivacyGate extends StatefulWidget {
  final bool privacyAgreed;
  final Widget child;

  const _PrivacyGate({
    required this.privacyAgreed,
    required this.child,
  });

  @override
  State<_PrivacyGate> createState() => _PrivacyGateState();
}

class _PrivacyGateState extends State<_PrivacyGate> {
  late bool _agreed;

  @override
  void initState() {
    super.initState();
    _agreed = widget.privacyAgreed;
  }

  Future<void> _onAgree() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.privacyAgreed, true);
    if (mounted) {
      setState(() => _agreed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_agreed) return widget.child;

    // 未同意时显示内联的全屏同意页面（无需 Navigator / showDialog）
    return _InlineConsentPage(onAgree: _onAgree);
  }
}

/// 内联隐私同意页面 — 不依赖 Navigator
class _InlineConsentPage extends StatelessWidget {
  final VoidCallback onAgree;

  const _InlineConsentPage({required this.onAgree});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      // l10n 未就绪时显示加载
      return const Material(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Material(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                l10n.appLaunchConsentTitle,
                style: AppTextStyles.h1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(l10n.appLaunchConsentDesc, style: AppTextStyles.body),
              const SizedBox(height: 20),
              _buildItem(Icons.person_outline, l10n.appLaunchConsentItem1),
              _buildItem(Icons.fitness_center, l10n.appLaunchConsentItem2),
              _buildItem(Icons.location_on_outlined, l10n.appLaunchConsentItem3),
              _buildItem(Icons.lock_outline, l10n.appLaunchConsentItem4),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  // 使用 MaterialApp 内置的 Navigator（通过 routerConfig 提供）
                  // 但这里没有 Navigator，所以用简单的链接文本提示
                },
                child: Text(
                  l10n.appLaunchConsentReadFull,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: onAgree,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(l10n.privacyAgree),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTextStyles.caption)),
        ],
      ),
    );
  }
}
