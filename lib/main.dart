import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/cache/app_cache_manager.dart';
import 'core/constants/storage_keys.dart';
import 'core/performance/frame_monitor.dart';

// 编译时注入的环境变量（通过 --dart-define=SUPABASE_URL=... 传入）
// 构建示例：flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co --dart-define=SUPABASE_ANON_KEY=xxx
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

/// VerveForge 应用入口
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  assert(
    _supabaseUrl.isNotEmpty,
    '缺少编译时环境变量 SUPABASE_URL，请使用 --dart-define=SUPABASE_URL=<your_url> 构建',
  );
  assert(
    _supabaseAnonKey.isNotEmpty,
    '缺少编译时环境变量 SUPABASE_ANON_KEY，请使用 --dart-define=SUPABASE_ANON_KEY=<your_key> 构建',
  );

  // 【性能优化 Step 1】全局图片缓存 — 所有 CachedNetworkImage 共享同一缓存池
  // 200 对象上限 / 7 天过期 / 200MB 磁盘上限 / LRU 自动清理
  CachedNetworkImageProvider.defaultCacheManager = AppCacheManager.instance;

  // 异步执行磁盘大小检查（不阻塞首帧渲染）
  // 超过 200MB 时自动按 LRU 策略清理最旧文件至 80% 水位
  AppCacheManager.enforceSizeLimit();

  // 【性能优化 Step 3】帧性能监控 — debug/profile 模式自动启用
  // 逐帧慢帧警告 + 连续丢帧检测 + 每 10 秒汇总报告
  // release 模式自动跳过，零开销
  FrameMonitor.start();

  // 初始化 Supabase（使用编译时注入的密钥）
  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  // 预读取隐私同意状态（用于启动拦截）
  final prefs = await SharedPreferences.getInstance();
  final privacyAgreed = prefs.getBool(StorageKeys.privacyAgreed) ?? false;

  runApp(
    ProviderScope(
      child: VerveForgeApp(privacyAgreed: privacyAgreed),
    ),
  );
}
