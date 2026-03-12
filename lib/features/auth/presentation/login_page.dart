import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/errors/error_handler.dart';
import '../data/auth_repository.dart';
import '../providers/auth_provider.dart';
import 'privacy_consent_dialog.dart';

/// 登录页 — 邮箱 + 密码 + Apple 登录
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _privacyAgreed = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 邮箱登录
  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_privacyAgreed) {
      final agreed = await PrivacyConsentDialog.show(context);
      if (!agreed) return;
      setState(() => _privacyAgreed = true);
    }

    ref.read(loginLoadingProvider.notifier).state = true;
    try {
      await ref.read(authRepositoryProvider).signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
          );
      // 登录成功后路由守卫会自动跳转
    } catch (e) {
      if (mounted) ErrorHandler.showError(context, e);
    } finally {
      ref.read(loginLoadingProvider.notifier).state = false;
    }
  }

  /// 邮箱注册
  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_privacyAgreed) {
      final agreed = await PrivacyConsentDialog.show(context);
      if (!agreed) return;
      setState(() => _privacyAgreed = true);
    }

    ref.read(loginLoadingProvider.notifier).state = true;
    try {
      await ref.read(authRepositoryProvider).signUpWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (mounted) {
        ErrorHandler.showSuccess(context, '注册成功！请查收邮箱确认链接');
        // 切换到登录模式
        ref.read(loginModeProvider.notifier).state = LoginMode.login;
      }
    } catch (e) {
      if (mounted) ErrorHandler.showError(context, e);
    } finally {
      ref.read(loginLoadingProvider.notifier).state = false;
    }
  }

  /// Apple 登录
  Future<void> _signInWithApple() async {
    if (!_privacyAgreed) {
      final agreed = await PrivacyConsentDialog.show(context);
      if (!agreed) return;
      setState(() => _privacyAgreed = true);
    }

    ref.read(loginLoadingProvider.notifier).state = true;
    try {
      await ref.read(authRepositoryProvider).signInWithApple();
    } catch (e) {
      if (mounted) ErrorHandler.showError(context, e);
    } finally {
      ref.read(loginLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginMode = ref.watch(loginModeProvider);
    final isLoading = ref.watch(loginLoadingProvider);
    final passwordVisible = ref.watch(passwordVisibleProvider);
    final isLogin = loginMode == LoginMode.login;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SizedBox(
            height: context.screenHeight -
                context.padding.top -
                context.padding.bottom,
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // 标题
                Text(context.l10n.loginTitle, style: AppTextStyles.h1),
                const SizedBox(height: 8),
                Text(
                  context.l10n.loginSubtitle,
                  style: AppTextStyles.caption.copyWith(
                    color:
                        context.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 48),

                // 邮箱 + 密码表单
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // 邮箱输入
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: context.l10n.emailLabel,
                          hintText: context.l10n.emailHint,
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 密码输入
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !passwordVisible,
                        validator: Validators.password,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) =>
                            isLogin ? _signInWithEmail() : _signUpWithEmail(),
                        decoration: InputDecoration(
                          labelText: context.l10n.passwordLabel,
                          hintText: context.l10n.passwordHint,
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              passwordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              ref
                                  .read(passwordVisibleProvider.notifier)
                                  .state = !passwordVisible;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 登录/注册按钮
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : (isLogin
                                  ? _signInWithEmail
                                  : _signUpWithEmail),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(isLogin
                                  ? context.l10n.login
                                  : context.l10n.register),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 切换登录/注册
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                ref.read(loginModeProvider.notifier).state =
                                    isLogin
                                        ? LoginMode.register
                                        : LoginMode.login;
                              },
                        child: Text(
                          isLogin
                              ? context.l10n.switchToRegister
                              : context.l10n.switchToLogin,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 分隔线
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        context.l10n.orLoginWith,
                        style: AppTextStyles.caption,
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                // Apple 登录
                OutlinedButton.icon(
                  onPressed: isLoading ? null : _signInWithApple,
                  icon: const Icon(Icons.apple, size: 24),
                  label: Text(context.l10n.signInWithApple),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // 隐私政策
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text.rich(
                    TextSpan(
                      text: context.l10n.privacyAgreement,
                      style: AppTextStyles.caption.copyWith(
                        color: context.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                      ),
                      children: [
                        TextSpan(
                          text: context.l10n.privacyPolicy,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        TextSpan(text: context.l10n.and),
                        TextSpan(
                          text: context.l10n.termsOfService,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
