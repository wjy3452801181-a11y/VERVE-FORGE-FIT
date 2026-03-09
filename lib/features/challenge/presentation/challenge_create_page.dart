import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/errors/error_handler.dart';
import '../data/challenge_repository.dart';
import '../providers/challenge_provider.dart';
import '../../workout/presentation/widgets/sport_type_selector.dart';

/// 创建挑战赛页面
class ChallengeCreatePage extends ConsumerStatefulWidget {
  const ChallengeCreatePage({super.key});

  @override
  ConsumerState<ChallengeCreatePage> createState() =>
      _ChallengeCreatePageState();
}

class _ChallengeCreatePageState extends ConsumerState<ChallengeCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _goalValueController = TextEditingController();
  final _maxParticipantsController = TextEditingController(text: '100');

  String _sportType = AppConstants.sportTypes.first;
  String _goalType = 'total_sessions';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  String? _city;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _goalValueController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.challengeCreate),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // 标题
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: context.l10n.challengeTitle,
                  hintText: '给挑战取个名字',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? '请输入标题' : null,
              ),
            ),
            const SizedBox(height: 16),

            // 运动类型
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                context.l10n.challengeSportType,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: 8),
            SportTypeSelector(
              selected: _sportType,
              onSelected: (type) => setState(() => _sportType = type),
            ),
            const SizedBox(height: 24),

            // 目标类型
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                context.l10n.challengeGoalType,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'total_sessions',
                    label: Text(context.l10n.challengeGoalSessions),
                  ),
                  ButtonSegment(
                    value: 'total_minutes',
                    label: Text(context.l10n.challengeGoalMinutes),
                  ),
                  ButtonSegment(
                    value: 'total_days',
                    label: Text(context.l10n.challengeGoalDays),
                  ),
                ],
                selected: {_goalType},
                onSelectionChanged: (set) {
                  setState(() => _goalType = set.first);
                },
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.15),
                  selectedForegroundColor: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 目标值
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: _goalValueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.l10n.challengeGoalValue,
                  hintText: _goalType == 'total_sessions'
                      ? '如：30 次'
                      : _goalType == 'total_minutes'
                          ? '如：600 分钟'
                          : '如：21 天',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n <= 0) return '请输入有效数值';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),

            // 日期选择
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: _buildDatePicker(context, isStart: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDatePicker(context, isStart: false)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 城市
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonFormField<String>(
                value: _city,
                decoration: InputDecoration(
                  labelText: context.l10n.challengeCity,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(context.l10n.challengeCityAll),
                  ),
                  ...AppConstants.supportedCities.map(
                    (city) => DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _city = v),
              ),
            ),
            const SizedBox(height: 16),

            // 最大参与人数
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: _maxParticipantsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.l10n.challengeMaxParticipants,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 2) return '至少 2 人';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),

            // 描述
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: _descController,
                maxLines: 3,
                maxLength: 500,
                decoration: InputDecoration(
                  labelText: context.l10n.challengeDescription,
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 保存按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
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
                    : Text(context.l10n.challengeCreate),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, {required bool isStart}) {
    final date = isStart ? _startDate : _endDate;
    final label = isStart
        ? context.l10n.challengeStartDate
        : context.l10n.challengeEndDate;

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: isStart ? DateTime.now() : _startDate,
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          setState(() {
            if (isStart) {
              _startDate = picked;
              // 确保结束日期在开始日期之后
              if (_endDate.isBefore(_startDate)) {
                _endDate = _startDate.add(const Duration(days: 7));
              }
            } else {
              _endDate = picked;
            }
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(challengeRepositoryProvider);
      await repo.create(
        title: _titleController.text.trim(),
        sportType: _sportType,
        goalType: _goalType,
        goalValue: int.parse(_goalValueController.text),
        startsAt: _startDate,
        endsAt: _endDate,
        description: _descController.text.trim(),
        city: _city,
        maxParticipants:
            int.tryParse(_maxParticipantsController.text) ?? 100,
      );

      ref.invalidate(challengeListProvider);

      if (mounted) {
        ErrorHandler.showSuccess(
            context, context.l10n.challengeCreateSuccess);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ErrorHandler.showError(context, e);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
