import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/utils/validators.dart';
import '../../gym/domain/gym_model.dart';
import '../../gym/providers/gym_provider.dart';
import '../data/workout_repository.dart';
import '../providers/workout_provider.dart';
import 'widgets/data_collection_consent.dart';
import 'widgets/metrics_form_switcher.dart';
import 'widgets/sport_type_selector.dart';
import 'widgets/intensity_slider.dart';
import 'widgets/photo_grid.dart';

/// 训练记录创建页 — 完整表单
class WorkoutCreatePage extends ConsumerStatefulWidget {
  const WorkoutCreatePage({super.key});

  @override
  ConsumerState<WorkoutCreatePage> createState() => _WorkoutCreatePageState();
}

class _WorkoutCreatePageState extends ConsumerState<WorkoutCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();

  String _sportType = AppConstants.sportTypes.first;
  int _intensity = 5;
  DateTime _workoutDate = DateTime.now();
  TimeOfDay _workoutTime = TimeOfDay.now();
  bool _isPublic = false;
  final List<File> _pendingPhotos = [];
  bool _isSaving = false;
  GymModel? _selectedGym;
  Map<String, dynamic> _metrics = {};
  bool _consentChecked = false;

  @override
  void dispose() {
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.workoutCreate),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : () => _save(isDraft: true),
            child: Text(context.l10n.workoutSaveDraft),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // 运动类型选择
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                context.l10n.workoutType,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: 8),
            SportTypeSelector(
              selected: _sportType,
              onSelected: (type) {
                setState(() {
                  _sportType = type;
                  _metrics = {}; // 切换运动类型时重置 metrics
                });
              },
            ),
            const SizedBox(height: 16),

            // 运动专项成绩（可折叠）
            if (MetricsFormSwitcher.hasMetricsForm(_sportType))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MetricsFormSwitcher(
                  sportType: _sportType,
                  onMetricsChanged: (m) => _metrics = m,
                ),
              ),
            const SizedBox(height: 8),

            // 训练时长
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.l10n.workoutDuration,
                  suffixText: 'min',
                  border: const OutlineInputBorder(),
                ),
                validator: Validators.duration,
              ),
            ),
            const SizedBox(height: 24),

            // 训练强度
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                context.l10n.workoutIntensity,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: IntensitySlider(
                value: _intensity,
                onChanged: (v) => setState(() => _intensity = v),
              ),
            ),
            const SizedBox(height: 24),

            // 日期 + 时间
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimePicker(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 备注
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: _notesController,
                maxLines: 3,
                maxLength: 500,
                decoration: InputDecoration(
                  labelText: context.l10n.workoutNotes,
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ),
            const SizedBox(height: 16),

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
            const SizedBox(height: 24),

            // 训练馆选择（可选）
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildGymSelector(context),
            ),
            const SizedBox(height: 24),

            // 发布开关
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.l10n.workoutShareAsPost),
                value: _isPublic,
                onChanged: (v) => setState(() => _isPublic = v),
                activeColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),

            // 保存按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton(
                onPressed: _isSaving ? null : () => _save(isDraft: false),
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
                    : Text(context.l10n.workoutSave),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildGymSelector(BuildContext context) {
    final gymsAsync = ref.watch(nearbyGymsProvider);

    return InkWell(
      onTap: () {
        final gyms = gymsAsync.valueOrNull ?? [];
        if (gyms.isEmpty) return;

        showModalBottomSheet(
          context: context,
          builder: (ctx) => ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: const Text('不选择训练馆'),
                onTap: () {
                  setState(() => _selectedGym = null);
                  Navigator.pop(ctx);
                },
              ),
              ...gyms.map((gym) => ListTile(
                    leading: const Icon(Icons.fitness_center),
                    title: Text(gym.name),
                    subtitle: Text(gym.address),
                    trailing: gym.distanceKm != null
                        ? Text(gym.distanceDisplay)
                        : null,
                    onTap: () {
                      setState(() => _selectedGym = gym);
                      Navigator.pop(ctx);
                    },
                  )),
            ],
          ),
        );
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: context.l10n.gymTitle,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.fitness_center, size: 18),
        ),
        child: Text(
          _selectedGym?.name ?? '选择训练馆（可选）',
          style: TextStyle(
            color: _selectedGym != null
                ? null
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _workoutDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (date != null) setState(() => _workoutDate = date);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: context.l10n.workoutDate,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(
          '${_workoutDate.year}-${_workoutDate.month.toString().padLeft(2, '0')}-${_workoutDate.day.toString().padLeft(2, '0')}',
        ),
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: _workoutTime,
        );
        if (time != null) setState(() => _workoutTime = time);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: context.l10n.workoutTime,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.access_time, size: 18),
        ),
        child: Text(
          '${_workoutTime.hour.toString().padLeft(2, '0')}:${_workoutTime.minute.toString().padLeft(2, '0')}',
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

  Future<void> _save({required bool isDraft}) async {
    if (!isDraft && !_formKey.currentState!.validate()) return;

    // 首次使用时弹出 PIPL 数据采集授权
    if (!_consentChecked) {
      final granted = await DataCollectionConsent.ensureConsent(context);
      if (!granted) return;
      _consentChecked = true;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(workoutRepositoryProvider);

      // 上传照片
      List<String> photoUrls = [];
      if (_pendingPhotos.isNotEmpty) {
        photoUrls = await repo.uploadPhotos(_pendingPhotos);
      }

      final workoutDateTime = DateTime(
        _workoutDate.year,
        _workoutDate.month,
        _workoutDate.day,
        _workoutTime.hour,
        _workoutTime.minute,
      );

      await repo.create(
        sportType: _sportType,
        durationMinutes: int.tryParse(_durationController.text) ?? 0,
        intensity: _intensity,
        workoutDate: workoutDateTime,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        photoUrls: photoUrls,
        isPublic: _isPublic,
        isDraft: isDraft,
        metrics: _metrics,
      );

      // 刷新列表和统计
      ref.invalidate(workoutListProvider);
      ref.invalidate(workoutStatsProvider);

      if (mounted) {
        ErrorHandler.showSuccess(
          context,
          isDraft ? '草稿已保存' : context.l10n.commonSuccess,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ErrorHandler.showError(context, e);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
