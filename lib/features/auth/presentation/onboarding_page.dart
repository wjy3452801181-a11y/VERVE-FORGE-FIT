import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/sport_type_icon.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/providers/profile_provider.dart';

/// 注册引导页 — 3 步完成：运动偏好 → 城市 → 头像昵称
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pageController = PageController();
  final _nicknameController = TextEditingController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Step 1: 运动偏好
  final Set<String> _selectedSports = {};

  // Step 2: 城市
  String? _selectedCity;

  // Step 3: 头像 + 昵称
  File? _avatarFile;
  String? _selectedGender;
  String? _selectedLevel;

  @override
  void dispose() {
    _pageController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  /// 下一步
  void _nextStep() {
    if (_currentStep == 0 && _selectedSports.isEmpty) {
      ErrorHandler.showError(context, '请至少选择一项运动');
      return;
    }
    if (_currentStep == 1 && _selectedCity == null) {
      ErrorHandler.showError(context, '请选择你所在的城市');
      return;
    }
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// 完成引导
  Future<void> _completeOnboarding() async {
    final nickname = _nicknameController.text.trim();
    if (Validators.nickname(nickname) != null) {
      ErrorHandler.showError(context, '请输入有效昵称（2-20字符）');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(profileRepositoryProvider);

      // 上传头像（如有）
      String? avatarUrl;
      if (_avatarFile != null) {
        avatarUrl = await repo.uploadAvatar(_avatarFile!);
      }

      // 创建档案
      await repo.createProfile(
        nickname: nickname,
        city: _selectedCity!,
        sportTypes: _selectedSports.toList(),
        avatarUrl: avatarUrl,
        gender: _selectedGender,
        experienceLevel: _selectedLevel,
      );

      // 刷新档案状态
      await ref.read(currentProfileProvider.notifier).refresh();

      if (mounted) {
        context.go(AppRoutes.feed);
      }
    } catch (e) {
      if (mounted) ErrorHandler.showError(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 选择头像
  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => _avatarFile = File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 顶部进度条
            _buildProgressBar(),
            const SizedBox(height: 16),

            // 页面内容
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildSportStep(),
                  _buildCityStep(),
                  _buildProfileStep(),
                ],
              ),
            ),

            // 底部按钮
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  /// 进度条
  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : context.colorScheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Step 1: 选择运动类型
  Widget _buildSportStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(context.l10n.onboardingStep1Title, style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text(
            context.l10n.onboardingStep1Subtitle,
            style: AppTextStyles.caption.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 32),

          // 运动类型网格
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: AppConstants.sportTypes.map((sport) {
              final isSelected = _selectedSports.contains(sport);
              return _buildSportChip(sport, isSelected);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSportChip(String sport, bool isSelected) {
    final labels = {
      'hyrox': 'HYROX',
      'crossfit': 'CrossFit',
      'yoga': context.l10n.sportYoga,
      'pilates': context.l10n.sportPilates,
      'running': context.l10n.sportRunning,
      'swimming': context.l10n.sportSwimming,
      'strength': context.l10n.sportStrength,
      'other': context.l10n.sportOther,
    };

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedSports.remove(sport);
          } else {
            _selectedSports.add(sport);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SportTypeIcon(sportType: sport, size: 28),
            const SizedBox(width: 10),
            Text(
              labels[sport] ?? sport,
              style: AppTextStyles.subtitle.copyWith(
                color: isSelected ? AppColors.primary : null,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
            ],
          ],
        ),
      ),
    );
  }

  /// Step 2: 选择城市
  Widget _buildCityStep() {
    final cities = {
      'beijing': context.l10n.cityBeijing,
      'shanghai': context.l10n.cityShanghai,
      'guangzhou': context.l10n.cityGuangzhou,
      'shenzhen': context.l10n.cityShenzhen,
      'hongkong': context.l10n.cityHongkong,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(context.l10n.onboardingStep2Title, style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text(
            context.l10n.onboardingStep2Subtitle,
            style: AppTextStyles.caption.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 32),

          // 城市列表
          ...cities.entries.map((entry) {
            final isSelected = _selectedCity == entry.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                tileColor: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : context.colorScheme.surfaceContainerHighest,
                leading: const Icon(Icons.location_city),
                title: Text(entry.value, style: AppTextStyles.subtitle),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () => setState(() => _selectedCity = entry.key),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Step 3: 头像 + 昵称 + 性别 + 经验等级
  Widget _buildProfileStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(context.l10n.onboardingStep3Title, style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text(
            context.l10n.onboardingStep3Subtitle,
            style: AppTextStyles.caption.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 32),

          // 头像选择
          Center(
            child: GestureDetector(
              onTap: _pickAvatar,
              child: Stack(
                children: [
                  _avatarFile != null
                      ? CircleAvatar(
                          radius: 48,
                          backgroundImage: FileImage(_avatarFile!),
                        )
                      : const AvatarWidget(size: 96, fallbackText: '?'),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 昵称
          TextFormField(
            controller: _nicknameController,
            decoration: InputDecoration(
              labelText: context.l10n.profileNickname,
              hintText: '给自己取个名字吧',
              prefixIcon: const Icon(Icons.person_outline),
            ),
            validator: Validators.nickname,
          ),
          const SizedBox(height: 16),

          // 性别（可选）
          DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: const InputDecoration(
              labelText: '性别（可选）',
              prefixIcon: Icon(Icons.wc_outlined),
            ),
            items: const [
              DropdownMenuItem(value: 'male', child: Text('男')),
              DropdownMenuItem(value: 'female', child: Text('女')),
              DropdownMenuItem(value: 'other', child: Text('其他')),
              DropdownMenuItem(
                  value: 'prefer_not_to_say', child: Text('不愿透露')),
            ],
            onChanged: (v) => setState(() => _selectedGender = v),
          ),
          const SizedBox(height: 16),

          // 经验等级（可选）
          DropdownButtonFormField<String>(
            value: _selectedLevel,
            decoration: const InputDecoration(
              labelText: '运动经验（可选）',
              prefixIcon: Icon(Icons.trending_up_outlined),
            ),
            items: [
              DropdownMenuItem(
                  value: 'beginner', child: Text(context.l10n.levelBeginner)),
              DropdownMenuItem(
                  value: 'intermediate',
                  child: Text(context.l10n.levelIntermediate)),
              DropdownMenuItem(
                  value: 'advanced', child: Text(context.l10n.levelAdvanced)),
              DropdownMenuItem(
                  value: 'elite', child: Text(context.l10n.levelElite)),
            ],
            onChanged: (v) => setState(() => _selectedLevel = v),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// 底部按钮栏
  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          // 返回按钮
          if (_currentStep > 0)
            TextButton(
              onPressed: () {
                setState(() => _currentStep--);
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text('返回'),
            ),
          const Spacer(),

          // 下一步 / 完成
          SizedBox(
            width: 160,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : (_currentStep < 2 ? _nextStep : _completeOnboarding),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      _currentStep < 2
                          ? context.l10n.next
                          : context.l10n.done,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
