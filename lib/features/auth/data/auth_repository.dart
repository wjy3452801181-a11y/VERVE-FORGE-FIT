import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../core/network/supabase_client.dart';
import '../../../core/errors/app_exception.dart';

/// 认证数据仓库 — 封装 Supabase Auth 操作
class AuthRepository {
  final _auth = SupabaseClientHelper.client.auth;
  final _log = Logger();

  /// 发送手机号验证码（OTP）
  /// [phone] 完整手机号（含国际区号，如 +8613812345678）
  Future<void> sendOtp(String phone) async {
    try {
      await _auth.signInWithOtp(phone: phone);
      _log.i('验证码已发送至 $phone');
    } on AuthException catch (e) {
      _log.e('发送验证码失败', error: e);
      throw AppAuthException(
        message: _mapAuthError(e.message),
        code: e.statusCode,
        originalError: e,
      );
    }
  }

  /// 验证手机号 OTP
  /// [phone] 完整手机号
  /// [otp] 6 位验证码
  Future<AuthResponse> verifyOtp(String phone, String otp) async {
    try {
      final response = await _auth.verifyOTP(
        phone: phone,
        token: otp,
        type: OtpType.sms,
      );
      _log.i('OTP 验证成功，用户ID: ${response.user?.id}');
      return response;
    } on AuthException catch (e) {
      _log.e('OTP 验证失败', error: e);
      throw AppAuthException(
        message: _mapAuthError(e.message),
        code: e.statusCode,
        originalError: e,
      );
    }
  }

  /// Apple 登录（通过 OAuth Provider）
  Future<bool> signInWithApple() async {
    try {
      final success = await _auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.verveforge://login-callback/',
      );
      _log.i('Apple 登录请求: $success');
      return success;
    } on AuthException catch (e) {
      _log.e('Apple 登录失败', error: e);
      throw AppAuthException(
        message: _mapAuthError(e.message),
        code: e.statusCode,
        originalError: e,
      );
    }
  }

  /// 退出登录
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _log.i('已退出登录');
    } on AuthException catch (e) {
      _log.e('退出登录失败', error: e);
      throw AppAuthException(
        message: '退出登录失败，请重试',
        originalError: e,
      );
    }
  }

  /// 注销账号（PIPL 合规）
  /// 标记账号为待删除，后端 Edge Function 定期清理
  Future<void> requestAccountDeletion() async {
    try {
      final userId = SupabaseClientHelper.currentUserId;
      if (userId == null) {
        throw const AppAuthException(message: '未登录');
      }

      // 标记数据库中的删除请求时间
      await SupabaseClientHelper.from('profiles').update({
        'account_deletion_requested_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      // 退出登录
      await _auth.signOut();
      _log.i('账号注销请求已提交');
    } on AppAuthException {
      rethrow;
    } catch (e) {
      _log.e('账号注销失败', error: e);
      throw const AppAuthException(message: '账号注销失败，请重试');
    }
  }

  /// 监听认证状态变化
  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;

  /// 当前 Session
  Session? get currentSession => _auth.currentSession;

  /// 当前用户
  User? get currentUser => _auth.currentUser;

  /// 是否已登录
  bool get isLoggedIn => currentUser != null;

  /// 映射 Supabase Auth 错误为中文提示
  String _mapAuthError(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('invalid otp') || msg.contains('token')) {
      return '验证码无效或已过期，请重新获取';
    }
    if (msg.contains('rate limit') || msg.contains('too many')) {
      return '请求过于频繁，请稍后再试';
    }
    if (msg.contains('phone') && msg.contains('invalid')) {
      return '手机号格式不正确';
    }
    if (msg.contains('user already registered')) {
      return '该手机号已注册，将直接登录';
    }
    if (msg.contains('network') || msg.contains('connection')) {
      return '网络连接失败，请检查网络';
    }
    return '认证失败，请重试';
  }
}

/// Auth Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});
