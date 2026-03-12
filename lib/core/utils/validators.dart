/// 表单校验器
class Validators {
  Validators._();

  /// 邮箱校验
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入邮箱';
    }
    final emailRegex = RegExp(r'^[\w\-.]+@[\w\-]+(\.[\w\-]+)+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return '请输入有效的邮箱地址';
    }
    return null;
  }

  /// 密码校验
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    if (value.length < 6) {
      return '密码至少需要6位';
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
