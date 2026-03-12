# VerveForge 集成测试指南 v2.0

> **版本**: 2.0
> **日期**: 2026-03-07
> **作者**: VerveForge QA Team
> **单元测试基线**: 219 tests passed（W1-W4: 92 + W5: 47 + W6: 37 + W7.5: 15 + W8: 28）

### 变更记录

| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v1.0 | 2026-03-07 | 初版：42 个手动用例 + 5 个自动化示例 + 12 个异常场景 |
| v2.0 | 2026-03-07 | 升级：65+ 手动用例（9 模块）、覆盖率目标、Android 兼容、CI/CD、性能/安全/i18n 专项测试、完整自动化示例 |

---

## 一、测试目标与范围

### 1.1 目标

| 维度 | 目标 | 说明 |
|------|------|------|
| 手动集成测试覆盖率 | **100%** | 65 个用例全部执行，P0/P1 无遗留 |
| 自动化测试覆盖率 | **≥ 85%** | `flutter test --coverage` 行覆盖率 |
| 单元测试通过率 | **100%** | 219 tests, 0 failures |
| 静态分析 | **0 issues** | `flutter analyze` 零警告 |
| P0/P1 Bug 遗留 | **0** | 发布前全部修复 |

### 1.2 覆盖模块

| 模块 | Week | 核心功能 | 用例分组 |
|------|------|----------|----------|
| 认证与隐私 | W1+W8 | 登录 + 引导流 + 三层隐私弹窗 | A |
| 动态 Feed | W8 | 3 Tab + 发布 + 点赞 + 评论 | B |
| 训练日志 | W2-W5 | CRUD + 照片 + Health + 运动专项 | C |
| 挑战赛 | W6 | 创建 + 参加 + 排行 + 打卡 | D |
| 训练馆 | W4+W7.5 | 地图 + 列表 + 评价 + 收藏 + 认领 | E |
| 个人中心 | W1-W8 | 资料 + 设置 + 收藏 + 隐私 + 导出 | F |
| 主题与外观 | 全局 | 深色/浅色切换 + 组件一致性 | G |
| 跨模块交互 | 全局 | 路由跳转 + 数据联动 + 状态同步 | H |
| 国际化与布局 | 全局 | 中/英/繁体切换 + 文本溢出 + RTL | I |

---

## 二、测试环境准备

### 2.1 设备矩阵

| 平台 | 设备 | 系统版本 | 用途 |
|------|------|----------|------|
| iOS 模拟器 | iPhone 15 Pro | iOS 17.0+ | 主测试设备 |
| iOS 模拟器 | iPhone SE 3 | iOS 17.0+ | 小屏适配验证 |
| iOS 真机 | iPhone 12+ | iOS 16.0+ | TestFlight 真机验证 |
| Android 模拟器 | Pixel 7 | API 34 (Android 14) | Android 兼容性 |
| Android 真机 | 任意 Android 10+ | API 29+ | 真机回归 |

### 2.2 后端环境

| 项目 | 说明 |
|------|------|
| Supabase 测试项目 | 独立于生产，数据可随时重置 |
| 迁移脚本 | `00001` ~ `00017` 全部执行 |
| RLS 策略 | 全部表已启用 |
| Storage Bucket | `post-photos`、`workout-photos`、`gym-photos` 已创建 |

### 2.3 测试账号

| 账号 | 角色 | 城市 | 用途 |
|------|------|------|------|
| 账号 A | 主测试 | shanghai | 完整功能测试 |
| 账号 B | 辅助 | beijing | 关注/互动/跨用户测试 |
| 账号 C | 全新 | — | 首次安装 + 引导流测试 |
| 账号 D | 馆主 | shanghai | 认领审核流程测试 |

### 2.4 测试数据初始化

```sql
-- 1. 训练馆（至少 3 个 approved + 1 个未认证）
INSERT INTO gyms (name, address, city, country, location, latitude, longitude, sport_types, status, submitted_by)
VALUES
  ('HYROX 训练中心', '上海市静安区南京西路100号', 'shanghai', 'CN',
   ST_SetSRID(ST_MakePoint(121.4737, 31.2304), 4326), 31.2304, 121.4737,
   '{hyrox,crossfit}', 'approved', '<账号A>'),
  ('瑜伽之家', '北京市朝阳区建国路88号', 'beijing', 'CN',
   ST_SetSRID(ST_MakePoint(116.4074, 39.9042), 4326), 39.9042, 116.4074,
   '{yoga,pilates}', 'approved', '<账号A>'),
  ('CrossFit 深圳', '深圳市南山区科技园路1号', 'shenzhen', 'CN',
   ST_SetSRID(ST_MakePoint(113.9213, 22.5431), 4326), 22.5431, 113.9213,
   '{crossfit,strength}', 'approved', '<账号A>'),
  ('未认证馆', '上海市浦东新区张江路1号', 'shanghai', 'CN',
   ST_SetSRID(ST_MakePoint(121.59, 31.20), 4326), 31.20, 121.59,
   '{strength}', 'approved', '<账号B>');

-- 2. 测试动态（确保 Feed 有数据）
INSERT INTO posts (id, user_id, content, city, photos) VALUES
  (gen_random_uuid(), '<账号A>', '第一条测试动态', 'shanghai', '{}'),
  (gen_random_uuid(), '<账号A>', '带照片的动态', 'shanghai', '{"https://picsum.photos/400/300"}'),
  (gen_random_uuid(), '<账号B>', '北京的训练日常', 'beijing', '{}');

-- 3. 关注关系
INSERT INTO user_follows (follower_id, following_id) VALUES ('<账号A>', '<账号B>');

-- 4. 批量动态（分页测试，25 条）
INSERT INTO posts (id, user_id, content, city)
SELECT gen_random_uuid(), '<账号A>', '分页测试动态 ' || generate_series, 'shanghai'
FROM generate_series(1, 25);

-- 5. 测试挑战赛
INSERT INTO challenges (id, name, sport_type, goal_type, goal_value, start_date, end_date, city, created_by)
VALUES
  (gen_random_uuid(), '30天跑步挑战', 'running', 'sessions', 30,
   CURRENT_DATE, CURRENT_DATE + INTERVAL '30 days', 'shanghai', '<账号A>');
```

### 2.5 覆盖率工具配置

```bash
# 生成覆盖率报告
flutter test --coverage

# 查看覆盖率摘要
lcov --summary coverage/lcov.info

# 生成 HTML 报告
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# CI 中提取行覆盖率百分比
lcov --summary coverage/lcov.info 2>&1 | grep 'lines' | awk '{print $2}'
```

### 2.6 启动命令

```bash
# 首次安装模拟（清除缓存）
flutter clean && flutter pub get && flutter run

# 正常启动
flutter run

# 指定设备启动
flutter run -d "iPhone 15 Pro"
flutter run -d emulator-5554   # Android

# 验证套件
flutter analyze && flutter test
```

---

## 三、手动集成测试用例清单

> **约定**: 优先级 P0=致命 P1=严重 P2=一般 P3=轻微；类型 N=正常 E=异常 B=边界

### 模块 A：启动与隐私合规（8 个用例）

| ID | 用例名称 | 前置条件 | 操作步骤 | 预期结果 | 优先级 | 耗时 | 依赖 | 类型 |
|----|----------|----------|----------|----------|--------|------|------|------|
| A01 | 首次冷启动隐私弹窗 | 清除 App 数据 | 1. 启动 App | 弹出「欢迎使用 VerveForge」弹窗；不可点击外部关闭；显示 4 项数据说明 + 2 个按钮 | P0 | 2 | — | N |
| A02 | 拒绝隐私弹窗 | A01 弹窗已显示 | 1. 点击「不同意」 | 弹窗关闭；App 显示空白无法使用；再次启动仍弹出弹窗 | P0 | 2 | A01 | E |
| A03 | 同意隐私弹窗 | A01 弹窗已显示 | 1. 点击「我已阅读并同意」 | 弹窗关闭；进入登录页；后续启动不再弹出 | P0 | 2 | A01 | N |
| A04 | 弹窗跳转隐私政策全文 | A01 弹窗已显示 | 1. 点击「查看完整隐私政策」 | 跳转隐私政策全文页（6 节内容）；返回后弹窗仍在 | P1 | 2 | A01 | N |
| A05 | 登录时隐私弹窗 | 已同意冷启动弹窗，未登录 | 1. 输入手机号<br>2. 点击获取验证码 | 弹出登录隐私弹窗（PrivacyConsentDialog）；同意后发送 OTP | P0 | 3 | — | N |
| A06 | 训练数据采集授权 | 已登录，从未记录训练 | 1.「+」→ 记录训练<br>2. 填写并保存 | 首次保存前弹出数据采集授权弹窗；同意后正常保存；后续不再弹出 | P0 | 3 | — | N |
| A07 | 隐私弹窗深色模式适配 | 深色主题 + 清除数据 | 1. 启动 App | 弹窗背景为 darkSurface；文字颜色对比度符合可读性；按钮色调正确 | P2 | 2 | A01 | N |
| A08 | 隐私弹窗浅色模式适配 | 浅色主题 + 清除数据 | 1. 启动 App | 弹窗背景为白色/浅灰；文字/按钮色调正确 | P2 | 2 | A01 | N |

### 模块 B：首页 Feed（12 个用例）

| ID | 用例名称 | 前置条件 | 操作步骤 | 预期结果 | 优先级 | 耗时 | 依赖 | 类型 |
|----|----------|----------|----------|----------|--------|------|------|------|
| B01 | Feed 三 Tab 默认状态 | 已登录 | 1. 进入 Feed 页 | 默认选中「附近」Tab；TabBar 指示器橙色；标签样式区分 | P0 | 2 | — | N |
| B02 | 切换到关注 Tab（有数据） | A 已关注 B，B 有动态 | 1. 点击「关注」Tab | 显示 B 的动态；卡片含头像/昵称/时间/正文 | P0 | 2 | — | N |
| B03 | 关注 Tab 空状态 | 账号未关注任何人 | 1. 切换到「关注」Tab | 显示空状态图标 + 「暂无关注动态」 + 提示文字 | P1 | 1 | — | B |
| B04 | 附近 Tab 下拉刷新 | Feed 有数据 | 1. 列表顶部下拉 | 显示橙色刷新指示器；松手后列表重新加载 | P1 | 2 | — | N |
| B05 | 上拉加载更多 | 动态数 > 20 条 | 1. 滑到列表底部 | 自动加载下一页；新数据追加到末尾；无重复项 | P1 | 2 | — | N |
| B06 | 发布纯文字动态 | 已登录 | 1.「+」→ 发布动态<br>2. 输入文字<br>3. 点击「发布」 | 发布按钮变加载态；成功 SnackBar；自动返回 Feed；新动态出现在列表 | P0 | 3 | — | N |
| B07 | 发布带照片动态 | 已登录 | 1. 发布页添加 2 张照片<br>2. 输入文字<br>3. 发布 | 照片上传成功；卡片显示照片网格 | P0 | 3 | — | N |
| B08 | 发布带城市标签 | 已登录 | 1. 发布页选择 city=shanghai<br>2. 发布 | 卡片右上角显示 city 标签 | P2 | 2 | — | N |
| B09 | 空内容无法发布 | 发布页 | 1. 不输入任何文字，不选照片 | 发布按钮保持禁用（灰色） | P1 | 1 | — | B |
| B10 | 点赞 / 取消点赞 | Feed 有动态 | 1. 点击心形<br>2. 再次点击 | 第一次：变红 + 计数 +1；第二次：变空心 + 计数 -1 | P0 | 2 | — | N |
| B11 | 快速双击点赞防重 | Feed 有动态 | 1. 快速双击心形 | 仅触发一次请求；最终状态正确（已赞或未赞） | P1 | 2 | — | E |
| B12 | 无网络发布动态 | 关闭网络 | 1. 填写内容<br>2. 点击发布 | 显示错误 SnackBar；内容不丢失；恢复网络后可重试 | P1 | 3 | — | E |

### 模块 C：训练日志（9 个用例）

| ID | 用例名称 | 前置条件 | 操作步骤 | 预期结果 | 优先级 | 耗时 | 依赖 | 类型 |
|----|----------|----------|----------|----------|--------|------|------|------|
| C01 | 创建基础训练 | 已登录，已同意数据采集 | 1.「+」→ 记录训练<br>2. 选类型/时长/强度<br>3. 保存 | 保存成功；训练列表出现新记录 | P0 | 3 | A06 | N |
| C02 | HYROX 专项成绩录入 | 已登录 | 1. 创建训练 → 类型=HYROX<br>2. 展开专项成绩<br>3. 填 8 站计时 + 总成绩<br>4. 保存 | 详情页显示 HYROX 成绩卡片；列表卡片摘要显示总成绩 | P0 | 5 | — | N |
| C03 | CrossFit WOD 成绩录入 | 已登录 | 1. 类型=CrossFit<br>2. 填 WOD 名/类型/成绩<br>3. 保存 | 详情页显示 CrossFit 成绩卡片 | P1 | 3 | — | N |
| C04 | 跑步配速录入 | 已登录 | 1. 类型=Running<br>2. 填距离/配速/爬升<br>3. 保存 | 详情页显示跑步成绩卡片（含配速格式化） | P1 | 3 | — | N |
| C05 | 训练照片上传 | 已登录 | 1. 创建训练<br>2. 添加 3 张照片<br>3. 删除 1 张<br>4. 保存 | 照片网格正确显示 2 张；详情页可查看 | P1 | 3 | — | N |
| C06 | 照片上限 9 张 | 已登录 | 1. 逐次添加照片至 9 张<br>2. 尝试继续添加 | 9 张后添加按钮消失；计数显示 9/9 | P2 | 3 | — | B |
| C07 | 训练日历视图 | 有多条不同日期训练 | 1. 进入训练日历<br>2. 点击有标记日期 | 日历正确标记训练日；点击跳转到当日训练详情 | P1 | 3 | — | N |
| C08 | 删除训练记录 | 有训练记录 | 1. 进入详情 → 删除<br>2. 确认 | 确认对话框弹出；确认后记录从列表消失（软删除） | P1 | 2 | — | N |
| C09 | 无网络创建训练 | 关闭网络 | 1. 填写训练信息<br>2. 保存 | 显示错误提示；数据不丢失 | P1 | 3 | — | E |

### 模块 D：挑战赛（8 个用例）

| ID | 用例名称 | 前置条件 | 操作步骤 | 预期结果 | 优先级 | 耗时 | 依赖 | 类型 |
|----|----------|----------|----------|----------|--------|------|------|------|
| D01 | 创建挑战赛 | 已登录 | 1. Tab 4 → 创建<br>2. 填写名称/类型/目标/日期/城市<br>3. 提交 | 创建成功 SnackBar；列表出现新挑战 | P0 | 3 | — | N |
| D02 | 参加挑战赛 | 有进行中的挑战 | 1. 点击挑战卡片<br>2. 点击「参加」 | 加入成功；排行榜出现自己（排名末尾） | P0 | 2 | D01 | N |
| D03 | 打卡 | 已参加挑战 | 1. 排行页点击「打卡」 | 打卡成功；打卡次数 +1；排名实时更新 | P0 | 2 | D02 | N |
| D04 | 退出挑战 | 已参加挑战 | 1. 点击「退出」<br>2. 确认 | 确认对话框弹出；退出成功；排行榜移除自己 | P1 | 2 | D02 | N |
| D05 | 城市筛选 | 有不同城市挑战 | 1. 选择城市筛选 | 列表仅显示对应城市挑战 | P1 | 2 | — | N |
| D06 | 运动类型筛选 | 有不同运动类型挑战 | 1. 选择运动类型 | 列表仅显示对应类型挑战 | P2 | 2 | — | N |
| D07 | 挑战列表空状态 | 无挑战数据 | 1. 进入挑战 Tab | 显示空状态 + 「创建或参加运动挑战」提示 | P2 | 1 | — | B |
| D08 | 已满员挑战 | 挑战 max_participants 已达上限 | 1. 尝试参加 | 显示「已满员」；参加按钮禁用 | P1 | 2 | — | B |

### 模块 E：训练馆（10 个用例）

| ID | 用例名称 | 前置条件 | 操作步骤 | 预期结果 | 优先级 | 耗时 | 依赖 | 类型 |
|----|----------|----------|----------|----------|--------|------|------|------|
| E01 | 训练馆地图浏览 | 有 approved 训练馆 | 1. 进入训练馆地图页 | 高德地图加载；标注点正确显示 | P0 | 3 | — | N |
| E02 | 训练馆列表搜索 | 有测试数据 | 1. 进入列表<br>2. 搜索「HYROX」 | 列表筛选显示匹配结果 | P1 | 2 | — | N |
| E03 | 训练馆详情页 | 有 approved 训练馆 | 1. 点击训练馆卡片 | 详情页显示：名称/地址/运动类型/评分/评价列表 | P0 | 2 | — | N |
| E04 | 卡片收藏 | 已登录 | 1. 训练馆卡片点击心形 | 心形变红；SnackBar「已添加收藏」 | P0 | 2 | — | N |
| E05 | 详情页收藏同步 | E04 已收藏 | 1. 进入该训练馆详情 | AppBar 心形为红色实心 | P1 | 1 | E04 | N |
| E06 | 取消收藏 | 已收藏训练馆 | 1. 再次点击心形 | 变回空心；SnackBar「已取消收藏」 | P1 | 1 | E04 | N |
| E07 | 收藏列表页 | 已收藏 2+ 训练馆 | 1.「我的」→「我的收藏训练馆」 | 列表按收藏时间倒序；点击可进入详情；取消收藏后该项消失 | P0 | 3 | E04 | N |
| E08 | 馆主认领流程 | 有 is_verified=FALSE 的训练馆 | 1. 进入未认证训练馆详情<br>2. 点击「认领此场馆」<br>3. 确认提交 | 确认对话框弹出；提交成功；按钮替换为「审核中」状态卡 | P0 | 3 | — | N |
| E09 | 重复认领防护 | E08 已提交认领 | 1. 再次访问该训练馆详情 | 显示「审核中」状态卡；不显示认领按钮 | P1 | 1 | E08 | B |
| E10 | 已认证训练馆蓝V | 有 is_verified=TRUE 的训练馆 | 1. 进入详情页 | 标题旁显示蓝V标记；不显示认领按钮/状态卡 | P1 | 1 | — | N |

### 模块 F：个人中心与设置（7 个用例）

| ID | 用例名称 | 前置条件 | 操作步骤 | 预期结果 | 优先级 | 耗时 | 依赖 | 类型 |
|----|----------|----------|----------|----------|--------|------|------|------|
| F01 | 编辑个人资料 | 已登录 | 1.「我的」→ 编辑资料<br>2. 修改昵称 + 运动偏好<br>3. 保存 | 保存成功；返回后显示新昵称 | P0 | 3 | — | N |
| F02 | 数据导出 | 已登录 | 1. 设置 → 隐私设置 → 导出数据 | 生成 JSON 文件；弹出系统分享面板 | P0 | 3 | — | N |
| F03 | 可见性开关 — 发现列表 | 已登录 | 1. 隐私设置 → 关闭「出现在发现列表」 | 开关切换成功；其他用户发现页不再显示本人 | P1 | 2 | — | N |
| F04 | 可见性开关 — 训练统计 | 已登录 | 1. 隐私设置 → 关闭「公开训练统计」 | 开关切换成功 | P2 | 1 | — | N |
| F05 | 注销账号（二次确认） | 已登录 | 1. 隐私设置 → 注销账号<br>2. 第一次确认<br>3. 第二次确认 | 两次确认对话框；注销请求提交成功；返回登录页 | P0 | 3 | — | N |
| F06 | 设置页隐私政策入口 | 已登录 | 1. 设置 → 隐私设置 → 隐私政策 | 跳转独立隐私政策全文页；显示完整 6 节内容 | P1 | 2 | — | N |
| F07 | 退出登录 | 已登录 | 1. 设置 → 退出登录 | 退出成功；跳转到登录页 | P0 | 1 | — | N |

### 模块 G：主题切换与外观一致性（5 个用例）

| ID | 用例名称 | 前置条件 | 操作步骤 | 预期结果 | 优先级 | 耗时 | 依赖 | 类型 |
|----|----------|----------|----------|----------|--------|------|------|------|
| G01 | 深色 → 浅色切换 | 当前深色模式 | 1. 设置 → 主题 → 浅色 | 全局切换：Scaffold 背景、NavigationBar、卡片、输入框、TabBar、Dialog、BottomSheet 均为浅色调 | P0 | 3 | — | N |
| G02 | 浅色 → 深色切换 | 当前浅色模式 | 1. 设置 → 主题 → 深色 | 全局切换：所有组件背景/文字色为深色调 | P0 | 3 | — | N |
| G03 | 浅色模式下 Feed 交互 | 浅色主题 | 1. 浏览 Feed<br>2. 点赞<br>3. 发布动态 | 所有交互正常；心形红色可见；发布按钮橙色 | P1 | 3 | G01 | N |
| G04 | 深色模式下弹窗外观 | 深色主题 | 1. 触发各类弹窗（隐私/确认/底部弹窗） | 弹窗背景为 darkSurface；圆角 20px；按钮/文字色调正确 | P1 | 3 | — | N |
| G05 | 跟随系统主题 | 主题=跟随系统 | 1. 修改系统深色/浅色<br>2. 返回 App | App 主题自动跟随系统变化 | P2 | 3 | — | N |

### 模块 H：跨模块交互（8 个用例）

| ID | 用例名称 | 前置条件 | 操作步骤 | 预期结果 | 优先级 | 耗时 | 依赖 | 类型 |
|----|----------|----------|----------|----------|--------|------|------|------|
| H01 | 底部「+」双入口 | 已登录 | 1. 点击底部「+」 | 弹出底部弹窗；显示「记录训练」（含副标题）+「发布动态」（含副标题）；分别可正常跳转 | P0 | 2 | — | N |
| H02 | 收藏列表 → 训练馆详情 | 已收藏训练馆 | 1.「我的」→ 收藏列表<br>2. 点击卡片 | 正确进入训练馆详情页；AppBar 心形为红色 | P1 | 2 | E04 | N |
| H03 | 挑战列表 → 排行页 → 返回 | 有挑战数据 | 1. 挑战列表 → 点击卡片<br>2. 查看排行<br>3. 返回 | 排行页正常加载；返回后列表滚动位置保持 | P1 | 2 | D01 | N |
| H04 | 训练馆详情 → 写评价 → 返回 | 有 approved 训练馆 | 1. 训练馆详情 → 写评价<br>2. 提交评价<br>3. 返回详情 | 评价提交成功；详情页评价列表刷新显示新评价 | P1 | 3 | — | N |
| H05 | 收藏状态跨页面同步 | 已登录 | 1. 列表页收藏训练馆<br>2. 进入详情页<br>3. 取消收藏<br>4. 返回列表页 | 详情页心形同步红色；取消后返回列表页心形恢复空心 | P1 | 3 | — | N |
| H06 | Feed 点赞计数跨页面同步 | Feed 有动态 | 1. 在 Feed 点赞<br>2. （如有详情页）进入详情 | 点赞计数一致 | P2 | 2 | — | N |
| H07 | 发布动态后 Feed 刷新 | 已登录 | 1. 发布动态<br>2. 返回 Feed 页 | Feed 列表自动刷新（invalidate）；新动态在列表顶部 | P0 | 3 | B06 | N |
| H08 | 「记录训练」路由 | 已登录 | 1.「+」→ 记录训练 | 跳转到 WorkoutCreatePage（通过 go_router）；表单正常加载 | P1 | 1 | — | N |

### 模块 I：国际化与布局（8 个用例）

| ID | 用例名称 | 前置条件 | 操作步骤 | 预期结果 | 优先级 | 耗时 | 依赖 | 类型 |
|----|----------|----------|----------|----------|--------|------|------|------|
| I01 | 中文 → English 切换 | 当前中文 | 1. 设置 → 语言 → English | 所有 Tab 标签/按钮/提示/空状态文本切换为英文 | P0 | 3 | — | N |
| I02 | English → 繁体中文切换 | 当前 English | 1. 设置 → 语言 → 繁體中文 | 所有文本切换为繁体；「設定」「訓練」「挑戰」等正确显示 | P1 | 3 | I01 | N |
| I03 | 繁体中文 → 简体中文切换 | 当前繁体 | 1. 设置 → 语言 → 简体中文 | 所有文本恢复简体 | P1 | 2 | I02 | N |
| I04 | 英文长文本布局 | English 模式 | 1. 浏览 Feed / 训练馆列表 / 挑战列表 | 无文本溢出（overflow）；按钮文字完整可见；卡片布局无破裂 | P1 | 5 | I01 | B |
| I05 | 小屏设备布局适配 | iPhone SE 模拟器 | 1. 浏览所有核心页面 | NavigationBar 5 个 Tab 完整显示；卡片不超屏；弹窗可滚动 | P1 | 5 | — | B |
| I06 | Android 布局差异验证 | Android 模拟器/真机 | 1. 浏览 Feed / 训练馆 / 挑战 | NavigationBar 样式正常（Material 3）；无 iOS 独有组件异常 | P1 | 5 | — | B |
| I07 | 切换语言后弹窗文本 | 切换到 English | 1. 触发隐私弹窗 / 确认对话框 / 底部弹窗 | 弹窗内所有文本为英文 | P2 | 3 | I01 | N |
| I08 | timeAgo 本地化 | 有不同时间段动态 | 1. 查看 Feed 卡片时间 | 中文：「刚刚」「3分钟前」「2小时前」「3天前」；英文模式下同逻辑（当前为中文固定） | P3 | 2 | — | B |

---

### 用例统计

| 模块 | 用例数 | P0 | P1 | P2 | P3 |
|------|--------|----|----|----|----|
| A. 启动与隐私合规 | 8 | 4 | 1 | 2 | 0 |
| B. 首页 Feed | 12 | 4 | 5 | 1 | 0 |
| C. 训练日志 | 9 | 2 | 5 | 1 | 0 |
| D. 挑战赛 | 8 | 3 | 2 | 2 | 0 |
| E. 训练馆 | 10 | 4 | 4 | 0 | 0 |
| F. 个人中心 | 7 | 3 | 2 | 1 | 0 |
| G. 主题切换 | 5 | 2 | 2 | 1 | 0 |
| H. 跨模块交互 | 8 | 2 | 5 | 1 | 0 |
| I. 国际化与布局 | 8 | 1 | 4 | 1 | 1 |
| **合计** | **75** | **25** | **30** | **10** | **1** |

> **Part 1 结束** — 共 75 个手动集成测试用例。

---

## 四、Part 2 概览

> Part 2 包含三大章节：自动化集成测试代码示例（12 个）、性能与负载测试（8 个场景）、安全与边界测试（16 个场景），共计 **36 个补充测试场景**。

---

## 五、自动化集成测试补充（12 个 integration_test 代码示例）

> **说明**: 以下所有测试使用 Flutter `integration_test` 框架，运行命令统一为：
> ```bash
> flutter test integration_test/<文件名>.dart
> ```
> 如需指定设备：
> ```bash
> flutter test integration_test/<文件名>.dart -d "iPhone 15 Pro"
> ```

### AT-01：冷启动隐私弹窗 → 同意 → 进入登录页

| 属性 | 值 |
|------|------|
| 对应手动用例 | A01, A03 |
| 优先级 | P0 |
| 文件名 | `integration_test/privacy_cold_start_test.dart` |

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:verveforge/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AT-01: 冷启动隐私弹窗 → 同意 → 进入登录页', (tester) async {
    // 清除本地存储模拟首次安装
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    app.main();
    await tester.pumpAndSettle();

    // 验证隐私弹窗出现
    expect(find.text('欢迎使用 VerveForge'), findsOneWidget);
    expect(find.text('我已阅读并同意'), findsOneWidget);
    expect(find.text('不同意'), findsOneWidget);

    // 验证 4 项数据说明
    expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    expect(find.byIcon(Icons.location_on), findsOneWidget);
    expect(find.byIcon(Icons.photo_camera), findsOneWidget);
    expect(find.byIcon(Icons.analytics), findsOneWidget);

    // 点击同意
    await tester.tap(find.text('我已阅读并同意'));
    await tester.pumpAndSettle();

    // 验证进入登录页
    expect(find.text('欢迎使用 VerveForge'), findsNothing); // 弹窗消失
    expect(find.byType(LoginPage), findsOneWidget);
  });
}
```

### AT-02：拒绝隐私弹窗 → 应用不可用

| 属性 | 值 |
|------|------|
| 对应手动用例 | A02 |
| 优先级 | P0 |
| 文件名 | `integration_test/privacy_reject_test.dart` |

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:verveforge/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AT-02: 拒绝隐私弹窗后应用不可用', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    app.main();
    await tester.pumpAndSettle();

    // 点击「不同意」
    await tester.tap(find.text('不同意'));
    await tester.pumpAndSettle();

    // 验证弹窗关闭但无法使用
    expect(find.text('欢迎使用 VerveForge'), findsNothing);
    expect(find.byType(LoginPage), findsNothing);

    // 模拟重新启动 — 弹窗应再次出现
    app.main();
    await tester.pumpAndSettle();
    expect(find.text('欢迎使用 VerveForge'), findsOneWidget);
  });
}
```

### AT-03：Feed 三 Tab 切换 + 下拉刷新

| 属性 | 值 |
|------|------|
| 对应手动用例 | B01, B02, B04 |
| 优先级 | P0 |
| 文件名 | `integration_test/feed_tabs_test.dart` |

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:verveforge/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AT-03: Feed 三 Tab 切换 + 下拉刷新', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    // 假设已登录状态（通过 test helper 注入认证 token）

    // 验证默认选中「附近」
    final nearbyTab = find.text('附近');
    expect(nearbyTab, findsOneWidget);

    // 切换到「关注」Tab
    await tester.tap(find.text('关注'));
    await tester.pumpAndSettle();

    // 验证关注 Tab 内容加载
    // （有关注数据时应显示动态卡片）
    expect(find.byType(PostCard), findsWidgets);

    // 切换到「推荐」Tab
    await tester.tap(find.text('推荐'));
    await tester.pumpAndSettle();

    // 切回「附近」并下拉刷新
    await tester.tap(nearbyTab);
    await tester.pumpAndSettle();

    // 下拉刷新
    await tester.fling(
      find.byType(ListView).first,
      const Offset(0, 300),
      1000,
    );
    await tester.pumpAndSettle();

    // 验证刷新后列表仍有数据
    expect(find.byType(PostCard), findsWidgets);
  });
}
```

### AT-04：发布纯文字动态完整流程

| 属性 | 值 |
|------|------|
| 对应手动用例 | B06 |
| 优先级 | P0 |
| 文件名 | `integration_test/post_create_text_test.dart` |

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:verveforge/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AT-04: 发布纯文字动态完整流程', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // 点击底部「+」按钮
    await tester.tap(find.byKey(const Key('fab_add_button')));
    await tester.pumpAndSettle();

    // 选择「发布动态」
    await tester.tap(find.text('发布动态'));
    await tester.pumpAndSettle();

    // 输入动态内容
    final contentField = find.byKey(const Key('post_content_field'));
    await tester.enterText(contentField, '自动化测试发布的动态 ${DateTime.now()}');
    await tester.pumpAndSettle();

    // 验证发布按钮变为可用
    final publishButton = find.text('发布');
    expect(tester.widget<ElevatedButton>(
      find.ancestor(of: publishButton, matching: find.byType(ElevatedButton)),
    ).enabled, isTrue);

    // 点击发布
    await tester.tap(publishButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // 验证成功 SnackBar
    expect(find.text('发布成功'), findsOneWidget);

    // 验证返回 Feed 页
    expect(find.byType(FeedPage), findsOneWidget);
  });
}
```

### AT-05：点赞 / 取消点赞切换

| 属性 | 值 |
|------|------|
| 对应手动用例 | B10 |
| 优先级 | P0 |
| 文件名 | `integration_test/like_toggle_test.dart` |

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:verveforge/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AT-05: 点赞 / 取消点赞切换', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // 找到第一个心形按钮
    final heartButton = find.byKey(const Key('like_button')).first;

    // 获取初始点赞计数
    final initialCount = _getLikeCount(tester);

    // 第一次点击 — 点赞
    await tester.tap(heartButton);
    await tester.pumpAndSettle();

    // 验证：图标变红，计数 +1
    expect(find.byIcon(Icons.favorite), findsWidgets);
    expect(_getLikeCount(tester), equals(initialCount + 1));

    // 第二次点击 — 取消点赞
    await tester.tap(heartButton);
    await tester.pumpAndSettle();

    // 验证：图标变空心，计数恢复
    expect(find.byIcon(Icons.favorite_border), findsWidgets);
    expect(_getLikeCount(tester), equals(initialCount));
  });
}

int _getLikeCount(WidgetTester tester) {
  // 辅助函数：提取第一个点赞计数文本
  final countWidget = tester.widget<Text>(
    find.byKey(const Key('like_count')).first,
  );
  return int.parse(countWidget.data ?? '0');
}
```

### AT-06：创建训练日志 + HYROX 专项成绩

| 属性 | 值 |
|------|------|
| 对应手动用例 | C01, C02 |
| 优先级 | P0 |
| 文件名 | `integration_test/workout_create_hyrox_test.dart` |

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:verveforge/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AT-06: 创建训练日志 + HYROX 专项成绩', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // 导航到创建训练
    await tester.tap(find.byKey(const Key('fab_add_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('记录训练'));
    await tester.pumpAndSettle();

    // 选择运动类型 = HYROX
    await tester.tap(find.byKey(const Key('sport_type_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('HYROX').last);
    await tester.pumpAndSettle();

    // 设置时长
    await tester.enterText(
      find.byKey(const Key('duration_field')),
      '90',
    );

    // 设置强度
    await tester.tap(find.byKey(const Key('intensity_high')));
    await tester.pumpAndSettle();

    // 展开 HYROX 专项成绩区域
    await tester.tap(find.text('HYROX 专项成绩'));
    await tester.pumpAndSettle();

    // 填写总成绩
    await tester.enterText(
      find.byKey(const Key('hyrox_total_time')),
      '01:25:30',
    );

    // 填写第 1 站（SkiErg）
    await tester.enterText(
      find.byKey(const Key('hyrox_station_1')),
      '04:30',
    );

    // 保存
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // 验证保存成功
    expect(find.text('保存成功'), findsOneWidget);

    // 验证详情页显示 HYROX 成绩卡片
    expect(find.text('HYROX 专项成绩'), findsOneWidget);
    expect(find.text('01:25:30'), findsOneWidget);
  });
}
```

### AT-07：挑战赛创建 → 参加 → 打卡完整链路

| 属性 | 值 |
|------|------|
| 对应手动用例 | D01, D02, D03 |
| 优先级 | P0 |
| 文件名 | `integration_test/challenge_full_flow_test.dart` |

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:verveforge/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AT-07: 挑战赛创建 → 参加 → 打卡', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // 导航到挑战赛 Tab
    await tester.tap(find.byKey(const Key('nav_challenges')));
    await tester.pumpAndSettle();

    // 创建挑战赛
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('challenge_name')),
      'AT-07 自动化挑战 ${DateTime.now().millisecondsSinceEpoch}',
    );
    await tester.tap(find.byKey(const Key('sport_type_running')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('goal_value')), '10');

    await tester.tap(find.text('创建'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // 验证创建成功
    expect(find.textContaining('AT-07 自动化挑战'), findsOneWidget);

    // 参加挑战
    await tester.tap(find.textContaining('AT-07 自动化挑战'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('参加'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('加入成功'), findsOneWidget);

    // 打卡
    await tester.tap(find.text('打卡'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('打卡成功'), findsOneWidget);
  });
}
```

### AT-08：训练馆收藏 + 收藏列表验证

| 属性 | 值 |
|------|------|
| 对应手动用例 | E04, E07 |
| 优先级 | P0 |
| 文件名 | `integration_test/gym_favorite_test.dart` |

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:verveforge/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AT-08: 训练馆收藏 + 收藏列表验证', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // 导航到训练馆 Tab
    await tester.tap(find.byKey(const Key('nav_gyms')));
    await tester.pumpAndSettle();

    // 切换到列表视图
    await tester.tap(find.byIcon(Icons.list));
    await tester.pumpAndSettle();

    // 点击第一个训练馆的心形收藏
    final favoriteButton = find.byKey(const Key('gym_favorite_button')).first;
    await tester.tap(favoriteButton);
    await tester.pumpAndSettle();

    // 验证收藏成功
    expect(find.text('已添加收藏'), findsOneWidget);

    // 记录训练馆名称
    final gymName = tester.widget<Text>(
      find.byKey(const Key('gym_name')).first,
    ).data!;

    // 导航到「我的」→ 收藏列表
    await tester.tap(find.byKey(const Key('nav_profile')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('我的收藏训练馆'));
    await tester.pumpAndSettle();

    // 验证收藏列表包含该训练馆
    expect(find.text(gymName), findsOneWidget);
  });
}
```

### AT-09：深色 / 浅色主题切换全局验证

| 属性 | 值 |
|------|------|
| 对应手动用例 | G01, G02 |
| 优先级 | P0 |
| 文件名 | `integration_test/theme_switch_test.dart` |

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:verveforge/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AT-09: 深色 / 浅色主题切换', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // 进入设置
    await tester.tap(find.byKey(const Key('nav_profile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // 切换到浅色模式
    await tester.tap(find.text('主题'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('浅色'));
    await tester.pumpAndSettle();

    // 验证浅色模式 — Scaffold 背景接近白色
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    final lightBg = scaffold.backgroundColor;
    expect(lightBg?.computeLuminance(), greaterThan(0.8));

    // 切换到深色模式
    await tester.tap(find.text('深色'));
    await tester.pumpAndSettle();

    // 验证深色模式 — Scaffold 背景偏暗
    final scaffoldDark = tester.widget<Scaffold>(find.byType(Scaffold).first);
    final darkBg = scaffoldDark.backgroundColor;
    expect(darkBg?.computeLuminance(), lessThan(0.2));
  });
}
```

### AT-10：语言切换（中 → 英 → 繁体 → 中）

| 属性 | 值 |
|------|------|
| 对应手动用例 | I01, I02, I03 |
| 优先级 | P0 |
| 文件名 | `integration_test/language_switch_test.dart` |

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:verveforge/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AT-10: 语言切换完整链路', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // 进入设置
    await tester.tap(find.byKey(const Key('nav_profile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // 切换到 English
    await tester.tap(find.text('语言'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    // 验证英文显示
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('设置'), findsNothing);

    // 切换到繁體中文
    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('繁體中文'));
    await tester.pumpAndSettle();

    // 验证繁体
    expect(find.text('設定'), findsOneWidget);

    // 切回简体中文
    await tester.tap(find.text('語言'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('简体中文'));
    await tester.pumpAndSettle();

    // 验证恢复简体
    expect(find.text('设置'), findsOneWidget);
  });
}
```

### AT-11：跨模块路由 —「+」按钮双入口验证

| 属性 | 值 |
|------|------|
| 对应手动用例 | H01, H08 |
| 优先级 | P0 |
| 文件名 | `integration_test/fab_dual_entry_test.dart` |

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:verveforge/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AT-11: 「+」按钮双入口路由验证', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // 点击「+」按钮
    await tester.tap(find.byKey(const Key('fab_add_button')));
    await tester.pumpAndSettle();

    // 验证底部弹窗双入口
    expect(find.text('记录训练'), findsOneWidget);
    expect(find.text('发布动态'), findsOneWidget);

    // 测试「记录训练」入口
    await tester.tap(find.text('记录训练'));
    await tester.pumpAndSettle();
    expect(find.byType(WorkoutCreatePage), findsOneWidget);

    // 返回
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // 再次点击「+」测试「发布动态」入口
    await tester.tap(find.byKey(const Key('fab_add_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('发布动态'));
    await tester.pumpAndSettle();
    expect(find.byType(PostCreatePage), findsOneWidget);
  });
}
```

### AT-12：馆主认领完整流程

| 属性 | 值 |
|------|------|
| 对应手动用例 | E08, E09 |
| 优先级 | P0 |
| 文件名 | `integration_test/gym_claim_test.dart` |

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:verveforge/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AT-12: 馆主认领完整流程', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // 导航到训练馆列表
    await tester.tap(find.byKey(const Key('nav_gyms')));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.list));
    await tester.pumpAndSettle();

    // 找到未认证训练馆并进入
    await tester.tap(find.text('未认证馆'));
    await tester.pumpAndSettle();

    // 验证「认领此场馆」按钮存在
    expect(find.text('认领此场馆'), findsOneWidget);

    // 点击认领
    await tester.tap(find.text('认领此场馆'));
    await tester.pumpAndSettle();

    // 确认对话框
    expect(find.text('确认认领'), findsOneWidget);
    await tester.tap(find.text('确认'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // 验证认领成功 — 按钮替换为审核中状态
    expect(find.text('认领此场馆'), findsNothing);
    expect(find.text('审核中'), findsOneWidget);

    // 返回后重新进入 — 仍显示审核中
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.text('未认证馆'));
    await tester.pumpAndSettle();

    expect(find.text('审核中'), findsOneWidget);
    expect(find.text('认领此场馆'), findsNothing);
  });
}
```

### 自动化测试汇总

| ID | 测试名称 | 对应手动用例 | 优先级 | 预计运行时间 |
|----|----------|------------|--------|------------|
| AT-01 | 冷启动隐私弹窗 → 同意 | A01, A03 | P0 | ~15s |
| AT-02 | 拒绝隐私弹窗 | A02 | P0 | ~10s |
| AT-03 | Feed 三 Tab + 下拉刷新 | B01, B02, B04 | P0 | ~20s |
| AT-04 | 发布纯文字动态 | B06 | P0 | ~25s |
| AT-05 | 点赞 / 取消点赞 | B10 | P0 | ~15s |
| AT-06 | 创建训练 + HYROX 成绩 | C01, C02 | P0 | ~30s |
| AT-07 | 挑战赛创建→参加→打卡 | D01, D02, D03 | P0 | ~35s |
| AT-08 | 训练馆收藏 + 列表 | E04, E07 | P0 | ~20s |
| AT-09 | 主题切换全局验证 | G01, G02 | P0 | ~15s |
| AT-10 | 语言切换链路 | I01, I02, I03 | P0 | ~20s |
| AT-11 | 「+」双入口路由 | H01, H08 | P0 | ~15s |
| AT-12 | 馆主认领流程 | E08, E09 | P0 | ~25s |
| | **合计** | **20 个手动用例** | | **~4 min** |

```bash
# 批量执行全部自动化集成测试
flutter test integration_test/

# 执行单个测试
flutter test integration_test/privacy_cold_start_test.dart

# 指定设备 + 生成截图
flutter test integration_test/ -d "iPhone 15 Pro" --screenshots
```

---

## 六、性能与负载测试（8 个场景）

> **工具**: Flutter DevTools、Dart Observatory、手动计时、Supabase Dashboard
> **基准设备**: iPhone 15 Pro 模拟器（iOS 17）+ Pixel 7 模拟器（API 34）

### 场景总览

| ID | 场景名称 | 测试目标 | 操作方法 | 通过标准 | 优先级 | 类型 |
|----|----------|----------|----------|----------|--------|------|
| PF-01 | 冷启动耗时 | App 从无到可交互 | 1. 杀掉 App 进程<br>2. `flutter run --profile`<br>3. DevTools Timeline 记录 | iOS ≤ 3s, Android ≤ 4s（首帧渲染到可交互） | P0 | 性能 |
| PF-02 | Feed 首屏加载 | 列表首屏数据渲染 | 1. 登录后进入 Feed<br>2. 记录从 Navigator.push 到列表首条渲染完成 | ≤ 1.5s（含网络请求） | P0 | 性能 |
| PF-03 | Feed 100 条滑动帧率 | 大量数据下列表流畅度 | 1. 数据库插入 100 条带图动态<br>2. 快速滑动列表<br>3. DevTools 帧率面板 | 帧率 ≥ 55fps；无掉帧 Jank（红帧 ≤ 2%） | P0 | 性能 |
| PF-04 | 训练馆地图 50 标注点 | 地图大量标注性能 | 1. 插入 50 个 approved 训练馆<br>2. 进入地图页<br>3. 缩放/平移操作 | 地图加载 ≤ 2s；缩放流畅无卡顿；内存增量 ≤ 30MB | P1 | 性能 |
| PF-05 | 照片上传 9 张 | 批量图片上传耗时 | 1. 创建训练 → 选 9 张 1MB 图片<br>2. 点击保存<br>3. 记录上传完成耗时 | 总耗时 ≤ 15s（Wi-Fi）；进度条正确更新；无 OOM | P1 | 性能 |
| PF-06 | 连续快速切换 Tab | 频繁操作下内存稳定性 | 1. 快速循环切换 5 个底部 Tab 各 20 次<br>2. 监控 DevTools Memory 面板 | 内存增量 ≤ 50MB；无 Flutter Engine Crash；无内存泄漏趋势 | P1 | 性能 |
| PF-07 | 长时间使用内存泄漏 | 内存泄漏检测 | 1. 正常使用 App 30 分钟（浏览、发布、训练记录、切换页面）<br>2. 周期性记录 RSS 内存 | 内存无持续上升趋势；GC 后能回到基线 ± 20MB | P1 | 性能 |
| PF-08 | 弱网环境响应 | 网络延迟/丢包容忍 | 1. 使用 Network Link Conditioner 设置 3G 网络（延迟 100ms，丢包 1%）<br>2. 执行发布动态、加载 Feed、保存训练 | 所有操作最终成功（允许重试）；超时有友好提示；无无限 Loading | P1 | 性能 |

### 性能测试执行命令参考

```bash
# Profile 模式启动（性能分析）
flutter run --profile

# 打开 DevTools
flutter pub global activate devtools
flutter pub global run devtools

# 内存 snapshot
# 在 DevTools > Memory > Take Heap Snapshot

# Network Link Conditioner (macOS)
# System Preferences → Network Link Conditioner → 3G Profile
```

### 性能基线记录表

| 指标 | iOS 基线 | Android 基线 | 实测 iOS | 实测 Android | 结果 |
|------|----------|-------------|----------|-------------|------|
| 冷启动 | ≤ 3s | ≤ 4s | ___ s | ___ s | ☐ Pass / ☐ Fail |
| Feed 首屏 | ≤ 1.5s | ≤ 2s | ___ s | ___ s | ☐ Pass / ☐ Fail |
| 滑动帧率 | ≥ 55fps | ≥ 50fps | ___ fps | ___ fps | ☐ Pass / ☐ Fail |
| 地图 50 点 | ≤ 2s | ≤ 3s | ___ s | ___ s | ☐ Pass / ☐ Fail |
| 9 图上传 | ≤ 15s | ≤ 15s | ___ s | ___ s | ☐ Pass / ☐ Fail |
| Tab 切换内存增量 | ≤ 50MB | ≤ 60MB | ___ MB | ___ MB | ☐ Pass / ☐ Fail |
| 30 分钟内存泄漏 | 无趋势 | 无趋势 | ☐ 无 / ☐ 有 | ☐ 无 / ☐ 有 | ☐ Pass / ☐ Fail |
| 弱网完成率 | 100% | 100% | __% | __% | ☐ Pass / ☐ Fail |

---

## 七、安全与边界测试（16 个场景）

> **目标**: 验证数据安全、输入防护、权限控制、边界条件，确保 App 在恶意或极端操作下仍然安全稳定。

### 7.1 输入安全（5 个场景）

| ID | 场景名称 | 操作步骤 | 预期结果 | 优先级 | 类型 |
|----|----------|----------|----------|--------|------|
| SEC-01 | XSS 注入 — 动态内容 | 1. 发布动态内容输入 `<script>alert('xss')</script>`<br>2. 查看 Feed | 内容作为纯文本显示（HTML 转义）；无脚本执行 | P0 | 安全 |
| SEC-02 | SQL 注入 — 搜索字段 | 1. 训练馆搜索输入 `'; DROP TABLE gyms; --`<br>2. 提交搜索 | 搜索正常返回空结果或无匹配；数据库表完好；无错误 500 | P0 | 安全 |
| SEC-03 | 超长文本输入 | 1. 动态输入 5000 字符文本<br>2. 昵称输入 200 字符<br>3. 提交 | 前端应有长度限制（截断或提示）；后端不崩溃；UI 不溢出 | P1 | 边界 |
| SEC-04 | 特殊字符输入 | 1. 动态内容输入 emoji 组合 `🏋️‍♀️💪🔥\n\t\r\0`<br>2. 昵称输入 `用户"<>&'` | 保存成功；显示正确（特殊字符被正确转义或保留）；无崩溃 | P1 | 边界 |
| SEC-05 | Unicode 边界字符 | 1. 输入零宽字符 `\u200B\u200C\u200D`<br>2. 输入 RTL 控制符 `\u200F`<br>3. 输入超长 emoji 序列 `👨‍👩‍👧‍👦` | 存储与显示正常；文本长度计算准确；不影响布局 | P2 | 边界 |

### 7.2 认证与权限安全（4 个场景）

| ID | 场景名称 | 操作步骤 | 预期结果 | 优先级 | 类型 |
|----|----------|----------|----------|--------|------|
| SEC-06 | Token 过期自动刷新 | 1. 登录成功<br>2. 手动将 Supabase access_token TTL 设为 10s<br>3. 等待 token 过期<br>4. 执行操作（发布/加载） | 自动刷新 token；操作无感知中断；不弹出登录页 | P0 | 安全 |
| SEC-07 | 越权访问他人数据 | 1. 用账号 A 登录<br>2. 构造请求尝试修改账号 B 的训练记录（直接调用 Supabase API with A's token） | RLS 策略拦截；返回 403 或空结果；B 的数据不受影响 | P0 | 安全 |
| SEC-08 | 未登录直接访问受保护页面 | 1. 未登录状态<br>2. 通过 deep link 直接访问 `/feed` `/profile` `/gym/xxx` | 自动重定向到登录页；无数据泄露 | P0 | 安全 |
| SEC-09 | 并发 Token 使用 | 1. 同一账号在两台设备同时登录<br>2. 设备 A 操作<br>3. 设备 B 操作 | 两台设备均可正常使用；或按策略踢出旧设备（取决于业务规则） | P1 | 安全 |

### 7.3 数据完整性（3 个场景）

| ID | 场景名称 | 操作步骤 | 预期结果 | 优先级 | 类型 |
|----|----------|----------|----------|--------|------|
| SEC-10 | 并发点赞同一动态 | 1. 两个账号同时对同一动态点赞<br>2. 检查点赞计数 | 计数精确为 2；无重复记录；数据库约束正确（unique: user_id + post_id） | P1 | 安全 |
| SEC-11 | 重复提交防护 — 发布动态 | 1. 快速连续点击发布按钮 5 次 | 仅创建 1 条动态；按钮点击后立即禁用/显示 loading | P0 | 安全 |
| SEC-12 | 数据导出完整性 | 1. 创建多种类型数据（训练、动态、收藏、挑战）<br>2. 导出个人数据<br>3. 验证 JSON 文件 | JSON 包含所有个人数据类别；字段完整；无其他用户数据混入 | P1 | 安全 |

### 7.4 边界条件与异常（4 个场景）

| ID | 场景名称 | 操作步骤 | 预期结果 | 优先级 | 类型 |
|----|----------|----------|----------|--------|------|
| SEC-13 | 磁盘空间不足时拍照 | 1. 模拟设备存储已满<br>2. 尝试拍照上传训练照片 | 友好错误提示「存储空间不足」；不崩溃 | P2 | 边界 |
| SEC-14 | 训练时长边界值 | 1. 时长输入 0 分钟<br>2. 时长输入 1440 分钟（24 小时）<br>3. 时长输入负数 `-5`<br>4. 时长输入非数字 `abc` | 0 分钟：提示无效或允许（依业务）；1440：允许保存；负数：拒绝；非数字：输入框不接受 | P1 | 边界 |
| SEC-15 | 挑战赛日期边界 | 1. 创建挑战：开始日期 > 结束日期<br>2. 创建挑战：开始日期 = 过去日期<br>3. 创建挑战：时间跨度 365 天 | 日期倒置：提交失败并提示；过去日期：拒绝或自动修正；365 天：允许 | P1 | 边界 |
| SEC-16 | 网络切换中保存操作 | 1. 开始保存训练记录<br>2. 保存过程中切换 Wi-Fi → 蜂窝网络 | 操作最终成功（底层 HTTP 重试）或明确失败提示；数据不丢失不重复 | P1 | 边界 |

### 安全测试汇总

| 类别 | 场景数 | P0 | P1 | P2 |
|------|--------|----|----|-----|
| 输入安全 | 5 | 2 | 2 | 1 |
| 认证与权限 | 4 | 3 | 1 | 0 |
| 数据完整性 | 3 | 1 | 2 | 0 |
| 边界条件 | 4 | 0 | 3 | 1 |
| **合计** | **16** | **6** | **8** | **2** |

---

## Part 2 全量统计

| 章节 | 场景数 | P0 | P1 | P2 |
|------|--------|----|----|-----|
| 五、自动化集成测试 | 12 | 12 | 0 | 0 |
| 六、性能与负载测试 | 8 | 2 | 6 | 0 |
| 七、安全与边界测试 | 16 | 6 | 8 | 2 |
| **Part 2 合计** | **36** | **20** | **14** | **2** |

### Part 1 + Part 2 总计

| 维度 | 数量 |
|------|------|
| 手动集成测试用例（Part 1） | 75 |
| 自动化集成测试（Part 2） | 12 |
| 性能测试场景（Part 2） | 8 |
| 安全与边界测试（Part 2） | 16 |
| **总计** | **111** |

> **Part 2 结束** — 共 36 个补充测试场景（12 自动化 + 8 性能 + 16 安全）。Part 3 将包含：国际化专项测试、通过标准、执行记录表、CI/CD 配置、排期与发布前 Checklist。

---

## Part 3 概览

> Part 3 包含五大章节：国际化与可访问性专项测试（第八章）、测试通过标准与缺陷管理（第九章）、执行记录表模板（第十章）、CI/CD 集成与自动化流水线（第十一章）、测试排期与发布前 Checklist（第十二章）。

---

## 八、国际化与可访问性专项测试

> **说明**: VerveForge 当前支持简体中文（zh-CN）、English（en）、繁體中文（zh-TW）三种语言。本章针对语言切换、文本渲染、布局适配、无障碍（a11y）进行系统化测试。

### 8.1 语言覆盖矩阵

| 编号 | 页面/组件 | zh-CN | en | zh-TW | 验证重点 |
|------|-----------|:-----:|:--:|:-----:|----------|
| L01 | 隐私政策弹窗 | ✅ | ✅ | ✅ | 全文翻译完整，无硬编码中文 |
| L02 | 登录/注册页 | ✅ | ✅ | ✅ | 按钮文本、placeholder、错误提示 |
| L03 | 首页 Feed 3 Tab | ✅ | ✅ | ✅ | Tab 标题、空状态提示、timeAgo |
| L04 | 发布动态页 | ✅ | ✅ | ✅ | 输入框 hint、字数统计文案、Toast |
| L05 | 训练日志列表 | ✅ | ✅ | ✅ | 筛选器标签、日期格式（yyyy-MM-dd vs MM/dd/yyyy） |
| L06 | 训练日志详情 | ✅ | ✅ | ✅ | 运动类型名称、单位（公里/km）、时长格式 |
| L07 | 挑战赛页面 | ✅ | ✅ | ✅ | 状态标签（进行中/Ongoing/進行中）、排行文案 |
| L08 | 训练馆详情 | ✅ | ✅ | ✅ | 地址、营业时间标签、评价 placeholder |
| L09 | 个人中心/设置 | ✅ | ✅ | ✅ | 所有设置项名称、版本号格式 |
| L10 | 所有弹窗/对话框 | ✅ | ✅ | ✅ | 确认/取消按钮、警告文案、底部弹窗标题 |
| L11 | 系统通知/Push | ✅ | ✅ | ✅ | 通知标题与正文跟随系统语言 |
| L12 | 错误页/空状态 | ✅ | ✅ | ✅ | 404、网络错误、列表为空的插图文案 |

### 8.2 国际化功能测试用例

| 编号 | 场景 | 前置条件 | 测试步骤 | 预期结果 | 优先级 | 预计耗时(min) |
|------|------|----------|----------|----------|--------|:------------:|
| I18N-01 | 冷启动默认语言 | 系统语言为英文的设备 | 1. 首次安装并启动 App | App 跟随系统语言显示英文；若系统语言不在支持列表则回退 zh-CN | P0 | 3 |
| I18N-02 | 运行时切换语言（zh→en） | 已登录，当前中文 | 1. 进入设置 → 语言<br>2. 选择 English<br>3. 返回首页 | 所有页面即时切换为英文，无需重启；NavigationBar 标签为英文 | P0 | 5 |
| I18N-03 | 运行时切换语言（en→zh-TW） | 当前英文 | 1. 设置 → Language → 繁體中文<br>2. 浏览 Feed、训练日志、挑战赛 | 全局文案切换为繁体；简体字零残留 | P1 | 5 |
| I18N-04 | 切换语言后数据保持 | 有已发布动态和训练记录 | 1. 切换语言<br>2. 检查动态内容和训练记录 | 用户生成内容（UGC）原样展示不翻译；仅 UI 标签切换 | P0 | 3 |
| I18N-05 | 日期格式本地化 | 有训练记录 | 1. 中文模式查看日期<br>2. 切换英文查看同一日期 | zh-CN: `2026年3月7日` 或 `2026-03-07`；en: `Mar 7, 2026` 或 `03/07/2026` | P1 | 3 |
| I18N-06 | 数字与单位本地化 | 训练记录含距离/时长 | 1. 中文模式查看<br>2. 英文模式查看 | zh-CN: `5.2 公里 · 35 分钟`；en: `5.2 km · 35 min` | P1 | 3 |
| I18N-07 | 长文本溢出验证（英文） | 英文模式 | 1. 浏览所有核心页面<br>2. 重点关注按钮、Tab、卡片标题 | 无文本截断、溢出或换行导致的布局错乱；英文通常比中文长 30-50% | P1 | 8 |
| I18N-08 | 长文本溢出验证（繁体） | 繁体中文模式 | 1. 浏览所有核心页面 | 繁体字宽度与简体一致，布局不受影响 | P2 | 5 |
| I18N-09 | 多语言键盘输入 | 英文模式 | 1. 发布动态输入中文内容<br>2. 训练日志备注输入日文/Emoji | 输入法切换不影响 App 语言；中文内容正常保存和显示 | P2 | 3 |
| I18N-10 | 语言偏好持久化 | 设置为英文 | 1. 杀掉 App<br>2. 冷启动 | 重启后仍为英文，不回退到中文 | P0 | 2 |
| I18N-11 | 未翻译 key 兜底 | 故意移除一个 en 翻译 key（开发环境） | 1. 切换到英文<br>2. 查看对应页面 | 显示 zh-CN 兜底文案，不显示 raw key（如 `feed.tab.following`） | P2 | 3 |
| I18N-12 | 复数与插值（Plural/Interpolation） | 英文模式 | 1. 查看「3 条评论」场景<br>2. 查看「1 条评论」场景 | en: `3 comments` / `1 comment`（正确复数）；zh: `3 条评论` / `1 条评论` | P2 | 3 |

### 8.3 可访问性（Accessibility）测试用例

| 编号 | 场景 | 测试步骤 | 预期结果 | 优先级 | 平台 |
|------|------|----------|----------|--------|------|
| A11Y-01 | VoiceOver 基础导航 | 1. 开启 iOS VoiceOver<br>2. 从首页依次滑动浏览 | 所有可交互元素有 Semantics 标签；图片有 alt 描述；Tab 报读正确 | P2 | iOS |
| A11Y-02 | TalkBack 基础导航 | 1. 开启 Android TalkBack<br>2. 浏览 Feed 和训练馆 | 同 A11Y-01 在 Android 上的表现 | P2 | Android |
| A11Y-03 | 动态字体（Dynamic Type） | 1. iOS 设置 → 辅助功能 → 更大字体<br>2. 将字体调至最大<br>3. 浏览核心页面 | 文本随系统字号放大；布局不重叠不截断；按钮仍可点击 | P2 | iOS |
| A11Y-04 | 色彩对比度 | 使用 Accessibility Inspector 检查 | 文本/背景对比度 ≥ 4.5:1（AA 标准）；深色/浅色模式均满足 | P3 | 全平台 |
| A11Y-05 | 触控目标尺寸 | 检查所有按钮和可点击区域 | 最小触控目标 44×44pt (iOS) / 48×48dp (Android) | P3 | 全平台 |
| A11Y-06 | 减弱动画模式 | 1. 开启「减弱动态效果」<br>2. 浏览页面切换和弹窗 | 页面转场使用渐变替代滑动；无闪烁动画 | P3 | iOS |

### 8.4 国际化与可访问性测试汇总

| 类别 | 场景数 | P0 | P1 | P2 | P3 |
|------|--------|----|----|----|----|
| 国际化功能测试 | 12 | 4 | 4 | 4 | 0 |
| 可访问性测试 | 6 | 0 | 0 | 3 | 3 |
| **合计** | **18** | **4** | **4** | **7** | **3** |

---

## 九、测试通过标准与缺陷管理

### 9.1 测试通过标准（Exit Criteria）

#### 9.1.1 分级通过标准

| 级别 | 标准名称 | 指标要求 | 是否阻塞发布 |
|------|----------|----------|:----------:|
| **L1** | 单元测试 | 219 tests 全部 PASS，0 failures，0 errors | 是 |
| **L2** | 静态分析 | `flutter analyze` 零 warning、零 error | 是 |
| **L3** | 自动化集成测试 | 12 个 AT 用例全部 PASS | 是 |
| **L4** | 手动集成测试 P0 | 25 个 P0 用例：通过率 **100%** | 是 |
| **L5** | 手动集成测试 P1 | 30 个 P1 用例：通过率 **≥ 95%**（允许 ≤1 个已知问题并有 Workaround） | 是 |
| **L6** | 手动集成测试 P2/P3 | P2 通过率 ≥ 90%；P3 不阻塞 | 否 |
| **L7** | 性能测试 | 8 个场景全部达标（见第六章基准值） | 是 |
| **L8** | 安全测试 P0 | 6 个 P0 安全用例全部 PASS | 是 |
| **L9** | 代码覆盖率 | `flutter test --coverage` 行覆盖率 **≥ 85%** | 是 |
| **L10** | 国际化 P0 | 4 个 P0 国际化用例全部 PASS | 是 |

#### 9.1.2 发布门禁判定矩阵

| 条件 | Alpha 内测 | Beta 公测 | 正式发布 (GA) |
|------|:----------:|:---------:|:------------:|
| L1 单元测试 100% | ✅ 必须 | ✅ 必须 | ✅ 必须 |
| L2 静态分析 0 issue | ✅ 必须 | ✅ 必须 | ✅ 必须 |
| L3 自动化集成 100% | ⚠️ ≥ 80% | ✅ 必须 | ✅ 必须 |
| L4 P0 手动 100% | ✅ 必须 | ✅ 必须 | ✅ 必须 |
| L5 P1 手动 ≥ 95% | ⚠️ ≥ 80% | ✅ 必须 | ✅ 必须 |
| L6 P2/P3 手动 | ⬜ 不要求 | ⚠️ P2 ≥ 80% | ✅ P2 ≥ 90% |
| L7 性能达标 | ⬜ 不要求 | ⚠️ 核心 4 项 | ✅ 全部 8 项 |
| L8 安全 P0 100% | ⚠️ ≥ 50% | ✅ 必须 | ✅ 必须 |
| L9 覆盖率 ≥ 85% | ⬜ 不要求 | ⚠️ ≥ 75% | ✅ ≥ 85% |
| L10 国际化 P0 100% | ⬜ 不要求 | ✅ 必须 | ✅ 必须 |

> 图例：✅ 必须达标 | ⚠️ 建议达标（未达标需 Tech Lead 签字豁免）| ⬜ 不要求

### 9.2 缺陷分级定义

| 严重等级 | 标签 | 定义 | 响应时间 | 修复时限 | 示例 |
|----------|------|------|----------|----------|------|
| **P0 - 阻塞** | `blocker` | 核心功能不可用 / 数据丢失 / 崩溃 / 安全漏洞 | 立即 | **4 小时** | 登录崩溃；训练记录保存后丢失；XSS 注入成功 |
| **P1 - 严重** | `critical` | 主要功能异常但有绕行方案 / 影响多数用户 | 2 小时 | **1 工作日** | 点赞后数字不更新（刷新后正常）；挑战排行榜排序错误 |
| **P2 - 一般** | `major` | 次要功能异常 / 影响少数用户 / UI 明显问题 | 4 小时 | **3 工作日** | 深色模式某卡片背景色不对；英文模式某按钮文字截断 |
| **P3 - 轻微** | `minor` | 体验优化 / 文案建议 / 极端边界场景 | 下一迭代 | **下一版本** | 色彩对比度不足；timeAgo 复数不正确 |

### 9.3 缺陷生命周期

```
[新建] → [已确认] → [修复中] → [已修复] → [验证通过] → [关闭]
           ↓                        ↓
       [拒绝/重复]              [验证失败] → [重新打开]
```

| 状态 | 责任人 | 操作说明 |
|------|--------|----------|
| 新建（Open） | QA | 按模板填写，附截图/录屏/日志，关联用例编号 |
| 已确认（Confirmed） | Tech Lead | 确认为有效 Bug，指定优先级和负责人 |
| 修复中（In Progress） | 开发 | 创建修复分支 `fix/<BUG-ID>` |
| 已修复（Fixed） | 开发 | 提交 PR 并注明关联 Bug ID |
| 验证通过（Verified） | QA | 在对应环境回归验证通过 |
| 关闭（Closed） | QA | 确认修复，关闭 Issue |
| 重新打开（Reopened） | QA | 验证失败或复现，附新的复现步骤 |

### 9.4 缺陷报告模板

```markdown
### Bug 标题: [模块] 简要描述

**缺陷编号**: BUG-XXXX
**关联用例**: A01 / AT-03 / PERF-02（填写触发此 Bug 的测试用例编号）
**严重等级**: P0 / P1 / P2 / P3
**发现环境**: iOS 18.3 / iPhone 15 Pro / v1.0.0-beta.1

#### 复现步骤
1. 步骤一
2. 步骤二
3. 步骤三

#### 预期结果
描述应有的行为

#### 实际结果
描述实际的行为（附截图/录屏）

#### 日志/堆栈
```
粘贴关键日志
```

#### 附件
- [ ] 截图
- [ ] 录屏
- [ ] 设备日志（flutter logs）
```

### 9.5 缺陷度量指标

| 指标 | 计算公式 | 目标值 | 用途 |
|------|----------|--------|------|
| 缺陷密度 | 总 Bug 数 / 功能模块数 | ≤ 3 per module | 识别高风险模块 |
| P0 逃逸率 | 发布后 P0 / 发布前 P0 | **0%** | 测试有效性 |
| 修复周转时间 | Avg(修复时间 - 确认时间) | P0 ≤ 4h, P1 ≤ 8h | 开发响应速度 |
| 回归缺陷率 | 修复后重新打开数 / 总修复数 | ≤ 5% | 修复质量 |
| 用例有效率 | 发现 Bug 的用例数 / 总用例数 | ≥ 30% | 用例设计质量 |
| 自动化拦截率 | CI 自动发现 Bug 数 / 总 Bug 数 | ≥ 40% | 自动化 ROI |

### 9.6 测试报告模板

每轮测试结束后输出以下报告：

```markdown
# VerveForge 集成测试报告 — Round X

**测试日期**: 2026-XX-XX
**测试版本**: v1.0.0-beta.X (build XXX)
**测试人员**: XXX
**测试环境**: iOS 18.3 / iPhone 15 Pro + Android 14 / Pixel 7

## 执行概况

| 维度 | 总数 | 通过 | 失败 | 阻塞 | 跳过 | 通过率 |
|------|------|------|------|------|------|--------|
| P0 手动用例 | 25 | — | — | — | — | —% |
| P1 手动用例 | 30 | — | — | — | — | —% |
| P2/P3 手动用例 | 11 | — | — | — | — | —% |
| 自动化集成 | 12 | — | — | — | — | —% |
| 性能测试 | 8 | — | — | — | — | —% |
| 安全测试 | 16 | — | — | — | — | —% |
| 国际化测试 | 12 | — | — | — | — | —% |

## 发布门禁检查

| 门禁项 | 状态 | 备注 |
|--------|------|------|
| L1 单元测试 | ✅/❌ | |
| L2 静态分析 | ✅/❌ | |
| ... | ... | ... |

## 新发现缺陷

| Bug ID | 标题 | 等级 | 模块 | 状态 |
|--------|------|------|------|------|
| BUG-XXXX | ... | P0 | Feed | 修复中 |

## 遗留风险

1. ...

## 结论

[ ] 建议发布 / [ ] 建议延迟发布 / [ ] 需要额外回归
```

---

## 十、执行记录表模板

> **使用说明**: 以下表格覆盖全部 **129 个测试场景**（75 手动 + 12 自动化 + 8 性能 + 16 安全 + 18 国际化/可访问性）。测试人员直接复制到 Excel / Notion / 飞书多维表格中使用，每轮测试填写一份。
>
> **状态填写规范**: ✅ 通过 | ❌ 失败 | ⏭️ 跳过 | 🚫 阻塞 | ⏳ 待执行

### 10.1 手动集成测试执行记录（75 用例）

#### A. 启动与隐私合规（8 用例）

| 编号 | 场景 | 优先级 | 执行人 | 执行日期 | 状态 | Bug ID | 备注 |
|------|------|--------|--------|----------|------|--------|------|
| A01 | 首次安装冷启动隐私弹窗 | P0 | | | ⏳ | | |
| A02 | 拒绝隐私协议后行为 | P0 | | | ⏳ | | |
| A03 | 同意后二次启动不再弹窗 | P0 | | | ⏳ | | |
| A04 | 引导流完整走通 | P0 | | | ⏳ | | |
| A05 | 隐私弹窗链接可点击跳转 | P1 | | | ⏳ | | |
| A06 | 卸载重装重新触发弹窗 | P2 | | | ⏳ | | |
| A07 | 弱网下隐私弹窗加载 | P2 | | | ⏳ | | |
| A08 | 隐私设置页手动撤回同意 | P2 | | | ⏳ | | |

#### B. 首页 Feed（12 用例）

| 编号 | 场景 | 优先级 | 执行人 | 执行日期 | 状态 | Bug ID | 备注 |
|------|------|--------|--------|----------|------|--------|------|
| B01 | 3 Tab 切换与数据隔离 | P0 | | | ⏳ | | |
| B02 | 下拉刷新加载最新动态 | P0 | | | ⏳ | | |
| B03 | 上拉加载更多（分页） | P0 | | | ⏳ | | |
| B04 | 发布纯文字动态 | P0 | | | ⏳ | | |
| B05 | 发布带图片动态 | P1 | | | ⏳ | | |
| B06 | 点赞/取消点赞 | P1 | | | ⏳ | | |
| B07 | 评论发布与显示 | P1 | | | ⏳ | | |
| B08 | 删除自己的动态 | P1 | | | ⏳ | | |
| B09 | 动态详情页跳转 | P1 | | | ⏳ | | |
| B10 | 空状态展示（无动态） | P2 | | | ⏳ | | |
| B11 | Feed 图片预览与手势缩放 | P1 | | | ⏳ | | |
| B12 | 动态中 @用户 / #话题 跳转 | P1 | | | ⏳ | | |

#### C. 训练日志（9 用例）

| 编号 | 场景 | 优先级 | 执行人 | 执行日期 | 状态 | Bug ID | 备注 |
|------|------|--------|--------|----------|------|--------|------|
| C01 | 创建训练记录（完整字段） | P0 | | | ⏳ | | |
| C02 | 编辑已有训练记录 | P0 | | | ⏳ | | |
| C03 | 删除训练记录 | P1 | | | ⏳ | | |
| C04 | 训练照片上传与查看 | P1 | | | ⏳ | | |
| C05 | HealthKit 数据同步 | P1 | | | ⏳ | | |
| C06 | 运动专项字段验证 | P1 | | | ⏳ | | |
| C07 | 训练列表筛选与排序 | P1 | | | ⏳ | | |
| C08 | 训练统计图表展示 | P2 | | | ⏳ | | |
| C09 | 离线创建训练记录 | P1 | | | ⏳ | | |

#### D. 挑战赛（8 用例）

| 编号 | 场景 | 优先级 | 执行人 | 执行日期 | 状态 | Bug ID | 备注 |
|------|------|--------|--------|----------|------|--------|------|
| D01 | 创建挑战赛 | P0 | | | ⏳ | | |
| D02 | 参加挑战赛 | P0 | | | ⏳ | | |
| D03 | 挑战打卡记录 | P0 | | | ⏳ | | |
| D04 | 排行榜展示与排序 | P1 | | | ⏳ | | |
| D05 | 挑战详情页信息完整性 | P1 | | | ⏳ | | |
| D06 | 已结束挑战的状态展示 | P2 | | | ⏳ | | |
| D07 | 退出挑战 | P2 | | | ⏳ | | |
| D08 | 挑战赛分享 | P1 | | | ⏳ | | |

#### E. 训练馆（10 用例）

| 编号 | 场景 | 优先级 | 执行人 | 执行日期 | 状态 | Bug ID | 备注 |
|------|------|--------|--------|----------|------|--------|------|
| E01 | 地图模式展示训练馆 | P0 | | | ⏳ | | |
| E02 | 列表模式展示训练馆 | P0 | | | ⏳ | | |
| E03 | 训练馆详情页完整信息 | P0 | | | ⏳ | | |
| E04 | 提交训练馆评价 | P0 | | | ⏳ | | |
| E05 | 收藏/取消收藏训练馆 | P1 | | | ⏳ | | |
| E06 | 馆主认领流程 | P1 | | | ⏳ | | |
| E07 | 按距离/评分排序 | P1 | | | ⏳ | | |
| E08 | 按类型/标签筛选 | P1 | | | ⏳ | | |
| E09 | 定位权限拒绝后降级 | P1 | | | ⏳ | | |
| E10 | 训练馆搜索 | P1 | | | ⏳ | | |

#### F. 个人中心（7 用例）

| 编号 | 场景 | 优先级 | 执行人 | 执行日期 | 状态 | Bug ID | 备注 |
|------|------|--------|--------|----------|------|--------|------|
| F01 | 编辑个人资料 | P0 | | | ⏳ | | |
| F02 | 修改头像 | P0 | | | ⏳ | | |
| F03 | 隐私设置三层控制 | P0 | | | ⏳ | | |
| F04 | 收藏列表查看与跳转 | P1 | | | ⏳ | | |
| F05 | 数据导出功能 | P1 | | | ⏳ | | |
| F06 | 退出登录 | P2 | | | ⏳ | | |
| F07 | 注销账户 | P1 | | | ⏳ | | |

#### G. 主题切换（5 用例）

| 编号 | 场景 | 优先级 | 执行人 | 执行日期 | 状态 | Bug ID | 备注 |
|------|------|--------|--------|----------|------|--------|------|
| G01 | 浅色→深色切换 | P0 | | | ⏳ | | |
| G02 | 深色→浅色切换 | P0 | | | ⏳ | | |
| G03 | 跟随系统主题 | P1 | | | ⏳ | | |
| G04 | 深色模式全组件一致性 | P1 | | | ⏳ | | |
| G05 | 主题偏好持久化 | P2 | | | ⏳ | | |

#### H. 跨模块交互（8 用例）

| 编号 | 场景 | 优先级 | 执行人 | 执行日期 | 状态 | Bug ID | 备注 |
|------|------|--------|--------|----------|------|--------|------|
| H01 | 「+」按钮双入口路由 | P0 | | | ⏳ | | |
| H02 | Feed→训练日志详情跳转 | P0 | | | ⏳ | | |
| H03 | 训练馆→发布动态联动 | P1 | | | ⏳ | | |
| H04 | 挑战打卡→训练日志关联 | P1 | | | ⏳ | | |
| H05 | 个人中心→收藏→训练馆跳转 | P1 | | | ⏳ | | |
| H06 | 深层返回栈一致性（5 层） | P1 | | | ⏳ | | |
| H07 | 数据变更后列表实时同步 | P1 | | | ⏳ | | |
| H08 | NavigationBar 状态高亮同步 | P2 | | | ⏳ | | |

#### I. 国际化与布局（8 用例）

| 编号 | 场景 | 优先级 | 执行人 | 执行日期 | 状态 | Bug ID | 备注 |
|------|------|--------|--------|----------|------|--------|------|
| I01 | 中→英语言切换全局验证 | P0 | | | ⏳ | | |
| I02 | 英→繁体切换全局验证 | P1 | | | ⏳ | | |
| I03 | 繁体→中切换回退验证 | P1 | | | ⏳ | | |
| I04 | 英文模式长文本布局 | P1 | | | ⏳ | | |
| I05 | 小屏设备布局适配 | P1 | | | ⏳ | | |
| I06 | Android 布局差异验证 | P1 | | | ⏳ | | |
| I07 | 切换语言后弹窗文本 | P2 | | | ⏳ | | |
| I08 | timeAgo 本地化 | P3 | | | ⏳ | | |

---

### 10.2 自动化集成测试执行记录（12 用例）

| 编号 | 场景 | 对应手动 | 执行方式 | 最近运行时间 | 状态 | 耗时(s) | 失败日志 |
|------|------|----------|----------|-------------|------|---------|----------|
| AT-01 | 冷启动隐私弹窗→同意→登录 | A01, A03 | CI 自动 | | ⏳ | | |
| AT-02 | 登录→Feed 加载→Tab 切换 | B01 | CI 自动 | | ⏳ | | |
| AT-03 | 发布动态完整流程 | B04, B05 | CI 自动 | | ⏳ | | |
| AT-04 | 训练日志 CRUD | C01, C02, C03 | CI 自动 | | ⏳ | | |
| AT-05 | 挑战赛创建→参加→打卡 | D01, D02, D03 | CI 自动 | | ⏳ | | |
| AT-06 | 训练馆列表+详情+收藏 | E02, E03, E05 | CI 自动 | | ⏳ | | |
| AT-07 | 深色/浅色主题切换 | G01, G02 | CI 自动 | | ⏳ | | |
| AT-08 | 个人资料编辑+头像更换 | F01, F02 | CI 自动 | | ⏳ | | |
| AT-09 | 隐私三层控制 | F03 | CI 自动 | | ⏳ | | |
| AT-10 | 语言切换完整链路 | I01, I02, I03 | CI 自动 | | ⏳ | | |
| AT-11 | 「+」按钮双入口路由 | H01, H08 | CI 自动 | | ⏳ | | |
| AT-12 | 馆主认领完整流程 | E06 | CI 自动 | | ⏳ | | |

---

### 10.3 性能测试执行记录（8 场景）

| 编号 | 场景 | 基准值 | 执行人 | 执行日期 | 实测值 | 状态 | 备注 |
|------|------|--------|--------|----------|--------|------|------|
| PERF-01 | 冷启动时间 | ≤ 2s | | | — | ⏳ | |
| PERF-02 | Feed 首屏渲染 | ≤ 1s | | | — | ⏳ | |
| PERF-03 | 滚动帧率（Feed 200条） | ≥ 55fps | | | — | ⏳ | |
| PERF-04 | 图片加载（训练馆列表） | ≤ 800ms | | | — | ⏳ | |
| PERF-05 | 训练记录保存响应 | ≤ 500ms | | | — | ⏳ | |
| PERF-06 | 内存占用峰值 | ≤ 300MB | | | — | ⏳ | |
| PERF-07 | 后台→前台恢复 | ≤ 500ms | | | — | ⏳ | |
| PERF-08 | 批量操作（50 条训练导出） | ≤ 5s | | | — | ⏳ | |

---

### 10.4 安全与边界测试执行记录（16 场景）

| 编号 | 场景 | 类别 | 优先级 | 执行人 | 执行日期 | 状态 | Bug ID | 备注 |
|------|------|------|--------|--------|----------|------|--------|------|
| SEC-01 | XSS 脚本注入（动态发布） | 输入安全 | P0 | | | ⏳ | | |
| SEC-02 | SQL 注入（搜索框） | 输入安全 | P0 | | | ⏳ | | |
| SEC-03 | 超长文本输入（10000 字） | 输入安全 | P1 | | | ⏳ | | |
| SEC-04 | 特殊字符输入（Emoji+零宽字符） | 输入安全 | P1 | | | ⏳ | | |
| SEC-05 | 恶意图片上传（非图片文件改后缀） | 输入安全 | P2 | | | ⏳ | | |
| SEC-06 | Token 过期后操作 | 认证权限 | P0 | | | ⏳ | | |
| SEC-07 | 篡改他人数据（越权访问） | 认证权限 | P0 | | | ⏳ | | |
| SEC-08 | 并发请求幂等性 | 认证权限 | P0 | | | ⏳ | | |
| SEC-09 | 未登录访问受保护页面 | 认证权限 | P1 | | | ⏳ | | |
| SEC-10 | 本地存储敏感信息检查 | 数据完整 | P0 | | | ⏳ | | |
| SEC-11 | 多设备登录数据一致性 | 数据完整 | P1 | | | ⏳ | | |
| SEC-12 | 并发编辑同一记录 | 数据完整 | P1 | | | ⏳ | | |
| SEC-13 | 磁盘空间不足时拍照 | 边界条件 | P2 | | | ⏳ | | |
| SEC-14 | 训练时长边界值 | 边界条件 | P1 | | | ⏳ | | |
| SEC-15 | 挑战赛日期边界 | 边界条件 | P1 | | | ⏳ | | |
| SEC-16 | 网络切换中保存操作 | 边界条件 | P1 | | | ⏳ | | |

---

### 10.5 国际化与可访问性测试执行记录（18 场景）

#### 国际化功能测试（12 用例）

| 编号 | 场景 | 优先级 | 执行人 | 执行日期 | 状态 | Bug ID | 备注 |
|------|------|--------|--------|----------|------|--------|------|
| I18N-01 | 冷启动默认语言 | P0 | | | ⏳ | | |
| I18N-02 | 运行时切换语言（zh→en） | P0 | | | ⏳ | | |
| I18N-03 | 运行时切换语言（en→zh-TW） | P1 | | | ⏳ | | |
| I18N-04 | 切换语言后数据保持 | P0 | | | ⏳ | | |
| I18N-05 | 日期格式本地化 | P1 | | | ⏳ | | |
| I18N-06 | 数字与单位本地化 | P1 | | | ⏳ | | |
| I18N-07 | 长文本溢出验证（英文） | P1 | | | ⏳ | | |
| I18N-08 | 长文本溢出验证（繁体） | P2 | | | ⏳ | | |
| I18N-09 | 多语言键盘输入 | P2 | | | ⏳ | | |
| I18N-10 | 语言偏好持久化 | P0 | | | ⏳ | | |
| I18N-11 | 未翻译 key 兜底 | P2 | | | ⏳ | | |
| I18N-12 | 复数与插值 | P2 | | | ⏳ | | |

#### 可访问性测试（6 用例）

| 编号 | 场景 | 优先级 | 平台 | 执行人 | 执行日期 | 状态 | 备注 |
|------|------|--------|------|--------|----------|------|------|
| A11Y-01 | VoiceOver 基础导航 | P2 | iOS | | | ⏳ | |
| A11Y-02 | TalkBack 基础导航 | P2 | Android | | | ⏳ | |
| A11Y-03 | 动态字体（Dynamic Type） | P2 | iOS | | | ⏳ | |
| A11Y-04 | 色彩对比度 | P3 | 全平台 | | | ⏳ | |
| A11Y-05 | 触控目标尺寸 | P3 | 全平台 | | | ⏳ | |
| A11Y-06 | 减弱动画模式 | P3 | iOS | | | ⏳ | |

---

### 10.6 执行记录汇总表

> 每轮测试结束后填写此汇总表，用于快速评估是否满足发布门禁。

| 测试类别 | 总数 | ✅ 通过 | ❌ 失败 | 🚫 阻塞 | ⏭️ 跳过 | ⏳ 待执行 | 通过率 |
|----------|------|---------|---------|---------|---------|----------|--------|
| 手动集成 P0 | 25 | | | | | 25 | —% |
| 手动集成 P1 | 30 | | | | | 30 | —% |
| 手动集成 P2 | 10 | | | | | 10 | —% |
| 手动集成 P3 | 1 | | | | | 1 | —% |
| 自动化集成 | 12 | | | | | 12 | —% |
| 性能测试 | 8 | | | | | 8 | —% |
| 安全与边界 | 16 | | | | | 16 | —% |
| 国际化功能 | 12 | | | | | 12 | —% |
| 可访问性 | 6 | | | | | 6 | —% |
| **总计** | **129** | | | | | **129** | **—%** |

| 签字项 | 姓名 | 日期 | 意见 |
|--------|------|------|------|
| 测试负责人 | | | |
| 开发负责人 | | | |
| Tech Lead | | | |

---

## 十一、测试执行时间估算与排期建议

### 11.1 单场景耗时估算

| 测试类别 | 场景数 | 单场景平均耗时 | 小计（分钟） | 说明 |
|----------|--------|:--------------:|:------------:|------|
| 手动集成 P0 | 25 | 8 min | 200 | 含环境准备、截图取证 |
| 手动集成 P1 | 30 | 6 min | 180 | 部分依赖 P0 前置 |
| 手动集成 P2 | 10 | 5 min | 50 | 优先级较低，可并行 |
| 手动集成 P3 | 1 | 3 min | 3 | 体验优化类 |
| 自动化集成（首次调试） | 12 | 15 min | 180 | 含编写/调试/稳定化 |
| 自动化集成（CI 运行） | 12 | 2 min | 24 | CI 上自动执行 |
| 性能测试 | 8 | 12 min | 96 | 含多轮采样取均值 |
| 安全与边界测试 | 16 | 8 min | 128 | 含构造异常输入 |
| 国际化功能测试 | 12 | 5 min | 60 | 需切换语言反复验证 |
| 可访问性测试 | 6 | 10 min | 60 | 需开启辅助功能逐页检查 |
| **手动执行总计** | **120** | — | **777 min ≈ 13h** | 不含自动化 CI 运行 |
| **含自动化调试总计** | **129** | — | **957 min ≈ 16h** | 首轮含自动化脚本调试 |

### 11.2 人天换算

> 按每工作日 **有效测试时间 6 小时**（扣除会议、Bug 记录、沟通等开销）估算。

| 方案 | 人数 | 首轮耗时 | 回归轮次耗时 | 总投入 | 适用场景 |
|------|:----:|:--------:|:----------:|:------:|----------|
| **A. 单人全量** | 1 人 | 2.7 天 | 1.5 天 | 约 4.2 人天 | 个人开发者 / 小团队 |
| **B. 双人并行** | 2 人 | 1.5 天 | 0.8 天 | 约 2.3 人天/人 | 推荐方案 |
| **C. 三人冲刺** | 3 人 | 1.0 天 | 0.5 天 | 约 1.5 人天/人 | 紧急发布 |

> **说明**: 回归轮次仅执行失败用例 + P0 全量回归 + 自动化 CI，通常为首轮的 50-60%。

### 11.3 双人并行分工建议（推荐方案 B）

| 时间段 | QA-1（iOS 主测） | QA-2（Android + 专项） |
|--------|-------------------|------------------------|
| **Day 1 上午** (3h) | A. 启动与隐私 (8) + B. Feed (12) | AT-01~12 自动化调试与稳定化 |
| **Day 1 下午** (3h) | C. 训练日志 (9) + D. 挑战赛 (8) | SEC-01~16 安全与边界测试 |
| **Day 2 上午** (3h) | E. 训练馆 (10) + F. 个人中心 (7) | PERF-01~08 性能测试 + I18N-01~12 国际化 |
| **Day 2 下午** (3h) | G. 主题 (5) + H. 跨模块 (8) + I. 布局 (8) | A11Y-01~06 可访问性 + Android 差异验证 |
| **Day 2 晚间** | 汇总 Bug、填写执行记录 | 汇总 Bug、整理测试报告 |
| **Day 3 上午** (3h) | 首轮 Bug 回归（P0+P1） | CI 流水线验证 + 自动化全量跑 |
| **Day 3 下午** (1h) | 签字、输出最终测试报告 | 签字、归档 |

### 11.4 里程碑排期建议

> 以下假设开发已完成 code freeze，进入专项测试阶段。

| 里程碑 | 时间点 | 交付物 | 门禁 |
|--------|--------|--------|------|
| **M1: 测试准备** | T+0 | 测试环境就绪、设备矩阵确认、测试数据准备 | 环境 checklist 全绿 |
| **M2: 首轮执行** | T+1 ~ T+2 | 129 场景全量执行、Bug 提交 | — |
| **M3: Bug 修复** | T+3 ~ T+4 | P0 全部修复、P1 ≥ 90% 修复 | P0 清零 |
| **M4: 回归验证** | T+5 | 修复验证 + P0 全量回归 + CI 全绿 | L1~L5 门禁达标 |
| **M5: 发布签字** | T+6 | 测试报告 + 签字 + 提审材料 | 9.1 全部门禁通过 |

```
T+0        T+1        T+2        T+3        T+4        T+5        T+6
 │          │          │          │          │          │          │
 ▼          ▼──────────▼          ▼──────────▼          ▼          ▼
准备      首轮测试执行          Bug 修复周期        回归验证    发布签字
          (Day1-2)              (Day3-4)           (Day5)     (Day6)
```

### 11.5 风险与缓冲

| 风险 | 影响 | 缓冲策略 |
|------|------|----------|
| P0 Bug 数量超预期（>5 个） | Bug 修复周期延长 | 预留 1 天缓冲；超过阈值启动方案 C（3 人冲刺） |
| 自动化脚本不稳定（Flaky Tests） | CI 假红阻塞 | 标记 Flaky，先 skip 不阻塞；后续单独修复 |
| 设备/模拟器环境问题 | 部分用例无法执行 | 提前 Day-1 验证设备矩阵；备用云真机（Firebase Test Lab） |
| HealthKit / 定位等权限依赖 | 模拟器无法测试 | 必须使用真机；排期中优先安排 |

---

## 十二、CI/CD 集成与覆盖率报告

### 12.1 本地命令速查

| 用途 | 命令 | 说明 |
|------|------|------|
| 单元测试 | `flutter test` | 运行全部 219 个单元测试 |
| 单元测试 + 覆盖率 | `flutter test --coverage` | 生成 `coverage/lcov.info` |
| 覆盖率 HTML 报告 | `genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html` | 需安装 lcov (`brew install lcov`) |
| 静态分析 | `flutter analyze` | 零 warning 零 error |
| 集成测试（全部） | `flutter test integration_test/` | 运行 12 个自动化集成测试 |
| 集成测试（单个） | `flutter test integration_test/privacy_cold_start_test.dart` | 指定文件 |
| 集成测试（指定设备） | `flutter test integration_test/ -d "iPhone 15 Pro"` | 真机/模拟器 |
| Android 集成测试 | `flutter test integration_test/ -d emulator-5554` | Android 模拟器 |
| 性能 Profile | `flutter run --profile` | Release 模式性能采集 |

### 12.2 GitHub Actions 完整配置

> 文件路径：`.github/workflows/ci.yml`

```yaml
name: VerveForge CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

env:
  FLUTTER_VERSION: "3.27.x"
  JAVA_VERSION: "17"

jobs:
  # ──────────────────────────────────────────────
  # Job 1: 静态分析 + 单元测试 + 覆盖率
  # ──────────────────────────────────────────────
  test:
    name: "Test & Coverage"
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Static analysis
        run: flutter analyze --no-pub

      - name: Run unit tests with coverage
        run: flutter test --coverage

      - name: Check coverage threshold (≥85%)
        run: |
          TOTAL_LINES=$(grep -c "^DA:" coverage/lcov.info || echo 0)
          HIT_LINES=$(grep "^DA:" coverage/lcov.info | grep -v ",0$" | wc -l | tr -d ' ')
          if [ "$TOTAL_LINES" -eq 0 ]; then
            echo "::error::No coverage data found"
            exit 1
          fi
          COVERAGE=$(echo "scale=2; $HIT_LINES * 100 / $TOTAL_LINES" | bc)
          echo "Coverage: $COVERAGE% ($HIT_LINES/$TOTAL_LINES lines)"
          echo "coverage=$COVERAGE" >> $GITHUB_OUTPUT
          if (( $(echo "$COVERAGE < 85" | bc -l) )); then
            echo "::error::Coverage $COVERAGE% is below 85% threshold"
            exit 1
          fi

      - name: Upload coverage to Codecov
        if: always()
        uses: codecov/codecov-action@v4
        with:
          file: coverage/lcov.info
          fail_ci_if_error: false
          token: ${{ secrets.CODECOV_TOKEN }}

      - name: Upload coverage artifact
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: coverage/lcov.info
          retention-days: 30

  # ──────────────────────────────────────────────
  # Job 2: iOS 集成测试
  # ──────────────────────────────────────────────
  integration-ios:
    name: "Integration Tests (iOS)"
    runs-on: macos-latest
    timeout-minutes: 45
    needs: test
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Boot iOS Simulator
        run: |
          DEVICE_ID=$(xcrun simctl list devices available -j | \
            python3 -c "import sys,json; devs=json.load(sys.stdin)['devices']; \
            print([d['udid'] for r in devs.values() for d in r if 'iPhone 15 Pro' in d['name']][0])")
          xcrun simctl boot "$DEVICE_ID"
          echo "DEVICE_ID=$DEVICE_ID" >> $GITHUB_ENV

      - name: Run integration tests
        run: flutter test integration_test/ -d "$DEVICE_ID" --timeout 300s

      - name: Upload test results
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: ios-integration-failure
          path: build/ios_integ/
          retention-days: 7

  # ──────────────────────────────────────────────
  # Job 3: Android 集成测试
  # ──────────────────────────────────────────────
  integration-android:
    name: "Integration Tests (Android)"
    runs-on: ubuntu-latest
    timeout-minutes: 45
    needs: test
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: "temurin"
          java-version: ${{ env.JAVA_VERSION }}

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Run Android integration tests
        uses: reactivecircus/android-emulator-runner@v2
        with:
          api-level: 34
          arch: x86_64
          profile: pixel_7
          emulator-options: -no-window -no-audio -no-snapshot
          script: flutter test integration_test/ --timeout 300s

      - name: Upload test results
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: android-integration-failure
          path: build/app/outputs/
          retention-days: 7

  # ──────────────────────────────────────────────
  # Job 4: 发布门禁检查
  # ──────────────────────────────────────────────
  release-gate:
    name: "Release Gate Check"
    runs-on: ubuntu-latest
    needs: [test, integration-ios, integration-android]
    if: github.ref == 'refs/heads/main'
    steps:
      - name: All gates passed
        run: |
          echo "============================================"
          echo "  VerveForge Release Gate: ALL PASSED"
          echo "============================================"
          echo "  L1 Unit Tests:        ✅"
          echo "  L2 Static Analysis:   ✅"
          echo "  L3 Integration (iOS): ✅"
          echo "  L3 Integration (And): ✅"
          echo "  L9 Coverage ≥85%:     ✅"
          echo "============================================"
          echo "  Ready for manual test sign-off (L4-L8,L10)"
          echo "============================================"
```

### 12.3 CI 流水线结构图

```
push / PR
    │
    ▼
┌──────────────────────┐
│  Job 1: test         │
│  ├─ flutter analyze  │
│  ├─ flutter test     │
│  ├─ coverage ≥ 85%   │
│  └─ upload codecov   │
└──────────┬───────────┘
           │ needs: test
     ┌─────┴─────┐
     ▼           ▼
┌─────────┐ ┌───────────┐
│  Job 2  │ │  Job 3    │
│ iOS     │ │ Android   │
│ Integ.  │ │ Integ.    │
└────┬────┘ └─────┬─────┘
     │            │
     └─────┬──────┘
           ▼
┌──────────────────────┐
│  Job 4: release-gate │  (仅 main 分支)
│  ALL PASSED → 可签字  │
└──────────────────────┘
```

### 12.4 PR 状态检查配置

> 在 GitHub 仓库 Settings → Branches → Branch protection rules 中配置：

| 规则 | 设置 |
|------|------|
| 保护分支 | `main`, `develop` |
| Require status checks | ✅ 启用 |
| 必须通过的 Checks | `Test & Coverage`, `Integration Tests (iOS)`, `Integration Tests (Android)` |
| Require branches up to date | ✅ 启用 |
| Require PR reviews | ✅ 至少 1 人 approve |
| Dismiss stale reviews | ✅ 代码更新后取消已有 approve |

### 12.5 覆盖率徽章

在 `README.md` 中添加覆盖率徽章：

```markdown
[![codecov](https://codecov.io/gh/<OWNER>/verveforge/branch/main/graph/badge.svg)](https://codecov.io/gh/<OWNER>/verveforge)
[![CI](https://github.com/<OWNER>/verveforge/actions/workflows/ci.yml/badge.svg)](https://github.com/<OWNER>/verveforge/actions/workflows/ci.yml)
```

### 12.6 本地 Git Hook（可选）

> 文件路径：`.githooks/pre-push`

```bash
#!/bin/bash
set -e

echo "🔍 Pre-push: Running analyze + unit tests..."

flutter analyze --no-pub
flutter test

echo "✅ All checks passed. Pushing..."
```

启用：

```bash
git config core.hooksPath .githooks
chmod +x .githooks/pre-push
```

---

## Part 3 全量统计

| 章节 | 内容 | 场景/项目数 |
|------|------|:-----------:|
| 八、国际化与可访问性专项测试 | 语言覆盖矩阵 + 功能测试 + a11y | 18 |
| 九、测试通过标准与缺陷管理 | 10 级门禁 + 缺陷流程 + 报告模板 | 10 门禁项 |
| 十、执行记录表模板 | 覆盖全部 129 场景的可填写表格 | 129 行 |
| 十一、排期与时间估算 | 人天分配 + 里程碑 + 风险缓冲 | 5 里程碑 |
| 十二、CI/CD 集成 | GitHub Actions + 覆盖率 + 门禁 | 4 Jobs |

### Part 1 + Part 2 + Part 3 最终总计

| 维度 | 数量 |
|------|------|
| 手动集成测试用例（Part 1） | 75 |
| 自动化集成测试（Part 2） | 12 |
| 性能测试场景（Part 2） | 8 |
| 安全与边界测试（Part 2） | 16 |
| 国际化与可访问性（Part 3） | 18 |
| **测试场景总计** | **129** |
| 发布门禁项（Part 3） | 10 |
| CI/CD Jobs（Part 3） | 4 |
| 执行记录表覆盖场景 | 129 |

> **Part 3 结束** — VerveForge 集成测试指南 v2.0 全部完成。文档共三部分、十二章，涵盖 129 个测试场景、10 级发布门禁、完整 CI/CD 流水线配置。
