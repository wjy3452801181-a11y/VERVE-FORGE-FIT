import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../shared/widgets/empty_state.dart';
import '../domain/workout_model.dart';
import '../providers/workout_provider.dart';
import 'widgets/workout_card.dart';
import 'workout_detail_page.dart';

/// 训练日历页 — table_calendar 月视图
class WorkoutCalendarPage extends ConsumerStatefulWidget {
  const WorkoutCalendarPage({super.key});

  @override
  ConsumerState<WorkoutCalendarPage> createState() =>
      _WorkoutCalendarPageState();
}

class _WorkoutCalendarPageState extends ConsumerState<WorkoutCalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  ({DateTime start, DateTime end}) get _currentRange {
    final first = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final last = DateTime(
        _focusedDay.year, _focusedDay.month + 1, 0, 23, 59, 59);
    return (start: first, end: last);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final range = _currentRange;
    final calendarAsync = ref.watch(workoutCalendarProvider(range));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.workoutCalendar),
      ),
      body: calendarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyStateWidget(
          icon: Icons.error_outline,
          title: context.l10n.commonError,
          actionText: context.l10n.commonRetry,
          onAction: () => ref.invalidate(workoutCalendarProvider(range)),
        ),
        data: (workouts) {
          final Map<DateTime, List<WorkoutModel>> grouped = {};
          for (final w in workouts) {
            final key = DateTime(
                w.workoutDate.year, w.workoutDate.month, w.workoutDate.day);
            grouped.putIfAbsent(key, () => []).add(w);
          }

          final selectedKey = _selectedDay != null
              ? DateTime(_selectedDay!.year, _selectedDay!.month,
                  _selectedDay!.day)
              : null;
          final selectedWorkouts =
              selectedKey != null ? (grouped[selectedKey] ?? []) : <WorkoutModel>[];

          return Column(
            children: [
              TableCalendar<WorkoutModel>(
                firstDay: DateTime(2020, 1, 1),
                lastDay: DateTime.now().add(const Duration(days: 1)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) {
                  setState(() => _calendarFormat = format);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() => _focusedDay = focusedDay);
                },
                eventLoader: (day) {
                  final key = DateTime(day.year, day.month, day.day);
                  return grouped[key] ?? [];
                },
                calendarStyle: CalendarStyle(
                  markerDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  markerSize: 6,
                  markersMaxCount: 3,
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
              Divider(
                height: 1,
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),

              // 选中日期的训练列表
              Expanded(
                child: selectedWorkouts.isEmpty
                    ? Center(
                        child: Text(
                          '该日无训练记录',
                          style: AppTextStyles.caption.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                          top: AppSpacing.xs,
                          bottom: AppSpacing.md,
                        ),
                        itemCount: selectedWorkouts.length,
                        itemBuilder: (context, index) {
                          return WorkoutCard(
                            workout: selectedWorkouts[index],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WorkoutDetailPage(
                                    workoutId: selectedWorkouts[index].id,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
