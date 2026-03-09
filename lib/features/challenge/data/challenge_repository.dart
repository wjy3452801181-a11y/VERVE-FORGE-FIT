import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/network/supabase_client.dart';
import '../domain/challenge_model.dart';
import '../domain/challenge_participant_model.dart';


const _uuid = Uuid();

/// 挑战赛 Repository
class ChallengeRepository {
  // -------------------------------------------------------
  // 挑战赛 CRUD
  // -------------------------------------------------------

  /// 创建挑战赛
  Future<ChallengeModel> create({
    required String title,
    required String sportType,
    required String goalType,
    required int goalValue,
    required DateTime startsAt,
    required DateTime endsAt,
    String description = '',
    String? city,
    int maxParticipants = 100,
    Map<String, dynamic> metricsRules = const {},
  }) async {
    final userId = SupabaseClientHelper.currentUserId!;
    final id = _uuid.v4();

    final data = {
      'id': id,
      'creator_id': userId,
      'title': title,
      'description': description,
      'sport_type': sportType,
      'goal_type': goalType,
      'goal_value': goalValue,
      'starts_at': startsAt.toIso8601String(),
      'ends_at': endsAt.toIso8601String(),
      'max_participants': maxParticipants,
      'city': city,
      'status': 'active',
      'metrics_rules': metricsRules,
    };

    await SupabaseClientHelper.from(SupabaseConstants.challenges).insert(data);

    // 创建者自动加入
    await join(id);

    return ChallengeModel(
      id: id,
      creatorId: userId,
      title: title,
      description: description,
      sportType: sportType,
      goalType: goalType,
      goalValue: goalValue,
      startsAt: startsAt,
      endsAt: endsAt,
      maxParticipants: maxParticipants,
      city: city,
      metricsRules: metricsRules,
      participantCount: 1,
      isJoined: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 获取挑战赛列表（使用 challenge_summary 视图）
  Future<List<ChallengeModel>> list({
    int page = 0,
    int pageSize = 20,
    String? city,
    String? sportType,
    String? status,
  }) async {
    var query = SupabaseClientHelper.from('challenge_summary').select();

    if (city != null) {
      query = query.eq('city', city);
    }
    if (sportType != null) {
      query = query.eq('sport_type', sportType);
    }
    if (status != null) {
      query = query.eq('status', status);
    }

    final data = await query
        .order('created_at', ascending: false)
        .range(page * pageSize, (page + 1) * pageSize - 1);

    return (data as List).map((e) => ChallengeModel.fromJson(e)).toList();
  }

  /// 获取单个挑战赛详情
  Future<ChallengeModel?> get(String id) async {
    final data = await SupabaseClientHelper.from('challenge_summary')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    return ChallengeModel.fromJson(data);
  }

  // -------------------------------------------------------
  // 参与（join / leave）
  // -------------------------------------------------------

  /// 加入挑战赛
  Future<void> join(String challengeId) async {
    final userId = SupabaseClientHelper.currentUserId!;
    final id = _uuid.v4();

    await SupabaseClientHelper.from(SupabaseConstants.challengeParticipants)
        .insert({
      'id': id,
      'challenge_id': challengeId,
      'user_id': userId,
    });
  }

  /// 退出挑战赛
  Future<void> leave(String challengeId) async {
    final userId = SupabaseClientHelper.currentUserId!;

    await SupabaseClientHelper.from(SupabaseConstants.challengeParticipants)
        .delete()
        .eq('challenge_id', challengeId)
        .eq('user_id', userId);
  }

  // -------------------------------------------------------
  // 排行榜（使用 challenge_leaderboard 视图）
  // -------------------------------------------------------

  /// 获取排行榜数据
  Future<List<ChallengeParticipantModel>> getLeaderboard(
    String challengeId,
  ) async {
    final data = await SupabaseClientHelper.from('challenge_leaderboard')
        .select()
        .eq('challenge_id', challengeId)
        .order('rank', ascending: true);

    return (data as List)
        .map((e) => ChallengeParticipantModel.fromJson(e))
        .toList();
  }

  /// 订阅排行榜实时更新（Supabase Realtime）
  /// 监听 challenge_participants 表的变更，触发回调刷新排行榜
  RealtimeChannel subscribeLeaderboard(
    String challengeId, {
    required void Function() onUpdate,
  }) {
    final channel = SupabaseClientHelper.client.channel('leaderboard:$challengeId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: SupabaseConstants.challengeParticipants,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'challenge_id',
            value: challengeId,
          ),
          callback: (payload) => onUpdate(),
        )
        .subscribe();

    return channel;
  }

  /// 取消订阅
  Future<void> unsubscribeLeaderboard(RealtimeChannel channel) async {
    await SupabaseClientHelper.client.removeChannel(channel);
  }

  // -------------------------------------------------------
  // 打卡
  // -------------------------------------------------------

  /// 打卡（关联训练日志）
  Future<void> checkIn({
    required String challengeId,
    required String participantId,
    required String workoutLogId,
    int value = 1,
  }) async {
    final id = _uuid.v4();

    await SupabaseClientHelper.from(SupabaseConstants.challengeCheckIns)
        .insert({
      'id': id,
      'challenge_id': challengeId,
      'participant_id': participantId,
      'workout_log_id': workoutLogId,
      'value': value,
    });
  }

  /// 获取当前用户在某挑战的 participant 记录
  Future<ChallengeParticipantModel?> getMyParticipant(
    String challengeId,
  ) async {
    final userId = SupabaseClientHelper.currentUserId!;

    final data =
        await SupabaseClientHelper.from(SupabaseConstants.challengeParticipants)
            .select()
            .eq('challenge_id', challengeId)
            .eq('user_id', userId)
            .maybeSingle();

    if (data == null) return null;
    return ChallengeParticipantModel.fromJson(data);
  }

  // -------------------------------------------------------
  // Realtime 订阅 — 挑战赛列表变更监听
  // -------------------------------------------------------

  /// 订阅挑战赛列表实时更新（监听 challenges 表 INSERT + UPDATE）
  RealtimeChannel subscribeChallengeList({
    required void Function() onUpdate,
  }) {
    final channel =
        SupabaseClientHelper.client.channel('challenges:realtime');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: SupabaseConstants.challenges,
          callback: (payload) => onUpdate(),
        )
        .subscribe();

    return channel;
  }

  /// 取消挑战赛列表订阅
  Future<void> unsubscribeChallengeList(RealtimeChannel channel) async {
    await SupabaseClientHelper.client.removeChannel(channel);
  }
}

/// Provider
final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  return ChallengeRepository();
});
