import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'router.dart';
import 'theme/app_theme.dart';
import '../shared/providers/locale_provider.dart';
import '../shared/providers/theme_provider.dart';
import '../features/auth/presentation/app_launch_consent.dart';

/// VerveForge 根组件
class VerveForgeApp extends ConsumerWidget {
  final bool privacyAgreed;

  const VerveForgeApp({super.key, required this.privacyAgreed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'VerveForge',
      debugShowCheckedModeBanner: false,

      // 主题配置 — Material 3 深色模式优先
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

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

      // 启动拦截 — 隐私弹窗
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
/// 首次安装启动时弹出，用户必须同意才能使用 App
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
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _agreed = widget.privacyAgreed;
    if (!_agreed) {
      // 延迟一帧后弹窗（确保 context 可用）
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showConsent();
      });
    }
  }

  Future<void> _showConsent() async {
    if (_checking) return;
    _checking = true;

    final agreed = await AppLaunchConsent.ensureConsent(context);
    if (mounted) {
      setState(() {
        _agreed = agreed;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_agreed) {
      // 未同意时显示空白背景，弹窗会覆盖在上面
      return const SizedBox.shrink();
    }
    return widget.child;
  }
}
