# Week 8 上线 Checklist + 最终测试说明

## 一、W8 功能验收

### 1.1 Feed 动态流（Step 1-2）
- [ ] 3 Tab 切换正常（关注/附近/推荐），默认选中「附近」
- [ ] 动态卡片显示完整（头像/昵称/时间/正文/照片网格/城市标签）
- [ ] 下拉刷新、上拉加载更多正常
- [ ] 关注 Tab 空状态提示正确
- [ ] 点赞交互：心形变红/变回，计数 +1/-1
- [ ] 从底部「+」→「发布动态」进入发布页
- [ ] 发布页：纯文字/带照片/带城市均可正常发布
- [ ] 发布成功后 SnackBar 提示 + 自动返回 Feed

### 1.2 隐私合规（Step 4）
- [ ] 首次安装冷启动弹出隐私弹窗，不可关闭
- [ ] 点击「查看完整隐私政策」跳转隐私政策全文页
- [ ] 点击「不同意」→ App 保持空白无法使用
- [ ] 点击「同意」→ 记录到 SharedPreferences，后续启动不再弹出
- [ ] 登录时的隐私弹窗（PrivacyConsentDialog）仍正常弹出
- [ ] 首次记录训练时的数据采集授权（DataCollectionConsent）仍正常弹出
- [ ] 设置 → 隐私设置 → 隐私政策 → 正确显示全文页
- [ ] 设置 → 隐私设置 → 导出数据 → JSON 文件正常导出
- [ ] 设置 → 隐私设置 → 注销账号 → 二次确认弹窗

### 1.3 主题一致性（Step 5）
- [ ] 深色模式下 TabBar 指示器橙色、Dialog 圆角、BottomSheet 圆角
- [ ] 浅色模式下同上效果一致
- [ ] NavigationBar 选中指示器颜色正确

---

## 二、全量回归测试

### 2.1 登录流
- [ ] 手机号 + OTP 登录
- [ ] Apple 登录
- [ ] 首次登录 → 引导流（运动类型/城市/头像昵称）

### 2.2 训练模块（W1-W5）
- [ ] 记录训练（基础字段 + 运动专项成绩 + 照片）
- [ ] 训练列表（分页/筛选/搜索）
- [ ] 训练详情（metrics 卡片展示）
- [ ] 训练日历（日期标记/点击跳转）
- [ ] Apple Health 同步
- [ ] 训练草稿保存/恢复

### 2.3 训练馆模块（W4 + W7.5）
- [ ] 训练馆地图（高德地图 + 标注）
- [ ] 训练馆列表（搜索/筛选/分页）
- [ ] 训练馆详情（评分/评价/照片/运动类型）
- [ ] 提交训练馆 + 写评价
- [ ] 收藏/取消收藏（卡片心形 + 详情页 AppBar + 收藏列表页）
- [ ] 馆主认领流程

### 2.4 挑战赛模块（W6）
- [ ] 挑战列表（城市/运动类型筛选）
- [ ] 创建挑战
- [ ] 参加/退出挑战
- [ ] 排行榜 + 实时打卡

### 2.5 动态模块（W8）
- [ ] Feed 3 Tab + 动态卡片 + 点赞/评论
- [ ] 发布动态（文字 + 照片 + 城市）
- [ ] 底部「+」弹窗（记录训练 / 发布动态）

### 2.6 个人中心
- [ ] 编辑资料
- [ ] 训练日志/日历/历史入口
- [ ] 收藏训练馆入口
- [ ] 设置（主题/语言/隐私/关于/退出）

---

## 三、自动化测试

```bash
# 静态分析
flutter analyze
# 预期: No issues found!

# 全部测试
flutter test
# 预期: 219 tests passed
#   W1-W4: 92 + W5: 47 + W6: 37 + W7.5: 15 + W8: 28

# 分模块测试
flutter test test/w5_test.dart        # 47 passed
flutter test test/w6_test.dart        # 37 passed
flutter test test/w75_test.dart       # 15 passed
flutter test test/w8_test.dart        # 28 passed
flutter test test/widget_test.dart    # 冒烟测试
```

---

## 四、上线 Checklist

### 4.1 代码质量
- [ ] `flutter analyze` → 0 issues
- [ ] `flutter test` → 219 tests passed, 0 failures
- [ ] 无硬编码字符串（全部走 i18n ARB）
- [ ] 无 `print()` 语句（使用 Logger）
- [ ] 无敏感信息泄露（.env 在 .gitignore 中）

### 4.2 数据库
- [ ] 所有迁移已执行（00001 ~ 00017）
- [ ] RLS 策略覆盖所有表（SELECT/INSERT/UPDATE/DELETE）
- [ ] 触发器正常（点赞计数、评论计数、馆主认领审核通过）
- [ ] 索引覆盖高频查询字段

### 4.3 隐私合规（PIPL / PDPO）
- [ ] 三层授权弹窗：冷启动 → 登录时 → 功能使用时
- [ ] 隐私政策全文可随时查阅
- [ ] 数据导出功能可用（JSON 格式）
- [ ] 账号注销功能可用（二次确认）
- [ ] 个人资料可见性开关可用（发现列表/训练统计）

### 4.4 性能
- [ ] 列表页均有分页（defaultPageSize=20）
- [ ] 图片使用 CachedNetworkImage 缓存
- [ ] Riverpod AutoDispose 防止内存泄漏
- [ ] 无不必要的 rebuild（AsyncNotifier + family）

### 4.5 安全
- [ ] Supabase RLS 启用（所有表）
- [ ] 用户只能操作自己的数据（跨用户隔离）
- [ ] 文件上传限制（5MB，仅图片类型）
- [ ] HTTPS 全程加密

### 4.6 国际化
- [ ] 4 语言完整：English / 简体中文 / 简体中文(CN) / 繁体中文(TW)
- [ ] 所有用户可见文本走 i18n
- [ ] 日期/时间格式本地化（timeAgo）

### 4.7 发布准备
- [ ] App Icon 已配置
- [ ] 启动图已配置
- [ ] Bundle ID / 签名证书配置
- [ ] App Store Connect 元数据准备
- [ ] TestFlight 内测分发

---

## 五、W1-W8 完整文件清单

### 迁移文件（17 个）
| 文件 | 说明 |
|------|------|
| `00001_profiles.sql` | 用户资料表 |
| `00002_onboarding.sql` | 引导流字段 |
| `00003_profile_visibility.sql` | 资料可见性 |
| `00004_workout_logs.sql` | 训练日志表 + RLS |
| `00005_gyms.sql` | 训练馆表 |
| `00006_gym_reviews.sql` | 训练馆评价表 |
| `00007_gym_photos.sql` | 训练馆照片 |
| `00008_draft.sql` | 训练草稿 |
| `00009_posts.sql` | 动态/点赞/评论表 |
| `00010_social.sql` | 关注/屏蔽表 |
| `00011_challenges.sql` | 挑战赛表 |
| `00012_challenge_participants.sql` | 参与者/打卡表 |
| `00013_functions.sql` | 触发器函数 |
| `00014_health_sync.sql` | Apple Health 同步 |
| `00015_workout_metrics.sql` | 运动专项 JSONB |
| `00016_challenge_enhancements.sql` | 挑战赛增强 |
| `00017_w75_gym_favorites_claims.sql` | 收藏 + 认领 |

### Dart 功能文件
| 模块 | 文件数 | 说明 |
|------|--------|------|
| core | ~15 | 常量/网络/工具/错误/扩展 |
| auth | ~8 | 登录/引导/隐私弹窗 |
| profile | ~8 | 个人中心/设置/隐私/编辑 |
| workout | ~18 | 训练 CRUD/日历/metrics 表单/照片/Health |
| gym | ~14 | 训练馆地图/列表/详情/评价/收藏/认领 |
| challenge | ~10 | 挑战赛列表/创建/排行/打卡 |
| post | ~6 | 动态 Feed/卡片/发布/评论 |
| buddy | ~3 | 发现页 |
| shared | ~8 | AppScaffold/Avatar/EmptyState/Dialog |
| app | ~5 | Router/Theme/App |

### 测试文件
| 文件 | 测试数 | 覆盖 |
|------|--------|------|
| `test/widget_test.dart` | 冒烟 | SportTypeIcon |
| `test/w5_test.dart` | 47 | WorkoutModel/Metrics |
| `test/w6_test.dart` | 37 | Challenge/Participant/CheckIn |
| `test/w75_test.dart` | 15 | GymFavorite/GymClaim |
| `test/w8_test.dart` | 28 | Post/PostComment |
| **合计** | **219** | |

### i18n
| 文件 | 语言 | Key 数量 |
|------|------|----------|
| `app_en.arb` | English | ~120 |
| `app_zh.arb` | 简体中文 | ~120 |
| `app_zh_CN.arb` | 简体中文(CN) | ~120 |
| `app_zh_TW.arb` | 繁体中文(TW) | ~120 |
