import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client.dart';

/// 认证状态 Provider — 监听 Supabase Auth 状态变化
final authStateProvider = StreamProvider<Session?>((ref) {
  return SupabaseClientHelper.client.auth.onAuthStateChange.map(
    (event) => event.session,
  );
});

/// 当前用户 Provider
final currentUserProvider = Provider<User?>((ref) {
  return SupabaseClientHelper.currentUser;
});

/// 是否已登录
final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull != null;
});

/// OTP 发送状态（倒计时用）
final otpCooldownProvider =
    StateNotifierProvider<OtpCooldownNotifier, int>((ref) {
  return OtpCooldownNotifier();
});

class OtpCooldownNotifier extends StateNotifier<int> {
  OtpCooldownNotifier() : super(0); // 0 = 可发送

  /// 开始 60 秒倒计时
  void startCooldown() {
    state = 60;
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      if (state > 0) {
        state = state - 1;
        _tick();
      }
    });
  }

  /// 是否在冷却中
  bool get isCooling => state > 0;
}

/// 登录流程状态
enum LoginStep { phone, otp }

final loginStepProvider = StateProvider<LoginStep>((ref) => LoginStep.phone);

/// 登录加载状态
final loginLoadingProvider = StateProvider<bool>((ref) => false);
