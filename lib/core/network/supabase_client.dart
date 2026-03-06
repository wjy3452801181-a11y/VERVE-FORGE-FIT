import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase 客户端快捷访问
class SupabaseClientHelper {
  SupabaseClientHelper._();

  /// Supabase 客户端实例
  static SupabaseClient get client => Supabase.instance.client;

  /// 当前登录用户
  static User? get currentUser => client.auth.currentUser;

  /// 当前用户 ID
  static String? get currentUserId => currentUser?.id;

  /// 是否已登录
  static bool get isLoggedIn => currentUser != null;

  /// 数据库操作快捷入口
  static SupabaseQueryBuilder from(String table) => client.from(table);

  /// Storage 操作快捷入口
  static SupabaseStorageClient get storage => client.storage;

  /// Realtime 操作快捷入口
  static RealtimeClient get realtime => client.realtime;

  /// RPC 调用
  static Future<dynamic> rpc(String functionName, {Map<String, dynamic>? params}) {
    return client.rpc(functionName, params: params);
  }
}
