# Week 6 测试说明 — PK 挑战赛系统

## 一、前置准备

### 1.1 环境要求
- Flutter 3.24+
- iOS 模拟器 (iPhone 15 Pro 推荐)
- Supabase 项目已部署 00016 迁移
- 3 个测试账号（不同手机号/邮箱）

### 1.2 执行迁移
```bash
# 确认 00016 迁移已应用
supabase db push
# 或在 Supabase Dashboard → SQL Editor 手动执行：
# supabase/migrations/00016_w6_challenge_enhance.sql
```

### 1.3 验证视图
在 Supabase Dashboard → SQL Editor 执行：
```sql
-- 确认 challenge_summary 视图存在
SELECT * FROM challenge_summary LIMIT 1;

-- 确认 challenge_leaderboard 视图存在
SELECT * FROM challenge_leaderboard LIMIT 1;
```

### 1.4 启动应用
```bash
flutter run
```

---

## 二、功能测试流程

### 测试 1: 创建挑战赛（账号 A）

1. 登录 **账号 A**
2. 点击底部 Tab 4「挑战」进入挑战列表页
3. 点击右上角 **+** 按钮，进入创建页
4. 填写表单：
   - 标题：`HYROX 30天打卡挑战`
   - 运动类型：选择 `HYROX`
   - 目标类型：选择 `总次数`
   - 目标值：`30`
   - 开始日期：今天
   - 结束日期：30 天后
   - 城市：`上海`
   - 最大参与人数：`50`
   - 描述：`每天一次 HYROX 训练`
5. 点击「创建挑战」

**预期结果：**
- 提示「创建成功」
- 自动返回列表页
- 列表中出现新创建的挑战卡片
- 卡片显示：HYROX 图标、标题、「总次数 30」、「1 人参与」、「进行中」标签
- 卡片底部显示账号 A 昵称 + 「已参加」标签

### 测试 2: 查看挑战详情 & 排行榜（账号 A）

1. 在列表页点击刚创建的挑战卡片
2. 进入排行榜页面

**预期结果：**
- AppBar 标题「排行榜」，右侧绿色圆点 + 「实时」标记
- 头部卡片显示：HYROX 图标、标题、进度条、「1 人参与」、剩余天数
- 头部卡片无「退出」按钮（创建者不能退出）
- 排行榜显示 1 条记录（账号 A），金牌图标（#1），进度 0/30

### 测试 3: 筛选功能（账号 A）

1. 返回挑战列表页
2. 在城市筛选栏点击「上海」

**预期结果：**
- 列表仅显示城市为「上海」的挑战

3. 在运动类型筛选栏点击「HYROX」

**预期结果：**
- 列表仅显示运动类型为 HYROX 且城市为上海的挑战

4. 点击城市「全部」+ 运动类型「全部」恢复

**预期结果：**
- 列表显示所有活跃挑战

### 测试 4: 加入挑战（账号 B）

1. 退出账号 A，登录 **账号 B**
2. 进入 Tab 4「挑战」列表
3. 找到账号 A 创建的挑战，点击进入排行榜
4. 点击「加入挑战」按钮

**预期结果：**
- 提示「加入成功」
- 头部卡片参与人数变为 2
- 排行榜出现 2 条记录
- 「加入挑战」按钮变为「退出挑战」按钮
- 返回列表页，卡片显示「2 人参与」+「已参加」标签

### 测试 5: 第三人加入（账号 C）

1. 退出账号 B，登录 **账号 C**
2. 进入挑战排行榜，点击「加入挑战」

**预期结果：**
- 参与人数变为 3
- 排行榜显示 3 条记录，所有人进度均为 0

### 测试 6: 打卡 & 实时排行榜更新

> 本测试需要配合训练日志功能

1. 登录 **账号 B**
2. 进入 Tab 3，记录一条 HYROX 训练日志并保存
3. 切换到 Tab 4，进入该挑战的排行榜

**预期结果（如果已实现训练日志自动关联打卡）：**
- 账号 B 的进度值 > 0
- 排名按进度自动排序
- 账号 B 的行高亮显示（蓝色边框+浅蓝背景）

**手动打卡验证（SQL）：**
如果训练日志尚未自动关联挑战打卡，可通过 SQL 模拟：
```sql
-- 1. 查找 participant_id
SELECT id, user_id FROM challenge_participants
WHERE challenge_id = '<挑战ID>';

-- 2. 为账号 B 插入打卡记录
INSERT INTO challenge_check_ins (id, challenge_id, participant_id, workout_log_id, value)
VALUES (
  gen_random_uuid(),
  '<挑战ID>',
  '<账号B的participant_id>',
  '<任意workout_log_id>',
  1
);

-- 3. 为账号 C 插入多条打卡
INSERT INTO challenge_check_ins (id, challenge_id, participant_id, workout_log_id, value)
VALUES
  (gen_random_uuid(), '<挑战ID>', '<账号C的participant_id>', gen_random_uuid(), 1),
  (gen_random_uuid(), '<挑战ID>', '<账号C的participant_id>', gen_random_uuid(), 1),
  (gen_random_uuid(), '<挑战ID>', '<账号C的participant_id>', gen_random_uuid(), 1);
```

**预期结果：**
- 打开排行榜页面后，或下拉刷新
- 账号 C (3次) 排名 #1 金牌，账号 B (1次) 排名 #2 银牌，账号 A (0次) 排名 #3 铜牌
- 进度条按比例显示

### 测试 7: 实时推送验证

> 验证 Supabase Realtime 订阅

1. 在 **账号 B 的模拟器** 上打开排行榜页面，保持停留
2. 在 Supabase Dashboard SQL Editor 插入一条打卡记录（模拟账号 A 打卡）：
```sql
INSERT INTO challenge_check_ins (id, challenge_id, participant_id, workout_log_id, value)
VALUES (
  gen_random_uuid(),
  '<挑战ID>',
  '<账号A的participant_id>',
  gen_random_uuid(),
  1
);
```

**预期结果：**
- 账号 B 的排行榜页面 **无需刷新**，自动更新排名和进度
- 如果 Realtime 未配置，下拉刷新也应正确更新

### 测试 8: 退出挑战（账号 B）

1. 登录 **账号 B**
2. 进入挑战排行榜
3. 点击「退出挑战」按钮

**预期结果：**
- 弹出确认对话框「确定要退出此挑战？」
- 点击「退出挑战」确认
- 提示「退出成功」
- 自动返回列表页
- 卡片显示参与人数减少
- 再次进入排行榜，账号 B 不在列表中

### 测试 9: 满员测试

1. 创建一个 `maxParticipants = 2` 的挑战（账号 A）
2. 账号 B 加入（此时 2/2 满员）
3. 账号 C 查看该挑战

**预期结果：**
- 列表卡片显示「已满」黄色标签
- 排行榜页面「加入挑战」按钮变为禁用状态，显示「已满员」

### 测试 10: 空状态

1. 登录新账号或清空挑战数据
2. 进入 Tab 4

**预期结果：**
- 显示空状态插画 + 「暂无挑战」 + 「发起第一个挑战」
- 点击按钮跳转到创建页

---

## 三、数据库检查

在 Supabase Dashboard → Table Editor 或 SQL Editor 验证：

### 3.1 challenges 表
```sql
SELECT id, title, sport_type, goal_type, goal_value,
       participant_count, max_participants, city, status,
       metrics_rules
FROM challenges
ORDER BY created_at DESC
LIMIT 5;
```
- `participant_count` 应与实际参与人数一致（由触发器维护）
- `metrics_rules` 默认为 `{}`
- `status` 为 `active`

### 3.2 challenge_participants 表
```sql
SELECT cp.id, cp.challenge_id, cp.user_id,
       cp.progress_value, cp.check_in_count,
       p.nickname
FROM challenge_participants cp
LEFT JOIN profiles p ON p.id = cp.user_id
WHERE cp.challenge_id = '<挑战ID>'
ORDER BY cp.progress_value DESC;
```
- 创建者应自动在参与者列表中
- `progress_value` 和 `check_in_count` 由触发器自动累加

### 3.3 challenge_check_ins 表
```sql
SELECT ci.id, ci.participant_id, ci.workout_log_id, ci.value, ci.created_at
FROM challenge_check_ins ci
WHERE ci.challenge_id = '<挑战ID>'
ORDER BY ci.created_at DESC;
```
- 每条打卡记录关联一个 `workout_log_id`

### 3.4 视图验证
```sql
-- challenge_summary 视图：包含 creator_nickname, is_joined
SELECT id, title, participant_count, creator_nickname, is_joined
FROM challenge_summary
WHERE id = '<挑战ID>';

-- challenge_leaderboard 视图：包含 rank, progress_pct, nickname
SELECT participant_id, nickname, progress_value, check_in_count,
       rank, progress_pct
FROM challenge_leaderboard
WHERE challenge_id = '<挑战ID>'
ORDER BY rank;
```

### 3.5 RLS 策略验证
```sql
-- 确认 DELETE 策略存在
SELECT policyname, cmd, qual
FROM pg_policies
WHERE tablename = 'challenge_participants' AND cmd = 'DELETE';
```
- 应存在 `challenge_parts_delete` 策略
- `qual` 应为 `(auth.uid() = user_id)`

---

## 四、Realtime 配置检查

如果实时更新不工作，检查以下配置：

### 4.1 Supabase Dashboard → Database → Replication
- 确认 `challenge_participants` 表已启用 Realtime
- 确认 `challenge_check_ins` 表已启用 Realtime

### 4.2 启用方法
```sql
-- 在 Supabase SQL Editor 执行
ALTER PUBLICATION supabase_realtime ADD TABLE challenge_participants;
ALTER PUBLICATION supabase_realtime ADD TABLE challenge_check_ins;
```

### 4.3 验证
```sql
SELECT * FROM pg_publication_tables
WHERE pubname = 'supabase_realtime'
  AND tablename IN ('challenge_participants', 'challenge_check_ins');
```

---

## 五、自动化测试

```bash
# 静态分析
flutter analyze
# 预期: No issues found!

# 单元测试
flutter test
# 预期: 176 tests passed (W1-W4: 92 + W5: 47 + W6: 37)

# 仅运行 W6 测试
flutter test test/w6_test.dart
# 预期: 37 tests passed
```

---

## 六、W6 文件清单

| 操作 | 路径 | 说明 |
|------|------|------|
| 新建 | `supabase/migrations/00016_w6_challenge_enhance.sql` | metrics_rules 列 + 视图 + RLS |
| 新建 | `lib/features/challenge/domain/challenge_model.dart` | 挑战赛数据模型 |
| 新建 | `lib/features/challenge/domain/challenge_participant_model.dart` | 参与者/排行榜模型 |
| 新建 | `lib/features/challenge/domain/challenge_check_in_model.dart` | 打卡记录模型 |
| 新建 | `lib/features/challenge/data/challenge_repository.dart` | CRUD + Realtime 订阅 |
| 新建 | `lib/features/challenge/providers/challenge_provider.dart` | Riverpod 状态管理 |
| 替换 | `lib/features/challenge/presentation/challenges_page.dart` | 挑战列表 + 筛选 |
| 新建 | `lib/features/challenge/presentation/challenge_create_page.dart` | 创建表单 |
| 新建 | `lib/features/challenge/presentation/challenge_rank_page.dart` | 实时排行榜 |
| 修改 | `lib/app/router.dart` | 新增路由 |
| 修改 | `lib/l10n/app_en.arb` | +30 i18n keys |
| 修改 | `lib/l10n/app_zh.arb` | +30 i18n keys |
| 修改 | `lib/l10n/app_zh_CN.arb` | +30 i18n keys |
| 修改 | `lib/l10n/app_zh_TW.arb` | +30 i18n keys |
| 新建 | `test/w6_test.dart` | 37 个单元测试 |
| 新建 | `docs/w6_test_guide.md` | 本文档 |
