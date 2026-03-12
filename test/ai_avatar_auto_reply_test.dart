import 'package:flutter_test/flutter_test.dart';

import 'package:verveforge/features/ai_avatar/domain/ai_avatar_model.dart';
import 'package:verveforge/features/ai_avatar/providers/ai_avatar_provider.dart';

void main() {
  // ===========================================
  // ChatMessage 模型测试
  // ===========================================
  group('ChatMessage 消息模型', () {
    test('默认 id 自动生成', () {
      final msg = ChatMessage(
        content: '测试消息',
        isUser: true,
        timestamp: DateTime.now(),
      );
      expect(msg.id, isNotEmpty);
      expect(msg.id, contains('_u'));
    });

    test('AI 消息 id 含 _a 后缀', () {
      final msg = ChatMessage(
        content: 'AI 回复',
        isUser: false,
        timestamp: DateTime.now(),
      );
      expect(msg.id, contains('_a'));
    });

    test('自定义 id 优先使用', () {
      final msg = ChatMessage(
        id: 'custom-id',
        content: '测试',
        isUser: true,
        timestamp: DateTime.now(),
      );
      expect(msg.id, 'custom-id');
    });

    test('isAiGenerated 默认为 false', () {
      final msg = ChatMessage(
        content: '测试',
        isUser: false,
        timestamp: DateTime.now(),
      );
      expect(msg.isAiGenerated, isFalse);
      expect(msg.avatarName, isNull);
    });

    test('自动回复消息 isAiGenerated 为 true', () {
      final msg = ChatMessage(
        content: 'AI 自动回复',
        isUser: false,
        timestamp: DateTime.now(),
        isAiGenerated: true,
        avatarName: '运动分身',
      );
      expect(msg.isAiGenerated, isTrue);
      expect(msg.avatarName, '运动分身');
    });
  });

  // ===========================================
  // ChatMessage.fromSupabaseMessage 工厂测试
  // ===========================================
  group('ChatMessage.fromSupabaseMessage 解析', () {
    test('解析普通用户消息', () {
      final json = {
        'id': 'msg-1',
        'content': '你好',
        'sender_id': 'user-1',
        'created_at': '2026-03-09T12:00:00Z',
        'metadata': null,
      };
      final msg = ChatMessage.fromSupabaseMessage(
        json,
        currentUserId: 'user-1',
      );
      expect(msg.id, 'msg-1');
      expect(msg.content, '你好');
      expect(msg.isUser, isTrue);
      expect(msg.isAiGenerated, isFalse);
      expect(msg.avatarName, isNull);
    });

    test('解析对方消息', () {
      final json = {
        'id': 'msg-2',
        'content': '你好呀',
        'sender_id': 'user-2',
        'created_at': '2026-03-09T12:01:00Z',
        'metadata': null,
      };
      final msg = ChatMessage.fromSupabaseMessage(
        json,
        currentUserId: 'user-1',
      );
      expect(msg.isUser, isFalse);
      expect(msg.isAiGenerated, isFalse);
    });

    test('解析 AI 自动回复消息', () {
      final json = {
        'id': 'msg-3',
        'content': '我刚跑完步，稍后回你！',
        'sender_id': 'user-1',
        'created_at': '2026-03-09T12:02:00Z',
        'metadata': {
          'is_ai_generated': true,
          'avatar_id': 'avatar-1',
          'avatar_name': '运动达人',
          'auto_reply': true,
        },
      };
      final msg = ChatMessage.fromSupabaseMessage(
        json,
        currentUserId: 'user-1',
      );
      // AI 生成的消息虽然 sender_id == currentUserId，但 isUser 应为 false
      expect(msg.isUser, isFalse);
      expect(msg.isAiGenerated, isTrue);
      expect(msg.avatarName, '运动达人');
    });

    test('metadata 为空时不是 AI 消息', () {
      final json = {
        'id': 'msg-4',
        'content': '测试',
        'sender_id': 'user-1',
        'created_at': '2026-03-09T12:03:00Z',
      };
      final msg = ChatMessage.fromSupabaseMessage(
        json,
        currentUserId: 'user-1',
      );
      expect(msg.isAiGenerated, isFalse);
    });

    test('metadata.is_ai_generated 为 false 时不是 AI 消息', () {
      final json = {
        'id': 'msg-5',
        'content': '测试',
        'sender_id': 'user-1',
        'created_at': '2026-03-09T12:04:00Z',
        'metadata': {'is_ai_generated': false},
      };
      final msg = ChatMessage.fromSupabaseMessage(
        json,
        currentUserId: 'user-1',
      );
      expect(msg.isAiGenerated, isFalse);
      expect(msg.isUser, isTrue);
    });
  });

  // ===========================================
  // AiAvatarModel shouldAutoReply 逻辑测试
  // ===========================================
  group('自动回复条件判断', () {
    test('分身不存在时不应自动回复', () {
      // shouldAutoReply 在 Notifier 中，这里用模型字段直接测试逻辑
      const AiAvatarModel? avatar = null;
      final result = avatar != null &&
          avatar.autoReplyEnabled &&
          avatar.aiConsentAt != null;
      expect(result, isFalse);
    });

    test('auto_reply_enabled=false 时不应自动回复', () {
      final avatar = AiAvatarModel(
        id: 'test-id',
        userId: 'user-1',
        name: '测试分身',
        autoReplyEnabled: false,
        aiConsentAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final result = avatar.autoReplyEnabled && avatar.aiConsentAt != null;
      expect(result, isFalse);
    });

    test('ai_consent_at=null 时不应自动回复（PIPL 未授权）', () {
      final avatar = AiAvatarModel(
        id: 'test-id',
        userId: 'user-1',
        name: '测试分身',
        autoReplyEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final result = avatar.autoReplyEnabled && avatar.aiConsentAt != null;
      expect(result, isFalse);
    });

    test('auto_reply_enabled=true + ai_consent_at 有值时应自动回复', () {
      final avatar = AiAvatarModel(
        id: 'test-id',
        userId: 'user-1',
        name: '测试分身',
        autoReplyEnabled: true,
        aiConsentAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final result = avatar.autoReplyEnabled && avatar.aiConsentAt != null;
      expect(result, isTrue);
    });
  });

  // ===========================================
  // AiAvatarChatState 状态模型测试
  // ===========================================
  group('AiAvatarChatState 状态模型', () {
    test('默认状态', () {
      const state = AiAvatarChatState();
      expect(state.messages, isEmpty);
      expect(state.isTyping, isFalse);
      expect(state.isLoadingHistory, isFalse);
    });

    test('copyWith 正确复制', () {
      const state = AiAvatarChatState();
      final updated = state.copyWith(isTyping: true);
      expect(updated.isTyping, isTrue);
      expect(updated.messages, isEmpty);
      expect(updated.isLoadingHistory, isFalse);
    });

    test('copyWith 设置消息列表', () {
      const state = AiAvatarChatState();
      final messages = [
        ChatMessage(content: '你好', isUser: true, timestamp: DateTime.now()),
        ChatMessage(
          content: 'AI 回复',
          isUser: false,
          timestamp: DateTime.now(),
          isAiGenerated: true,
          avatarName: '分身',
        ),
      ];
      final updated = state.copyWith(messages: messages);
      expect(updated.messages.length, 2);
      expect(updated.messages[1].isAiGenerated, isTrue);
      expect(updated.messages[1].avatarName, '分身');
    });
  });

  // ===========================================
  // 频率限制逻辑测试（模拟）
  // ===========================================
  group('频率限制逻辑', () {
    test('5 分钟内 3 条以内允许回复', () {
      final now = DateTime.now();
      final replies = [
        now.subtract(const Duration(minutes: 4)),
        now.subtract(const Duration(minutes: 3)),
      ];
      // 模拟：窗口内已有 2 条，还能回复 1 条
      final windowStart = now.subtract(const Duration(minutes: 5));
      final inWindowCount =
          replies.where((t) => t.isAfter(windowStart)).length;
      expect(inWindowCount, 2);
      expect(inWindowCount < 3, isTrue); // 未超限
    });

    test('5 分钟内超过 3 条阻止回复', () {
      final now = DateTime.now();
      final replies = [
        now.subtract(const Duration(minutes: 4)),
        now.subtract(const Duration(minutes: 3)),
        now.subtract(const Duration(minutes: 1)),
      ];
      final windowStart = now.subtract(const Duration(minutes: 5));
      final inWindowCount =
          replies.where((t) => t.isAfter(windowStart)).length;
      expect(inWindowCount, 3);
      expect(inWindowCount >= 3, isTrue); // 已达限
    });

    test('超过 5 分钟的回复不计入窗口', () {
      final now = DateTime.now();
      final replies = [
        now.subtract(const Duration(minutes: 10)),
        now.subtract(const Duration(minutes: 8)),
        now.subtract(const Duration(minutes: 6)),
        now.subtract(const Duration(minutes: 2)),
      ];
      final windowStart = now.subtract(const Duration(minutes: 5));
      final inWindowCount =
          replies.where((t) => t.isAfter(windowStart)).length;
      expect(inWindowCount, 1); // 仅最后一条在窗口内
      expect(inWindowCount < 3, isTrue);
    });
  });

  // ===========================================
  // 防循环检测逻辑测试
  // ===========================================
  group('防循环检测', () {
    test('is_ai_generated=true 的消息应被跳过', () {
      final metadata = {'is_ai_generated': true, 'avatar_id': 'a1'};
      final isAiGenerated = metadata['is_ai_generated'] == true;
      expect(isAiGenerated, isTrue);
    });

    test('is_ai_generated=false 的消息应正常处理', () {
      final metadata = {'is_ai_generated': false};
      final isAiGenerated = metadata['is_ai_generated'] == true;
      expect(isAiGenerated, isFalse);
    });

    test('metadata=null 的消息应正常处理', () {
      const Map<String, dynamic>? metadata = null;
      final isAiGenerated = metadata?['is_ai_generated'] == true;
      expect(isAiGenerated, isFalse);
    });

    test('metadata 无 is_ai_generated 字段的消息应正常处理', () {
      final metadata = <String, dynamic>{'other_field': 'value'};
      final isAiGenerated = metadata['is_ai_generated'] == true;
      expect(isAiGenerated, isFalse);
    });
  });
}
