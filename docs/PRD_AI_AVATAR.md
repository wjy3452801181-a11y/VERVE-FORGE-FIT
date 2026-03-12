# PRD: AI 社交虚拟分身 (AI Avatar)

**版本**: v1.0
**日期**: 2026-03-09
**作者**: VerveForge Team
**状态**: Draft

---

## 1. 产品概述

### 1.1 定位

AI 社交虚拟分身是 VerveForge 的社交增强功能，让用户创建一个能代表自己社交的 AI 虚拟小人物。AI 学习用户的运动习惯、说话风格和个性特征，在用户离线时自动代替用户进行社交回复。

### 1.2 目标

- 提升用户社交活跃度，减少因离线导致的消息延迟
- 增强用户个性化表达，通过 DIY 虚拟分身展示运动人设
- 为后续 AI 社交能力（智能推荐、自动约练）奠定基础

### 1.3 MVP 范围

| 包含 | 不包含 |
|------|--------|
| DIY 创建虚拟分身 | 语音/视频分身 |
| 与分身聊天（体验模式） | 多分身切换 |
| 离线自动代替回复 | 分身主动发起对话 |
| 基础性格/风格配置 | 深度学习用户历史 |
| PIPL 三层同意流程 | 跨平台分身同步 |

---

## 2. 用户故事

### MVP 用户故事（8 条）

| # | 角色 | 故事 | 验收标准 |
|---|------|------|----------|
| US-1 | 运动用户 | 我想创建一个 AI 虚拟分身，让它代表我的运动人设 | 能设置名称、头像、性格标签、说话风格 |
| US-2 | 运动用户 | 我想选择分身的性格特征，比如"热情"、"专业"、"幽默" | 至少提供 8 种性格标签可多选 |
| US-3 | 运动用户 | 我想选择分身的说话风格，比如"简洁"、"详细"、"鼓励" | 提供 4 种预设风格单选 |
| US-4 | 运动用户 | 我想和自己的分身聊天，看看它回复得像不像我 | 能在专属聊天页面与分身对话，分身基于配置回复 |
| US-5 | 运动用户 | 我想开启/关闭离线自动回复功能 | 在分身详情页有开关，默认关闭 |
| US-6 | 运动用户 | 当我离线超过 5 分钟时，分身自动代我回复新消息 | 消息带 AI 标记，对方可见"由 AI 分身回复" |
| US-7 | 运动用户 | 我想看到哪些消息是分身代替我回复的 | AI 回复消息有明显的视觉标记 |
| US-8 | 运动用户 | 我需要明确同意 AI 数据处理，符合隐私法规 | 创建分身前弹出 AI 数据授权弹窗，记录同意时间 |

---

## 3. 功能清单

| 优先级 | 功能 | 描述 | 状态 |
|--------|------|------|------|
| **P0** | 创建 AI 分身 | 多步骤表单：名称→头像→性格→风格→自定义提示词 | MVP |
| **P0** | 分身详情/管理 | 查看/编辑分身配置，开关自动回复 | MVP |
| **P0** | AI 数据授权同意 | PIPL 合规的三层同意弹窗 | MVP |
| **P1** | 与分身聊天 | 体验模式，在专属页面与分身对话 | MVP |
| **P1** | 离线自动回复 | 检测离线状态，触发 AI 生成回复 | MVP |
| **P1** | AI 消息标记 | 前端展示 AI 生成标记 | MVP |
| **P2** | 自定义提示词 | 用户可写自定义 prompt 微调回复风格 | MVP |
| **P2** | 分身入口 | Profile 页新增"我的 AI 分身"菜单项 | MVP |
| **P3** | 分身头像生成 | AI 根据用户头像生成虚拟形象 | Future |
| **P3** | 智能风格学习 | 分析用户历史消息自动调整风格 | Future |
| **P3** | 多分身 | 支持多个分身用于不同场景 | Future |

---

## 4. 用户旅程图

### 4.1 创建分身

```
┌─────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│ Profile  │───>│ AI 数据  │───>│ Step 1   │───>│ Step 2   │───>│ Step 3   │
│   页面   │    │ 授权弹窗 │    │ 名称+    │    │ 性格标签 │    │ 说话风格 │
│ 点击入口 │    │ 同意/拒绝│    │ 头像     │    │ 多选     │    │ +自定义  │
└─────────┘    └──────────┘    └──────────┘    └──────────┘    └────┬─────┘
                    │                                               │
                    │ 拒绝                                          │ 保存
                    v                                               v
               ┌──────────┐                                   ┌──────────┐
               │ 返回     │                                   │ 分身详情 │
               │ Profile  │                                   │ 管理页   │
               └──────────┘                                   └──────────┘
```

### 4.2 与分身聊天（体验模式）

```
┌──────────┐    ┌──────────┐    ┌──────────┐
│ 分身详情 │───>│ 聊天页   │───>│ Edge Fn  │
│ 点击聊天 │    │ 发送消息 │    │ AI 回复  │
└──────────┘    └──────────┘    └──────────┘
```

### 4.3 离线自动回复

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│ 用户 A   │───>│ messages  │───>│ DB 触发器│───>│ 检查:    │───>│ Edge Fn  │
│ 发消息   │    │ INSERT   │    │ 触发     │    │ B 离线?  │    │ AI 回复  │
│ 给用户 B │    │          │    │          │    │ 启用?    │    │          │
└──────────┘    └──────────┘    └──────────┘    └──────────┘    └────┬─────┘
                                                                     │
                                                                     v
                                                               ┌──────────┐
                                                               │ AI 消息  │
                                                               │ INSERT   │
                                                               │ 带标记   │
                                                               └──────────┘
```

---

## 5. 数据模型

### 5.1 `ai_avatars` 表

| 列名 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | UUID | PK, DEFAULT uuid_generate_v4() | 主键 |
| user_id | UUID | UNIQUE, FK→profiles(id), NOT NULL | 每个用户最多一个分身 |
| name | VARCHAR(50) | NOT NULL | 分身名称 |
| avatar_url | TEXT | | 分身头像 URL |
| personality_traits | TEXT[] | DEFAULT '{}' | 性格标签数组 |
| speaking_style | VARCHAR(20) | DEFAULT 'friendly' | 说话风格 |
| custom_prompt | TEXT | DEFAULT '' | 用户自定义提示词 |
| auto_reply_enabled | BOOLEAN | DEFAULT FALSE | 是否启用离线自动回复 |
| ai_consent_at | TIMESTAMPTZ | | AI 数据处理同意时间 |
| created_at | TIMESTAMPTZ | NOT NULL, DEFAULT NOW() | 创建时间 |
| updated_at | TIMESTAMPTZ | NOT NULL, DEFAULT NOW() | 更新时间 |

### 5.2 `profiles` 表新增列

| 列名 | 类型 | 说明 |
|------|------|------|
| last_seen_at | TIMESTAMPTZ | 最后在线时间，用于离线检测 |

### 5.3 关系图

```
profiles (1) ─── (0..1) ai_avatars      用户 : 分身 = 1:1
profiles (1) ─── (N)    messages         用户 : 消息 = 1:N
messages.metadata.is_ai_generated        标记 AI 生成的消息
messages.metadata.avatar_id              关联生成此消息的分身
```

---

## 6. 技术实现方案

### 6.1 Supabase Migration SQL

**文件**: `supabase/migrations/00018_ai_avatars.sql`

完整 SQL 包含：
- `ai_avatars` 表创建（含所有字段和约束）
- `profiles.last_seen_at` 列添加
- RLS 策略：owner 全权 CRUD + 公开只读（name, avatar_url）
- 自动回复触发器函数：`trigger_ai_auto_reply()`
  - 检查 `metadata->>'is_ai_generated'` 防循环
  - 检查接收者 `last_seen_at` 是否超过 5 分钟
  - 检查接收者是否启用 `auto_reply_enabled`
  - 通过 `pg_net` 异步调用 Edge Function
- `updated_at` 自动更新触发器

### 6.2 Edge Function 架构

#### `ai-avatar-reply` (离线自动回复)

```
请求 → 验证 → 获取数据 → 构造 Prompt → Claude API → 插入消息
         │        │           │
         │        ├─ avatar 配置
         │        ├─ 用户 profile
         │        └─ 对话上下文 (最近 10 条)
         │
         └─ 验证 service_role_key
```

#### `ai-avatar-chat` (体验模式聊天)

```
请求 → JWT 验证 → 获取数据 → 构造 Prompt → Claude API → 返回响应
                      │           │
                      ├─ avatar 配置
                      ├─ 用户 profile
                      └─ 最近 5 条公开动态
```

### 6.3 System Prompt 构造逻辑

```
你是 {avatar.name}，一个运动爱好者的 AI 虚拟分身。

用户背景信息：
- 昵称: {profile.nickname}
- 城市: {profile.city}
- 运动类型: {profile.sport_types}
- 运动水平: {profile.experience_level}
- 个人简介: {profile.bio}

性格特征: {avatar.personality_traits}
说话风格: {avatar.speaking_style}
{avatar.custom_prompt ? "用户特别要求: " + avatar.custom_prompt : ""}

最近动态:
{recent_posts}

回复规则:
1. 用第一人称回复，像真人一样自然
2. 回复要简短，一般 1-3 句话
3. 基于用户的运动背景回复运动相关话题
4. 不要透露自己是 AI
5. 如果遇到敏感话题，礼貌地转移话题
```

### 6.4 离线检测机制

- **数据源**: `profiles.last_seen_at` 字段
- **更新时机**: 客户端 App 每 60 秒心跳更新一次
- **离线阈值**: `NOW() - last_seen_at > INTERVAL '5 minutes'`
- **优势**: 比 Supabase Presence Channel 更简单可靠，无需 WebSocket 常连

---

## 7. 隐私合规

### 7.1 PIPL 三层同意机制

| 层级 | 触发时机 | 内容 | 存储 |
|------|---------|------|------|
| L1 - 应用级 | 首次启动 | 通用数据处理告知 | profiles.privacy_agreed_at |
| L2 - 功能级 | 首次创建分身 | AI 数据处理专项授权 | ai_avatars.ai_consent_at |
| L3 - 操作级 | 开启自动回复 | 代替回复知情同意确认 | 开关操作即视为确认 |

### 7.2 AI 数据处理授权内容

创建分身时展示的授权弹窗需明确告知：

1. **数据采集范围**：个人资料、运动偏好、聊天内容（最近 10 条）、公开动态（最近 5 条）
2. **数据用途**：用于生成符合用户风格的 AI 回复
3. **数据处理方**：通过 Anthropic Claude API 处理，数据不持久化存储
4. **用户权利**：可随时关闭功能、删除分身、撤回授权
5. **自动回复声明**：对方将看到"由 AI 分身回复"的标记

### 7.3 数据最小化原则

- 仅在触发回复时实时获取上下文，不预存聊天历史
- System Prompt 不包含敏感个人信息（手机号、位置坐标等）
- AI 回复的 metadata 中记录生成来源，支持审计追溯

---

## 8. l10n Key 清单

以下为本功能新增的国际化 Key（~40 个）：

### 分身通用
| Key | EN | ZH |
|-----|----|----|
| aiAvatarTitle | My AI Avatar | 我的 AI 分身 |
| aiAvatarCreate | Create AI Avatar | 创建 AI 分身 |
| aiAvatarEdit | Edit Avatar | 编辑分身 |
| aiAvatarDelete | Delete Avatar | 删除分身 |
| aiAvatarDeleteConfirm | Delete your AI avatar? This cannot be undone. | 确定删除 AI 分身吗？此操作不可恢复。 |
| aiAvatarDeleted | AI avatar deleted | AI 分身已删除 |
| aiAvatarSaved | AI avatar saved | AI 分身已保存 |
| aiAvatarEmpty | No AI avatar yet | 还没有 AI 分身 |
| aiAvatarEmptyTip | Create an AI avatar that represents you | 创建一个代表你的 AI 虚拟分身 |

### 创建流程
| Key | EN | ZH |
|-----|----|----|
| aiAvatarStepName | Name & Avatar | 名称和头像 |
| aiAvatarStepPersonality | Personality | 性格特征 |
| aiAvatarStepStyle | Speaking Style | 说话风格 |
| aiAvatarName | Avatar Name | 分身名称 |
| aiAvatarNameHint | Give your avatar a name | 给你的分身取个名字 |
| aiAvatarPhoto | Avatar Photo | 分身头像 |
| aiAvatarCustomPrompt | Custom Instructions | 自定义指令 |
| aiAvatarCustomPromptHint | Optional: Add special instructions for your avatar | 可选：添加特别指令来调整分身行为 |

### 性格标签
| Key | EN | ZH |
|-----|----|----|
| aiTraitEnthusiastic | Enthusiastic | 热情 |
| aiTraitProfessional | Professional | 专业 |
| aiTraitHumorous | Humorous | 幽默 |
| aiTraitEncouraging | Encouraging | 鼓励 |
| aiTraitCalm | Calm | 沉稳 |
| aiTraitFriendly | Friendly | 友好 |
| aiTraitDirect | Direct | 直接 |
| aiTraitCurious | Curious | 好奇 |

### 说话风格
| Key | EN | ZH |
|-----|----|----|
| aiStyleFriendly | Friendly & Casual | 友好随意 |
| aiStyleProfessional | Professional & Concise | 专业简洁 |
| aiStyleEncouraging | Warm & Encouraging | 温暖鼓励 |
| aiStyleHumorous | Fun & Humorous | 有趣幽默 |

### 自动回复
| Key | EN | ZH |
|-----|----|----|
| aiAutoReply | Auto Reply | 离线自动回复 |
| aiAutoReplyDesc | When you're offline for 5+ minutes, your avatar replies automatically | 当你离线超过 5 分钟时，分身自动代替你回复 |
| aiAutoReplyEnabled | Auto reply enabled | 自动回复已开启 |
| aiAutoReplyDisabled | Auto reply disabled | 自动回复已关闭 |
| aiGeneratedLabel | Replied by AI Avatar | 由 AI 分身回复 |

### 聊天
| Key | EN | ZH |
|-----|----|----|
| aiAvatarChat | Chat with Avatar | 与分身聊天 |
| aiAvatarChatHint | Say something to your avatar... | 对你的分身说点什么... |
| aiAvatarChatIntro | Chat with your AI avatar to see how it responds | 和你的 AI 分身聊聊，看看它的回复效果 |
| aiAvatarThinking | Avatar is thinking... | 分身思考中... |

### 隐私授权
| Key | EN | ZH |
|-----|----|----|
| aiConsentTitle | AI Data Authorization | AI 数据处理授权 |
| aiConsentDesc | To create an AI avatar, we need to process the following data: | 创建 AI 分身需要处理以下数据： |
| aiConsentItem1 | Your profile info (nickname, bio, sports, city) | 您的个人资料（昵称、简介、运动类型、城市） |
| aiConsentItem2 | Recent chat messages (last 10) for context | 最近的聊天消息（最近 10 条）用于上下文 |
| aiConsentItem3 | Your recent public posts (last 5) | 您最近的公开动态（最近 5 条） |
| aiConsentItem4 | Data is processed via AI and not permanently stored | 数据通过 AI 处理，不会永久存储 |
| aiConsentItem5 | Others will see an "AI replied" label on auto-replies | 对方会看到"AI 分身回复"的标记 |
| aiConsentAgree | Agree & Continue | 同意并继续 |
| aiConsentDisagree | Cancel | 取消 |

---

## 9. 里程碑

| 阶段 | 内容 | 依赖 |
|------|------|------|
| M1 | DB Migration + Edge Function + Flutter 代码框架 | 无 |
| M2 | 创建分身 UI + 分身详情管理 | M1 |
| M3 | 体验聊天 + Edge Function 联调 | M1 |
| M4 | 离线自动回复 + 消息 AI 标记 | M1 + 聊天功能 |
| M5 | PIPL 合规测试 + 安全审计 | M1-M4 |

---

## 10. 风险 & 缓解

| 风险 | 概率 | 影响 | 缓解 |
|------|------|------|------|
| AI 回复不自然 | 高 | 中 | 提供体验聊天让用户调整配置 |
| AI 回复敏感内容 | 中 | 高 | Claude API 内置安全过滤 + System Prompt 限制 |
| 用户混淆 AI 回复 | 中 | 高 | 强制 AI 标记，不可关闭 |
| 数据隐私投诉 | 低 | 高 | PIPL 三层同意 + 数据最小化 |
| Edge Function 延迟 | 中 | 中 | 异步触发，不阻塞用户操作 |
