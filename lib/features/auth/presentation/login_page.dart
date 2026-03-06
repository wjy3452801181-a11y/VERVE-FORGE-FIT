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
import 'widgets/phone_input_field.dart';
import 'widgets/otp_input_field.dart';

/// 登录页 — 手机号 + OTP 验证码 + Apple 登录
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _countryCode = '+86';
  bool _privacyAgreed = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  /// 完整手机号（含区号）
  String get _fullPhone => '$_countryCode${_phoneController.text.trim()}';

  /// 发送验证码
  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    // 隐私政策检查
    if (!_privacyAgreed) {
      final agreed = await PrivacyConsentDialog.show(context);
      if (!agreed) return;
      setState(() => _privacyAgreed = true);
    }

    ref.read(loginLoadingProvider.notifier).state = true;
    try {
      await ref.read(authRepositoryProvider).sendOtp(_fullPhone);
      ref.read(otpCooldownProvider.notifier).startCooldown();
      ref.read(loginStepProvider.notifier).state = LoginStep.otp;
    } catch (e) {
      if (mounted) ErrorHandler.showError(context, e);
    } finally {
      ref.read(loginLoadingProvider.notifier).state = false;
    }
  }

  /// 验证 OTP
  Future<void> _verifyOtp(String otp) async {
    ref.read(loginLoadingProvider.notifier).state = true;
    try {
      await ref.read(authRepositoryProvider).verifyOtp(_fullPhone, otp);
      // 登录成功后路由守卫会自动跳转
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

  /// 返回手机号输入步骤
  void _backToPhone() {
    ref.read(loginStepProvider.notifier).state = LoginStep.phone;
  }

  @override
  Widget build(BuildContext context) {
    final loginStep = ref.watch(loginStepProvider);
    final isLoading = ref.watch(loginLoadingProvider);
    final otpCooldown = ref.watch(otpCooldownProvider);

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
                    color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 48),

                // 手机号 or OTP 输入
                if (loginStep == LoginStep.phone) ...[
                  _buildPhoneStep(isLoading, otpCooldown),
                ] else ...[
                  _buildOtpStep(isLoading, otpCooldown),
                ],

                const SizedBox(height: 32),

                // 分隔线
                if (loginStep == LoginStep.phone) ...[
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
                ],

                const Spacer(flex: 3),

                // 隐私政策
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text.rich(
                    TextSpan(
                      text: context.l10n.privacyAgreement,
                      style: AppTextStyles.caption.copyWith(
                        color: context.colorScheme.onSurface.withValues(alpha: 0.5),
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

  /// 手机号输入步骤
  Widget _buildPhoneStep(bool isLoading, int otpCooldown) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          PhoneInputField(
            controller: _phoneController,
            validator: Validators.phone,
            label: context.l10n.phoneLabel,
            hint: context.l10n.phoneHint,
            countryCode: _countryCode,
            onCountryCodeChanged: (code) {
              setState(() => _countryCode = code);
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _sendOtp,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      otpCooldown > 0
                          ? '${otpCooldown}s 后重新获取'
                          : context.l10n.getOtp,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// OTP 验证码输入步骤
  Widget _buildOtpStep(bool isLoading, int otpCooldown) {
    return Column(
      children: [
        // 返回按钮 + 提示
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _backToPhone,
            ),
            Expanded(
              child: Text(
                '验证码已发送至 $_fullPhone',
                style: AppTextStyles.caption,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // OTP 输入框
        OtpInputField(
          onCompleted: _verifyOtp,
        ),
        const SizedBox(height: 24),

        // 重新发送
        TextButton(
          onPressed: otpCooldown > 0 ? null : _sendOtp,
          child: Text(
            otpCooldown > 0
                ? '${otpCooldown}s 后重新发送'
                : '重新发送验证码',
          ),
        ),

        if (isLoading) ...[
          const SizedBox(height: 16),
          const CircularProgressIndicator(),
        ],
      ],
    );
  }
}
