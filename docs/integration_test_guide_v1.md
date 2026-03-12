# VerveForge 集成测试指南 v1.0

> **版本**: 1.0
> **日期**: 2026-03-07
> **覆盖范围**: W1-W8 全部模块
> **单元测试基线**: 219 tests passed

---

## 一、测试目标与范围

### 1.1 目标
- 验证所有核心模块的端到端用户流程
- 验证跨模块交互和数据一致性
- 验证 PIPL/PDPO 隐私合规三层弹窗机制
- 验证深色/浅色主题切换一致性
- 验证异常场景（无网络、权限拒绝、空数据）的容错能力

### 1.2 覆盖模块

| 模块 | Week | 核心功能 |
|------|------|----------|
| 认证 | W1 | 手机号 OTP + Apple 登录 + 引导流 |
| 训练日志 | W2-W5 | CRUD + 照片 + Health 同步 + 运动专项成绩 |
| 训练馆 | W4+W7.5 | 地图 + 列表 + 详情 + 评价 + 收藏 + 认领 |
| 挑战赛 | W6 | 创建 + 参加 + 排行 + 实时打卡 |
| 动态 Feed | W8 | 3 Tab + 发布 + 点赞 + 评论 |
| 隐私合规 | W8 | 冷启动弹窗 + 登录弹窗 + 数据采集授权 |
| 主题/i18n | 全局 | 深色/浅色 + 中/英/繁体 |

---

## 二、测试环境准备

### 2.1 设备
- **iOS 模拟器**: iPhone 15 Pro (iOS 17+)
- **iOS 真机**: 至少 1 台 iPhone（TestFlight 分发）
- **Flutter**: 3.24+，Dart 3.5+

### 2.2 后端
- **Supabase 测试项目**: 独立于生产环境
- 执行全部迁移脚本 `00001` ~ `00017`
- 确认 RLS 策略已启用

### 2.3 账号准备

| 账号 | 用途 | 说明 |
|------|------|------|
| 账号 A | 主测试账号 | 完成引导流，城市=shanghai |
| 账号 B | 辅助账号 | 用于关注/点赞/评论交互测试 |
| 账号 C | 空账号 | 用于首次安装冷启动测试 |

### 2.4 测试数据
```sql
-- 插入测试训练馆（至少 3 个 approved）
INSERT INTO gyms (name, address, city, country, location, latitude, longitude, sport_types, status, submitted_by)
VALUES
  ('HYROX 训练中心', '上海市静安区南京西路100号', 'shanghai', 'CN',
   ST_SetSRID(ST_MakePoint(121.4737, 31.2304), 4326), 31.2304, 121.4737,
   '{hyrox,crossfit}', 'approved', '<账号A的user_id>'),
  ('瑜伽之家', '北京市朝阳区建国路88号', 'beijing', 'CN',
   ST_SetSRID(ST_MakePoint(116.4074, 39.9042), 4326), 39.9042, 116.4074,
   '{yoga,pilates}', 'approved', '<账号A的user_id>'),
  ('CrossFit 深圳', '深圳市南山区科技园路1号', 'shenzhen', 'CN',
   ST_SetSRID(ST_MakePoint(113.9213, 22.5431), 4326), 22.5431, 113.9213,
   '{crossfit,strength}', 'approved', '<账号A的user_id>');

-- 插入测试动态
INSERT INTO posts (id, user_id, content, city)
VALUES
  (gen_random_uuid(), '<账号A的user_id>', '测试动态1', 'shanghai'),
  (gen_random_uuid(), '<账号B的user_id>', '测试动态2', 'beijing');

-- 账号 A 关注 账号 B
INSERT INTO user_follows (follower_id, following_id)
VALUES ('<账号A的user_id>', '<账号B的user_id>');
```

### 2.5 启动命令
```bash
# 清除缓存后启动（模拟首次安装）
flutter clean && flutter pub get && flutter run

# 正常启动
flutter run

# 静态分析 + 测试
flutter analyze
flutter test
```

---

## 三、手动集成测试用例清单

### 模块 A：启动与隐私合规

| # | 用例名称 | 前置条件 | 操作步骤 | 预期结果 | 优先级 |
|---|----------|----------|----------|----------|--------|
| A1 | 首次安装冷启动弹窗 | 清除 App 数据（SharedPreferences） | 1. 启动 App | 1. 显示隐私弹窗「欢迎使用 VerveForge」<br>2. 弹窗不可关闭（点击外部无反应）<br>3. 显示 4 项数据说明<br>4. 底部「不同意」/「同意」按钮 | 高 |
| A2 | 拒绝隐私弹窗 | A1 弹窗已显示 | 1. 点击「不同意」 | 1. 弹窗关闭<br>2. App 显示空白，无法使用<br>3. 再次启动仍弹出弹窗 | 高 |
| A3 | 同意隐私弹窗 | A1 弹窗已显示 | 1. 点击「我已阅读并同意」 | 1. 弹窗关闭<br>2. 进入登录页<br>3. 后续启动不再弹出 | 高 |
| A4 | 弹窗内跳转隐私政策全文 | A1 弹窗已显示 | 1. 点击「查看完整隐私政策」链接 | 1. 跳转到隐私政策全文页<br>2. 显示完整 6 节内容<br>3. 返回后弹窗仍在 | 高 |
| A5 | 设置页查阅隐私政策 | 已登录 | 1. Tab 5「我的」→ 设置<br>2. 隐私设置 → 隐私政策 | 1. 显示完整隐私政策全文页 | 中 |

### 模块 B：首页 Feed

| # | 用例名称 | 前置条件 | 操作步骤 | 预期结果 | 优先级 |
|---|----------|----------|----------|----------|--------|
| B1 | Feed 三 Tab 切换 | 已登录，有测试动态 | 1. 进入 Feed 页<br>2. 分别点击「关注」「附近」「推荐」 | 1. 默认选中「附近」<br>2. Tab 切换流畅，指示器跟随<br>3. 各 Tab 内容独立加载 | 高 |
| B2 | 关注 Tab 空状态 | 账号未关注任何人 | 1. 切换到「关注」Tab | 1. 显示空状态图标<br>2. 提示「暂无关注动态」 | 中 |
| B3 | 关注 Tab 有数据 | 账号 A 已关注账号 B，B 有动态 | 1. 切换到「关注」Tab | 1. 显示账号 B 的动态<br>2. 卡片含头像/昵称/时间/正文 | 高 |
| B4 | 下拉刷新 | Feed 有数据 | 1. 在列表顶部下拉 | 1. 显示刷新指示器<br>2. 列表重新加载 | 中 |
| B5 | 上拉加载更多 | 动态数 > 20 条 | 1. 滑到列表底部 | 1. 自动加载下一页<br>2. 新数据追加到列表末尾 | 中 |
| B6 | 发布纯文字动态 | 已登录 | 1. 点击底部「+」→「发布动态」<br>2. 输入文字内容<br>3. 点击「发布」 | 1. 发布成功 SnackBar<br>2. 自动返回 Feed<br>3. 新动态出现在列表顶部 | 高 |
| B7 | 发布带照片动态 | 已登录 | 1.「+」→「发布动态」<br>2. 输入文字 + 添加 2 张照片<br>3. 发布 | 1. 照片上传成功<br>2. 卡片显示照片网格 | 高 |
| B8 | 发布带城市动态 | 已登录 | 1. 发布页选择城市 ChoiceChip<br>2. 发布 | 1. 卡片右上角显示城市标签 | 中 |
| B9 | 点赞/取消点赞 | Feed 有动态 | 1. 点击心形图标<br>2. 再次点击 | 1. 变红 + 计数 +1<br>2. 变回空心 + 计数 -1 | 高 |
| B10 | 空内容无法发布 | 发布页 | 1. 不输入任何内容 | 1. 发布按钮保持禁用 | 中 |

### 模块 C：训练日志

| # | 用例名称 | 前置条件 | 操作步骤 | 预期结果 | 优先级 |
|---|----------|----------|----------|----------|--------|
| C1 | 创建基础训练 | 已登录 | 1.「+」→「记录训练」<br>2. 选择运动类型、时长、强度<br>3. 保存 | 1. 首次弹出数据采集授权弹窗<br>2. 同意后保存成功<br>3. 训练列表出现新记录 | 高 |
| C2 | HYROX 专项成绩 | 已登录 | 1. 创建训练 → 运动类型=HYROX<br>2. 展开「运动专项成绩」<br>3. 填入 8 站计时 + 总成绩<br>4. 保存 | 1. 详情页显示 HYROX 成绩卡片<br>2. 列表卡片显示总成绩摘要 | 高 |
| C3 | 训练照片上传 | 已登录 | 1. 创建训练<br>2. 添加 3 张照片<br>3. 删除 1 张<br>4. 保存 | 1. 照片网格正确显示 2 张<br>2. 详情页可查看照片 | 中 |
| C4 | 训练日历视图 | 有多条训练记录 | 1. 进入训练日历页<br>2. 点击有标记的日期 | 1. 日历正确标记训练日<br>2. 点击跳转到当日训练详情 | 中 |
| C5 | 删除训练记录 | 有训练记录 | 1. 进入训练详情<br>2. 点击删除<br>3. 确认 | 1. 弹出确认对话框<br>2. 确认后记录消失（软删除） | 中 |

### 模块 D：挑战赛

| # | 用例名称 | 前置条件 | 操作步骤 | 预期结果 | 优先级 |
|---|----------|----------|----------|----------|--------|
| D1 | 创建挑战赛 | 已登录 | 1. Tab 4「挑战」→ 创建<br>2. 填写名称/运动类型/目标/日期<br>3. 提交 | 1. 创建成功 SnackBar<br>2. 挑战列表出现新项 | 高 |
| D2 | 参加挑战赛 | 有进行中的挑战 | 1. 点击挑战卡片进入详情<br>2. 点击「参加」 | 1. 加入成功<br>2. 排行榜出现自己 | 高 |
| D3 | 打卡 | 已参加挑战 | 1. 在排行页点击「打卡」 | 1. 打卡成功<br>2. 打卡次数 +1<br>3. 排行实时更新 | 高 |
| D4 | 退出挑战 | 已参加挑战 | 1. 点击「退出」<br>2. 确认 | 1. 弹出确认对话框<br>2. 退出成功<br>3. 排行榜移除自己 | 中 |
| D5 | 城市筛选 | 有不同城市的挑战 | 1. 选择城市筛选 | 1. 列表仅显示对应城市挑战 | 中 |

### 模块 E：训练馆

| # | 用例名称 | 前置条件 | 操作步骤 | 预期结果 | 优先级 |
|---|----------|----------|----------|----------|--------|
| E1 | 训练馆地图浏览 | 有 approved 训练馆 | 1. 进入训练馆地图页 | 1. 高德地图加载<br>2. 标注点显示 | 高 |
| E2 | 训练馆列表搜索 | 有测试数据 | 1. 进入列表页<br>2. 搜索「HYROX」 | 1. 列表筛选显示匹配结果 | 中 |
| E3 | 收藏训练馆 | 已登录 | 1. 训练馆卡片点击心形<br>2. 进入详情页点击 AppBar 心形 | 1. 卡片心形变红<br>2. 详情页心形同步变红 | 高 |
| E4 | 收藏列表页 | 已收藏 2+ 训练馆 | 1. Tab 5「我的」→「我的收藏训练馆」 | 1. 显示收藏列表<br>2. 点击心形取消收藏，该项消失 | 高 |
| E5 | 馆主认领 | 有未认证训练馆 | 1. 进入未认证训练馆详情<br>2. 点击「认领此场馆」<br>3. 确认提交 | 1. 显示确认对话框<br>2. 提交成功<br>3. 认领按钮替换为「审核中」状态卡 | 高 |
| E6 | 已认证训练馆显示 | 有 is_verified=TRUE 的馆 | 1. 进入详情页 | 1. 标题旁显示蓝V<br>2. 不显示认领按钮 | 中 |
| E7 | 提交新训练馆 | 已登录 | 1. 训练馆列表 → 提交<br>2. 填写信息并提交 | 1. 提交成功提示<br>2. 状态为「待审核」 | 中 |

### 模块 F：个人中心与设置

| # | 用例名称 | 前置条件 | 操作步骤 | 预期结果 | 优先级 |
|---|----------|----------|----------|----------|--------|
| F1 | 数据导出 | 已登录 | 1. 设置 → 隐私设置 → 导出数据 | 1. 生成 JSON 文件<br>2. 弹出系统分享面板 | 高 |
| F2 | 可见性开关 | 已登录 | 1. 隐私设置 → 关闭「出现在发现列表」 | 1. 开关切换成功<br>2. 其他用户发现页不再看到本人 | 中 |
| F3 | 注销账号 | 已登录 | 1. 隐私设置 → 注销账号<br>2. 第一次确认<br>3. 第二次确认 | 1. 弹出两次确认对话框<br>2. 注销请求提交成功<br>3. 返回登录页 | 高 |

### 模块 G：主题与 i18n

| # | 用例名称 | 前置条件 | 操作步骤 | 预期结果 | 优先级 |
|---|----------|----------|----------|----------|--------|
| G1 | 深色 → 浅色切换 | 当前深色模式 | 1. 设置 → 主题 → 浅色 | 1. 全局切换为浅色<br>2. 导航栏/卡片/输入框/弹窗/TabBar 背景色一致 | 高 |
| G2 | 浅色 → 深色切换 | 当前浅色模式 | 1. 设置 → 主题 → 深色 | 1. 全局切换为深色<br>2. 所有组件色调一致 | 高 |
| G3 | 语言切换 | 当前中文 | 1. 设置 → 语言 → English | 1. 所有 UI 文本切换为英文<br>2. Tab 标签/按钮/提示均为英文 | 中 |

### 模块 H：跨模块交互

| # | 用例名称 | 前置条件 | 操作步骤 | 预期结果 | 优先级 |
|---|----------|----------|----------|----------|--------|
| H1 | 底部「+」双入口 | 已登录 | 1. 点击底部「+」 | 1. 弹出底部弹窗<br>2. 显示「记录训练」+「发布动态」两项<br>3. 分别可正常跳转 | 高 |
| H2 | 收藏入口联动 | 已收藏训练馆 | 1.「我的」→「我的收藏训练馆」<br>2. 点击卡片 | 1. 进入训练馆详情页<br>2. AppBar 心形为红色 | 中 |
| H3 | 挑战列表路由 | 有挑战数据 | 1. 挑战列表 → 点击卡片 | 1. 进入排行榜页<br>2. 返回后列表状态保持 | 中 |

---

## 四、自动化测试补充建议

### 4.1 现有单元测试可扩展方向

| 现有测试文件 | 现有覆盖 | 建议扩展为集成测试 |
|-------------|----------|-------------------|
| `w5_test.dart` (47) | WorkoutModel / Metrics | Widget 测试：WorkoutCreatePage 表单提交流程 |
| `w6_test.dart` (37) | Challenge 模型 | Widget 测试：ChallengesPage 列表渲染 + 筛选 |
| `w75_test.dart` (15) | Favorite / Claim 模型 | Widget 测试：GymCard 收藏按钮交互 |
| `w8_test.dart` (28) | Post / Comment 模型 | Widget 测试：FeedPage Tab 切换 + PostCard 渲染 |

### 4.2 integration_test 框架示例

在项目根目录创建 `integration_test/` 目录：

```bash
mkdir -p integration_test
```

#### 示例 1：冷启动隐私弹窗流程

```dart
// integration_test/privacy_consent_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verveforge/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('首次启动显示隐私弹窗，同意后进入登录页', (tester) async {
    // 清除隐私同意状态
    SharedPreferences.setMockInitialValues({'privacy_agreed': false});

    app.main();
    await tester.pumpAndSettle();

    // 验证弹窗显示
    expect(find.text('欢迎使用 VerveForge'), findsOneWidget);
    expect(find.text('查看完整隐私政策'), findsOneWidget);

    // 点击同意
    await tester.tap(find.text('我已阅读并同意'));
    await tester.pumpAndSettle();

    // 验证进入登录页
    expect(find.text('登录 VerveForge'), findsOneWidget);
  });
}
```

#### 示例 2：Feed 三 Tab 切换

```dart
// integration_test/feed_tab_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:verveforge/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Feed 页三 Tab 切换正常', (tester) async {
    // 假设已登录状态
    app.main();
    await tester.pumpAndSettle();

    // 默认选中「附近」Tab
    final nearbyTab = find.text('附近');
    expect(nearbyTab, findsOneWidget);

    // 切换到「关注」
    await tester.tap(find.text('关注'));
    await tester.pumpAndSettle();

    // 切换到「推荐」
    await tester.tap(find.text('推荐'));
    await tester.pumpAndSettle();

    // 切回「附近」
    await tester.tap(nearbyTab);
    await tester.pumpAndSettle();
  });
}
```

#### 示例 3：发布动态端到端

```dart
// integration_test/post_create_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:verveforge/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('发布纯文字动态并返回 Feed', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // 点击底部「+」按钮（index=2）
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // 选择「发布动态」
    await tester.tap(find.text('发布动态'));
    await tester.pumpAndSettle();

    // 输入内容
    await tester.enterText(
      find.byType(TextField),
      '集成测试动态 - ${DateTime.now()}',
    );
    await tester.pumpAndSettle();

    // 点击发布
    await tester.tap(find.text('发布'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // 验证返回 Feed 页
    expect(find.text('动态'), findsWidgets);
  });
}
```

#### 示例 4：训练馆收藏交互

```dart
// integration_test/gym_favorite_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:verveforge/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('收藏训练馆后在收藏列表可见', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // 导航到训练馆列表
    // ... 找到心形图标并点击
    final favoriteIcon = find.byIcon(Icons.favorite_border).first;
    await tester.tap(favoriteIcon);
    await tester.pumpAndSettle();

    // 验证变为已收藏
    expect(find.byIcon(Icons.favorite), findsWidgets);

    // 导航到收藏列表验证
    // ... 省略导航步骤
  });
}
```

#### 示例 5：主题切换

```dart
// integration_test/theme_switch_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:verveforge/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('深色浅色主题切换后 Scaffold 背景色正确', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // 导航到设置页 → 主题
    // ... 省略导航步骤

    // 切换到浅色
    await tester.tap(find.text('浅色'));
    await tester.pumpAndSettle();

    // 验证 Scaffold 背景色为浅色
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, isNot(equals(const Color(0xFF0D0D0D))));

    // 切回深色
    await tester.tap(find.text('深色'));
    await tester.pumpAndSettle();
  });
}
```

### 4.3 运行集成测试
```bash
# 在 iOS 模拟器上运行
flutter test integration_test/privacy_consent_test.dart
flutter test integration_test/feed_tab_test.dart

# 运行全部集成测试
flutter test integration_test/
```

---

## 五、异常与边界测试

| # | 场景 | 前置条件 | 操作步骤 | 预期结果 | 优先级 |
|---|------|----------|----------|----------|--------|
| X1 | 无网络 — Feed 加载 | 关闭网络 | 1. 打开 Feed 页 | 1. 显示错误状态<br>2. 显示「重试」按钮<br>3. 恢复网络后点击重试可正常加载 | 高 |
| X2 | 无网络 — 发布动态 | 关闭网络 | 1. 填写并提交动态 | 1. 显示错误 SnackBar<br>2. 内容不丢失，可重试 | 高 |
| X3 | 无网络 — 点赞 | 关闭网络 | 1. 点击点赞 | 1. 错误提示<br>2. 状态不变 | 中 |
| X4 | 相册权限拒绝 | 系统权限=拒绝 | 1. 发布动态 → 添加照片 | 1. 系统提示无权限<br>2. App 不崩溃 | 高 |
| X5 | Health 权限拒绝 | HealthKit 权限=拒绝 | 1. 训练页 → Apple Health 同步 | 1. 提示「请在设置中允许…」<br>2. 同步按钮可用但不执行 | 中 |
| X6 | 数据为空 — 训练列表 | 无任何训练记录 | 1. 进入训练历史 | 1. 显示空状态<br>2. 提示「去记录第一次训练吧」 | 中 |
| X7 | 数据为空 — 挑战列表 | 无挑战赛 | 1. 进入挑战 Tab | 1. 显示空状态<br>2. 提示「创建或参加运动挑战」 | 中 |
| X8 | 数据为空 — 收藏列表 | 未收藏训练馆 | 1. 进入收藏页 | 1. 显示空状态<br>2. 按钮可跳转训练馆列表 | 低 |
| X9 | 重复操作 — 双击点赞 | Feed 有动态 | 1. 快速双击点赞 | 1. 不重复请求<br>2. 状态正确（赞/未赞） | 中 |
| X10 | 重复操作 — 双击发布 | 发布页已填内容 | 1. 快速双击「发布」 | 1. 按钮进入加载态后禁用<br>2. 仅发布 1 条动态 | 高 |
| X11 | 超长文本 | 发布页 | 1. 输入 500 字文本 | 1. 字数计数器正确<br>2. 超过 500 字无法继续输入 | 低 |
| X12 | 9 张照片上限 | 发布页/训练页 | 1. 添加 9 张照片<br>2. 尝试继续添加 | 1. 达到上限后添加按钮消失<br>2. 已选照片正常显示 | 低 |

---

## 六、测试通过标准

### 6.1 通过条件
- **自动化测试**: `flutter test` → 219 tests passed, 0 failures
- **静态分析**: `flutter analyze` → No issues found
- **手动测试**: 所有「高」优先级用例 100% 通过，「中」优先级 ≥ 95% 通过
- **异常测试**: 所有「高」优先级异常场景 100% 通过
- **无 P0/P1 级 Bug 遗留**

### 6.2 Bug 严重等级

| 等级 | 定义 | 示例 |
|------|------|------|
| P0 — 致命 | App 崩溃、数据丢失、安全漏洞 | 发布动态导致闪退；用户数据泄露 |
| P1 — 严重 | 核心功能不可用 | 无法登录；无法发布动态；点赞无效 |
| P2 — 一般 | 功能异常但有绕过方案 | 照片上传偶尔失败（重试可解决） |
| P3 — 轻微 | UI 显示问题、文案错误 | 浅色模式下某处字色偏暗 |

### 6.3 Bug 报告模板

```markdown
## Bug 报告

**标题**: [模块] 简短描述

**严重等级**: P0 / P1 / P2 / P3

**环境**:
- 设备: iPhone 15 Pro / 模拟器
- iOS 版本: 17.x
- App 版本: 1.0.0
- 主题: 深色 / 浅色
- 语言: 中文 / English

**复现步骤**:
1.
2.
3.

**预期结果**:

**实际结果**:

**截图/录屏**: （附件）

**日志**: （如有 Flutter 错误日志）

**复现频率**: 每次 / 偶发（约 x/10 次）
```

---

## 七、执行记录表模板

复制以下表格用于实际测试执行：

| 用例 # | 用例名称 | 测试人 | 测试日期 | 设备 | 结果 | Bug # | 备注 |
|--------|----------|--------|----------|------|------|-------|------|
| A1 | 首次安装冷启动弹窗 | | | | ⬜ Pass / ⬜ Fail | | |
| A2 | 拒绝隐私弹窗 | | | | ⬜ Pass / ⬜ Fail | | |
| A3 | 同意隐私弹窗 | | | | ⬜ Pass / ⬜ Fail | | |
| A4 | 弹窗内跳转隐私政策全文 | | | | ⬜ Pass / ⬜ Fail | | |
| A5 | 设置页查阅隐私政策 | | | | ⬜ Pass / ⬜ Fail | | |
| B1 | Feed 三 Tab 切换 | | | | ⬜ Pass / ⬜ Fail | | |
| B2 | 关注 Tab 空状态 | | | | ⬜ Pass / ⬜ Fail | | |
| B3 | 关注 Tab 有数据 | | | | ⬜ Pass / ⬜ Fail | | |
| B4 | 下拉刷新 | | | | ⬜ Pass / ⬜ Fail | | |
| B5 | 上拉加载更多 | | | | ⬜ Pass / ⬜ Fail | | |
| B6 | 发布纯文字动态 | | | | ⬜ Pass / ⬜ Fail | | |
| B7 | 发布带照片动态 | | | | ⬜ Pass / ⬜ Fail | | |
| B8 | 发布带城市动态 | | | | ⬜ Pass / ⬜ Fail | | |
| B9 | 点赞/取消点赞 | | | | ⬜ Pass / ⬜ Fail | | |
| B10 | 空内容无法发布 | | | | ⬜ Pass / ⬜ Fail | | |
| C1 | 创建基础训练 | | | | ⬜ Pass / ⬜ Fail | | |
| C2 | HYROX 专项成绩 | | | | ⬜ Pass / ⬜ Fail | | |
| C3 | 训练照片上传 | | | | ⬜ Pass / ⬜ Fail | | |
| C4 | 训练日历视图 | | | | ⬜ Pass / ⬜ Fail | | |
| C5 | 删除训练记录 | | | | ⬜ Pass / ⬜ Fail | | |
| D1 | 创建挑战赛 | | | | ⬜ Pass / ⬜ Fail | | |
| D2 | 参加挑战赛 | | | | ⬜ Pass / ⬜ Fail | | |
| D3 | 打卡 | | | | ⬜ Pass / ⬜ Fail | | |
| D4 | 退出挑战 | | | | ⬜ Pass / ⬜ Fail | | |
| D5 | 城市筛选 | | | | ⬜ Pass / ⬜ Fail | | |
| E1 | 训练馆地图浏览 | | | | ⬜ Pass / ⬜ Fail | | |
| E2 | 训练馆列表搜索 | | | | ⬜ Pass / ⬜ Fail | | |
| E3 | 收藏训练馆 | | | | ⬜ Pass / ⬜ Fail | | |
| E4 | 收藏列表页 | | | | ⬜ Pass / ⬜ Fail | | |
| E5 | 馆主认领 | | | | ⬜ Pass / ⬜ Fail | | |
| E6 | 已认证训练馆显示 | | | | ⬜ Pass / ⬜ Fail | | |
| E7 | 提交新训练馆 | | | | ⬜ Pass / ⬜ Fail | | |
| F1 | 数据导出 | | | | ⬜ Pass / ⬜ Fail | | |
| F2 | 可见性开关 | | | | ⬜ Pass / ⬜ Fail | | |
| F3 | 注销账号 | | | | ⬜ Pass / ⬜ Fail | | |
| G1 | 深色 → 浅色切换 | | | | ⬜ Pass / ⬜ Fail | | |
| G2 | 浅色 → 深色切换 | | | | ⬜ Pass / ⬜ Fail | | |
| G3 | 语言切换 | | | | ⬜ Pass / ⬜ Fail | | |
| H1 | 底部「+」双入口 | | | | ⬜ Pass / ⬜ Fail | | |
| H2 | 收藏入口联动 | | | | ⬜ Pass / ⬜ Fail | | |
| H3 | 挑战列表路由 | | | | ⬜ Pass / ⬜ Fail | | |
| X1 | 无网络 — Feed 加载 | | | | ⬜ Pass / ⬜ Fail | | |
| X2 | 无网络 — 发布动态 | | | | ⬜ Pass / ⬜ Fail | | |
| X4 | 相册权限拒绝 | | | | ⬜ Pass / ⬜ Fail | | |
| X10 | 双击发布防重 | | | | ⬜ Pass / ⬜ Fail | | |

**测试汇总**:
- 总用例数: ___
- Pass: ___
- Fail: ___
- 通过率: ___%
- 遗留 Bug 数: ___ (P0:___ P1:___ P2:___ P3:___)
- 测试结论: ⬜ 通过 / ⬜ 有条件通过 / ⬜ 不通过
- 签字: ___________  日期: ___________
