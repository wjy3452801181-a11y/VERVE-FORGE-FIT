import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/avatar_widget.dart';
import '../../../shared/widgets/sport_type_icon.dart';
import '../domain/profile_model.dart';
import '../providers/profile_provider.dart';

/// 档案编辑页
class ProfileEditPage extends ConsumerStatefulWidget {
  final ProfileModel profile;

  const ProfileEditPage({super.key, required this.profile});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  late final TextEditingController _nicknameController;
  late final TextEditingController _bioController;
  late Set<String> _selectedSports;
  late String? _selectedCity;
  late String? _selectedGender;
  late String? _selectedLevel;
  File? _newAvatarFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.profile.nickname);
    _bioController = TextEditingController(text: widget.profile.bio);
    _selectedSports = Set.from(widget.profile.sportTypes);
    _selectedCity = widget.profile.city;
    _selectedGender = widget.profile.gender;
    _selectedLevel = widget.profile.experienceLevel;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => _newAvatarFile = File(image.path));
    }
  }

  Future<void> _save() async {
    final nickname = _nicknameController.text.trim();
    if (Validators.nickname(nickname) != null) {
      ErrorHandler.showError(context, '请输入有效昵称（2-20字符）');
      return;
    }
    if (_selectedSports.isEmpty) {
      ErrorHandler.showError(context, '请至少选择一项运动');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final notifier = ref.read(currentProfileProvider.notifier);

      // 上传新头像
      String? avatarUrl = widget.profile.avatarUrl;
      if (_newAvatarFile != null) {
        avatarUrl = await notifier.uploadAvatar(_newAvatarFile!);
      }

      // 更新档案
      final updated = widget.profile.copyWith(
        nickname: nickname,
        bio: _bioController.text.trim(),
        avatarUrl: avatarUrl,
        sportTypes: _selectedSports.toList(),
        city: _selectedCity,
        gender: _selectedGender,
        experienceLevel: _selectedLevel,
      );

      await notifier.updateProfile(updated);

      if (mounted) {
        ErrorHandler.showSuccess(context, '保存成功');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ErrorHandler.showError(context, e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.profileEdit),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(context.l10n.commonSave),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 头像
            GestureDetector(
              onTap: _pickAvatar,
              child: Stack(
                children: [
                  _newAvatarFile != null
                      ? CircleAvatar(
                          radius: 48,
                          backgroundImage: FileImage(_newAvatarFile!),
                        )
                      : AvatarWidget(
                          size: 96,
                          imageUrl: widget.profile.avatarUrl,
                          fallbackText: widget.profile.nickname,
                        ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 昵称
            TextFormField(
              controller: _nicknameController,
              decoration: InputDecoration(
                labelText: context.l10n.profileNickname,
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),

            // 简介
            TextFormField(
              controller: _bioController,
              maxLines: 3,
              maxLength: 200,
              decoration: InputDecoration(
                labelText: context.l10n.profileBio,
                hintText: '介绍一下你自己',
                prefixIcon: const Icon(Icons.edit_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            // 性别
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: '性别',
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

            // 城市
            DropdownButtonFormField<String>(
              value: _selectedCity,
              decoration: const InputDecoration(
                labelText: '城市',
                prefixIcon: Icon(Icons.location_city),
              ),
              items: [
                DropdownMenuItem(
                    value: 'beijing', child: Text(context.l10n.cityBeijing)),
                DropdownMenuItem(
                    value: 'shanghai', child: Text(context.l10n.cityShanghai)),
                DropdownMenuItem(
                    value: 'guangzhou', child: Text(context.l10n.cityGuangzhou)),
                DropdownMenuItem(
                    value: 'shenzhen', child: Text(context.l10n.cityShenzhen)),
                DropdownMenuItem(
                    value: 'hongkong', child: Text(context.l10n.cityHongkong)),
              ],
              onChanged: (v) => setState(() => _selectedCity = v),
            ),
            const SizedBox(height: 16),

            // 经验等级
            DropdownButtonFormField<String>(
              value: _selectedLevel,
              decoration: const InputDecoration(
                labelText: '运动经验',
                prefixIcon: Icon(Icons.trending_up_outlined),
              ),
              items: [
                DropdownMenuItem(
                    value: 'beginner',
                    child: Text(context.l10n.levelBeginner)),
                DropdownMenuItem(
                    value: 'intermediate',
                    child: Text(context.l10n.levelIntermediate)),
                DropdownMenuItem(
                    value: 'advanced',
                    child: Text(context.l10n.levelAdvanced)),
                DropdownMenuItem(
                    value: 'elite', child: Text(context.l10n.levelElite)),
              ],
              onChanged: (v) => setState(() => _selectedLevel = v),
            ),
            const SizedBox(height: 24),

            // 运动偏好
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('运动偏好', style: AppTextStyles.subtitle),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.sportTypes.map((sport) {
                final isSelected = _selectedSports.contains(sport);
                return FilterChip(
                  selected: isSelected,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SportTypeIcon(sportType: sport, size: 20),
                      const SizedBox(width: 6),
                      Text(sport),
                    ],
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSports.add(sport);
                      } else {
                        _selectedSports.remove(sport);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
