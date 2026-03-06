import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/supabase_constants.dart';
import '../../../core/network/supabase_client.dart';
import '../../../core/utils/image_utils.dart';
import '../domain/gym_model.dart';

const _uuid = Uuid();

/// 训练馆 Repository
class GymRepository {
  /// 查询附近训练馆（调用 nearby_gyms RPC）
  Future<List<GymModel>> getNearbyGyms({
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
      SupabaseConstants.nearbyGyms,
      params: params,
    );

    return (data as List).map((e) => GymModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// 按城市列表
  Future<List<GymModel>> listByCity({
    required String city,
    String? sportType,
    int page = 0,
    int pageSize = 20,
  }) async {
    var query = SupabaseClientHelper.from(SupabaseConstants.gyms)
        .select()
        .eq('city', city)
        .eq('status', 'verified');

    if (sportType != null) {
      query = query.contains('sport_types', [sportType]);
    }

    final data = await query
        .order('rating', ascending: false)
        .range(page * pageSize, (page + 1) * pageSize - 1);

    return (data as List).map((e) => GymModel.fromJson(e)).toList();
  }

  /// 搜索训练馆
  Future<List<GymModel>> search({
    required String keyword,
    String? city,
    int page = 0,
    int pageSize = 20,
  }) async {
    var query = SupabaseClientHelper.from(SupabaseConstants.gyms)
        .select()
        .eq('status', 'verified')
        .or('name.ilike.%$keyword%,address.ilike.%$keyword%');

    if (city != null) {
      query = query.eq('city', city);
    }

    final data = await query
        .order('rating', ascending: false)
        .range(page * pageSize, (page + 1) * pageSize - 1);

    return (data as List).map((e) => GymModel.fromJson(e)).toList();
  }

  /// 获取训练馆详情
  Future<GymModel?> getDetail(String id) async {
    final data = await SupabaseClientHelper.from(SupabaseConstants.gyms)
        .select()
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    return GymModel.fromJson(data);
  }

  /// 提交新训练馆
  Future<GymModel> submit({
    required String name,
    required String address,
    required String city,
    required double latitude,
    required double longitude,
    String? description,
    String? phone,
    String? website,
    String? openingHours,
    List<String> sportTypes = const [],
    List<String> photoUrls = const [],
  }) async {
    final userId = SupabaseClientHelper.currentUserId!;
    final id = _uuid.v4();
    final now = DateTime.now();

    final data = {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'website': website,
      'opening_hours': openingHours,
      'sport_types': sportTypes,
      'photo_urls': photoUrls,
      'submitted_by': userId,
      'status': 'pending',
    };

    await SupabaseClientHelper.from(SupabaseConstants.gyms).insert(data);

    return GymModel(
      id: id,
      name: name,
      description: description,
      address: address,
      city: city,
      latitude: latitude,
      longitude: longitude,
      phone: phone,
      website: website,
      openingHours: openingHours,
      sportTypes: sportTypes,
      photoUrls: photoUrls,
      submittedBy: userId,
      status: 'pending',
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 上传训练馆照片
  Future<List<String>> uploadPhotos(List<File> files) async {
    return ImageUtils.uploadImages(
      files: files,
      bucket: SupabaseConstants.gymPhotosBucket,
      folder: SupabaseClientHelper.currentUserId,
    );
  }
}

/// Provider
final gymRepositoryProvider = Provider<GymRepository>((ref) {
  return GymRepository();
});
