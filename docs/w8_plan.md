# Week 8 功能清单与变更影响

## 目标

W8 聚焦三大方向：**Feed 动态流完整实现**、**隐私合规最终加固**、**上线前打磨**。
为 App Store 首次提审做好技术准备。

---

## 一、Feed 动态流（核心功能）

### 1.1 新建 Supabase 迁移

| 操作 | 说明 |
|------|------|
| 新建 `00017_w8_feed.sql` | `feed_items` 视图（聚合 workout_logs + challenges + gyms）；`posts` 表（用户发布动态）；`post_likes` 表；RLS 策略 |

**feed_items 视图设计：**
- 联合查询 `workout_logs`（type=log）、`challenges`（type=challenge）、`gyms`（type=gym）
- 按 `created_at DESC` 统一排序
- 包含发布者 `nickname`、`avatar_url`（JOIN profiles）
- 包含隐私过滤：仅展示 `show_workout_stats = TRUE` 的用户训练日志

**posts 表：**
- `id`, `user_id`, `content`, `photos[]`, `city`, `sport_type`, `linked_workout_id` (nullable), `linked_challenge_id` (nullable), `linked_gym_id` (nullable)
- `like_count`, `comment_count`（触发器维护）
- `created_at`, `updated_at`, `deleted_at`

**post_likes 表：**
- `id`, `post_id`, `user_id`, `created_at`
- UNIQUE(post_id, user_id)

### 1.2 Domain 模型

| 操作 | 文件 | 说明 |
|------|------|------|
| 新建 | `lib/features/feed/domain/feed_item_model.dart` | 统一 Feed 项模型（type 枚举：post/log/challenge/gym） |
| 新建 | `lib/features/feed/domain/post_model.dart` | 用户发布动态模型 |

### 1.3 Data 层

| 操作 | 文件 | 说明 |
|------|------|------|
| 新建 | `lib/features/feed/data/feed_repository.dart` | 混合 Feed 查询（分页、城市筛选）+ Realtime 订阅 |
| 新建 | `lib/features/feed/data/post_repository.dart` | Post CRUD + 点赞 + 照片上传 |

### 1.4 Provider 层

| 操作 | 文件 | 说明 |
|------|------|------|
| 新建 | `lib/features/feed/providers/feed_provider.dart` | FeedListNotifier（分页+Realtime）+ 城市筛选 |
| 新建 | `lib/features/feed/providers/post_provider.dart` | Post 操作（发布/点赞/删除） |

### 1.5 Presentation 层

| 操作 | 文件 | 说明 |
|------|------|------|
| 重写 | `lib/features/post/presentation/feed_page.dart` | 三 Tab（关注/附近/推荐）+ 下拉刷新 + 无限滚动 |
| 新建 | `lib/features/feed/presentation/widgets/feed_item_card.dart` | 统一卡片（post/log/challenge/gym 四种样式） |
| 新建 | `lib/features/feed/presentation/widgets/post_action_bar.dart` | 点赞/评论/分享按钮行 |
| 新建 | `lib/features/feed/presentation/post_create_page.dart` | 发布动态页（文字+照片+关联训练/挑战/馆） |

### 1.6 AppScaffold 联动

| 操作 | 文件 | 说明 |
|------|------|------|
| 修改 | `lib/shared/widgets/app_scaffold.dart` | "发布动态"按钮接通 PostCreatePage |

---

## 二、隐私合规最终加固

### 2.1 现有隐私基础（不重复实现）

| 已完成 | 位置 |
|--------|------|
| 登录前隐私弹窗 | `auth/presentation/privacy_consent_dialog.dart` |
| 训练数据采集授权 | `workout/presentation/widgets/data_collection_consent.dart` |
| 隐私设置页 | `profile/presentation/privacy_settings_page.dart` |
| 数据导出 + 账号注销 | `profile/data/profile_repository.dart` |
| 个人信息可见性控制 | ProfileModel (`isDiscoverable`, `showWorkoutStats`) |
| `privacy_agreed_at` 记录 | profiles 表 |

### 2.2 W8 补充内容

| 操作 | 文件 | 说明 |
|------|------|------|
| 新建 | `lib/core/privacy/app_launch_consent.dart` | 冷启动隐私检查（确保任何入口都经过同意，覆盖深链跳入场景） |
| 修改 | `lib/main.dart` | 启动时调用冷启动隐私检查 |
| 修改 | `lib/features/auth/presentation/privacy_consent_dialog.dart` | 添加 PDPO（香港）条款引用 + 链接到完整政策页 |
| 新建 | `lib/core/privacy/privacy_policy_page.dart` | 独立完整隐私政策页面（可从设置/弹窗/App Store 链接进入） |

### 2.3 App Store 合规要点

- 隐私政策 URL（Settings → Privacy Policy 可访问）
- App Tracking Transparency (ATT)：本项目不使用 IDFA 广告追踪，无需弹窗
- 数据收集声明：配合 App Store Connect Privacy Nutrition Labels
- 账号注销：已实现（W3 隐私设置页）

---

## 三、上线前全局打磨

### 3.1 主题一致性

| 操作 | 文件 | 说明 |
|------|------|------|
| 修改 | `lib/app/theme/app_theme.dart` | TabBar 样式统一 + Feed 卡片阴影/分割线样式 |

### 3.2 路由更新

| 操作 | 文件 | 说明 |
|------|------|------|
| 修改 | `lib/app/router.dart` | 新增 `/post/create`、`/privacy-policy` 路由 |

### 3.3 i18n 补充

| 操作 | 文件 | 说明 |
|------|------|------|
| 修改 | 4 个 ARB 文件 | 新增 ~25 个 Feed/Post/隐私相关 key |

---

## 四、变更影响矩阵

| 文件 | 操作 | 影响范围 |
|------|------|----------|
| `supabase/migrations/00017_w8_feed.sql` | 新建 | DB schema |
| `lib/features/feed/domain/feed_item_model.dart` | 新建 | 新模块 |
| `lib/features/feed/domain/post_model.dart` | 新建 | 新模块 |
| `lib/features/feed/data/feed_repository.dart` | 新建 | 新模块 |
| `lib/features/feed/data/post_repository.dart` | 新建 | 新模块 |
| `lib/features/feed/providers/feed_provider.dart` | 新建 | 新模块 |
| `lib/features/feed/providers/post_provider.dart` | 新建 | 新模块 |
| `lib/features/post/presentation/feed_page.dart` | 重写 | Tab 1 首页 |
| `lib/features/feed/presentation/widgets/feed_item_card.dart` | 新建 | 新模块 |
| `lib/features/feed/presentation/widgets/post_action_bar.dart` | 新建 | 新模块 |
| `lib/features/feed/presentation/post_create_page.dart` | 新建 | 新模块 |
| `lib/core/privacy/app_launch_consent.dart` | 新建 | 启动流程 |
| `lib/core/privacy/privacy_policy_page.dart` | 新建 | 隐私合规 |
| `lib/main.dart` | 修改 | 启动流程 |
| `lib/shared/widgets/app_scaffold.dart` | 修改 | 底部导航 |
| `lib/features/auth/presentation/privacy_consent_dialog.dart` | 修改 | 登录流程 |
| `lib/app/theme/app_theme.dart` | 修改 | 全局主题 |
| `lib/app/router.dart` | 修改 | 路由 |
| `lib/l10n/app_en.arb` | 修改 | i18n |
| `lib/l10n/app_zh.arb` | 修改 | i18n |
| `lib/l10n/app_zh_CN.arb` | 修改 | i18n |
| `lib/l10n/app_zh_TW.arb` | 修改 | i18n |
| `lib/core/constants/supabase_constants.dart` | 修改 | 新增表名常量 |
| `test/w8_test.dart` | 新建 | 单元测试 |

---

## 五、不修改的模块（确认兼容）

| 模块 | 状态 | 说明 |
|------|------|------|
| Workout (W1-W5) | 不变 | Feed 仅读取 workout_logs，不修改训练模块 |
| Challenge (W6) | 不变 | Feed 仅读取 challenges，不修改挑战模块 |
| Gym (W4) | 不变 | Feed 仅读取 gyms，不修改训练馆模块 |
| Auth (W2) | 微调 | 仅增强隐私弹窗措辞，不改登录流程 |
| Profile (W3) | 不变 | 隐私设置页不修改，复用现有隐私字段 |
| Health Sync (W2) | 不变 | 无关 |
| 高德地图 (W4) | 不变 | Feed 不涉及地图 |

---

## 六、Step 执行顺序

| Step | 内容 | 预计测试数 |
|------|------|-----------|
| Step 1 | 本文档（功能清单） | — |
| Step 2 | 迁移 SQL + Domain 模型 + 常量更新 | ~20 |
| Step 3 | Repository + Provider + i18n | ~15 |
| Step 4 | Feed 页面 + 卡片组件 + 发布页 + AppScaffold 修改 | — |
| Step 5 | 隐私合规补充 + main.dart + 路由 + 主题 | — |
| Step 6 | 单元测试 + 上线 checklist | ~20 |
