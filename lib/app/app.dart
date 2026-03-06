import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'router.dart';
import 'theme/app_theme.dart';
import '../shared/providers/locale_provider.dart';
import '../shared/providers/theme_provider.dart';

/// VerveForge 根组件
class VerveForgeApp extends ConsumerWidget {
  const VerveForgeApp({super.key});

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
    );
  }
}
