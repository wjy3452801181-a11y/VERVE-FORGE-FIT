# Week 7.5 测试说明 — 训练馆收藏 + 馆主认领

## 一、前置准备

### 1.1 执行迁移
```bash
supabase db push
# 或在 Supabase Dashboard → SQL Editor 手动执行：
# supabase/migrations/00017_w75_gym_favorites_claims.sql
```

### 1.2 验证表创建
```sql
-- 确认 user_gym_favorites 表存在
SELECT column_name, data_type FROM information_schema.columns
WHERE table_name = 'user_gym_favorites';

-- 确认 gym_claims 表存在
SELECT column_name, data_type FROM information_schema.columns
WHERE table_name = 'gym_claims';

-- 确认 gym_claim_status 枚举
SELECT enum_range(NULL::gym_claim_status);
-- 预期: {pending,approved,rejected}
```

### 1.3 准备测试数据
确保 gyms 表中有至少 3 个 `status = 'approved'` 的训练馆。若无，可手动插入：
```sql
INSERT INTO gyms (name, address, city, country, location, latitude, longitude, sport_types, status, submitted_by)
VALUES
  ('HYROX 训练中心', '上海市静安区南京西路100号', 'shanghai', 'CN',
   ST_SetSRID(ST_MakePoint(121.4737, 31.2304), 4326), 31.2304, 121.4737,
   '{hyrox,crossfit}', 'approved', '<你的user_id>'),
  ('瑜伽之家', '北京市朝阳区建国路88号', 'beijing', 'CN',
   ST_SetSRID(ST_MakePoint(116.4074, 39.9042), 4326), 39.9042, 116.4074,
   '{yoga,pilates}', 'approved', '<你的user_id>'),
  ('CrossFit 深圳', '深圳市南山区科技园路1号', 'shenzhen', 'CN',
   ST_SetSRID(ST_MakePoint(113.9213, 22.5431), 4326), 22.5431, 113.9213,
   '{crossfit,strength}', 'approved', '<你的user_id>');
```

### 1.4 启动应用
```bash
flutter run
```

---

## 二、收藏功能测试

### 测试 1: 训练馆卡片收藏

1. 进入训练馆列表页（Tab 5 → 附近训练馆，或训练馆地图 → 列表模式）
2. 找到任意训练馆卡片，观察右侧心形图标（灰色空心）
3. 点击心形图标

**预期结果：**
- 心形变为红色实心（Icons.favorite）
- 再次点击变回灰色空心（Icons.favorite_border）

### 测试 2: 详情页收藏

1. 进入任意训练馆详情页
2. 观察 AppBar 右侧心形图标
3. 点击心形图标

**预期结果：**
- 心形变为红色实心
- 返回列表页，该卡片心形同步为红色实心

### 测试 3: 收藏列表页

1. 先收藏 2-3 个训练馆
2. 进入 Tab 5（我的） → 点击「我的收藏训练馆」
3. 查看收藏列表

**预期结果：**
- 列表显示已收藏的训练馆，按收藏时间倒序
- 每个卡片显示：缩略图、名称、地址、运动类型图标、评分
- 右侧为红色实心心形
- 点击心形取消收藏，该项从列表消失
- 点击卡片进入训练馆详情页

### 测试 4: 收藏空状态

1. 取消所有收藏
2. 进入收藏列表页

**预期结果：**
- 显示空状态图标（空心心形）+ 「暂无收藏」
- 显示按钮可跳转至训练馆列表

### 测试 5: 下拉刷新

1. 收藏 1 个训练馆
2. 进入收藏列表页
3. 在 Supabase Dashboard 中手动删除该收藏记录
4. 在 App 中下拉刷新

**预期结果：**
- 列表刷新后该项消失

---

## 三、馆主认领功能测试

### 测试 6: 未认证训练馆显示认领按钮

1. 进入一个 `is_verified = FALSE` 的训练馆详情页

**预期结果：**
- 运动类型列表下方显示「认领此场馆」按钮（OutlinedButton）
- 按钮带 store 图标

### 测试 7: 提交认领

1. 点击「认领此场馆」按钮
2. 弹出确认对话框

**预期结果：**
- 对话框标题：「认领场馆」
- 对话框内容：「您是此训练馆的馆主或管理员吗？提交认领后将进入审核流程。」
- 两个按钮：「取消」/「提交认领」

3. 点击「提交认领」

**预期结果：**
- 显示成功提示：「认领申请已提交，等待审核」
- 认领按钮消失，替换为状态卡片：「认领状态: 审核中」

### 测试 8: 重复认领

1. 对同一训练馆再次访问详情页

**预期结果：**
- 显示状态卡片「认领状态: 审核中」，不显示认领按钮
- （由 UNIQUE(gym_id, claimant_user_id) 约束防止重复提交）

### 测试 9: 已认证训练馆不显示认领

1. 进入一个 `is_verified = TRUE` 的训练馆详情页

**预期结果：**
- 不显示认领按钮，也不显示认领状态卡片
- 标题旁显示蓝V认证标记

### 测试 10: 认领审核通过（管理员模拟）

1. 在 Supabase Dashboard SQL Editor 执行：
```sql
-- 模拟管理员审核通过
UPDATE gym_claims
SET status = 'approved', reviewed_at = NOW(), reviewed_by = '<admin_user_id>'
WHERE gym_id = '<训练馆ID>' AND status = 'pending';
```

2. 刷新该训练馆详情页

**预期结果：**
- 触发器自动将 `gyms.claimed_by` 设为认领者 ID
- `gyms.is_verified` 自动设为 `TRUE`
- `gyms.verified_at` 自动填充
- 详情页显示蓝V认证标记
- 认领区域不再显示

**验证触发器：**
```sql
SELECT id, name, claimed_by, is_verified, verified_at
FROM gyms WHERE id = '<训练馆ID>';
```

---

## 四、数据库检查

### 4.1 user_gym_favorites 表
```sql
SELECT f.id, f.user_id, f.gym_id, g.name, f.created_at
FROM user_gym_favorites f
JOIN gyms g ON g.id = f.gym_id
ORDER BY f.created_at DESC;
```

### 4.2 gym_claims 表
```sql
SELECT c.id, c.gym_id, g.name AS gym_name,
       c.claimant_user_id, p.nickname AS claimant,
       c.status, c.reason, c.applied_at, c.reviewed_at
FROM gym_claims c
JOIN gyms g ON g.id = c.gym_id
JOIN profiles p ON p.id = c.claimant_user_id
ORDER BY c.applied_at DESC;
```

### 4.3 RLS 策略验证
```sql
-- user_gym_favorites: 用户只能看到自己的收藏
SELECT policyname, cmd, qual, with_check
FROM pg_policies WHERE tablename = 'user_gym_favorites';
-- 预期 3 条策略: SELECT(own), INSERT(own), DELETE(own)

-- gym_claims: 用户只能看到和提交自己的认领
SELECT policyname, cmd, qual, with_check
FROM pg_policies WHERE tablename = 'gym_claims';
-- 预期 2 条策略: SELECT(own), INSERT(own)
```

### 4.4 RLS 跨用户隔离测试
```sql
-- 用账号 A 的 JWT 登录，查询收藏
-- 应只返回账号 A 的收藏，看不到账号 B 的
SELECT * FROM user_gym_favorites;

-- 用账号 A 的 JWT，尝试删除账号 B 的收藏
-- 应返回 0 行影响
DELETE FROM user_gym_favorites WHERE user_id = '<账号B的ID>';
```

---

## 五、自动化测试

```bash
# 静态分析
flutter analyze
# 预期: No issues found!

# 全部测试
flutter test
# 预期: 191 tests passed (W1-W4: 92 + W5: 47 + W6: 37 + W7.5: 15)

# 仅 W7.5 测试
flutter test test/w75_test.dart
# 预期: 15 tests passed
```

---

## 六、W7.5 完整文件清单

| 操作 | 路径 | 说明 |
|------|------|------|
| 新建 | `supabase/migrations/00017_w75_gym_favorites_claims.sql` | 收藏表 + 认领表 + RLS + 触发器 |
| 新建 | `lib/features/gym/domain/user_gym_favorite_model.dart` | 收藏模型（支持 JOIN） |
| 新建 | `lib/features/gym/domain/gym_claim_model.dart` | 认领模型 |
| 修改 | `lib/core/constants/supabase_constants.dart` | +2 表名常量 |
| 修改 | `lib/features/gym/data/gym_repository.dart` | +6 方法（收藏 + 认领） |
| 修改 | `lib/features/gym/providers/gym_provider.dart` | +6 providers |
| 修改 | `lib/features/gym/presentation/widgets/gym_card.dart` | +心形收藏按钮 |
| 修改 | `lib/features/gym/presentation/gym_detail_page.dart` | +AppBar 收藏 + 认领区域 |
| 新建 | `lib/features/gym/presentation/gym_favorites_page.dart` | 收藏列表页 |
| 修改 | `lib/app/router.dart` | +gymFavorites 路由 |
| 修改 | `lib/features/profile/presentation/profile_page.dart` | +收藏入口菜单项 |
| 修改 | `lib/l10n/app_en.arb` | +16 i18n keys |
| 修改 | `lib/l10n/app_zh.arb` | +16 i18n keys |
| 修改 | `lib/l10n/app_zh_CN.arb` | +16 i18n keys |
| 修改 | `lib/l10n/app_zh_TW.arb` | +16 i18n keys |
| 新建 | `test/w75_test.dart` | 15 个单元测试 |
| 新建 | `docs/w75_test_guide.md` | 本文档 |
