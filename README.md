# VerveForge (Private Repository)

VerveForge 是一款专注于运动社交与健康追踪的 iOS 优先移动应用。

## 项目概述
- 核心功能：训练日志记录、挑战赛 PK、训练馆地图与收藏、AI 虚拟分身社交
- 技术栈：Flutter 3.x + Supabase (后端) + Riverpod (状态管理) + go_router (路由)
- 目标平台：iOS（优先） / Android / Web
- 当前状态：MVP 功能基本完成，AI 分身模块已实现完整闭环

## 启动方式（本地开发）

1. 安装依赖
   ```bash
   flutter pub get
   ```

2. 配置环境变量
   ```bash
   cp .env.production.example .env
   # 编辑 .env 填入 Supabase URL、Anon Key、高德 Key
   ```

3. 运行应用
   ```bash
   # iOS 模拟器
   flutter run

   # Web 端
   flutter run -d chrome
   ```

4. 数据库初始化
   ```
   在 Supabase SQL Editor 中按顺序执行 supabase/migrations/ 下的 SQL 文件（00001 → 00024）
   ```

## 项目结构

```
lib/
├── app/                       # 应用配置（主题、路由）
├── core/                      # 公共工具、常量、异常处理
├── features/
│   ├── ai_avatar/             # AI 虚拟分身
│   │   ├── presentation/widgets/  # ai_glass_card.dart（玻璃拟态共享卡片）
│   ├── auth/                  # 登录（Apple Sign-In）
│   ├── buddy/                 # 伙伴发现 & 约练
│   ├── challenge/             # 挑战赛
│   ├── chat/                  # 实时聊天
│   ├── gym/                   # 训练馆目录 & 地图
│   ├── notification/          # 通知
│   ├── post/                  # 社区动态
│   ├── profile/               # 个人主页
│   └── workout/               # 训练日志 & 统计
├── l10n/                      # 国际化（中文 / 英文）
└── shared/widgets/            # 共享组件（CapCard 等）
```

## 设计系统

设计规范文档见 [`DESIGN.md`](./DESIGN.md)，包含：色彩系统、Inter 字体比例、AppSpacing 4px 网格、组件规范、AI Avatar 子品牌视觉语言、无障碍规则。

## 环境要求
- Flutter SDK ≥ 3.24.0
- Dart SDK ≥ 3.6.2
- Xcode 15+
- Supabase 项目

## 注意事项
- 本仓库为私有仓库，请勿公开分享
- `.env` 文件包含密钥，已在 `.gitignore` 中排除
- 高德地图 SDK 暂时禁用以支持模拟器预览
