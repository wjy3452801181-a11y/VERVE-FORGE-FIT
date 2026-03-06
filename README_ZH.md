# VerveForge

**记录训练 · 发现伙伴 · 挑战自我**

一款面向 HYROX、CrossFit、瑜伽、普拉提爱好者的运动社交 App，聚焦全球一线城市。

> [English README](README.md)

## 核心功能

- **训练日志** — 手动记录训练数据，支持 Apple Health 同步，照片上传
- **训练馆目录** — 用户共建训练馆数据库，高德地图展示
- **伙伴发现** — 按运动类型和城市发现附近训练伙伴
- **实时聊天** — 与伙伴沟通，发送训练邀约
- **挑战赛** — 创建或参加运动挑战，排行榜激励
- **社区动态** — 分享训练动态，点赞评论互动

## 技术栈

| 层级 | 技术选型 |
|------|----------|
| 框架 | Flutter 3.27+（Material 3 深色模式） |
| 后端 | Supabase（Auth + PostgreSQL + Realtime + Storage + Edge Functions） |
| 状态管理 | Riverpod |
| 路由 | go_router |
| 地图 | 高德地图 Flutter SDK（GCJ-02 坐标系） |
| 健康数据 | Apple HealthKit（通过 `health` 插件） |
| CI/CD | GitHub Actions → TestFlight |

## 快速开始

### 环境要求

- Flutter SDK ≥ 3.24.0
- Xcode 15+（iOS 开发）
- Supabase 项目（[supabase.com](https://supabase.com)）
- 高德开发者账号（[lbs.amap.com](https://lbs.amap.com)）

### 安装步骤

```bash
# 克隆仓库
git clone https://github.com/your-username/verveforge.git
cd verveforge

# 复制环境变量
cp .env.example .env
# 编辑 .env 填入你的 Supabase URL、Key 和高德 Key

# 执行搭建脚本
chmod +x scripts/setup.sh
./scripts/setup.sh

# 启动应用
flutter run
```

### 数据库初始化

在 Supabase 项目的 SQL Editor 中按顺序执行 `supabase/migrations/` 下的 SQL 文件（00001 → 00014）。

## 项目结构

```
lib/
├── main.dart              # 应用入口
├── app/                   # 应用配置（主题、路由）
├── core/                  # 公共工具、常量、异常处理
├── features/              # 功能模块（认证、训练、训练馆、伙伴、聊天、挑战、动态、通知）
│   └── <模块>/
│       ├── data/          # 数据仓库（Supabase 交互）
│       ├── domain/        # 数据模型
│       ├── presentation/  # 页面 & 组件
│       └── providers/     # Riverpod 状态管理
├── l10n/                  # 多语言文案（简体/繁体/英文）
└── shared/                # 共享组件 & Provider
```

## 多语言支持

- 简体中文 — 默认语言
- 繁體中文 — 香港用户
- English — 国际用户

## 隐私合规

- **PIPL**（中国）— 数据导出、账号注销、明确同意机制
- **PDPO**（香港）— 繁体中文和英文隐私政策

## 开源协议

[MIT](LICENSE)

## 贡献指南

欢迎贡献！请在提交 PR 前阅读贡献指南。
