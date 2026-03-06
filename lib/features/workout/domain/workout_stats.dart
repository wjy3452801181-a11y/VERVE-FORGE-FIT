import 'workout_model.dart';

/// 训练统计聚合模型
class WorkoutStats {
  final int weeklyCount;
  final int monthlyCount;
  final int totalMinutes;
  final int totalWorkouts;

  const WorkoutStats({
    this.weeklyCount = 0,
    this.monthlyCount = 0,
    this.totalMinutes = 0,
    this.totalWorkouts = 0,
  });

  /// 从训练列表聚合统计
  factory WorkoutStats.fromWorkouts(List<WorkoutModel> workouts) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final monthStart = DateTime(now.year, now.month, 1);

    int weekly = 0;
    int monthly = 0;
    int totalMins = 0;

    for (final w in workouts) {
      if (w.isDraft || w.isDeleted) continue;
      totalMins += w.durationMinutes;
      if (!w.workoutDate.isBefore(monthStart)) monthly++;
      if (!w.workoutDate.isBefore(weekStartDate)) weekly++;
    }

    return WorkoutStats(
      weeklyCount: weekly,
      monthlyCount: monthly,
      totalMinutes: totalMins,
      totalWorkouts: workouts.where((w) => !w.isDraft && !w.isDeleted).length,
    );
  }

  /// 总时长显示（小时）
  String get totalHoursDisplay {
    if (totalMinutes < 60) return '${totalMinutes}m';
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    return mins > 0 ? '${hours}h${mins}m' : '${hours}h';
  }
}
