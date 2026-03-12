# VerveForge

**记录训练 · 发现伙伴 · 挑战自我**

一款面向 HYROX、CrossFit、瑜伽、普拉提爱好者的运动社交 App，聚焦全球一线城市。

> [English README](README.md)

---

## 功能模块

### 核心功能
- **训练日志** — 手动记录训练数据，Apple Health 同步，强度分级（1-10），照片上传
- **训练馆目录** — 用户共建数据库，高德地图展示，收藏 & 评价
- **伙伴发现** — 按运动类型、城市、经验等级发现附近训练伙伴
- **实时聊天** — 与伙伴 1v1 消息沟通，发起训练邀约
- **挑战赛** — 创建或参加运动挑战，打卡追踪，排行榜激励
- **社区动态** — 分享训练日常，点赞、评论、关注

### AI 数字分身
- **AI 训练伙伴** — 创建专属 AI 分身，反映你的运动风格和个性
- **智能回复** — AI 分身可根据你的训练习惯自动回复消息
- **分享名片** — 生成 AI 分身的公开主页，唯一链接分享
- **内容过滤** — 关键词过滤机制，确保 AI 回复安全合规

### UI 设计系统
- **Cap Card** — 玻璃拟态卡片组件（步骤卡 / 引用卡 / 能力卡 / 数据卡）
- **深浅色模式** — 真正暗黑模式（#0A0A0A）+ 自适应主题切换
- **Web 预览** — 独立 HTML/CSS 预览页，展示 Cap Card 设计系统

## 技术栈

| 层级 | 技术选型 |
|------|----------|
| 框架 | Flutter 3.24+（Material 3，深色/浅色模式） |
| 后端 | Supabase（Auth + PostgreSQL + Realtime + Storage + Edge Functions） |
| 状态管理 | Riverpod |
| 路由 | go_router |
| 地图 | 高德地图 Flutter SDK（GCJ-02 坐标系） |
| 健康数据 | Apple HealthKit（`health` 插件） |
| 登录 | Apple Sign-In + Supabase Auth |
| Web | Flutter Web + 自定义 CSS（Cap Card UI System） |
| 字体 | Inter（400/500/600/700/900） |

## 快速开始

### 环境要求

- Flutter SDK ≥ 3.24.0
- Dart SDK ≥ 3.6.2
- Xcode 15+（iOS 开发）
- Supabase 项目 — [supabase.com](https://supabase.com)
- 高德开发者账号 — [lbs.amap.com](https://lbs.amap.com)（可选，地图功能）

### 安装步骤

```bash
# 克隆仓库
git clone https://github.com/wjy3452801181-a11y/VERVE-FORGE-FIT.git
cd VERVE-FORGE-FIT

# 配置环境变量
cp .env.production.example .env
# 编辑 .env 填入你的 Supabase URL、Anon Key 和高德 Key

# 安装依赖
flutter pub get

# iOS 模拟器运行
flutter run

# Web 端运行
flutter run -d chrome
```

### 数据库初始化

在 Supabase 项目的 SQL Editor 中按顺序执行 `supabase/migrations/` 下的 SQL 文件（00001 → 00024）。

## 项目结构

```
lib/
├── main.dart                  # 应用入口
├── app/
│   ├── app.dart               # MaterialApp 配置
│   ├── router.dart            # go_router 路由
│   └── theme/
│       ├── app_colors.dart    # 颜色体系（黑白灰 + tint/glow）
│       ├── app_theme.dart     # 深色 & 浅色 ThemeData
│       └── app_text_styles.dart
├── core/
│   ├── constants/             # Supabase 表名、高德配置
│   ├── errors/                # 异常处理
│   ├── extensions/            # Context 扩展
│   └── utils/                 # 校验工具
├── features/
│   ├── ai_avatar/             # AI 数字分身（创建 / 聊天 / 分享）
│   ├── auth/                  # 登录（Apple Sign-In）
│   ├── buddy/                 # 伙伴发现 & 约练请求
│   ├── challenge/             # 运动挑战赛
│   ├── chat/                  # 实时聊天
│   ├── gym/                   # 训练馆目录 & 地图
│   ├── notification/          # 推送通知
│   ├── post/                  # 社区动态
│   ├── profile/               # 个人主页 & 设置
│   └── workout/               # 训练日志 & 统计
├── l10n/                      # 国际化（中文 / 英文）
└── shared/widgets/
    ├── cap_card.dart           # 玻璃拟态卡片组件
    ├── avatar_widget.dart
    ├── sport_type_icon.dart
    └── ...

web/
├── index.html                 # Flutter Web 入口
├── cap-card-preview.html      # Cap Card UI 预览页
└── styles/cap-card.css        # Cap Card CSS（CSS 变量、深色模式）

supabase/
├── migrations/                # 24 个 SQL 迁移文件
├── functions/                 # Edge Functions（AI 分身逻辑）
└── snippets/                  # SQL 验证脚本
```

## Cap Card 设计系统

Cap Card 是共享卡片组件库，包含 4 种卡片类型：

| 类型 | 说明 |
|------|------|
| **Step Card 步骤卡** | 渐变边框、编号徽章、进度条（浅→深渐变） |
| **Quote Card 引用卡** | 左侧竖线、引用符号、署名 |
| **Capability Card 能力卡** | 发光图标区、粗体标题、标签 |
| **Stats Card 数据卡** | 三栏数据展示、竖线分隔 |

预览：用浏览器打开 `web/cap-card-preview.html`，支持深浅色切换。

## 国际化

- **简体中文** — 默认语言
- **English** — 国际用户

## 隐私合规

- **PIPL**（中国）— 数据导出、账号注销、明确同意机制
- **PDPO**（香港）— 繁体中文和英文隐私政策

## 开源协议

[MIT](LICENSE)
