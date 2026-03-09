/// 挑战赛打卡记录模型 — 映射 challenge_check_ins 表
class ChallengeCheckInModel {
  final String id;
  final String challengeId;
  final String participantId;
  final String workoutLogId;
  final int value;
  final DateTime createdAt;

  const ChallengeCheckInModel({
    required this.id,
    required this.challengeId,
    required this.participantId,
    required this.workoutLogId,
    this.value = 1,
    required this.createdAt,
  });

  factory ChallengeCheckInModel.fromJson(Map<String, dynamic> json) {
    return ChallengeCheckInModel(
      id: json['id'] as String,
      challengeId: json['challenge_id'] as String,
      participantId: json['participant_id'] as String,
      workoutLogId: json['workout_log_id'] as String,
      value: json['value'] as int? ?? 1,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'challenge_id': challengeId,
      'participant_id': participantId,
      'workout_log_id': workoutLogId,
      'value': value,
    };
  }
}
