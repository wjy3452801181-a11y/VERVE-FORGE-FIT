import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/constants/storage_keys.dart';

/// VerveForge 应用入口
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 加载环境变量
  await dotenv.load(fileName: '.env');

  // 初始化 Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
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
