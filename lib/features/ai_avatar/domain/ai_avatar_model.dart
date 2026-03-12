/// AI 虚拟分身数据模型
class AiAvatarModel {
  final String id;
  final String userId;
  final String name;
  final String? avatarUrl;
  final List<String> personalityTraits;
  final String speakingStyle;
  final String customPrompt;
  final bool autoReplyEnabled;
  final DateTime? aiConsentAt;

  /// AI 分析的运动习惯画像（每日自动更新）
  final Map<String, dynamic> fitnessHabits;

  /// 画像最后更新时间
  final DateTime? profileUpdatedAt;

  /// 分享令牌（构造公开分享链接）
  final String? shareToken;

  final DateTime createdAt;
  final DateTime updatedAt;

  const AiAvatarModel({
    required this.id,
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.personalityTraits = const [],
    this.speakingStyle = 'friendly',
    this.customPrompt = '',
    this.autoReplyEnabled = false,
    this.aiConsentAt,
    this.fitnessHabits = const {},
    this.profileUpdatedAt,
    this.shareToken,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从 Supabase JSON 构造
  factory AiAvatarModel.fromJson(Map<String, dynamic> json) {
    return AiAvatarModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      personalityTraits: (json['personality_traits'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      speakingStyle: json['speaking_style'] as String? ?? 'friendly',
      customPrompt: json['custom_prompt'] as String? ?? '',
      autoReplyEnabled: json['auto_reply_enabled'] as bool? ?? false,
      aiConsentAt: json['ai_consent_at'] != null
          ? DateTime.parse(json['ai_consent_at'] as String)
          : null,
      fitnessHabits:
          (json['fitness_habits'] as Map<String, dynamic>?) ?? const {},
      profileUpdatedAt: json['profile_updated_at'] != null
          ? DateTime.parse(json['profile_updated_at'] as String)
          : null,
      shareToken: json['share_token'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// 转为 Supabase JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'avatar_url': avatarUrl,
      'personality_traits': personalityTraits,
      'speaking_style': speakingStyle,
      'custom_prompt': customPrompt,
      'auto_reply_enabled': autoReplyEnabled,
    };
  }

  /// 复制修改
  AiAvatarModel copyWith({
    String? name,
    String? avatarUrl,
    List<String>? personalityTraits,
    String? speakingStyle,
    String? customPrompt,
    bool? autoReplyEnabled,
    DateTime? aiConsentAt,
    Map<String, dynamic>? fitnessHabits,
    DateTime? profileUpdatedAt,
    String? shareToken,
  }) {
    return AiAvatarModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      speakingStyle: speakingStyle ?? this.speakingStyle,
      customPrompt: customPrompt ?? this.customPrompt,
      autoReplyEnabled: autoReplyEnabled ?? this.autoReplyEnabled,
      aiConsentAt: aiConsentAt ?? this.aiConsentAt,
      fitnessHabits: fitnessHabits ?? this.fitnessHabits,
      profileUpdatedAt: profileUpdatedAt ?? this.profileUpdatedAt,
      shareToken: shareToken ?? this.shareToken,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// ========== 预设头像（emoji 标识 + 键值） ==========
  /// 每个预设头像用 emoji 在 UI 上展示，键值存入 avatar_url 字段
  static const List<PresetAvatar> presetAvatars = [
    PresetAvatar(key: 'runner',      emoji: '🏃', labelKey: 'presetRunner'),
    PresetAvatar(key: 'yogi',        emoji: '🧘', labelKey: 'presetYogi'),
    PresetAvatar(key: 'lifter',      emoji: '🏋️', labelKey: 'presetLifter'),
    PresetAvatar(key: 'swimmer',     emoji: '🏊', labelKey: 'presetSwimmer'),
    PresetAvatar(key: 'cyclist',     emoji: '🚴', labelKey: 'presetCyclist'),
    PresetAvatar(key: 'boxer',       emoji: '🥊', labelKey: 'presetBoxer'),
    PresetAvatar(key: 'climber',     emoji: '🧗', labelKey: 'presetClimber'),
    PresetAvatar(key: 'dancer',      emoji: '💃', labelKey: 'presetDancer'),
    PresetAvatar(key: 'martial',     emoji: '🥋', labelKey: 'presetMartial'),
    PresetAvatar(key: 'skier',       emoji: '⛷️', labelKey: 'presetSkier'),
    PresetAvatar(key: 'surfer',      emoji: '🏄', labelKey: 'presetSurfer'),
    PresetAvatar(key: 'tennis',      emoji: '🎾', labelKey: 'presetTennis'),
    PresetAvatar(key: 'basketball',  emoji: '🏀', labelKey: 'presetBasketball'),
    PresetAvatar(key: 'soccer',      emoji: '⚽', labelKey: 'presetSoccer'),
    PresetAvatar(key: 'hiker',       emoji: '🥾', labelKey: 'presetHiker'),
    PresetAvatar(key: 'gymnast',     emoji: '🤸', labelKey: 'presetGymnast'),
    PresetAvatar(key: 'rower',       emoji: '🚣', labelKey: 'presetRower'),
    PresetAvatar(key: 'skater',      emoji: '⛸️', labelKey: 'presetSkater'),
    PresetAvatar(key: 'ninja',       emoji: '🥷', labelKey: 'presetNinja'),
    PresetAvatar(key: 'robot',       emoji: '🤖', labelKey: 'presetRobot'),
    PresetAvatar(key: 'fire',        emoji: '🔥', labelKey: 'presetFire'),
    PresetAvatar(key: 'lightning',   emoji: '⚡', labelKey: 'presetLightning'),
    PresetAvatar(key: 'star',        emoji: '⭐', labelKey: 'presetStar'),
    PresetAvatar(key: 'diamond',     emoji: '💎', labelKey: 'presetDiamond'),
  ];

  /// ========== 运动主题个性标签 ==========
  static const List<String> availableTraits = [
    'earlyRunner',
    'yogaMaster',
    'ironAddict',
    'crossfitFanatic',
    'marathoner',
    'gymRat',
    'outdoorExplorer',
    'flexibilityPro',
    'teamPlayer',
    'soloWarrior',
    'techGeek',
    'nutritionNerd',
    'restDayHater',
    'warmupSkipper',
    'prBeast',
    'cheerleader',
  ];

  /// 可选的说话风格列表（3 种：活泼/沉稳/幽默）
  static const List<String> availableStyles = [
    'lively',
    'steady',
    'humorous',
  ];
}

/// 预设头像数据类
class PresetAvatar {
  final String key;
  final String emoji;
  final String labelKey;

  const PresetAvatar({
    required this.key,
    required this.emoji,
    required this.labelKey,
  });
}
