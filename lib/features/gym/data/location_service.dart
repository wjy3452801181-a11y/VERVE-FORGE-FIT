import 'package:permission_handler/permission_handler.dart';

/// 封装定位服务（高德 SDK 暂时禁用用于模拟器预览）
class LocationService {
  /// 请求定位权限
  Future<bool> requestPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  /// 获取当前位置 — stub
  Future<({double latitude, double longitude})?> getCurrentLocation() async {
    return null;
  }

  void dispose() {}
}
