import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../../app/theme/app_colors.dart';
import 'app_exception.dart';

/// 全局错误处理器
class ErrorHandler {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 80,
    ),
  );

  /// 处理错误并返回用户友好的消息
  /// [error] 可以是 String（业务校验提示）或 Exception（系统异常）
  static String handleError(dynamic error) {
    // 业务校验类错误（String）：仅在 debug 模式打印，不输出完整堆栈
    if (error is String) {
      if (kDebugMode) {
        debugPrint('⚠️ 校验提示: $error');
      }
      return error;
    }

    // AppException：已知业务异常，用 warning 级别记录
    if (error is AppException) {
      _logger.w('业务异常: ${error.message}');
      return error.message;
    }

    // 以下为系统级异常，用 error 级别记录完整堆栈
    _logger.e('应用错误', error: error);

    if (error is supa.AuthException) {
      return _handleAuthError(error);
    }

    if (error is supa.PostgrestException) {
      return _handleDatabaseError(error);
    }

    if (error is supa.StorageException) {
      return '文件操作失败，请重试';
    }

    return '操作失败，请稍后重试';
  }

  /// 处理 Supabase 认证错误
  static String _handleAuthError(supa.AuthException error) {
    final message = error.message.toLowerCase();

    if (message.contains('invalid login')) {
      return '登录信息无效，请检查后重试';
    }
    if (message.contains('email not confirmed')) {
      return '请先验证您的邮箱';
    }
    if (message.contains('invalid otp') || message.contains('token')) {
      return '验证码无效或已过期，请重新获取';
    }
    if (message.contains('user already registered')) {
      return '该账号已注册，请直接登录';
    }

    return '认证失败：${error.message}';
  }

  /// 处理数据库错误
  static String _handleDatabaseError(supa.PostgrestException error) {
    if (error.code == '23505') {
      return '数据已存在，请勿重复操作';
    }
    if (error.code == '42501') {
      return '权限不足，无法执行此操作';
    }

    return '数据操作失败，请重试';
  }

  /// 在 UI 中显示错误 SnackBar
  static void showError(BuildContext context, dynamic error) {
    final message = handleError(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 显示成功消息
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
