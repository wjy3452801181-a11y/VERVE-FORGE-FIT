/// String 扩展方法
extension StringExtensions on String {
  /// 手机号脱敏 — 保留前3位和后4位，中间替换为 ****
  /// 示例：13812345678 → 138****5678
  String get maskedPhone {
    if (length < 7) return this;
    return '${substring(0, 3)}****${substring(length - 4)}';
  }

  /// 是否是有效手机号（大陆11位 / 香港8位）
  bool get isValidPhone {
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(this) ||
        RegExp(r'^[456789]\d{7}$').hasMatch(this);
  }

  /// 首字母大写
  String get capitalize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// 超出 [maxLength] 时截断并追加 '...'
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}
