import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/errors/error_handler.dart';
import '../../workout/presentation/widgets/photo_grid.dart';
import '../data/gym_repository.dart';
import '../providers/gym_provider.dart';

/// 提交新训练馆页面
class GymSubmitPage extends ConsumerStatefulWidget {
  const GymSubmitPage({super.key});

  @override
  ConsumerState<GymSubmitPage> createState() => _GymSubmitPageState();
}

class _GymSubmitPageState extends ConsumerState<GymSubmitPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  final _openingHoursController = TextEditingController();

  String _city = AppConstants.supportedCities.first;
  final List<String> _selectedSportTypes = [];
  final List<File> _pendingPhotos = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _openingHoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.gymSubmit),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // 训练馆名称
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: context.l10n.gymTitle,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? '请输入训练馆名称' : null,
              ),
            ),
            const SizedBox(height: 16),

            // 地址
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: context.l10n.gymAddress,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? '请输入地址' : null,
              ),
            ),
            const SizedBox(height: 16),

            // 城市选择
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonFormField<String>(
                value: _city,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.supportedCities
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(_cityName(context, c)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _city = v!),
              ),
            ),
            const SizedBox(height: 24),

            // 运动类型选择
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                context.l10n.gymSportTypes,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.sportTypes.map((type) {
                  final isSelected = _selectedSportTypes.contains(type);
                  return FilterChip(
                    label: Text(_sportLabel(context, type)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSportTypes.add(type);
                        } else {
                          _selectedSportTypes.remove(type);
                        }
                      });
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // 电话
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: context.l10n.gymPhone,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 描述
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: '简介',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 网站
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: _websiteController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: context.l10n.gymWebsite,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 营业时间
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: _openingHoursController,
                decoration: InputDecoration(
                  labelText: context.l10n.gymOpeningHours,
                  hintText: '例：09:00-22:00',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 照片
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                context.l10n.workoutPhotos,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PhotoGrid(
                pendingFiles: _pendingPhotos,
                onAdd: _pickPhotos,
                onRemoveFile: (index) {
                  setState(() => _pendingPhotos.removeAt(index));
                },
              ),
            ),
            const SizedBox(height: 32),

            // 提交按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton(
                onPressed: _isSaving ? null : _submit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(context.l10n.gymSubmit),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPhotos() async {
    final remaining = AppConstants.maxPhotos - _pendingPhotos.length;
    if (remaining <= 0) return;
    final files = await pickPhotos(maxCount: remaining);
    if (files.isNotEmpty) {
      setState(() => _pendingPhotos.addAll(files));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSportTypes.isEmpty) {
      ErrorHandler.showError(context, '请至少选择一种运动类型');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(gymRepositoryProvider);

      // 获取当前位置作为训练馆坐标
      final location = await ref.read(currentLocationProvider.future);
      final lat = location?.latitude ?? 0;
      final lng = location?.longitude ?? 0;

      // 上传照片
      List<String> photoUrls = [];
      if (_pendingPhotos.isNotEmpty) {
        photoUrls = await repo.uploadPhotos(_pendingPhotos);
      }

      await repo.submit(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        city: _city,
        latitude: lat,
        longitude: lng,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        website: _websiteController.text.trim().isEmpty
            ? null
            : _websiteController.text.trim(),
        openingHours: _openingHoursController.text.trim().isEmpty
            ? null
            : _openingHoursController.text.trim(),
        sportTypes: _selectedSportTypes,
        photoUrls: photoUrls,
      );

      ref.invalidate(nearbyGymsProvider);
      ref.invalidate(gymListProvider);

      if (mounted) {
        ErrorHandler.showSuccess(context, context.l10n.gymSubmitSuccess);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ErrorHandler.showError(context, e);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _cityName(BuildContext context, String city) {
    final l10n = context.l10n;
    final names = {
      'beijing': l10n.cityBeijing,
      'shanghai': l10n.cityShanghai,
      'guangzhou': l10n.cityGuangzhou,
      'shenzhen': l10n.cityShenzhen,
      'hongkong': l10n.cityHongkong,
    };
    return names[city] ?? city;
  }

  String _sportLabel(BuildContext context, String type) {
    final l10n = context.l10n;
    switch (type) {
      case 'hyrox':
        return l10n.sportHyrox;
      case 'crossfit':
        return l10n.sportCrossfit;
      case 'yoga':
        return l10n.sportYoga;
      case 'pilates':
        return l10n.sportPilates;
      case 'running':
        return l10n.sportRunning;
      case 'swimming':
        return l10n.sportSwimming;
      case 'strength':
        return l10n.sportStrength;
      default:
        return l10n.sportOther;
    }
  }
}
