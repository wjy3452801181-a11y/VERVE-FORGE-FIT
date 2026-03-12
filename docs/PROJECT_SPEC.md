# VerveForge 项目书

> **运动社交平台 — 记录训练 · 发现伙伴 · 挑战自我**

---

## 一、项目概述

### 1.1 产品定位

VerveForge 是一款面向 HYROX、CrossFit、瑜伽、普拉提等功能性训练爱好者的运动社交 App。产品以「训练记录」为核心，围绕「LBS 社交发现」和「运动挑战」构建用户增长飞轮，目标成为中国功能性训练社区的第一入口。

### 1.2 核心价值主张

| 维度 | 价值 |
|------|------|
| **记录** | 一键记录训练，支持 Apple Health 自动同步，运动专项成绩追踪（HYROX 分站、CrossFit WOD、配速等） |
| **发现** | 基于 LBS 发现附近训练伙伴和训练馆，运动类型智能匹配 |
| **挑战** | 创建/参加运动挑战赛，排行榜实时更新，打卡激励 |
| **社交** | 动态流（关注/附近/推荐），约练请求，训练馆评价与收藏 |

### 1.3 目标用户画像

- **核心用户**：25-40 岁，一二线城市，功能性训练爱好者（HYROX/CrossFit/瑜伽/普拉提）
- **扩展用户**：跑步、游泳、力量训练等大众运动人群
- **地区**：中国大陆（北京/上海/广州/深圳）+ 香港

### 1.4 产品阶段

当前版本：**v1.0.0**（Pre-Launch，准备 TestFlight 分发）

---

## 二、功能架构

### 2.1 功能模块总览

```
┌──────────────────────────────────────────────────┐
│                  VerveForge App                    │
├──────────┬──────────┬──────────┬────────┬─────────┤
│  动态     │  训练馆   │  挑战     │  我的   │  附近    │
│  Feed    │  Gyms    │Challenge │Profile │ Nearby  │
├──────────┴──────────┴──────────┴────────┴─────────┤
│  全局浮动按钮：记录训练 / 发布动态                       │
├───────────────────────────────────────────────────┤
│  登录 → 引导流 → 主界面                               │
│  Phone OTP / Apple Sign-In                        │
├───────────────────────────────────────────────────┤
│  Supabase Backend (PostgreSQL + Realtime + Storage)│
└───────────────────────────────────────────────────┘
```

### 2.2 Tab 1：动态（Feed）

- **3 个子标签**：关注 / 附近 / 推荐
- **Supabase Realtime** 实时监听新动态，顶部横幅提示刷新
- 推荐 tab 按点赞数排序（热门推荐）
- 支持发布图文动态，可关联训练记录/训练馆/挑战赛
- 点赞、评论、分享、举报

### 2.3 Tab 2：训练馆（Gyms）

- **高德地图集成**（AMap SDK，GCJ-02 坐标系）
- 附近训练馆列表 + 全屏地图视图
- 内联搜索（名称/地址模糊匹配）
- 运动类型筛选
- 训练馆详情：照片、评价、营业时间、运动类型
- **收藏系统**：收藏/取消收藏，我的收藏列表
- **馆主认领**：提交认领申请 → 审核流程
- **用户提交**：提交新训练馆 → 待审核

### 2.4 Tab 3：挑战（Challenges）

- 创建/参加运动挑战赛
- 目标类型：总次数 / 总时长(分钟) / 总天数
- 城市 + 运动类型双重筛选
- **Supabase Realtime** 实时订阅挑战更新
- 排行榜：参与者排名 + 打卡进度
- 挑战状态：进行中 / 已结束 / 已取消 / 已满员

### 2.5 Tab 4：我的（Profile）

- 用户信息卡片（头像、昵称、简介、运动标签、城市、等级）
- 训练统计（本周/本月/总时长）
- 功能入口：
  - 训练日历（日历视图 + 训练详情）
  - 训练日志（时间线列表 + 筛选）
  - 训练馆地图
  - 收藏训练馆
  - 我的挑战（跳转挑战 Tab）
  - 我的伙伴（跳转附近 Tab）
  - 隐私设置
- 设置：语言 / 主题 / Apple Health 同步 / 隐私 / 退出登录

### 2.6 Tab 5：附近（Nearby）

- **附近伙伴**：基于 LBS 定位，调用 `nearby_buddies` RPC
- 运动类型筛选（伙伴 + 训练馆联动）
- 伙伴卡片：头像 + 昵称 + 距离 + 运动标签 + 等级 + 约练按钮
- **推荐训练馆**：复用附近训练馆数据，展示 Top 5
- 无定位权限时降级为按城市查询

### 2.7 训练记录（全局 FAB 触发）

- 运动类型选择（8 种）
- 基础信息：时长、强度（1-10）、备注、照片
- **运动专项成绩**（可选）：
  - HYROX：8 分站用时 + 总成绩
  - CrossFit：WOD 名称 + 类型 + 成绩 + 动作列表
  - 跑步：距离 + 配速 + 爬升
  - 瑜伽/普拉提：课程名称 + 专注区域 + 难度
- Apple Health 自动同步（心率、卡路里、步数）
- 草稿保存 + 同时发布为动态

### 2.8 认证与引导

- **登录方式**：手机号 OTP + Apple Sign-In
- **引导流**（3 步）：
  1. 选择运动类型（多选）
  2. 选择城市
  3. 设置头像和昵称
- **隐私合规**：冷启动同意弹窗（PIPL/PDPO）

---

## 三、技术架构

### 3.1 技术栈

| 层级 | 技术选型 | 说明 |
|------|---------|------|
| **前端框架** | Flutter 3.27+ | 跨平台（iOS 优先） |
| **UI 规范** | Material 3 | 深色模式为默认 |
| **状态管理** | Riverpod | AsyncNotifier + StateProvider + FutureProvider |
| **路由** | go_router | StatefulShellRoute 底部导航 + 深度链接 |
| **后端** | Supabase | PostgreSQL + Auth + Realtime + Storage + Edge Functions |
| **地图** | 高德地图 SDK | AMap Flutter（GCJ-02 坐标系，中国合规） |
| **健康数据** | Apple HealthKit | health 插件 v11.0.0 |
| **国际化** | flutter_localizations | 4 语言 ARB 文件 |
| **CI/CD** | GitHub Actions | → TestFlight 自动分发 |

### 3.2 项目结构

```
lib/
├── main.dart                          # 入口：Supabase 初始化 + 隐私检查
├── app/
│   ├── app.dart                       # 根 Widget：主题/语言/路由
│   ├── router.dart                    # go_router 配置（5 Tab + 独立页面）
│   └── theme/                         # 主题系统（颜色/字体/Material 3）
├── core/
│   ├── constants/                     # 全局常量（运动类型/城市/分页大小）
│   ├── network/                       # Supabase 客户端封装
│   ├── errors/                        # 异常处理
│   ├── extensions/                    # Context/DateTime/String 扩展
│   └── utils/                         # 工具类（验证/防抖/图片处理）
├── features/                          # 功能模块（Clean Architecture）
│   ├── auth/                          # 认证 + 引导流
│   ├── profile/                       # 个人资料 + 设置 + 隐私
│   ├── workout/                       # 训练记录 + Apple Health
│   ├── gym/                           # 训练馆目录 + 地图 + 收藏 + 认领
│   ├── challenge/                     # 挑战赛 + 排行榜 + 打卡
│   ├── post/                          # 社交动态 + 评论 + 点赞
│   └── buddy/                         # 伙伴发现 + 约练
├── shared/
│   ├── providers/                     # 全局 Provider（语言/主题）
│   └── widgets/                       # 通用组件（头像/空状态/确认弹窗）
└── l10n/                              # 国际化 ARB 文件（en/zh/zh_CN/zh_TW）
```

### 3.3 功能模块分层（Clean Architecture）

每个 feature 模块遵循统一分层：

```
feature/
├── domain/        # 数据模型（fromJson/toJson/copyWith）
├── data/          # Repository（Supabase 查询/RPC/Storage）
├── providers/     # Riverpod 状态管理（异步加载/分页/操作）
└── presentation/  # 页面 + 组件
    ├── *_page.dart
    └── widgets/
```

### 3.4 实时数据架构

```
┌─────────────┐    Realtime Channel    ┌──────────────┐
│  Supabase   │ ◄──────────────────── │  Flutter App  │
│  PostgreSQL │    INSERT/UPDATE/ALL   │  (Riverpod)  │
└─────────────┘                        └──────────────┘
       │                                      │
       │  posts 表 INSERT                     │  feedRealtimeProvider
       │  → 新动态提示横幅                      │  → feedHasNewPostsProvider
       │                                      │
       │  challenges 表 ALL                   │  challengeRealtimeProvider
       │  → 挑战更新提示横幅                    │  → challengeHasUpdatesProvider
       │                                      │
       │  challenge_check_ins 表 INSERT       │  leaderboardRealtimeProvider
       │  → 排行榜实时刷新                      │  → 自动 invalidate
```

### 3.5 LBS 定位架构

```
LocationService (高德 AMap)
       │
       ▼
currentLocationProvider (FutureProvider)
       │
       ├─► nearbyGymsProvider ──► nearby_gyms RPC (PostGIS)
       │
       ├─► nearbyBuddiesProvider ──► nearby_buddies RPC (PostGIS)
       │
       └─► (无定位时降级) ──► listByCity() 按城市查询
```

---

## 四、数据库设计

### 4.1 核心数据表（17 个 Migration）

| 表名 | 说明 | 关键字段 |
|------|------|---------|
| `profiles` | 用户档案 | nickname, avatar_url, city, sport_types[], experience_level, is_discoverable |
| `workout_logs` | 训练记录 | sport_type, duration_minutes, intensity, metrics(JSONB), photos[], is_draft |
| `gyms` | 训练馆 | name, address, location(PostGIS), sport_types[], avg_rating, status |
| `gym_reviews` | 训练馆评价 | gym_id, rating(1-5), content, photos[] |
| `user_gym_favorites` | 训练馆收藏 | user_id, gym_id |
| `gym_claims` | 馆主认领 | gym_id, claimant_user_id, status |
| `challenges` | 挑战赛 | title, sport_type, goal_type, goal_value, starts_at, ends_at, max_participants |
| `challenge_participants` | 挑战参与者 | challenge_id, user_id, progress_value, check_in_count, rank |
| `challenge_check_ins` | 挑战打卡 | challenge_id, user_id, workout_log_id |
| `posts` | 社交动态 | content, photos[], city, like_count, comment_count |
| `post_likes` | 点赞 | post_id, user_id |
| `post_comments` | 评论 | post_id, user_id, content, parent_id(嵌套) |
| `buddy_requests` | 约练请求 | sender_id, receiver_id, status |
| `user_follows` | 关注关系 | follower_id, following_id |
| `user_blocks` | 屏蔽关系 | blocker_id, blocked_id |
| `reports` | 举报 | reporter_id, report_type, is_resolved |
| `notifications` | 通知 | user_id, type, ref_*_id, is_read |

### 4.2 RPC 函数

| 函数名 | 说明 | 参数 |
|--------|------|------|
| `nearby_gyms` | 附近训练馆查询 | lat, lng, radius_km, sport_filter |
| `nearby_buddies` | 附近伙伴查询 | lat, lng, radius_km, sport_filter |

### 4.3 数据库触发器

- `update_updated_at()` — 自动更新时间戳
- `update_gym_rating()` — 评价后聚合评分
- `update_post_like_count()` — 点赞计数器
- `update_post_comment_count()` — 评论计数器
- `update_challenge_participant_count()` — 参与人数
- `update_challenge_progress()` — 打卡后更新进度

### 4.4 Storage Buckets（5 个）

| Bucket | 用途 |
|--------|------|
| `avatars` | 用户头像 |
| `workout-photos` | 训练照片 |
| `gym-photos` | 训练馆照片 |
| `post-photos` | 动态图片 |
| `chat-media` | 聊天附件 |

---

## 五、设计规范

### 5.1 品牌色彩

| 色彩 | 色值 | 用途 |
|------|------|------|
| **Primary** | `#FF6B35` 活力橙 | 品牌色、CTA 按钮、强调 |
| **Secondary** | `#4ECDC4` 薄荷绿 | 辅助色、成功状态、已参加标记 |
| **Accent** | `#FFE66D` 明亮黄 | 高亮、评分星标 |

### 5.2 运动类型色彩系统

| 运动 | 色值 | 示例 |
|------|------|------|
| HYROX | `#FF6B35` 橙 | 品牌同色 |
| CrossFit | `#E63946` 红 | 高强度 |
| 瑜伽 | `#4ECDC4` 薄荷绿 | 平静 |
| 普拉提 | `#7B68EE` 紫 | 优雅 |
| 跑步 | `#45B7D1` 天蓝 | 自由 |
| 游泳 | `#2196F3` 深蓝 | 水元素 |
| 力量 | `#FF8C00` 深橙 | 力量感 |

### 5.3 深色主题（默认）

| 元素 | 色值 |
|------|------|
| 背景 | `#0D0D0D` |
| 表面 | `#1A1A1A` |
| 卡片 | `#252525` |
| 主文字 | `#F5F5F5` |
| 辅助文字 | `#9E9E9E` |
| 分割线 | `#333333` |

### 5.4 字体系统

| 样式 | 字号 | 字重 | 用途 |
|------|------|------|------|
| h1 | 28 | Bold | 大标题 |
| h2 | 22 | SemiBold | 页面标题 |
| h3 | 18 | SemiBold | 区块标题 |
| subtitle | 16 | Medium | 卡片标题 |
| body | 15 | Regular | 正文 |
| caption | 13 | Regular | 辅助文字 |
| label | 12 | Medium | 小标签 |
| number | 24 | Bold | 统计数字 |

---

## 六、国际化

### 6.1 支持语言

| 语言 | ARB 文件 | 目标地区 |
|------|---------|---------|
| 简体中文 | `app_zh_CN.arb` | 中国大陆 |
| 繁体中文 | `app_zh_TW.arb` | 香港/台湾 |
| 英文 | `app_en.arb` | 国际用户 |
| 简体中文(回退) | `app_zh.arb` | 默认中文 |

### 6.2 本地化覆盖

约 **130+ 个 l10n key**，覆盖：
- 导航标签、登录/注册流程
- 引导流 3 步骤
- 8 种运动类型 + 5 个城市 + 4 个等级
- 训练记录/日历/统计全流程
- 运动专项成绩（HYROX/CrossFit/跑步/瑜伽指标）
- 挑战赛创建/参加/退出/排行榜
- 社交动态发布/点赞/评论
- 训练馆搜索/详情/评价/收藏/认领
- 附近伙伴/约练
- 设置/隐私/合规文案
- 通用操作（取消/确认/删除/重试/加载中...）

---

## 七、隐私合规

### 7.1 合规框架

| 法规 | 适用地区 | 合规措施 |
|------|---------|---------|
| **PIPL** | 中国大陆 | 冷启动同意弹窗 + 明确数据采集范围 + 数据导出/删除 |
| **PDPO** | 香港 | 繁体中文隐私政策 + 显式同意 |
| **GDPR** | 参考 | 软删除 + 数据可移植性 |

### 7.2 三层隐私同意

1. **App 冷启动** — 首次打开显示数据处理说明，阻断式同意
2. **登录页** — "登录即表示您同意隐私政策和服务条款"
3. **Apple Health 授权** — 训练数据采集单独授权

### 7.3 用户数据权利

| 权利 | 实现方式 |
|------|---------|
| 知情权 | 完整隐私政策页面 |
| 同意权 | 显式同意弹窗 + 时间戳记录 |
| 可见性控制 | `is_discoverable` + `show_workout_stats` |
| 数据导出 | 设置页「导出我的数据」→ JSON 下载 |
| 账号注销 | 设置页「注销账号」→ 软删除 + 30 天保留期 |

---

## 八、测试

### 8.1 测试覆盖

| 测试文件 | 测试数 | 覆盖范围 |
|---------|--------|---------|
| `w5_test.dart` | 47 | 训练模型、运动专项成绩、草稿 |
| `w6_test.dart` | 37 | 挑战模型、参与者、打卡 |
| `w75_test.dart` | 15 | 训练馆收藏、馆主认领 |
| `w8_test.dart` | 28 | 社交动态、评论、点赞 |
| **合计** | **127+** | 核心业务逻辑 |

### 8.2 质量保障

- `flutter analyze` — 静态分析零 warning
- 无硬编码字符串（全部使用 l10n）
- 无 `print()` 语句（使用 Logger）
- 无敏感数据进入版本控制（.env 配置）

---

## 九、环境配置

### 9.1 开发环境要求

| 工具 | 版本要求 |
|------|---------|
| Flutter SDK | >= 3.24.0 |
| Dart | >= 3.6.2 |
| Xcode | 15+ |
| CocoaPods | 最新版 |

### 9.2 环境变量（.env）

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
AMAP_IOS_KEY=your-amap-ios-key
AMAP_ANDROID_KEY=your-amap-android-key
```

### 9.3 iOS 权限配置

| 权限 | Info.plist Key | 用途 |
|------|---------------|------|
| 位置 | `NSLocationWhenInUseUsageDescription` | 发现附近训练馆和伙伴 |
| 健康读取 | `NSHealthShareUsageDescription` | 同步 Apple Health 训练数据 |
| 健康写入 | `NSHealthUpdateUsageDescription` | 写入训练数据 |

---

## 十、路由架构

### 10.1 底部导航（5 Tab）

| Tab | 路径 | 页面 | 图标 |
|-----|------|------|------|
| 1 | `/feed` | FeedPage | dynamic_feed |
| 2 | `/gyms` | GymsPage | fitness_center |
| 3 | `/challenges` | ChallengesPage | emoji_events |
| 4 | `/profile` | ProfilePage | person |
| 5 | `/nearby` | NearbyPage | location_on |

### 10.2 独立页面路由

| 路径 | 页面 | 说明 |
|------|------|------|
| `/login` | LoginPage | 手机号 OTP + Apple 登录 |
| `/onboarding` | OnboardingPage | 3 步引导流 |
| `/create-workout` | WorkoutCreatePage | 记录训练（FAB 触发） |
| `/workout-detail/:id` | WorkoutDetailPage | 训练详情 |
| `/workout-history` | WorkoutListPage | 训练历史列表 |
| `/workout-calendar` | WorkoutCalendarPage | 训练日历 |
| `/gym-map` | GymMapPage | 高德地图全屏 |
| `/gym-detail/:id` | GymDetailPage | 训练馆详情 |
| `/gym-submit` | GymSubmitPage | 提交新训练馆 |
| `/gym-review/:gymId` | GymReviewPage | 写评价 |
| `/gym-favorites` | GymFavoritesPage | 收藏列表 |
| `/challenge-create` | ChallengeCreatePage | 创建挑战 |
| `/challenge-detail/:id` | ChallengeRankPage | 排行榜 |
| `/post-create` | PostCreatePage | 发布动态 |
| `/profile-edit` | ProfileEditPage | 编辑资料 |
| `/settings` | SettingsPage | 设置 |
| `/privacy-policy` | PrivacyPolicyPage | 隐私政策 |

---

## 十一、开发里程碑

| 阶段 | 内容 | 状态 |
|------|------|------|
| W1-W3 | 脚手架 + 认证 + 个人资料 + 训练记录 + Apple Health | ✅ 已完成 |
| W4 | 训练馆目录 + 高德地图集成 | ✅ 已完成 |
| W5 | 运动专项成绩（HYROX/CrossFit/跑步/瑜伽指标） | ✅ 已完成 |
| W6 | 挑战赛系统（创建/参加/排行榜/Realtime） | ✅ 已完成 |
| W7.5 | 训练馆收藏 + 馆主认领 | ✅ 已完成 |
| W8 | 社交动态 + 5 Tab 完整功能页 + 隐私合规 + Pre-Launch | ✅ 已完成 |

### 代码统计

| 指标 | 数值 |
|------|------|
| Dart 文件数 | 119 |
| l10n Key 数 | 130+ |
| 数据库 Migration | 17 |
| 测试用例 | 127+ |
| 功能模块 | 7（auth/profile/workout/gym/challenge/post/buddy） |

---

## 十二、后续规划

### Phase 2 规划

| 功能 | 优先级 | 说明 |
|------|--------|------|
| 即时通讯 | P0 | 基于 conversations/messages 表，伙伴私聊 |
| 推送通知 | P0 | 约练请求/挑战邀请/点赞评论通知 |
| 训练数据分析 | P1 | 周报/月报/趋势图表（fl_chart） |
| 训练馆入驻后台 | P1 | 馆主管理端（课程/活动/优惠） |
| Android 适配 | P1 | 高德地图 Android + Google Health Connect |
| 社区运营工具 | P2 | 话题标签、热门话题、编辑推荐 |
| 赛事系统 | P2 | HYROX/CrossFit 正式赛事对接 |
| 商业化 | P3 | 训练馆广告位、挑战赛赞助、会员订阅 |

---

> **VerveForge** — 让每一次训练都有伙伴，让每一次挑战都有回响。
