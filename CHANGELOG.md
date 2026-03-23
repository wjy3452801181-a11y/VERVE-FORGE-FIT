# Changelog / 变更日志

## [1.0.2] - 2026-03-23

### Fixed
- **ISSUE-001** — `AiAvatarModel.copyWith()` 无法清除 nullable 字段：引入 `_Sentinel` 哨兵模式，区分"未传参"与"显式传 null"，修复 AI 授权撤销、头像清除不生效的问题
- **ISSUE-002** — 分享 Sheet `_isSharing` 加载圈永久悬挂：服务端返回 `null` shareLink 时现在正确重置状态并提示用户
- **ISSUE-003** — 分享页"与 TA 聊天"始终打开自己的分身：新增 `aiAvatarChatByIdProvider` family provider，路由传参 `avatarId`，聊天 notifier 使用显式 avatarId
- **F7** — copyWith sentinel 模式中 `as String?` 裸转型：改为带类型检查的安全转型，防止错误类型导致运行时 TypeError
- **F2** — 分享页游客聊天路径 `currentUserId=''` 导致历史消息气泡方向全错：改用 `SupabaseClientHelper.currentUserId` 获取真实登录用户 ID
- **F10** — 尾部斜杠深链接（`/ai-avatar-chat/`）可能传入空字符串 `avatarId` 到 Edge Function：路由层新增空字符串防护

### Tests
- 新增 19 个回归测试（`test/ai_avatar_share_test.dart`）覆盖全部修复路径

## [1.0.1] - 2026-03-22

### Added
- **DESIGN.md** — 项目设计系统文档（色彩系统、排版、间距网格、组件规范、AI Avatar 子品牌视觉语言）
- **AiGlassCard** 共享 Widget — 从三处重复的 `_buildGlassCard` 方法提取，统一玻璃拟态卡片实现
- **聊天页滚动到底部 FAB** — 上滑超过 100px 时显示，带 AnimatedPositioned 入场动画
- AI Avatar 页面新增 l10n 键（`aiAvatarAutoReplyBadge`、`aiAvatarOfflineBadge` 等）

### Changed
- **AI Avatar 聊天页**：历史消息加载失败时显示"加载失败，点击重试"芯片（替代静默失败）
- `getChatHistory` 不再吞掉异常，改为 rethrow 以触发 provider 层错误处理
- `loadHistory` 错误标记 (`historyLoadFailed`) 现在只在确认发起请求后才清除，避免 avatar 未加载时重试 UI 消失
- **PersonalityChip** — 非交互展示模式（`onTap == null`）用 `ExcludeSemantics` 包裹，屏幕阅读器不公告纯装饰性芯片

### Fixed
- AI Avatar 详情页、创建页、分享页中五处生产崩溃和数据完整性问题
- 设计系统 token 补全（AppColors.info、AppSpacing.xs/sm/md/lg/xl、cardPaddingCompact）
- 聊天页 `_isSendingMessage` 标志在 avatar 为 null 时未重置的问题
- `AiAvatarSharedView` 聊天入口按钮路由传参修复

## [1.0.0] - 2026-03-06

### Week 1 — 项目初始化 & 基础架构
- 创建 Flutter 项目脚手架（Material 3 深色模式）
- Supabase 数据库 Schema（18 张表 + RLS + 触发器）
- go_router 路由体系 + Riverpod 状态管理
- 多语言框架（简体中文 / 繁体中文 / English）
- 通用 UI 组件（头像、空状态、加载遮罩、运动类型图标等）
- GitHub Actions CI/CD 流水线
- MIT 开源许可
