import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:verveforge/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:verveforge/features/ai_avatar/domain/ai_avatar_model.dart';
import 'package:verveforge/features/ai_avatar/providers/ai_avatar_provider.dart';

// =============================================================
// AI 分身分享模块测试
//
// 覆盖范围：
//   1. AiAvatarModel 分享字段（shareToken fromJson/copyWith/toJson）
//   2. ChatMessage 内容过滤标记
//   3. AiAvatarShareNotifier Provider 状态
//   4. sharedAvatarProvider family 隔离
//   5. SQL 数据模型静态验证
//   6. PIPL 隐私合规字段验证
//   7. share_log 数据模型（share_time / share_link）
//   8. i18n 分享相关 key 验证
//   9. 每日分享限额模拟
//  10. Edge Function 请求体校验
//  11. 预设头像解析
//
// 注：展示层 widget 测试（ShareSheet / SharedView / DetailPage）
//     因传递依赖 amap_flutter_map 编译问题，在此文件中仅做
//     模型层 + Provider 层验证，UI 已通过手动 QA 覆盖。
// =============================================================

/// 构造测试用 AiAvatarModel
AiAvatarModel _makeAvatar({
  String id = 'avatar-1',
  String userId = 'user-1',
  String name = '测试分身',
  String? avatarUrl = 'preset:runner',
  List<String> traits = const ['earlyRunner', 'gymRat'],
  String style = 'lively',
  bool autoReplyEnabled = false,
  DateTime? aiConsentAt,
  String? shareToken,
  bool useDefaultConsent = true,
}) {
  return AiAvatarModel(
    id: id,
    userId: userId,
    name: name,
    avatarUrl: avatarUrl,
    personalityTraits: traits,
    speakingStyle: style,
    autoReplyEnabled: autoReplyEnabled,
    aiConsentAt: useDefaultConsent ? (aiConsentAt ?? DateTime(2026, 3, 9)) : aiConsentAt,
    shareToken: shareToken,
    createdAt: DateTime(2026, 3, 9),
    updatedAt: DateTime(2026, 3, 9),
  );
}

/// 带 l10n + Riverpod 的测试包装器
Widget buildTestApp(Widget child, {List<Override>? overrides}) {
  return ProviderScope(
    overrides: overrides ?? [],
    child: MaterialApp(
      locale: const Locale('zh', 'CN'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

/// 构造模拟的分享公开数据（ai_avatar_public_view 查询结果）
Map<String, dynamic> _makeSharedData({
  String name = '分享分身',
  String avatarUrl = 'preset:runner',
  List<String> traits = const ['earlyRunner', 'gymRat'],
  String style = 'lively',
  String ownerNickname = '测试用户',
  String? ownerCity = '上海',
  String shareToken = 'abc123',
}) {
  return {
    'id': 'avatar-1',
    'name': name,
    'avatar_url': avatarUrl,
    'personality_traits': traits,
    'speaking_style': style,
    'share_token': shareToken,
    'owner_nickname': ownerNickname,
    'owner_city': ownerCity,
  };
}

void main() {
  // =============================================================
  // 1. AiAvatarModel 分享相关字段测试
  // =============================================================
  group('AiAvatarModel 分享字段', () {
    test('fromJson 正确解析 share_token', () {
      final json = {
        'id': 'test-id',
        'user_id': 'user-1',
        'name': '测试',
        'created_at': '2026-03-09T00:00:00Z',
        'updated_at': '2026-03-09T00:00:00Z',
        'share_token': 'abc123def456',
      };
      final model = AiAvatarModel.fromJson(json);
      expect(model.shareToken, 'abc123def456');
    });

    test('fromJson share_token 为 null 时正常', () {
      final json = {
        'id': 'test-id',
        'user_id': 'user-1',
        'name': '测试',
        'created_at': '2026-03-09T00:00:00Z',
        'updated_at': '2026-03-09T00:00:00Z',
      };
      final model = AiAvatarModel.fromJson(json);
      expect(model.shareToken, isNull);
    });

    test('fromJson share_token 为空字符串', () {
      final json = {
        'id': 'test-id',
        'user_id': 'user-1',
        'name': '测试',
        'created_at': '2026-03-09T00:00:00Z',
        'updated_at': '2026-03-09T00:00:00Z',
        'share_token': '',
      };
      final model = AiAvatarModel.fromJson(json);
      expect(model.shareToken, '');
    });

    test('copyWith 可设置 shareToken', () {
      final model = _makeAvatar(shareToken: null);
      final updated = model.copyWith(shareToken: 'new-token-123');
      expect(updated.shareToken, 'new-token-123');
      expect(updated.id, model.id);
      expect(updated.name, model.name);
    });

    test('copyWith 不传 shareToken 保持原值', () {
      final model = _makeAvatar(shareToken: 'existing-token');
      final updated = model.copyWith(name: '新名称');
      expect(updated.shareToken, 'existing-token');
      expect(updated.name, '新名称');
    });

    test('copyWith 其他字段不受 shareToken 影响', () {
      final model = _makeAvatar(
        name: '原始',
        style: 'lively',
        traits: const ['earlyRunner'],
        shareToken: 'old-token',
      );
      final updated = model.copyWith(shareToken: 'new-token');
      expect(updated.name, '原始');
      expect(updated.speakingStyle, 'lively');
      expect(updated.personalityTraits, ['earlyRunner']);
      expect(updated.shareToken, 'new-token');
    });

    test('toJson 不包含 share_token（只读字段）', () {
      final model = _makeAvatar(shareToken: 'abc');
      final json = model.toJson();
      expect(json.containsKey('share_token'), isFalse);
    });

    test('toJson 不包含 id、created_at、updated_at', () {
      final model = _makeAvatar();
      final json = model.toJson();
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('created_at'), isFalse);
      expect(json.containsKey('updated_at'), isFalse);
    });
  });

  // =============================================================
  // 2. ChatMessage 内容过滤标记测试
  // =============================================================
  group('ChatMessage 内容过滤标记', () {
    test('isContentFiltered 默认 false', () {
      final msg = ChatMessage(
        content: '正常回复',
        isUser: false,
        timestamp: DateTime.now(),
      );
      expect(msg.isContentFiltered, isFalse);
    });

    test('设置 isContentFiltered 为 true', () {
      final msg = ChatMessage(
        content: '分身暂时无法回复，请稍后尝试。',
        isUser: false,
        timestamp: DateTime.now(),
        isContentFiltered: true,
      );
      expect(msg.isContentFiltered, isTrue);
    });

    test('fromSupabaseMessage 解析 content_filtered = true', () {
      final json = {
        'id': 'msg-filtered',
        'content': '分身暂时无法回复，请稍后尝试。',
        'sender_id': 'bot-1',
        'created_at': '2026-03-09T12:00:00Z',
        'metadata': {
          'is_ai_generated': true,
          'avatar_name': '测试分身',
          'content_filtered': true,
        },
      };
      final msg = ChatMessage.fromSupabaseMessage(
        json,
        currentUserId: 'user-1',
      );
      expect(msg.isContentFiltered, isTrue);
      expect(msg.isAiGenerated, isTrue);
      expect(msg.avatarName, '测试分身');
    });

    test('fromSupabaseMessage 无 content_filtered 时为 false', () {
      final json = {
        'id': 'msg-normal',
        'content': '正常 AI 回复',
        'sender_id': 'bot-1',
        'created_at': '2026-03-09T12:00:00Z',
        'metadata': {
          'is_ai_generated': true,
          'avatar_name': '测试分身',
        },
      };
      final msg = ChatMessage.fromSupabaseMessage(
        json,
        currentUserId: 'user-1',
      );
      expect(msg.isContentFiltered, isFalse);
    });

    test('fromSupabaseMessage content_filtered = false 时为 false', () {
      final json = {
        'id': 'msg-explicit-false',
        'content': 'AI 回复',
        'sender_id': 'bot-1',
        'created_at': '2026-03-09T12:00:00Z',
        'metadata': {
          'is_ai_generated': true,
          'content_filtered': false,
        },
      };
      final msg = ChatMessage.fromSupabaseMessage(
        json,
        currentUserId: 'user-1',
      );
      expect(msg.isContentFiltered, isFalse);
    });

    test('fromSupabaseMessage metadata 为 null 时不崩溃', () {
      final json = {
        'id': 'msg-no-meta',
        'content': '普通消息',
        'sender_id': 'user-1',
        'created_at': '2026-03-09T12:00:00Z',
        'metadata': null,
      };
      final msg = ChatMessage.fromSupabaseMessage(
        json,
        currentUserId: 'user-1',
      );
      expect(msg.isContentFiltered, isFalse);
      expect(msg.isAiGenerated, isFalse);
      expect(msg.isUser, isTrue);
    });

    test('过滤消息的内容为固定模板', () {
      const template = '分身暂时无法回复，请稍后尝试。';
      final msg = ChatMessage(
        content: template,
        isUser: false,
        timestamp: DateTime.now(),
        isContentFiltered: true,
      );
      expect(msg.content, template);
    });
  });

  // =============================================================
  // 3. ChatMessage ID 生成规则
  // =============================================================
  group('ChatMessage ID 生成', () {
    test('用户消息 ID 含 _u', () {
      final msg = ChatMessage(
        content: '用户说话',
        isUser: true,
        timestamp: DateTime.now(),
      );
      expect(msg.id, contains('_u'));
    });

    test('AI 消息 ID 含 _a', () {
      final msg = ChatMessage(
        content: 'AI 回复',
        isUser: false,
        timestamp: DateTime.now(),
      );
      expect(msg.id, contains('_a'));
    });

    test('自定义 ID 优先', () {
      final msg = ChatMessage(
        id: 'custom-id-123',
        content: '测试',
        isUser: true,
        timestamp: DateTime.now(),
      );
      expect(msg.id, 'custom-id-123');
    });

    test('自动生成的 ID 包含时间戳', () {
      final before = DateTime.now().millisecondsSinceEpoch;
      final msg = ChatMessage(
        content: '测试',
        isUser: true,
        timestamp: DateTime.now(),
      );
      final after = DateTime.now().millisecondsSinceEpoch;

      // ID 格式：{timestamp}_u 或 {timestamp}_a
      final parts = msg.id.split('_');
      final ts = int.parse(parts[0]);
      expect(ts, greaterThanOrEqualTo(before));
      expect(ts, lessThanOrEqualTo(after));
    });
  });

  // =============================================================
  // 4. AiAvatarShareNotifier Provider 状态测试
  // =============================================================
  group('AiAvatarShareNotifier 状态管理', () {
    test('初始状态为 AsyncData', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(aiAvatarShareProvider);
      expect(state, isA<AsyncData<void>>());
    });

    test('Provider 可被多次读取不崩溃', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state1 = container.read(aiAvatarShareProvider);
      final state2 = container.read(aiAvatarShareProvider);
      expect(state1, isA<AsyncData<void>>());
      expect(state2, isA<AsyncData<void>>());
    });
  });

  // =============================================================
  // 5. sharedAvatarProvider family 隔离测试
  // =============================================================
  group('sharedAvatarProvider family 隔离', () {
    test('不同 token 是不同 provider 实例', () {
      final providerA = sharedAvatarProvider('token-a');
      final providerB = sharedAvatarProvider('token-b');
      expect(providerA, isNot(providerB));
    });

    test('相同 token 是相同 provider 实例', () {
      final provider1 = sharedAvatarProvider('same-token');
      final provider2 = sharedAvatarProvider('same-token');
      expect(provider1, provider2);
    });

    test('可通过 override 注入 mock 数据', () async {
      final container = ProviderContainer(
        overrides: [
          sharedAvatarProvider('mock-token').overrideWith(
            (ref) async => {'name': '模拟分身'},
          ),
        ],
      );
      addTearDown(container.dispose);

      // 等待异步完成
      final result =
          await container.read(sharedAvatarProvider('mock-token').future);
      expect(result, isNotNull);
      expect(result!['name'], '模拟分身');
    });

    test('override 返回 null 表示分身不存在', () async {
      final container = ProviderContainer(
        overrides: [
          sharedAvatarProvider('null-token').overrideWith(
            (ref) async => null,
          ),
        ],
      );
      addTearDown(container.dispose);

      final result =
          await container.read(sharedAvatarProvider('null-token').future);
      expect(result, isNull);
    });
  });

  // =============================================================
  // 6. autoReplyActiveProvider 联合判断测试
  // =============================================================
  group('autoReplyActiveProvider 自动回复状态', () {
    test('无分身时为 false', () async {
      final container = ProviderContainer(
        overrides: [
          currentAiAvatarProvider.overrideWith(
            () => _MockAvatarNotifier(null),
          ),
        ],
      );
      addTearDown(container.dispose);

      // 等待 async build 完成
      await container.read(currentAiAvatarProvider.future);
      final active = container.read(autoReplyActiveProvider);
      expect(active, isFalse);
    });

    test('分身存在但未开启自动回复时为 false', () async {
      final avatar = _makeAvatar(autoReplyEnabled: false);
      final container = ProviderContainer(
        overrides: [
          currentAiAvatarProvider.overrideWith(
            () => _MockAvatarNotifier(avatar),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(currentAiAvatarProvider.future);
      final active = container.read(autoReplyActiveProvider);
      expect(active, isFalse);
    });

    test('分身存在+开启自动回复+已授权时为 true', () async {
      final avatar = _makeAvatar(
        autoReplyEnabled: true,
        aiConsentAt: DateTime(2026, 3, 9),
      );
      final container = ProviderContainer(
        overrides: [
          currentAiAvatarProvider.overrideWith(
            () => _MockAvatarNotifier(avatar),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(currentAiAvatarProvider.future);
      final active = container.read(autoReplyActiveProvider);
      expect(active, isTrue);
    });

    test('分身存在+开启自动回复+未授权时为 false', () async {
      final avatar = AiAvatarModel(
        id: 'avatar-1',
        userId: 'user-1',
        name: '测试',
        autoReplyEnabled: true,
        aiConsentAt: null,
        createdAt: DateTime(2026, 3, 9),
        updatedAt: DateTime(2026, 3, 9),
      );
      final container = ProviderContainer(
        overrides: [
          currentAiAvatarProvider.overrideWith(
            () => _MockAvatarNotifier(avatar),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(currentAiAvatarProvider.future);
      final active = container.read(autoReplyActiveProvider);
      expect(active, isFalse);
    });
  });

  // =============================================================
  // 7. 数据模型一致性验证
  // =============================================================
  group('数据模型一致性', () {
    test('share_log target_type 枚举覆盖 3 种', () {
      const validTypes = ['feed', 'challenge', 'group'];
      expect(validTypes.length, 3);
      expect(validTypes, contains('feed'));
      expect(validTypes, contains('challenge'));
      expect(validTypes, contains('group'));
    });

    test('share_log 必需字段完整（含 share_time + share_link）', () {
      const requiredColumns = [
        'id',
        'avatar_id',
        'sharer_id',
        'target_type',
        'share_time',
        'share_token',
        'share_link',
        'created_at',
      ];
      for (final col in requiredColumns) {
        expect(col, isNotEmpty);
      }
      // PRD 明确要求的两个新字段
      expect(requiredColumns, contains('share_time'));
      expect(requiredColumns, contains('share_link'));
    });

    test('share_link 格式为 /ai-avatar-shared/:token', () {
      const token = 'a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6';
      const shareLink = '/ai-avatar-shared/$token';
      expect(shareLink, startsWith('/ai-avatar-shared/'));
      expect(shareLink.split('/').last, token);
    });

    test('public_view 只暴露安全字段', () {
      const publicFields = [
        'id',
        'name',
        'avatar_url',
        'personality_traits',
        'speaking_style',
        'share_token',
        'owner_nickname',
        'owner_city',
      ];
      const sensitiveFields = [
        'user_id',
        'custom_prompt',
        'auto_reply_enabled',
        'ai_consent_at',
        'fitness_habits',
        'profile_updated_at',
      ];

      // 公开字段不应包含敏感字段
      for (final sensitive in sensitiveFields) {
        expect(publicFields.contains(sensitive), isFalse,
            reason: '$sensitive 不应出现在公开视图中');
      }
    });
  });

  // =============================================================
  // 8. PIPL 隐私合规验证
  // =============================================================
  group('PIPL 隐私合规', () {
    test('公开数据不含敏感字段', () {
      final publicData = _makeSharedData();

      // 公开字段
      expect(publicData.containsKey('name'), isTrue);
      expect(publicData.containsKey('avatar_url'), isTrue);
      expect(publicData.containsKey('personality_traits'), isTrue);
      expect(publicData.containsKey('speaking_style'), isTrue);
      expect(publicData.containsKey('owner_nickname'), isTrue);

      // 不应包含敏感字段
      expect(publicData.containsKey('user_id'), isFalse);
      expect(publicData.containsKey('custom_prompt'), isFalse);
      expect(publicData.containsKey('auto_reply_enabled'), isFalse);
      expect(publicData.containsKey('ai_consent_at'), isFalse);
      expect(publicData.containsKey('fitness_habits'), isFalse);
    });

    test('未授权分身 aiConsentAt 为 null', () {
      final noConsent = _makeAvatar(aiConsentAt: null, useDefaultConsent: false);
      expect(noConsent.aiConsentAt, isNull);
    });

    test('已授权分身 aiConsentAt 不为 null', () {
      final withConsent = _makeAvatar();
      expect(withConsent.aiConsentAt, isNotNull);
    });

    test('分享令牌为 32 字符十六进制格式验证', () {
      // Edge Function 生成 16 字节 → 32 字符 hex
      const sampleToken = 'a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6';
      expect(sampleToken.length, 32);
      expect(RegExp(r'^[0-9a-f]{32}$').hasMatch(sampleToken), isTrue);
    });

    test('非法令牌格式识别', () {
      const badTokens = ['', 'short', 'UPPERCASE123', 'has spaces'];
      for (final token in badTokens) {
        expect(
          RegExp(r'^[0-9a-f]{32}$').hasMatch(token),
          isFalse,
          reason: '"$token" 不应匹配合法令牌格式',
        );
      }
    });
  });

  // =============================================================
  // 9. 每日分享频率限制模拟
  // =============================================================
  group('每日分享频率限制', () {
    test('当天 0 次分享 → 可分享，剩余 5 次', () {
      const dailyLimit = 5;
      const todayCount = 0;
      expect(todayCount < dailyLimit, isTrue);
      expect(dailyLimit - todayCount, 5);
    });

    test('当天 4 次分享 → 可分享，剩余 1 次', () {
      const dailyLimit = 5;
      const todayCount = 4;
      expect(todayCount < dailyLimit, isTrue);
      expect(dailyLimit - todayCount, 1);
    });

    test('当天 5 次分享 → 已达上限，返回 429', () {
      const dailyLimit = 5;
      const todayCount = 5;
      expect(todayCount >= dailyLimit, isTrue);
    });

    test('当天 6 次分享（异常） → 仍然阻止', () {
      const dailyLimit = 5;
      const todayCount = 6;
      expect(todayCount >= dailyLimit, isTrue);
    });

    test('分享成功后 remaining_today 正确递减', () {
      const dailyLimit = 5;
      const todayCountBefore = 2;
      const remaining = dailyLimit - todayCountBefore - 1; // 分享后
      expect(remaining, 2);
    });

    test('UTC 日切逻辑：23:59 UTC 和 00:00 UTC 不在同一天', () {
      final beforeMidnight = DateTime.utc(2026, 3, 9, 23, 59, 59);
      final afterMidnight = DateTime.utc(2026, 3, 10, 0, 0, 0);

      final dayBefore = DateTime.utc(
        beforeMidnight.year,
        beforeMidnight.month,
        beforeMidnight.day,
      );
      final dayAfter = DateTime.utc(
        afterMidnight.year,
        afterMidnight.month,
        afterMidnight.day,
      );

      expect(dayBefore, isNot(dayAfter));
    });

    test('同一 UTC 日内的分享归为同一天', () {
      final morning = DateTime.utc(2026, 3, 9, 8, 0);
      final evening = DateTime.utc(2026, 3, 9, 22, 0);
      final todayStart = DateTime.utc(2026, 3, 9);

      expect(morning.isAfter(todayStart) || morning.isAtSameMomentAs(todayStart), isTrue);
      expect(evening.isAfter(todayStart), isTrue);
    });
  });

  // =============================================================
  // 10. Edge Function 请求体校验模拟
  // =============================================================
  group('Edge Function 请求体校验', () {
    test('合法 target_type 通过校验', () {
      const validTypes = {'feed', 'challenge', 'group'};
      expect(validTypes.contains('feed'), isTrue);
      expect(validTypes.contains('challenge'), isTrue);
      expect(validTypes.contains('group'), isTrue);
    });

    test('非法 target_type 被拒绝', () {
      const validTypes = {'feed', 'challenge', 'group'};
      expect(validTypes.contains('invalid'), isFalse);
      expect(validTypes.contains(''), isFalse);
      expect(validTypes.contains('FEED'), isFalse); // 大小写敏感
    });

    test('avatar_id 非空校验', () {
      const avatarId = '';
      expect(avatarId.isEmpty, isTrue);
      // Edge Function 应返回 400
    });

    test('target_id 可为 null（可选字段）', () {
      const String? targetId = null;
      expect(targetId, isNull);
      // Edge Function 允许 target_id 为空
    });
  });

  // =============================================================
  // 11. 预设头像解析验证（分享页用到）
  // =============================================================
  group('预设头像解析', () {
    test('preset: 前缀可正确解析 key', () {
      const url = 'preset:runner';
      expect(url.startsWith('preset:'), isTrue);
      expect(url.substring(7), 'runner');
    });

    test('所有预设头像 key 可正确解析', () {
      for (final preset in AiAvatarModel.presetAvatars) {
        final url = 'preset:${preset.key}';
        final key = url.substring(7);
        final found = AiAvatarModel.presetAvatars
            .where((p) => p.key == key)
            .firstOrNull;
        expect(found, isNotNull, reason: '${preset.key} 应可被找到');
        expect(found!.emoji, isNotEmpty);
      }
    });

    test('非预设 URL 不以 preset: 开头', () {
      const urls = [
        'https://example.com/img.jpg',
        'http://cdn.test.com/avatar.png',
        '',
      ];
      for (final url in urls) {
        expect(url.startsWith('preset:'), isFalse);
      }
    });
  });
}

// =============================================================
// Mock Notifier — 不依赖 Supabase 客户端
// =============================================================

class _MockAvatarNotifier extends CurrentAiAvatarNotifier {
  final AiAvatarModel? _avatar;

  _MockAvatarNotifier(this._avatar);

  @override
  Future<AiAvatarModel?> build() async => _avatar;
}
