import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 主题模式 Provider
/// 默认深色模式（Material 3 深色优先）
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark); // 默认深色模式

  /// 设置主题模式
  void setThemeMode(ThemeMode mode) {
    state = mode;
  }

  /// 切换深色/浅色
  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  /// 跟随系统
  void setSystem() => state = ThemeMode.system;
}
