import 'package:amap_flutter_location/amap_flutter_location.dart';
import 'package:amap_flutter_location/amap_location_option.dart';
import 'package:permission_handler/permission_handler.dart';

/// 封装高德定位服务
class LocationService {
  final AMapFlutterLocation _location = AMapFlutterLocation();

  /// 请求定位权限
  Future<bool> requestPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  /// 获取当前位置（GCJ-02 坐标）
  /// 返回 {latitude, longitude} 或 null
  Future<({double latitude, double longitude})?> getCurrentLocation() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return null;

    _location.setLocationOption(AMapLocationOption(
      onceLocation: true,
      needAddress: false,
    ));

    _location.startLocation();

    try {
      final result = await _location.onLocationChanged().first;
      _location.stopLocation();

      final lat = double.tryParse(result['latitude']?.toString() ?? '');
      final lng = double.tryParse(result['longitude']?.toString() ?? '');

      if (lat == null || lng == null || lat == 0 || lng == 0) return null;

      return (latitude: lat, longitude: lng);
    } catch (_) {
      _location.stopLocation();
      return null;
    }
  }

  /// 销毁定位资源
  void dispose() {
    _location.stopLocation();
    _location.destroy();
  }
}
