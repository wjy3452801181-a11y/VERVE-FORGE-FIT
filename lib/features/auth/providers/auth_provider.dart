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

/// 登录/注册模式切换
enum LoginMode { login, register }

final loginModeProvider = StateProvider<LoginMode>((ref) => LoginMode.login);

/// 登录加载状态
final loginLoadingProvider = StateProvider<bool>((ref) => false);

/// 密码可见性
final passwordVisibleProvider = StateProvider<bool>((ref) => false);
