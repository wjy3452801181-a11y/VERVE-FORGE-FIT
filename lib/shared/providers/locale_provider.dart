import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 多语言切换 Provider
/// 默认简体中文，支持切换繁体中文和英文
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null); // null = 跟随系统

  /// 切换语言
  void setLocale(Locale locale) {
    state = locale;
  }

  /// 跟随系统
  void clearLocale() {
    state = null;
  }

  /// 切换为简体中文
  void setSimplifiedChinese() => setLocale(const Locale('zh', 'CN'));

  /// 切换为繁体中文（香港）
  void setTraditionalChinese() => setLocale(const Locale('zh', 'TW'));

  /// 切换为英文
  void setEnglish() => setLocale(const Locale('en'));
}
