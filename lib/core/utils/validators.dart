/// 表单校验器
class Validators {
  Validators._();

  /// 手机号校验
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入手机号';
    }
    // 中国大陆
    if (RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) return null;
    // 香港
    if (RegExp(r'^[5-9]\d{7}$').hasMatch(value)) return null;
    return '请输入有效的手机号';
  }

  /// 验证码校验
  static String? otp(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入验证码';
    }
    if (value.length != 6 || !RegExp(r'^\d{6}$').hasMatch(value)) {
      return '请输入6位数字验证码';
    }
    return null;
  }

  /// 昵称校验
  static String? nickname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入昵称';
    }
    if (value.trim().length < 2) {
      return '昵称至少2个字符';
    }
    if (value.trim().length > 20) {
      return '昵称最多20个字符';
    }
    return null;
  }

  /// 非空校验
  static String? required(String? value, [String fieldName = '此项']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName不能为空';
    }
    return null;
  }

  /// 训练时长校验
  static String? duration(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入训练时长';
    }
    final minutes = int.tryParse(value);
    if (minutes == null || minutes <= 0) {
      return '请输入有效的训练时长';
    }
    if (minutes > 600) {
      return '训练时长不能超过10小时';
    }
    return null;
  }
}
