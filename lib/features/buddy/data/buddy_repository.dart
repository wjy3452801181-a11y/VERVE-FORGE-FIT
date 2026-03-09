import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/buddy_model.dart';

/// 伙伴 Repository — 附近伙伴查询 + 约练请求
class BuddyRepository {
  /// 查询附近伙伴（调用 nearby_buddies RPC）
  /// RPC 自动排除当前用户、尊重 is_discoverable 隐私设置
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
        .select('id, nickname, avatar_url, bio, city, sport_types, experience_level, fitness_score')
        .eq('is_discoverable', true)
        .eq('city', city);

    // 排除自己
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

  /// 发送约练请求
  Future<void> sendBuddyRequest(String targetUserId) async {
    final userId = SupabaseClientHelper.currentUserId!;

    await SupabaseClientHelper.from(SupabaseConstants.buddyRequests).insert({
      'sender_id': userId,
      'receiver_id': targetUserId,
      'status': 'pending',
    });
  }

  /// 检查是否已发送过约练请求
  Future<bool> hasSentRequest(String targetUserId) async {
    final userId = SupabaseClientHelper.currentUserId;
    if (userId == null) return false;

    final data = await SupabaseClientHelper.from(SupabaseConstants.buddyRequests)
        .select('id')
        .eq('sender_id', userId)
        .eq('receiver_id', targetUserId)
        .inFilter('status', ['pending', 'accepted'])
        .maybeSingle();

    return data != null;
  }
}

/// Provider
final buddyRepositoryProvider = Provider<BuddyRepository>((ref) {
  return BuddyRepository();
});
