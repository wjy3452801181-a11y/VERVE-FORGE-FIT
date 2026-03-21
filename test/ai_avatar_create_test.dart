import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:verveforge/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:verveforge/features/ai_avatar/domain/ai_avatar_model.dart';
import 'package:verveforge/features/ai_avatar/presentation/ai_avatar_create_page.dart';
import 'package:verveforge/features/ai_avatar/presentation/widgets/personality_chip.dart';
import 'package:verveforge/features/ai_avatar/presentation/widgets/style_selector.dart';

/// 测试辅助：构建带 l10n + Riverpod 的 MaterialApp 包装器
Widget buildTestApp(Widget child) {
  return ProviderScope(
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

void main() {
  // ===========================================
  // AI 分身模型测试
  // ===========================================
  group('AiAvatarModel 数据模型', () {
    test('预设头像列表包含 24 个', () {
      expect(AiAvatarModel.presetAvatars.length, 24);
    });

    test('每个预设头像有 key/emoji/labelKey', () {
      for (final preset in AiAvatarModel.presetAvatars) {
        expect(preset.key, isNotEmpty);
        expect(preset.emoji, isNotEmpty);
        expect(preset.labelKey, isNotEmpty);
      }
    });

    test('预设头像 key 唯一', () {
      final keys = AiAvatarModel.presetAvatars.map((p) => p.key).toList();
      expect(keys.toSet().length, keys.length);
    });

    test('运动个性标签列表包含 16 个', () {
      expect(AiAvatarModel.availableTraits.length, 16);
    });

    test('标签 key 唯一', () {
      const traits = AiAvatarModel.availableTraits;
      expect(traits.toSet().length, traits.length);
    });

    test('说话风格有 3 种', () {
      expect(AiAvatarModel.availableStyles.length, 3);
      expect(AiAvatarModel.availableStyles, contains('lively'));
      expect(AiAvatarModel.availableStyles, contains('steady'));
      expect(AiAvatarModel.availableStyles, contains('humorous'));
    });

    test('fromJson 正确解析', () {
      final json = {
        'id': 'test-id',
        'user_id': 'user-1',
        'name': '测试分身',
        'avatar_url': 'preset:runner',
        'personality_traits': ['earlyRunner', 'gymRat'],
        'speaking_style': 'lively',
        'custom_prompt': '自定义指令',
        'auto_reply_enabled': true,
        'ai_consent_at': '2026-03-09T00:00:00Z',
        'created_at': '2026-03-09T00:00:00Z',
        'updated_at': '2026-03-09T00:00:00Z',
      };
      final model = AiAvatarModel.fromJson(json);
      expect(model.id, 'test-id');
      expect(model.name, '测试分身');
      expect(model.personalityTraits, ['earlyRunner', 'gymRat']);
      expect(model.speakingStyle, 'lively');
      expect(model.autoReplyEnabled, isTrue);
      expect(model.aiConsentAt, isNotNull);
    });

    test('toJson 正确输出', () {
      final model = AiAvatarModel(
        id: 'test-id',
        userId: 'user-1',
        name: '测试分身',
        avatarUrl: 'preset:runner',
        personalityTraits: const ['earlyRunner'],
        speakingStyle: 'steady',
        customPrompt: '',
        autoReplyEnabled: false,
        createdAt: DateTime(2026, 3, 9),
        updatedAt: DateTime(2026, 3, 9),
      );
      final json = model.toJson();
      expect(json['name'], '测试分身');
      expect(json['speaking_style'], 'steady');
      expect(json['personality_traits'], ['earlyRunner']);
    });

    test('copyWith 正确复制', () {
      final model = AiAvatarModel(
        id: 'test-id',
        userId: 'user-1',
        name: '原始名称',
        speakingStyle: 'lively',
        createdAt: DateTime(2026, 3, 9),
        updatedAt: DateTime(2026, 3, 9),
      );
      final updated = model.copyWith(name: '新名称', speakingStyle: 'humorous');
      expect(updated.name, '新名称');
      expect(updated.speakingStyle, 'humorous');
      expect(updated.id, 'test-id'); // id 不变
      expect(updated.userId, 'user-1'); // userId 不变
    });
  });

  // ===========================================
  // PersonalityChip 组件测试
  // ===========================================
  group('PersonalityChip 个性标签', () {
    testWidgets('显示 emoji + 标签文字', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const Scaffold(
            body: PersonalityChip(
              trait: 'earlyRunner',
              isSelected: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 应该显示 emoji 🌅 和中文标签
      expect(find.text('🌅'), findsOneWidget);
      expect(find.text('晨跑达人'), findsOneWidget);
    });

    testWidgets('选中状态显示对号', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const Scaffold(
            body: PersonalityChip(
              trait: 'gymRat',
              isSelected: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('点击触发 onTap 回调', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: PersonalityChip(
              trait: 'earlyRunner',
              isSelected: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PersonalityChip));
      expect(tapped, isTrue);
    });

    testWidgets('未知标签显示 fallback', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const Scaffold(
            body: PersonalityChip(
              trait: 'unknownTrait',
              isSelected: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 未知标签回退到 🏷️ + 原始 key
      expect(find.text('🏷️'), findsOneWidget);
      expect(find.text('unknownTrait'), findsOneWidget);
    });
  });

  // ===========================================
  // StyleSelector 风格选择器测试
  // ===========================================
  group('StyleSelector 风格选择器', () {
    testWidgets('显示 3 种风格选项', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: SingleChildScrollView(
              child: StyleSelector(
                selectedStyle: 'lively',
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 3 种风格的 emoji 标识
      expect(find.text('⚡'), findsOneWidget);
      expect(find.text('🧊'), findsOneWidget);
      expect(find.text('😂'), findsOneWidget);
    });

    testWidgets('选中风格显示预览气泡', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: SingleChildScrollView(
              child: StyleSelector(
                selectedStyle: 'lively',
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 选中 lively 时应显示预览文本
      expect(find.textContaining('太棒了'), findsOneWidget);
      // 应显示选中对号
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('点击切换选中风格', (tester) async {
      String selectedStyle = 'lively';
      await tester.pumpWidget(
        buildTestApp(
          StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: SingleChildScrollView(
                  child: StyleSelector(
                    selectedStyle: selectedStyle,
                    onChanged: (style) {
                      setState(() => selectedStyle = style);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 点击 "沉稳" 选项（🧊 emoji 所在行）
      await tester.tap(find.text('🧊'));
      await tester.pumpAndSettle();

      expect(selectedStyle, 'steady');
    });
  });

  // ===========================================
  // AiAvatarCreatePage 3 步向导冒烟测试
  // ===========================================
  group('AiAvatarCreatePage 向导流程', () {
    testWidgets('页面渲染无崩溃', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const AiAvatarCreatePage()),
      );
      await tester.pumpAndSettle();

      // 页面标题
      expect(find.text('创建 AI 分身'), findsOneWidget);
    });

    testWidgets('初始在 Step 1，显示步骤指示器', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const AiAvatarCreatePage()),
      );
      await tester.pumpAndSettle();

      // 步骤编号 1/2/3
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      // 步骤标签
      expect(find.text('选择外貌'), findsOneWidget);
      expect(find.text('性格特征'), findsOneWidget);
      expect(find.text('名称和风格'), findsOneWidget);
    });

    testWidgets('Step 1 显示预设头像网格（24 个）', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const AiAvatarCreatePage()),
      );
      await tester.pumpAndSettle();

      // 网格标题
      expect(find.text('选择一个预设头像'), findsOneWidget);

      // 预设头像至少部分在视图中可见（GridView 有 24 个）
      // 检查第一行的部分 emoji
      expect(find.text('🏃'), findsOneWidget);
      expect(find.text('🧘'), findsOneWidget);
    });

    testWidgets('Step 1 显示自定义上传入口', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const AiAvatarCreatePage()),
      );
      await tester.pumpAndSettle();

      // Step 1 内容较长，向下滚动以露出自定义上传区域
      final listView = find.byType(ListView).first;
      await tester.drag(listView, const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('或上传自定义头像'), findsOneWidget);
      expect(find.byIcon(Icons.add_a_photo_outlined), findsOneWidget);
    });

    testWidgets('Step 1 默认显示 🤖 预览', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const AiAvatarCreatePage()),
      );
      await tester.pumpAndSettle();

      // 没选择任何头像时预览区显示 🤖（44px）+ 网格中 robot 预设也是 🤖（22px）
      // 至少出现 1 个（预览区的大号 🤖）
      expect(find.text('🤖'), findsAtLeastNWidgets(1));
    });

    testWidgets('Step 1 选择预设头像后预览更新', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const AiAvatarCreatePage()),
      );
      await tester.pumpAndSettle();

      // 点击第一个预设头像 🏃
      await tester.tap(find.text('🏃').first);
      await tester.pumpAndSettle();

      // 预览区域应更新为 🏃（预览 44px + 网格中 26px，但至少出现 2 次）
      // 网格中选中的也会变大
      expect(find.text('🏃'), findsNWidgets(2));
    });

    testWidgets('Step 1 未选头像时点击下一步不前进', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const AiAvatarCreatePage()),
      );
      await tester.pumpAndSettle();

      // 初始 step 1，底部按钮文字为"下一步"
      expect(find.text('下一步'), findsOneWidget);

      // 不选头像直接点下一步
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();

      // 应该仍在 Step 1（SnackBar 会显示错误，仍能看到预设头像标题）
      expect(find.text('选择一个预设头像'), findsOneWidget);
    });

    testWidgets('Step 1 → Step 2 前进成功', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const AiAvatarCreatePage()),
      );
      await tester.pumpAndSettle();

      // 先选择一个头像
      await tester.tap(find.text('🏃').first);
      await tester.pumpAndSettle();

      // 点击下一步
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();

      // Step 2 应显示性格特征标题和提示
      expect(find.text('性格特征'), findsAtLeastNWidgets(1));
      expect(find.text('选择符合你的标签（最多 5 个）'), findsOneWidget);
    });

    testWidgets('Step 2 显示 16 个运动标签', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const AiAvatarCreatePage()),
      );
      await tester.pumpAndSettle();

      // 先进入 Step 2
      await tester.tap(find.text('🏃').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();

      // 16 个 PersonalityChip
      expect(find.byType(PersonalityChip), findsNWidgets(16));
    });

    testWidgets('Step 2 标签多选且最多 5 个', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const AiAvatarCreatePage()),
      );
      await tester.pumpAndSettle();

      // 先进入 Step 2
      await tester.tap(find.text('🏃').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();

      // 找到所有 PersonalityChip，逐个点击前 6 个
      final chips = find.byType(PersonalityChip);
      expect(chips, findsNWidgets(16));

      // 点击前 5 个
      for (int i = 0; i < 5; i++) {
        await tester.tap(chips.at(i));
        await tester.pumpAndSettle();
      }

      // 应该显示 5/5 计数
      expect(find.text('5/5'), findsOneWidget);

      // 点击第 6 个（应该不被选中，因为已满 5 个）
      await tester.tap(chips.at(5));
      await tester.pumpAndSettle();

      // 计数仍然是 5/5
      expect(find.text('5/5'), findsOneWidget);
    });

    testWidgets('Step 2 → Step 3 前进成功', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const AiAvatarCreatePage()),
      );
      await tester.pumpAndSettle();

      // Step 1 → Step 2
      await tester.tap(find.text('🏃').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();

      // Step 2 → Step 3（标签可选，不选也能前进）
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();

      // Step 3 应显示名称输入框
      expect(find.text('分身名称'), findsOneWidget);
      expect(find.text('给你的分身取个名字'), findsOneWidget);
    });

    testWidgets('Step 3 显示名称输入 + 风格选择 + 自定义指令', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const AiAvatarCreatePage()),
      );
      await tester.pumpAndSettle();

      // 快速导航到 Step 3
      await tester.tap(find.text('🏃').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();

      // 名称输入
      expect(find.text('分身名称'), findsOneWidget);

      // 风格预览标题
      expect(find.text('风格预览'), findsOneWidget);

      // StyleSelector 组件
      expect(find.byType(StyleSelector), findsOneWidget);

      // 向下滚动以露出自定义指令区域
      await tester.drag(find.byType(ListView).last, const Offset(0, -300));
      await tester.pumpAndSettle();

      // 自定义指令（可能因 TextField 渲染方式出现在 labelText 中）
      expect(find.text('自定义指令'), findsAtLeastNWidgets(1));
    });

    testWidgets('Step 3 按钮文字变为"创建 AI 分身"', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const AiAvatarCreatePage()),
      );
      await tester.pumpAndSettle();

      // 快速导航到 Step 3
      await tester.tap(find.text('🏃').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();

      // 按钮区域中包含"创建 AI 分身"文字（AppBar 标题也有一个，共 2 处）
      expect(find.text('创建 AI 分身'), findsNWidgets(2));
      // FilledButton 存在（创建按钮）
      expect(find.byType(FilledButton), findsOneWidget);
      // 不再显示"下一步"
      expect(find.text('下一步'), findsNothing);
    });

    testWidgets('Step 3 显示返回按钮', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const AiAvatarCreatePage()),
      );
      await tester.pumpAndSettle();

      // Step 1 不显示返回按钮
      expect(find.byIcon(Icons.arrow_back_rounded), findsNothing);

      // 前进到 Step 2
      await tester.tap(find.text('🏃').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();

      // Step 2 应显示返回按钮
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('返回按钮可回退步骤', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const AiAvatarCreatePage()),
      );
      await tester.pumpAndSettle();

      // 前进到 Step 2
      await tester.tap(find.text('🏃').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();

      // 确认在 Step 2
      expect(find.text('选择符合你的标签（最多 5 个）'), findsOneWidget);

      // 点击返回
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      // 应回到 Step 1，显示预设头像
      expect(find.text('选择一个预设头像'), findsOneWidget);
    });

    testWidgets('Step 3 名称为空时点击创建不提交', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const AiAvatarCreatePage()),
      );
      await tester.pumpAndSettle();

      // 快速导航到 Step 3
      await tester.tap(find.text('🏃').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();

      // 不输入名称，直接点创建按钮（FilledButton）
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // 应该仍在 Step 3（显示错误 SnackBar）
      expect(find.text('创建 AI 分身'), findsNWidgets(2));
      expect(find.text('风格预览'), findsOneWidget);
    });

    testWidgets('玻璃拟态卡片渲染无异常', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const AiAvatarCreatePage()),
      );
      await tester.pumpAndSettle();

      // 检查 BackdropFilter 存在（玻璃拟态核心组件）
      expect(find.byType(BackdropFilter), findsAtLeastNWidgets(1));
    });

    testWidgets('Step 3 输入名称后点创建弹出授权弹窗', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const AiAvatarCreatePage()),
      );
      await tester.pumpAndSettle();

      // 快速导航到 Step 3
      await tester.tap(find.text('🏃').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();

      // 输入名称
      await tester.enterText(find.byType(TextField).first, '我的分身');
      await tester.pumpAndSettle();

      // 点击创建按钮（FilledButton）
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // 应弹出 AI 数据授权同意弹窗
      expect(find.text('AI 数据处理授权'), findsOneWidget);
      expect(find.text('同意并继续'), findsOneWidget);
      expect(find.text('取消'), findsAtLeastNWidgets(1));
    });

    testWidgets('授权弹窗点取消回到 Step 3', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const AiAvatarCreatePage()),
      );
      await tester.pumpAndSettle();

      // 快速导航到 Step 3 + 输入名称
      await tester.tap(find.text('🏃').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '我的分身');
      await tester.pumpAndSettle();

      // 点击创建按钮（FilledButton）→ 弹窗
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // 点击取消
      await tester.tap(find.text('取消').last);
      await tester.pumpAndSettle();

      // 弹窗关闭，仍在 Step 3
      expect(find.text('AI 数据处理授权'), findsNothing);
      expect(find.text('创建 AI 分身'), findsNWidgets(2));
    });
  });
}
