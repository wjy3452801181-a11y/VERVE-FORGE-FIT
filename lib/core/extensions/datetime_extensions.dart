import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

/// DateTime 扩展方法
extension DateTimeExtensions on DateTime {
  /// 格式化为 yyyy-MM-dd
  String get ymd => DateFormat('yyyy-MM-dd').format(this);

  /// 格式化为 MM月dd日
  String get monthDay => DateFormat('MM月dd日').format(this);

  /// 格式化为 yyyy年MM月dd日
  String get fullDate => DateFormat('yyyy年MM月dd日').format(this);

  /// 格式化为 HH:mm
  String get hm => DateFormat('HH:mm').format(this);

  /// 格式化为 yyyy-MM-dd HH:mm
  String get ymdHm => DateFormat('yyyy-MM-dd HH:mm').format(this);

  /// 相对时间（"3分钟前"）
  String get ago => timeago.format(this, locale: 'zh');

  /// 是否是今天
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// 是否是昨天
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// 智能时间显示（今天显示时间，昨天显示"昨天"，其他显示日期）
  String get smart {
    if (isToday) return hm;
    if (isYesterday) return '昨天 $hm';
    if (DateTime.now().difference(this).inDays < 7) {
      return ago;
    }
    return monthDay;
  }
}
