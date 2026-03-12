# Week 8 测试说明 — Feed 动态流 + 发布

## 一、前置准备

### 1.1 确认数据库表
W8 无新迁移。动态相关表在 W4 已创建，请确认以下表存在：
```sql
-- 确认 posts 表
SELECT column_name, data_type FROM information_schema.columns
WHERE table_name = 'posts';

-- 确认 post_likes 表
SELECT column_name, data_type FROM information_schema.columns
WHERE table_name = 'post_likes';

-- 确认 post_comments 表
SELECT column_name, data_type FROM information_schema.columns
WHERE table_name = 'post_comments';

-- 确认计数触发器
SELECT trigger_name FROM information_schema.triggers
WHERE event_object_table IN ('post_likes', 'post_comments');
-- 预期: update_post_like_count, update_post_comment_count
```

### 1.2 准备测试数据
确保至少有 1 个注册用户。可手动插入动态测试数据：
```sql
INSERT INTO posts (id, user_id, content, city, photos)
VALUES
  (gen_random_uuid(), '<你的user_id>', '第一条测试动态 — HYROX 模拟赛', 'shanghai', '{}'),
  (gen_random_uuid(), '<你的user_id>', '今天瑜伽课感觉很棒', 'beijing', '{}'),
  (gen_random_uuid(), '<你的user_id>', 'CrossFit WOD: Fran 3:45', 'shanghai', '{}');
```

### 1.3 启动应用
```bash
flutter run
```

---

## 二、Feed 页面测试

### 测试 1: 3 Tab 切换

1. 进入 Tab 1（动态）
2. 观察顶部 3 个 Tab：关注 / 附近 / 推荐
3. 默认选中「附近」Tab

**预期结果：**
- TabBar 正确显示 3 个标签
- 默认高亮「附近」
- 点击切换 Tab 流畅

### 测试 2: 附近 Tab 列表

1. 切换到「附近」Tab
2. 观察动态列表

**预期结果：**
- 列表显示动态卡片（头像、昵称、时间、正文、照片网格、点赞/评论按钮）
- 按时间倒序排列
- 下拉刷新正常
- 滑到底部触发加载更多

### 测试 3: 关注 Tab 空状态

1. 切换到「关注」Tab（如未关注任何人）

**预期结果：**
- 显示空状态图标 + 「暂无关注动态」 + 提示文字

### 测试 4: 动态卡片

1. 查看任意一条动态卡片

**预期结果：**
- 左侧头像（AvatarWidget，无头像显示首字符占位）
- 昵称 + 发布时间（如 "3分钟前"）
- 右上角城市标签（如 "shanghai"）
- 正文内容
- 有照片时显示照片网格（1 张全宽，多张九宫格）
- 底部点赞/评论互动栏

### 测试 5: 点赞交互

1. 找到一条未点赞的动态
2. 点击心形图标

**预期结果：**
- 心形变红色实心
- 点赞数 +1
- 再次点击变回空心，点赞数 -1

---

## 三、发布动态测试

### 测试 6: 从底部「+」进入发布

1. 点击底部导航栏中间「+」按钮
2. 弹出底部选项
3. 点击「发布动态」

**预期结果：**
- 弹出模态底部弹窗，显示「记录训练」和「发布动态」两个选项
- 「发布动态」有副标题「分享你的训练瞬间」
- 点击后跳转到发布页

### 测试 7: 发布动态页

1. 进入发布动态页

**预期结果：**
- AppBar 标题「发布动态」
- 右上角「发布」按钮（初始禁用状态）
- 文本输入区（最多 500 字）
- 照片网格（可添加最多 9 张）
- 底部城市选择 ChoiceChip

### 测试 8: 纯文字发布

1. 输入文本内容
2. 观察「发布」按钮变为可用
3. 点击发布

**预期结果：**
- 按钮变为加载状态
- 发布成功后显示 SnackBar「动态发布成功」
- 自动返回 Feed 页
- Feed 列表刷新后可看到新动态

### 测试 9: 带照片发布

1. 输入文本
2. 点击照片添加区域选择 1-3 张照片
3. 确认照片缩略图显示，可删除
4. 点击发布

**预期结果：**
- 照片上传成功，动态卡片显示照片网格
- 照片可正常加载

### 测试 10: 带城市发布

1. 输入文本
2. 选择一个城市 ChoiceChip（如 shanghai）
3. 发布

**预期结果：**
- 发布成功
- 动态卡片右上角显示城市标签

### 测试 11: 空内容无法发布

1. 不输入任何文本，不选照片
2. 观察发布按钮

**预期结果：**
- 发布按钮保持禁用状态

---

## 四、数据库检查

### 4.1 posts 表
```sql
SELECT p.id, p.user_id, p.content, p.city, p.like_count, p.comment_count,
       pr.nickname
FROM posts p
JOIN profiles pr ON pr.id = p.user_id
WHERE p.deleted_at IS NULL
ORDER BY p.created_at DESC
LIMIT 10;
```

### 4.2 post_likes 表
```sql
SELECT pl.id, pl.post_id, pl.user_id, p.content
FROM post_likes pl
JOIN posts p ON p.id = pl.post_id
ORDER BY pl.created_at DESC;
```

### 4.3 确认点赞计数触发器
```sql
-- 点赞后 posts.like_count 应自动更新
SELECT id, content, like_count FROM posts WHERE id = '<动态ID>';
```

---

## 五、自动化测试

```bash
# 静态分析
flutter analyze
# 预期: No issues found!

# 全部测试
flutter test
# 预期: 219 tests passed (W1-W4: 92 + W5: 47 + W6: 37 + W7.5: 15 + W8: 28)

# 仅 W8 测试
flutter test test/w8_test.dart
# 预期: 28 tests passed
```

---

## 六、W8 完整文件清单

| 操作 | 路径 | 说明 |
|------|------|------|
| 新建 | `lib/features/post/domain/post_model.dart` | 动态模型（profiles JOIN、timeAgo、copyWith） |
| 新建 | `lib/features/post/domain/post_comment_model.dart` | 评论模型（parentId 回复、profiles JOIN） |
| 新建 | `lib/features/post/data/post_repository.dart` | Repository（CRUD + 点赞 + 评论 + 分页） |
| 新建 | `lib/features/post/providers/post_provider.dart` | 7 个 Provider（Feed Tab + 列表 + 详情 + 操作） |
| 重写 | `lib/features/post/presentation/feed_page.dart` | 3 Tab Feed 页（关注/附近/推荐 + 下拉刷新 + 无限滚动） |
| 新建 | `lib/features/post/presentation/widgets/post_card.dart` | 动态卡片组件（头像 + 正文 + 照片 + 互动栏） |
| 新建 | `lib/features/post/presentation/post_create_page.dart` | 发布动态页（文本 + 照片 + 城市 + 上传） |
| 修改 | `lib/shared/widgets/app_scaffold.dart` | 「+」按钮发布动态联动 postCreate 路由 |
| 修改 | `lib/app/router.dart` | +postCreate 路由常量 + GoRoute |
| 修改 | `lib/l10n/app_en.arb` | +14 个 post i18n keys |
| 修改 | `lib/l10n/app_zh.arb` | +14 个 post i18n keys |
| 修改 | `lib/l10n/app_zh_CN.arb` | +14 个 post i18n keys |
| 修改 | `lib/l10n/app_zh_TW.arb` | +14 个 post i18n keys |
| 新建 | `test/w8_test.dart` | 28 个单元测试 |
| 新建 | `docs/w8_test_guide.md` | 本文档 |
