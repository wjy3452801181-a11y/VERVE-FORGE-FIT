import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/errors/error_handler.dart';
import '../data/ai_avatar_repository.dart';
import '../domain/ai_avatar_model.dart';
import '../providers/ai_avatar_provider.dart';
import 'widgets/personality_chip.dart';
import 'widgets/style_selector.dart';
import 'widgets/ai_consent_dialog.dart';

/// AI 分身创建页 — 3 步向导式（玻璃拟态 + Material 3 深色适配）
///
/// Step 1: 外貌选择（24 个预设 emoji 头像 + 自定义上传）
/// Step 2: 个性标签（16 个运动主题标签多选，最多 5 个）
/// Step 3: 名称 + 说话风格预览 + 自定义指令 + 创建按钮
class AiAvatarCreatePage extends ConsumerStatefulWidget {
  const AiAvatarCreatePage({super.key});

  @override
  ConsumerState<AiAvatarCreatePage> createState() =>
      _AiAvatarCreatePageState();
}

class _AiAvatarCreatePageState extends ConsumerState<AiAvatarCreatePage>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Step 1: 外貌
  String? _selectedPresetKey; // 选中的预设头像 key
  File? _selectedImage; // 用户自定义上传的图片
  String? _uploadedAvatarUrl;

  // Step 2: 个性标签（最多 5 个）
  final Set<String> _selectedTraits = {};

  // Step 3: 名称 + 说话风格 + 自定义提示词
  final _nameController = TextEditingController();
  String _selectedStyle = 'lively';
  final _customPromptController = TextEditingController();

  late final AnimationController _stepAnimController;

  @override
  void initState() {
    super.initState();
    _stepAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _customPromptController.dispose();
    _stepAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(context.l10n.aiAvatarCreate),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0D0D0D),
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                  ]
                : [
                    const Color(0xFFF8F9FA),
                    const Color(0xFFE8EAF6),
                    const Color(0xFFF3E5F5),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 步骤指示器
              _buildStepIndicator(),
              // 内容区
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1Appearance(),
                    _buildStep2Personality(),
                    _buildStep3NameAndStyle(),
                  ],
                ),
              ),
              // 底部操作按钮
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 步骤指示器 — 圆形编号 + 连线 + 动态高亮
  // ============================================================
  Widget _buildStepIndicator() {
    final steps = [
      context.l10n.aiAvatarStepStyle,
      context.l10n.aiAvatarStepPersonality,
      context.l10n.aiAvatarStepName,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          // 奇数位 → 连线
          if (i.isOdd) {
            final stepBefore = i ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1),
                  color: stepBefore < _currentStep
                      ? AppColors.info
                      : context.colorScheme.outlineVariant,
                ),
              ),
            );
          }
          // 偶数位 → 圆形步骤编号
          final stepIndex = i ~/ 2;
          final isActive = stepIndex <= _currentStep;
          final isCurrent = stepIndex == _currentStep;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isCurrent ? 36 : 28,
                height: isCurrent ? 36 : 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? AppColors.info
                      : context.colorScheme.surfaceContainerHighest,
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: AppColors.info.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${stepIndex + 1}',
                    style: TextStyle(
                      fontSize: isCurrent ? 14 : 12,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? Colors.white
                          : context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                steps[stepIndex],
                style: AppTextStyles.label.copyWith(
                  color: isActive
                      ? AppColors.info
                      : context.colorScheme.onSurfaceVariant,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ============================================================
  // Step 1: 外貌选择 — 24 个预设 emoji 头像网格 + 自定义上传
  // ============================================================
  Widget _buildStep1Appearance() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      children: [
        // 选中的头像预览
        Center(child: _buildSelectedAvatarPreview()),
        AppSpacing.vGap20,

        // 预设头像网格（玻璃拟态卡片）
        _buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.aiAvatarPickPreset,
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: AppSpacing.x12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 1,
                ),
                itemCount: AiAvatarModel.presetAvatars.length,
                itemBuilder: (context, index) {
                  final preset = AiAvatarModel.presetAvatars[index];
                  final isSelected = _selectedPresetKey == preset.key &&
                      _selectedImage == null;
                  return _buildPresetAvatarItem(preset, isSelected);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.x12),

        // 自定义上传入口
        _buildGlassCard(
          child: InkWell(
            onTap: _pickImage,
            borderRadius: BorderRadius.circular(AppSpacing.x12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  const Icon(
                    Icons.add_a_photo_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  AppSpacing.hGap12,
                  Text(
                    context.l10n.aiAvatarOrUpload,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (_selectedImage != null)
                    const Icon(Icons.check_circle,
                        color: AppColors.primary, size: 20),
                ],
              ),
            ),
          ),
        ),
        AppSpacing.vGapLG,
      ],
    );
  }

  /// 选中头像预览（大号，带动画）
  Widget _buildSelectedAvatarPreview() {
    final preset = _selectedPresetKey != null
        ? AiAvatarModel.presetAvatars
            .where((p) => p.key == _selectedPresetKey)
            .firstOrNull
        : null;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey('$_selectedPresetKey-${_selectedImage?.path}'),
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: 0.1),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
          image: _selectedImage != null
              ? DecorationImage(
                  image: FileImage(_selectedImage!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _selectedImage != null
            ? null
            : Center(
                child: Text(
                  preset?.emoji ?? '🤖',
                  style: const TextStyle(fontSize: 44),
                ),
              ),
      ),
    );
  }

  /// 单个预设头像网格项
  Widget _buildPresetAvatarItem(PresetAvatar preset, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPresetKey = preset.key;
          _selectedImage = null; // 清除自定义上传
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.2)
              : context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.x12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            preset.emoji,
            style: TextStyle(fontSize: isSelected ? 26 : 22),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Step 2: 个性标签选择（运动主题，多选，最多 5 个）
  // ============================================================
  Widget _buildStep2Personality() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      children: [
        _buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.aiAvatarStepPersonality,
                style: AppTextStyles.h3,
              ),
              AppSpacing.vGapXS,
              Text(
                context.l10n.aiAvatarSelectTraitsHint,
                style: AppTextStyles.caption.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              AppSpacing.vGapMD,
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.x10,
                children: AiAvatarModel.availableTraits.map((trait) {
                  final isSelected = _selectedTraits.contains(trait);
                  return PersonalityChip(
                    trait: trait,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedTraits.remove(trait);
                        } else if (_selectedTraits.length < 5) {
                          _selectedTraits.add(trait);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.x12),

        // 已选计数
        if (_selectedTraits.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Text(
              '${_selectedTraits.length}/5',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
      ],
    );
  }

  // ============================================================
  // Step 3: 名称 + 说话风格预览 + 自定义指令 + 创建
  // ============================================================
  Widget _buildStep3NameAndStyle() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      children: [
        // 名称输入
        _buildGlassCard(
          child: TextField(
            controller: _nameController,
            maxLength: 50,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              labelText: context.l10n.aiAvatarName,
              hintText: context.l10n.aiAvatarNameHint,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.badge_outlined),
            ),
          ),
        ),
        AppSpacing.vGap12,

        // 说话风格选择器（含实时预览气泡）
        _buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.aiAvatarPreviewTitle,
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: AppSpacing.x12),
              StyleSelector(
                selectedStyle: _selectedStyle,
                onChanged: (style) {
                  setState(() => _selectedStyle = style);
                },
              ),
            ],
          ),
        ),
        AppSpacing.vGap12,

        // 自定义指令
        _buildGlassCard(
          child: TextField(
            controller: _customPromptController,
            maxLines: 3,
            maxLength: 500,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              labelText: context.l10n.aiAvatarCustomPrompt,
              hintText: context.l10n.aiAvatarCustomPromptHint,
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
        ),
        AppSpacing.vGapLG,
      ],
    );
  }

  // ============================================================
  // 底部按钮栏
  // ============================================================
  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.x12),
      child: Row(
        children: [
          // 上一步按钮
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousStep,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: Text(context.l10n.commonCancel),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) AppSpacing.hGap12,

          // 下一步 / 创建按钮
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: _isLoading ? null : _nextStep,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.info,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentStep < 2
                              ? context.l10n.next
                              : context.l10n.aiAvatarCreate,
                          style: AppTextStyles.button,
                        ),
                        if (_currentStep < 2) ...[
                          AppSpacing.hGapXS,
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 玻璃拟态卡片容器
  // ============================================================
  Widget _buildGlassCard({required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.md),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: AppSpacing.cardPaddingCompact,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(AppSpacing.md),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.5),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  // ============================================================
  // 导航逻辑
  // ============================================================
  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  Future<void> _nextStep() async {
    // Step 1 验证：必须选择头像
    if (_currentStep == 0) {
      if (_selectedPresetKey == null && _selectedImage == null) {
        ErrorHandler.showError(context, '请选择一个头像');
        return;
      }
    }

    // Step 2 验证：性格标签可选，不强制

    // 前进到下一步
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
      return;
    }

    // Step 3 验证：名称必填
    if (_nameController.text.trim().isEmpty) {
      ErrorHandler.showError(context, '请输入分身名称');
      return;
    }

    // 弹出 AI 数据授权同意弹窗
    final consent = await AiConsentDialog.show(context);
    if (!consent) return;

    // 创建分身
    await _saveAvatar();
  }

  Future<void> _saveAvatar() async {
    setState(() => _isLoading = true);

    try {
      // 上传自定义头像
      if (_selectedImage != null) {
        final repo = ref.read(aiAvatarRepositoryProvider);
        _uploadedAvatarUrl = await repo.uploadAvatarImage(_selectedImage!);
      }

      // 确定头像 URL：自定义上传 > 预设 key（存为 preset:xxx 格式）
      final avatarUrl = _uploadedAvatarUrl ??
          (_selectedPresetKey != null ? 'preset:$_selectedPresetKey' : null);

      // 调用 provider 创建分身
      await ref.read(currentAiAvatarProvider.notifier).createAvatar(
            name: _nameController.text.trim(),
            avatarUrl: avatarUrl,
            personalityTraits: _selectedTraits.toList(),
            speakingStyle: _selectedStyle,
            customPrompt: _customPromptController.text.trim(),
          );

      if (mounted) {
        await _showCreationSuccessOverlay(
          avatarEmoji: _selectedPresetKey != null
              ? (AiAvatarModel.presetAvatars
                      .where((p) => p.key == _selectedPresetKey)
                      .firstOrNull
                      ?.emoji ??
                  '🤖')
              : '🤖',
          avatarName: _nameController.text.trim(),
        );
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showError(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _selectedPresetKey = null; // 清除预设选中
      });
    }
  }

  /// 分身创建成功庆祝弹窗 — 全屏模态 + 自动关闭
  Future<void> _showCreationSuccessOverlay({
    required String avatarEmoji,
    required String avatarName,
  }) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (ctx, anim, _, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (ctx, _, __) {
        // 自动 1.8s 后关闭
        Future.delayed(const Duration(milliseconds: 1800), () {
          if (ctx.mounted) Navigator.of(ctx).pop();
        });
        return _AvatarCreatedOverlay(
          avatarEmoji: avatarEmoji,
          avatarName: avatarName,
        );
      },
    );
  }
}

// ============================================================
// 分身创建成功庆祝覆盖层 — 全屏模态 + 发光效果
// ============================================================
class _AvatarCreatedOverlay extends StatelessWidget {
  final String avatarEmoji;
  final String avatarName;

  const _AvatarCreatedOverlay({
    required this.avatarEmoji,
    required this.avatarName,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 发光头像
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.info.withValues(alpha: 0.12),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.4),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.info.withValues(alpha: 0.35),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: Center(
                child: Text(avatarEmoji,
                    style: const TextStyle(fontSize: 48)),
              ),
            ),
            AppSpacing.vGapLG,
            Text(
              context.l10n.aiAvatarCreatedTitle,
              style: AppTextStyles.h2.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGapSM,
            Text(
              avatarName,
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.info,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            AppSpacing.vGapSM,
            Text(
              context.l10n.aiAvatarCreatedSubtitle,
              style: AppTextStyles.body.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
