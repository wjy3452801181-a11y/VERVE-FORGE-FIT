import 'package:flutter/material.dart';
import 'package:verveforge/l10n/app_localizations.dart';

/// BuildContext 扩展方法
extension ContextExtensions on BuildContext {
  // 主题快捷访问
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  // 屏幕尺寸
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get padding => MediaQuery.paddingOf(this);

  // 多语言快捷访问
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  // 是否深色模式
  bool get isDarkMode => theme.brightness == Brightness.dark;
}
