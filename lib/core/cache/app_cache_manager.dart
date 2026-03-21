import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

/// VerveForge 全局图片缓存管理器
///
/// 【性能优化】统一管理网络图片缓存，避免重复下载
/// 配置参数：
/// - maxNrOfCacheObjects: 200   — 覆盖训练馆、Feed、头像等高频图片
/// - stalePeriod: 7 天          — 平衡新鲜度与离线体验
/// - maxCacheSizeBytes: 200MB   — 磁盘占用硬上限，超限时自动按 LRU 清理
///
/// 使用方式：
///   CachedNetworkImage(cacheManager: AppCacheManager.instance, ...)
///   或在 main() 中全局绑定：
///   CachedNetworkImageProvider.defaultCacheManager = AppCacheManager.instance;
class AppCacheManager {
  /// 缓存标识键（对应磁盘目录名）
  static const _key = 'verveforge_image_cache';

  /// 最大缓存对象数
  static const int maxObjects = 200;

  /// 缓存过期时间
  static const Duration stalePeriod = Duration(days: 7);

  /// 磁盘缓存上限（200MB）
  /// flutter_cache_manager 不内置 maxSize，由 [enforceSizeLimit] 手动清理
  static const int maxCacheSizeBytes = 200 * 1024 * 1024; // 200 MB

  /// 全局单例 CacheManager 实例
  // Web 平台不使用 SQLite repo（sqflite 不支持 Web），直接用默认 Config。
  // 移动端使用持久化的 JsonCacheInfoRepository。
  static final CacheManager instance = kIsWeb
      ? CacheManager(
          Config(
            _key,
            maxNrOfCacheObjects: maxObjects,
            stalePeriod: stalePeriod,
            fileService: HttpFileService(),
          ),
        )
      : CacheManager(
          Config(
            _key,
            maxNrOfCacheObjects: maxObjects,
            stalePeriod: stalePeriod,
            repo: JsonCacheInfoRepository(databaseName: _key),
            fileService: HttpFileService(),
          ),
        );

  // -------------------------------------------------------
  // 磁盘大小管理
  // -------------------------------------------------------

  /// 获取当前缓存目录路径（仅移动端可用）
  static Future<Directory> _cacheDir() async {
    final base = await getTemporaryDirectory();
    return Directory('${base.path}/$_key');
  }

  /// 计算当前缓存目录总大小（字节）；Web 上返回 0
  static Future<int> getCacheSizeBytes() async {
    if (kIsWeb) return 0;
    final dir = await _cacheDir();
    if (!dir.existsSync()) return 0;

    int total = 0;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

  /// 获取格式化的缓存大小（如 "45.2 MB"）
  static Future<String> getFormattedCacheSize() async {
    final bytes = await getCacheSizeBytes();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// 强制磁盘大小检查 — 超过 [maxCacheSizeBytes] 时按最后访问时间清理最旧文件
  ///
  /// Web 平台无磁盘文件系统，直接跳过。
  /// 建议在以下时机调用：
  /// 1. App 启动后（main 中异步调用，不阻塞首帧）
  /// 2. 大量图片加载后（如 Feed 长列表滑动结束）
  /// 3. 设置页"清理缓存"按钮触发
  static Future<void> enforceSizeLimit() async {
    if (kIsWeb) return;
    final dir = await _cacheDir();
    if (!dir.existsSync()) return;

    // 收集所有缓存文件及其大小和最后访问时间
    final files = <_CacheFileInfo>[];
    int totalSize = 0;

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        final stat = await entity.stat();
        final size = stat.size;
        totalSize += size;
        files.add(_CacheFileInfo(
          file: entity,
          size: size,
          lastAccessed: stat.accessed,
        ));
      }
    }

    // 未超限，无需清理
    if (totalSize <= maxCacheSizeBytes) {
      developer.log(
        '缓存大小检查通过：${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB / '
        '${(maxCacheSizeBytes / (1024 * 1024)).toStringAsFixed(0)} MB',
        name: 'AppCacheManager',
      );
      return;
    }

    // 按最后访问时间升序排列（最久未访问的排前面）
    files.sort((a, b) => a.lastAccessed.compareTo(b.lastAccessed));

    // 逐个删除最旧文件，直到总大小降到上限的 80%（预留空间避免频繁触发）
    final targetSize = (maxCacheSizeBytes * 0.8).toInt();
    int deletedCount = 0;

    for (final info in files) {
      if (totalSize <= targetSize) break;
      try {
        await info.file.delete();
        totalSize -= info.size;
        deletedCount++;
      } catch (_) {
        // 文件可能已被系统回收，忽略
      }
    }

    developer.log(
      '缓存清理完成：删除 $deletedCount 个文件，'
      '当前 ${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB',
      name: 'AppCacheManager',
    );
  }

  /// 清除全部缓存（供设置页 / 退出登录调用）
  static Future<void> clearAll() async {
    await instance.emptyCache();

    // Web 无磁盘文件系统，跳过目录删除
    if (!kIsWeb) {
      final dir = await _cacheDir();
      if (dir.existsSync()) {
        await dir.delete(recursive: true);
      }
    }

    developer.log('缓存已全部清除', name: 'AppCacheManager');
  }

  AppCacheManager._();
}

/// 缓存文件信息（仅内部使用）
class _CacheFileInfo {
  final File file;
  final int size;
  final DateTime lastAccessed;

  const _CacheFileInfo({
    required this.file,
    required this.size,
    required this.lastAccessed,
  });
}
