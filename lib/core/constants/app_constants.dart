/// VerveForge 全局常量
class AppConstants {
  AppConstants._();

  static const String appName = 'VerveForge';
  static const String appVersion = '1.0.0';

  // 运动类型
  static const List<String> sportTypes = [
    'hyrox',
    'crossfit',
    'yoga',
    'pilates',
    'running',
    'swimming',
    'strength',
    'other',
  ];

  // 经验等级
  static const List<String> experienceLevels = [
    'beginner',
    'intermediate',
    'advanced',
    'elite',
  ];

  // 支持的城市（首批）
  static const List<String> supportedCities = [
    'beijing',
    'shanghai',
    'guangzhou',
    'shenzhen',
    'hongkong',
  ];

  // 照片相关
  static const int maxPhotos = 9;
  static const int maxPhotoSizeKB = 5120; // 5MB
  static const double imageCompressQuality = 0.8;

  // 分页
  static const int defaultPageSize = 20;

  // 训练强度范围
  static const int minIntensity = 1;
  static const int maxIntensity = 10;
}
