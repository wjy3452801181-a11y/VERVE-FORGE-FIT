import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 高德地图配置
class AMapConfig {
  AMapConfig._();

  static AMapApiKey get apiKey => AMapApiKey(
        androidKey: dotenv.env['AMAP_ANDROID_KEY'] ?? '',
        iosKey: dotenv.env['AMAP_IOS_KEY'] ?? '',
      );

  static const AMapPrivacyStatement privacyStatement = AMapPrivacyStatement(
    hasContains: true,
    hasShow: true,
    hasAgree: true,
  );
}
