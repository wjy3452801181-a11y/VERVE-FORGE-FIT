import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/buddy_model.dart';
import '../domain/buddy_request_model.dart';

/// 伙伴 Repository — 附近伙伴查询 + 好友请求管理
class BuddyRepository {
  static const _table = SupabaseConstants.buddies;
  static const _profileFields =
      'nickname, avatar_url, bio, sport_types';

  // ═══════════════════════════════════════
  // 发现伙伴
  // ═══════════════════════════════════════

  /// 查询附近伙伴（调用 nearby_buddies RPC）
  Future<List<BuddyModel>> getNearbyBuddies({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    String? sportType,
  }) async {
    final params = <String, dynamic>{
      'lat': latitude,
      'lng': longitude,
      'radius_km': radiusKm,
    };
    if (sportType != null) {
      params['sport_filter'] = sportType;
    }

    final data = await SupabaseClientHelper.rpc(
      SupabaseConstants.nearbyBuddies,
      params: params,
    );

    return (data as List)
        .map((e) => BuddyModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 按城市查询伙伴（无定位时的降级方案）
  Future<List<BuddyModel>> listByCity({
    required String city,
    String? sportType,
    int page = 0,
    int pageSize = 20,
  }) async {
    final userId = SupabaseClientHelper.currentUserId;

    var query = SupabaseClientHelper.from(SupabaseConstants.profiles)
        .select(
            'id, nickname, avatar_url, bio, city, sport_types, experience_level, fitness_score')
        .eq('is_discoverable', true)
        .eq('city', city);

    if (userId != null) {
      query = query.neq('id', userId);
    }

    if (sportType != null) {
      query = query.contains('sport_types', [sportType]);
    }

    final data = await query
        .order('fitness_score', ascending: false, nullsFirst: false)
        .range(page * pageSize, (page + 1) * pageSize - 1);

    return (data as List)
        .map((e) => BuddyModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ═══════════════════════════════════════
  // 好友请求操作
  // ═══════════════════════════════════════

  /// 发送好友请求
  Future<void> sendBuddyRequest(String targetUserId,
      {String message = ''}) async {
    final userId = SupabaseClientHelper.currentUserId!;
    await SupabaseClientHelper.from(_table).insert({
      'requester_id': userId,
      'receiver_id': targetUserId,
      'status': 'pending',
      'message': message,
    });
  }

  /// 检查是否已发送/存在请求
  Future<bool> hasSentRequest(String targetUserId) async {
    final userId = SupabaseClientHelper.currentUserId;
    if (userId == null) return false;

    final data = await SupabaseClientHelper.from(_table)
        .select('id')
        .eq('requester_id', userId)
        .eq('receiver_id', targetUserId)
        .inFilter('status', ['pending', 'accepted'])
        .maybeSingle();

    return data != null;
  }

  /// 接受好友请求
  Future<void> acceptRequest(String requestId) async {
    await SupabaseClientHelper.from(_table)
        .update({'status': 'accepted'}).eq('id', requestId);
  }

  /// 拒绝好友请求
  Future<void> rejectRequest(String requestId) async {
    await SupabaseClientHelper.from(_table)
        .update({'status': 'rejected'}).eq('id', requestId);
  }

  /// 取消已发送的请求
  Future<void> cancelRequest(String requestId) async {
    await SupabaseClientHelper.from(_table)
        .update({'status': 'cancelled'}).eq('id', requestId);
  }

  /// 删除好友（将状态改为 cancelled）
  Future<void> removeBuddy(String requestId) async {
    await SupabaseClientHelper.from(_table)
        .update({'status': 'cancelled'}).eq('id', requestId);
  }

  // ═══════════════════════════════════════
  // 查询列表
  // ═══════════════════════════════════════

  /// 获取收到的好友请求（pending 状态）
  Future<List<BuddyRequestModel>> getReceivedRequests() async {
    final userId = SupabaseClientHelper.currentUserId!;

    final data = await SupabaseClientHelper.from(_table)
        .select('*, requester:profiles!buddies_requester_id_fkey($_profileFields)')
        .eq('receiver_id', userId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) =>
            BuddyRequestModel.fromReceivedJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 获取发出的好友请求（pending 状态）
  Future<List<BuddyRequestModel>> getSentRequests() async {
    final userId = SupabaseClientHelper.currentUserId!;

    final data = await SupabaseClientHelper.from(_table)
        .select('*, receiver:profiles!buddies_receiver_id_fkey($_profileFields)')
        .eq('requester_id', userId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) =>
            BuddyRequestModel.fromSentJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 获取好友列表（accepted 状态）
  Future<List<BuddyRequestModel>> getAcceptedBuddies() async {
    final userId = SupabaseClientHelper.currentUserId!;

    final data = await SupabaseClientHelper.from(_table)
        .select(
            '*, requester:profiles!buddies_requester_id_fkey($_profileFields), receiver:profiles!buddies_receiver_id_fkey($_profileFields)')
        .eq('status', 'accepted')
        .or('requester_id.eq.$userId,receiver_id.eq.$userId')
        .order('updated_at', ascending: false);

    return (data as List)
        .map((e) => BuddyRequestModel.fromBuddyJson(
            e as Map<String, dynamic>, userId))
        .toList();
  }
}

/// Provider
final buddyRepositoryProvider = Provider<BuddyRepository>((ref) {
  return BuddyRepository();
});
