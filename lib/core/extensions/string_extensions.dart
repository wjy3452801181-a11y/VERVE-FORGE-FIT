/// String 扩展方法
extension StringExtensions on String {
  /// 手机号脱敏（138****1234）
  String get maskedPhone {
    if (length < 7) return this;
    return '${substring(0, 3)}****${substring(length - 4)}';
  }

  /// 是否是有效手机号（中国大陆 + 香港）
  bool get isValidPhone {
    // 中国大陆手机号：11位，1开头
    if (RegExp(r'^1[3-9]\d{9}$').hasMatch(this)) return true;
    // 香港手机号：8位，以5/6/7/8/9开头
    if (RegExp(r'^[5-9]\d{7}$').hasMatch(this)) return true;
    return false;
  }

  /// 首字母大写
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// 截断文字（超过指定长度加省略号）
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}
