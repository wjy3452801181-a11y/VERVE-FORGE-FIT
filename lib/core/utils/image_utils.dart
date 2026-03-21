import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../network/supabase_client.dart';

/// 图片工具类
class ImageUtils {
  static const _uuid = Uuid();
  static const _allowedExtensions = {'jpg', 'jpeg', 'png', 'webp'};

  /// 上传图片到 Supabase Storage
  /// 返回图片公开 URL
  static Future<String> uploadImage({
    required File file,
    required String bucket,
    String? folder,
  }) async {
    final ext = file.path.split('.').last.toLowerCase();
    if (!_allowedExtensions.contains(ext)) {
      throw ArgumentError('不支持的图片格式: $ext，仅支持 jpg、jpeg、png、webp');
    }
    final fileName = '${_uuid.v4()}.$ext';
    final path = folder != null ? '$folder/$fileName' : fileName;

    await SupabaseClientHelper.storage.from(bucket).upload(
      path,
      file,
    );

    final url = SupabaseClientHelper.storage.from(bucket).getPublicUrl(path);
    return url;
  }

  /// 批量上传图片
  static Future<List<String>> uploadImages({
    required List<File> files,
    required String bucket,
    String? folder,
  }) async {
    final futures = files.map((f) => uploadImage(
      file: f,
      bucket: bucket,
      folder: folder,
    ));
    return Future.wait(futures);
  }

  /// 获取临时目录（用于图片压缩缓存）
  static Future<Directory> get tempDir async {
    return getTemporaryDirectory();
  }
}
