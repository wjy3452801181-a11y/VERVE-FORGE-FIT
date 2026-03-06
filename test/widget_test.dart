import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verveforge/app/theme/app_colors.dart';
import 'package:verveforge/app/theme/app_theme.dart';
import 'package:verveforge/core/constants/app_constants.dart';
import 'package:verveforge/core/extensions/string_extensions.dart';
import 'package:verveforge/core/extensions/datetime_extensions.dart';
import 'package:verveforge/core/utils/validators.dart';
import 'package:verveforge/core/utils/debouncer.dart';
import 'package:verveforge/shared/widgets/empty_state.dart';
import 'package:verveforge/shared/widgets/avatar_widget.dart';
import 'package:verveforge/shared/widgets/sport_type_icon.dart';

void main() {
  // ===========================================
  // 主题测试
  // ===========================================
  group('AppTheme', () {
    test('深色主题使用 Material 3', () {
      final theme = AppTheme.darkTheme;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
    });

    test('浅色主题使用 Material 3', () {
      final theme = AppTheme.lightTheme;
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
    });

    test('主色调为活力橙', () {
      expect(AppColors.primary, const Color(0xFFFF6B35));
    });

    test('运动类型各有独立标识色', () {
      expect(AppColors.hyrox, isNot(equals(AppColors.crossfit)));
      expect(AppColors.yoga, isNot(equals(AppColors.pilates)));
    });

    test('训练强度色阶有 10 级', () {
      expect(AppColors.intensityGradient.length, 10);
    });
  });

  // ===========================================
  // 常量测试
  // ===========================================
  group('AppConstants', () {
    test('运动类型包含 HYROX 和 CrossFit', () {
      expect(AppConstants.sportTypes, contains('hyrox'));
      expect(AppConstants.sportTypes, contains('crossfit'));
      expect(AppConstants.sportTypes, contains('yoga'));
      expect(AppConstants.sportTypes, contains('pilates'));
    });

    test('支持的城市包含首批 5 个', () {
      expect(AppConstants.supportedCities.length, 5);
      expect(AppConstants.supportedCities, contains('beijing'));
      expect(AppConstants.supportedCities, contains('hongkong'));
    });

    test('经验等级有 4 级', () {
      expect(AppConstants.experienceLevels.length, 4);
    });

    test('最大照片数为 9', () {
      expect(AppConstants.maxPhotos, 9);
    });

    test('训练强度范围 1-10', () {
      expect(AppConstants.minIntensity, 1);
      expect(AppConstants.maxIntensity, 10);
    });
  });

  // ===========================================
  // 表单校验器测试
  // ===========================================
  group('Validators', () {
    group('手机号校验', () {
      test('有效的中国大陆手机号', () {
        expect(Validators.phone('13812345678'), isNull);
        expect(Validators.phone('18999999999'), isNull);
      });

      test('有效的香港手机号', () {
        expect(Validators.phone('51234567'), isNull);
        expect(Validators.phone('98765432'), isNull);
      });

      test('无效手机号', () {
        expect(Validators.phone('12345'), isNotNull);
        expect(Validators.phone(''), isNotNull);
        expect(Validators.phone(null), isNotNull);
        expect(Validators.phone('abcdefghijk'), isNotNull);
      });
    });

    group('验证码校验', () {
      test('有效验证码', () {
        expect(Validators.otp('123456'), isNull);
        expect(Validators.otp('000000'), isNull);
      });

      test('无效验证码', () {
        expect(Validators.otp('12345'), isNotNull); // 5位
        expect(Validators.otp('1234567'), isNotNull); // 7位
        expect(Validators.otp('abcdef'), isNotNull); // 非数字
        expect(Validators.otp(''), isNotNull);
        expect(Validators.otp(null), isNotNull);
      });
    });

    group('昵称校验', () {
      test('有效昵称', () {
        expect(Validators.nickname('小明'), isNull);
        expect(Validators.nickname('VerveForge'), isNull);
      });

      test('昵称太短', () {
        expect(Validators.nickname('a'), isNotNull);
      });

      test('昵称太长', () {
        expect(Validators.nickname('a' * 21), isNotNull);
      });

      test('空昵称', () {
        expect(Validators.nickname(''), isNotNull);
        expect(Validators.nickname('   '), isNotNull);
      });
    });

    group('训练时长校验', () {
      test('有效时长', () {
        expect(Validators.duration('30'), isNull);
        expect(Validators.duration('120'), isNull);
      });

      test('无效时长', () {
        expect(Validators.duration('0'), isNotNull);
        expect(Validators.duration('-10'), isNotNull);
        expect(Validators.duration('601'), isNotNull); // 超过10小时
        expect(Validators.duration('abc'), isNotNull);
      });
    });

    group('非空校验', () {
      test('有效值', () {
        expect(Validators.required('hello'), isNull);
      });

      test('空值', () {
        expect(Validators.required(''), isNotNull);
        expect(Validators.required(null), isNotNull);
        expect(Validators.required('   '), isNotNull);
      });
    });
  });

  // ===========================================
  // String 扩展测试
  // ===========================================
  group('StringExtensions', () {
    test('手机号脱敏', () {
      expect('13812345678'.maskedPhone, '138****5678');
    });

    test('有效手机号检测', () {
      expect('13812345678'.isValidPhone, isTrue);
      expect('51234567'.isValidPhone, isTrue); // 香港
      expect('12345'.isValidPhone, isFalse);
    });

    test('首字母大写', () {
      expect('hello'.capitalize, 'Hello');
      expect(''.capitalize, '');
    });

    test('文字截断', () {
      expect('Hello World'.truncate(5), 'Hello...');
      expect('Hi'.truncate(5), 'Hi');
    });
  });

  // ===========================================
  // DateTime 扩展测试
  // ===========================================
  group('DateTimeExtensions', () {
    test('日期格式化 ymd', () {
      final date = DateTime(2026, 3, 6);
      expect(date.ymd, '2026-03-06');
    });

    test('月日格式化', () {
      final date = DateTime(2026, 3, 6);
      expect(date.monthDay, '03月06日');
    });

    test('isToday 检测', () {
      expect(DateTime.now().isToday, isTrue);
      expect(DateTime(2020, 1, 1).isToday, isFalse);
    });

    test('isYesterday 检测', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(yesterday.isYesterday, isTrue);
      expect(DateTime.now().isYesterday, isFalse);
    });
  });

  // ===========================================
  // Debouncer 测试
  // ===========================================
  group('Debouncer', () {
    test('debouncer 可以创建和销毁', () {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 100));
      debouncer.dispose();
    });

    test('cancel 可以取消操作', () {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 100));
      var called = false;
      debouncer.run(() => called = true);
      debouncer.cancel();
      // 由于取消了，called 应该仍为 false（同步检查）
      expect(called, isFalse);
      debouncer.dispose();
    });
  });

  // ===========================================
  // Widget 测试
  // ===========================================
  group('Widget 冒烟测试', () {
    testWidgets('EmptyStateWidget 显示标题', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(title: '暂无数据'),
          ),
        ),
      );

      expect(find.text('暂无数据'), findsOneWidget);
    });

    testWidgets('EmptyStateWidget 显示副标题和按钮', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: '空空如也',
              subtitle: '快去训练吧',
              actionText: '开始训练',
              onAction: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('空空如也'), findsOneWidget);
      expect(find.text('快去训练吧'), findsOneWidget);
      expect(find.text('开始训练'), findsOneWidget);

      await tester.tap(find.text('开始训练'));
      expect(tapped, isTrue);
    });

    testWidgets('AvatarWidget 无图片时显示 fallback', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AvatarWidget(
              size: 48,
              fallbackText: '张',
            ),
          ),
        ),
      );

      expect(find.text('张'), findsOneWidget);
    });

    testWidgets('AvatarWidget 无 fallback 时显示图标', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AvatarWidget(size: 48),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('SportTypeIcon 显示正确图标', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SportTypeIcon(sportType: 'yoga', showLabel: true),
          ),
        ),
      );

      expect(find.byIcon(Icons.self_improvement), findsOneWidget);
      expect(find.text('瑜伽'), findsOneWidget);
    });

    testWidgets('SportTypeIcon 未知类型显示 other', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SportTypeIcon(sportType: 'unknown', showLabel: true),
          ),
        ),
      );

      expect(find.byIcon(Icons.sports), findsOneWidget);
      expect(find.text('其他'), findsOneWidget);
    });
  });
}
