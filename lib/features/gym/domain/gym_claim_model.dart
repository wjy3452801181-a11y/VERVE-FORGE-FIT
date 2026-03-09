/// 训练馆认领申请模型 — 映射 gym_claims 表
class GymClaimModel {
  final String id;
  final String gymId;
  final String claimantUserId;
  final String status; // 'pending' / 'approved' / 'rejected'
  final String reason;
  final List<String> evidenceUrls;
  final DateTime appliedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;

  // JOIN 扩展字段
  final String? gymName;
  final String? claimantNickname;

  const GymClaimModel({
    required this.id,
    required this.gymId,
    required this.claimantUserId,
    this.status = 'pending',
    this.reason = '',
    this.evidenceUrls = const [],
    required this.appliedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.gymName,
    this.claimantNickname,
  });

  /// 从 Supabase JSON 构造
  factory GymClaimModel.fromJson(Map<String, dynamic> json) {
    return GymClaimModel(
      id: json['id'] as String,
      gymId: json['gym_id'] as String,
      claimantUserId: json['claimant_user_id'] as String,
      status: json['status'] as String? ?? 'pending',
      reason: json['reason'] as String? ?? '',
      evidenceUrls: (json['evidence_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      appliedAt: DateTime.parse(json['applied_at'] as String),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      reviewedBy: json['reviewed_by'] as String?,
      gymName: json['gym_name'] as String?,
      claimantNickname: json['claimant_nickname'] as String?,
    );
  }

  /// 转为 Supabase JSON（提交认领用）
  Map<String, dynamic> toJson() {
    return {
      'gym_id': gymId,
      'claimant_user_id': claimantUserId,
      'reason': reason,
      'evidence_urls': evidenceUrls,
    };
  }

  /// 复制修改
  GymClaimModel copyWith({
    String? status,
    String? reason,
    List<String>? evidenceUrls,
    DateTime? reviewedAt,
    String? reviewedBy,
  }) {
    return GymClaimModel(
      id: id,
      gymId: gymId,
      claimantUserId: claimantUserId,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      evidenceUrls: evidenceUrls ?? this.evidenceUrls,
      appliedAt: appliedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      gymName: gymName,
      claimantNickname: claimantNickname,
    );
  }

  /// 是否待审核
  bool get isPending => status == 'pending';

  /// 是否已通过
  bool get isApproved => status == 'approved';

  /// 是否已拒绝
  bool get isRejected => status == 'rejected';

  /// 状态显示文字
  String get statusDisplay {
    switch (status) {
      case 'pending':
        return '审核中';
      case 'approved':
        return '已通过';
      case 'rejected':
        return '已拒绝';
      default:
        return status;
    }
  }
}
