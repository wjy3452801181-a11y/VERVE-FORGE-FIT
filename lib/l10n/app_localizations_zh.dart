// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'VerveForge';

  @override
  String get tabFeed => '动态';

  @override
  String get tabGyms => '训练馆';

  @override
  String get tabChallenge => '挑战';

  @override
  String get tabProfile => '我的';

  @override
  String get tabNearby => '附近';

  @override
  String get loginTitle => '登录 VerveForge';

  @override
  String get loginSubtitle => '记录训练·发现伙伴·挑战自我';

  @override
  String get emailLabel => '邮箱';

  @override
  String get emailHint => '请输入邮箱地址';

  @override
  String get passwordLabel => '密码';

  @override
  String get passwordHint => '请输入密码';

  @override
  String get login => '登录';

  @override
  String get register => '注册';

  @override
  String get switchToRegister => '没有账号？立即注册';

  @override
  String get switchToLogin => '已有账号？直接登录';

  @override
  String get orLoginWith => '或使用以下方式登录';

  @override
  String get signInWithApple => '通过 Apple 登录';

  @override
  String get privacyAgreement => '登录即表示您同意我们的';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get termsOfService => '服务条款';

  @override
  String get and => '和';

  @override
  String get onboardingStep1Title => '选择你的运动';

  @override
  String get onboardingStep1Subtitle => '选择你感兴趣的运动类型（可多选）';

  @override
  String get onboardingStep2Title => '选择你的城市';

  @override
  String get onboardingStep2Subtitle => '我们会推荐附近的训练馆和伙伴';

  @override
  String get onboardingStep3Title => '完善个人资料';

  @override
  String get onboardingStep3Subtitle => '设置头像和昵称，让伙伴认识你';

  @override
  String get next => '下一步';

  @override
  String get done => '完成';

  @override
  String get skip => '跳过';

  @override
  String get sportHyrox => 'HYROX';

  @override
  String get sportCrossfit => 'CrossFit';

  @override
  String get sportYoga => '瑜伽';

  @override
  String get sportPilates => '普拉提';

  @override
  String get sportRunning => '跑步';

  @override
  String get sportSwimming => '游泳';

  @override
  String get sportStrength => '力量训练';

  @override
  String get sportOther => '其他';

  @override
  String get cityBeijing => '北京';

  @override
  String get cityShanghai => '上海';

  @override
  String get cityGuangzhou => '广州';

  @override
  String get cityShenzhen => '深圳';

  @override
  String get cityHongkong => '香港';

  @override
  String get levelBeginner => '入门';

  @override
  String get levelIntermediate => '进阶';

  @override
  String get levelAdvanced => '高级';

  @override
  String get levelElite => '精英';

  @override
  String get feedTitle => '动态';

  @override
  String get feedTabFollowing => '关注';

  @override
  String get feedTabNearby => '附近';

  @override
  String get feedTabLatest => '最新';

  @override
  String get feedTabRecommend => '推荐';

  @override
  String get discoverTitle => '发现';

  @override
  String get discoverNearbyPeople => '附近的人';

  @override
  String get discoverNearbyGyms => '附近训练馆';

  @override
  String get sendBuddyRequest => '约练';

  @override
  String get nearbyTitle => '附近';

  @override
  String get nearbyBuddies => '附近伙伴';

  @override
  String get nearbyGymsRecommend => '推荐训练馆';

  @override
  String get nearbyNoBuddies => '附近暂无伙伴';

  @override
  String get nearbyNoBuddiesTip => '试试扩大搜索范围';

  @override
  String get nearbyNoGyms => '附近暂无训练馆';

  @override
  String get nearbyNoGymsTip => '可以提交一个你常去的训练馆';

  @override
  String get workoutCreate => '记录训练';

  @override
  String get workoutType => '运动类型';

  @override
  String get workoutDuration => '训练时长（分钟）';

  @override
  String get workoutIntensity => '训练强度';

  @override
  String get workoutNotes => '备注';

  @override
  String get workoutPhotos => '训练照片';

  @override
  String get workoutSave => '保存';

  @override
  String get workoutShareAsPost => '同时发布为动态？';

  @override
  String get workoutCalendar => '训练日历';

  @override
  String get workoutDetail => '训练详情';

  @override
  String get workoutHistory => '训练历史';

  @override
  String get workoutDraft => '草稿';

  @override
  String get workoutDrafts => '训练草稿';

  @override
  String get workoutDate => '训练日期';

  @override
  String get workoutTime => '训练时间';

  @override
  String get workoutSaveDraft => '保存草稿';

  @override
  String get workoutDeleteConfirm => '确定删除这条训练记录吗？';

  @override
  String workoutMinutes(int count) {
    return '$count 分钟';
  }

  @override
  String workoutIntensityLevel(int level) {
    return '强度 $level/10';
  }

  @override
  String get workoutThisWeek => '本周训练';

  @override
  String get workoutThisMonth => '本月训练';

  @override
  String get workoutTotalHours => '总时长';

  @override
  String get workoutFilterAll => '全部';

  @override
  String get workoutNoRecords => '还没有训练记录';

  @override
  String get workoutStartFirst => '去记录第一次训练吧';

  @override
  String get healthSync => 'Apple Health 同步';

  @override
  String get healthSyncDescription => '自动同步 Apple Health 中的训练数据';

  @override
  String get healthSyncNow => '立即同步';

  @override
  String get healthSyncing => '同步中...';

  @override
  String get healthSyncSuccess => '同步完成';

  @override
  String get healthSyncError => '同步失败';

  @override
  String get healthPermissionDenied => '请在设置中允许 VerveForge 访问健康数据';

  @override
  String get metricsTitle => '运动专项成绩（可选）';

  @override
  String get metricsStation => '分站';

  @override
  String get metricsTime => '用时';

  @override
  String get metricsTotalTime => '总成绩';

  @override
  String get metricsWod => 'WOD 名称';

  @override
  String get metricsScore => '成绩';

  @override
  String get metricsWodType => 'WOD 类型';

  @override
  String get metricsMovement => '动作列表';

  @override
  String get metricsDistance => '距离（公里）';

  @override
  String get metricsPace => '配速（分钟/公里）';

  @override
  String get metricsElevation => '爬升（米）';

  @override
  String get metricsFocusArea => '专注区域';

  @override
  String get metricsDifficulty => '难度';

  @override
  String get metricsClassName => '课程名称';

  @override
  String get dataCollectionConsent => '训练数据采集授权';

  @override
  String get dataCollectionDesc =>
      '为了提供训练数据分析服务，VerveForge 需要采集以下信息：\n\n• 运动成绩数据（用时、得分、配速等）\n• Apple Health 健康数据（心率、卡路里、步数）\n• 训练照片和视频\n\n您的数据将加密存储，可随时在设置中导出或删除。';

  @override
  String get challengeTitle => '挑战';

  @override
  String get challengeCreate => '创建挑战';

  @override
  String get challengeJoin => '参加';

  @override
  String get challengeLeave => '退出';

  @override
  String get challengeLeaderboard => '排行榜';

  @override
  String get challengeCheckIn => '打卡';

  @override
  String get challengeProgress => '进度';

  @override
  String get challengeDetail => '挑战详情';

  @override
  String get challengeStartDate => '开始日期';

  @override
  String get challengeEndDate => '结束日期';

  @override
  String get challengeGoalType => '目标类型';

  @override
  String get challengeGoalValue => '目标值';

  @override
  String get challengeGoalSessions => '总次数';

  @override
  String get challengeGoalMinutes => '总时长(分钟)';

  @override
  String get challengeGoalDays => '总天数';

  @override
  String get challengeCity => '城市';

  @override
  String get challengeCityAll => '全部城市';

  @override
  String get challengeSportType => '运动类型';

  @override
  String get challengeMaxParticipants => '最大参与人数';

  @override
  String get challengeDescription => '描述';

  @override
  String challengeParticipants(int count) {
    return '$count 人参加';
  }

  @override
  String challengeRemainingDays(int days) {
    return '还剩 $days 天';
  }

  @override
  String get challengeStatusActive => '进行中';

  @override
  String get challengeStatusCompleted => '已结束';

  @override
  String get challengeStatusCancelled => '已取消';

  @override
  String get challengeFull => '已满员';

  @override
  String get challengeNoRecords => '暂无挑战';

  @override
  String get challengeStartFirst => '创建或参加运动挑战，与伙伴一起进步';

  @override
  String get challengeCreateSuccess => '挑战创建成功';

  @override
  String get challengeJoinSuccess => '已加入挑战';

  @override
  String get challengeLeaveSuccess => '已退出挑战';

  @override
  String get challengeLeaveConfirm => '确定退出这个挑战吗？';

  @override
  String get challengeRank => '排名';

  @override
  String get challengeCheckInCount => '打卡次数';

  @override
  String get challengeRealtime => '实时';

  @override
  String get challengeNewAvailable => '挑战赛有更新，点击刷新';

  @override
  String get profileTitle => '我的';

  @override
  String get profileEdit => '编辑资料';

  @override
  String get profileWorkoutLog => '训练日志';

  @override
  String get profileSettings => '设置';

  @override
  String get profileNickname => '昵称';

  @override
  String get profileBio => '简介';

  @override
  String get profileAvatar => '头像';

  @override
  String get profileBioHint => '介绍一下你自己';

  @override
  String get profileGender => '性别';

  @override
  String get profileGenderMale => '男';

  @override
  String get profileGenderFemale => '女';

  @override
  String get profileGenderOther => '其他';

  @override
  String get profileGenderPreferNotToSay => '不愿透露';

  @override
  String get profileCity => '城市';

  @override
  String get profileExperienceLevel => '运动经验';

  @override
  String get profileSportPreference => '运动偏好';

  @override
  String get profileNicknameError => '请输入有效昵称（2-20字符）';

  @override
  String get profileSportSelectionError => '请至少选择一项运动';

  @override
  String get profileSaveSuccess => '保存成功';

  @override
  String get profileUserNotFound => '用户不存在';

  @override
  String get avatarPickerGallery => '从相册选择';

  @override
  String get avatarPickerCamera => '拍照';

  @override
  String get avatarPickerCropTitle => '裁剪头像';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsTheme => '主题';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsThemeSystem => '跟随系统';

  @override
  String get settingsPrivacy => '隐私设置';

  @override
  String get settingsAbout => '关于';

  @override
  String get settingsLogout => '退出登录';

  @override
  String get settingsDeleteAccount => '注销账号';

  @override
  String get settingsExportData => '导出我的数据';

  @override
  String get privacyTitle => '隐私政策';

  @override
  String get privacyAgree => '我已阅读并同意';

  @override
  String get privacyDisagree => '不同意';

  @override
  String get commonCancel => '取消';

  @override
  String get commonConfirm => '确认';

  @override
  String get commonSave => '保存';

  @override
  String get commonDelete => '删除';

  @override
  String get commonEdit => '编辑';

  @override
  String get commonShare => '分享';

  @override
  String get commonReport => '举报';

  @override
  String get commonBlock => '屏蔽';

  @override
  String get commonRetry => '重试';

  @override
  String get commonLoading => '加载中...';

  @override
  String get commonEmpty => '暂无数据';

  @override
  String get commonError => '出错了，请重试';

  @override
  String get commonSuccess => '操作成功';

  @override
  String get commonNoNetwork => '网络连接失败，请检查网络';

  @override
  String get commonDone => '完成';

  @override
  String get chatTitle => '私信';

  @override
  String get chatNoConversations => '暂无消息';

  @override
  String get chatNoConversationsTip => '和好友聊聊天吧';

  @override
  String get chatEmpty => '发送第一条消息吧';

  @override
  String get chatInputHint => '输入消息...';

  @override
  String get gymTitle => '训练馆';

  @override
  String get gymNearby => '附近训练馆';

  @override
  String get gymSearch => '搜索训练馆...';

  @override
  String get gymDetail => '训练馆详情';

  @override
  String get gymSubmit => '提交训练馆';

  @override
  String get gymAddress => '地址';

  @override
  String get gymPhone => '电话';

  @override
  String get gymWebsite => '网站';

  @override
  String get gymOpeningHours => '营业时间';

  @override
  String get gymSportTypes => '运动类型';

  @override
  String get gymReviews => '评价';

  @override
  String get gymWriteReview => '写评价';

  @override
  String get gymRating => '评分';

  @override
  String get gymNoReviews => '暂无评价';

  @override
  String get gymSubmitSuccess => '训练馆已提交，等待审核';

  @override
  String get gymPending => '待审核';

  @override
  String get gymVerified => '已认证';

  @override
  String get gymFavorite => '收藏';

  @override
  String get gymFavorited => '已收藏';

  @override
  String get gymFavoriteAdded => '已添加收藏';

  @override
  String get gymFavoriteRemoved => '已取消收藏';

  @override
  String get gymMyFavorites => '我的收藏训练馆';

  @override
  String get gymNoFavorites => '暂无收藏';

  @override
  String get gymClaimThis => '认领此场馆';

  @override
  String get gymClaimConfirm => '认领场馆';

  @override
  String get gymClaimConfirmDesc => '您是此训练馆的馆主或管理员吗？提交认领后将进入审核流程。';

  @override
  String get gymClaimSubmit => '提交认领';

  @override
  String get gymClaimSuccess => '认领申请已提交，等待审核';

  @override
  String get gymClaimStatus => '认领状态';

  @override
  String get gymClaimPending => '审核中';

  @override
  String get gymClaimApproved => '已通过';

  @override
  String get gymClaimRejected => '已拒绝';

  @override
  String get postCreate => '发布动态';

  @override
  String get postPublish => '发布';

  @override
  String get postPublishSuccess => '动态发布成功';

  @override
  String get postContentHint => '分享你的训练或想法...';

  @override
  String get postCity => '城市';

  @override
  String get postCreateSubtitle => '分享你的训练瞬间';

  @override
  String get postEmpty => '暂无动态';

  @override
  String get postEmptyTip => '成为第一个分享动态的人';

  @override
  String get postNewAvailable => '有新动态，点击刷新';

  @override
  String get postNoFollowing => '暂无关注动态';

  @override
  String get postFollowTip => '关注运动伙伴，查看他们的训练动态';

  @override
  String postLikes(int count) {
    return '$count 个赞';
  }

  @override
  String postComments(int count) {
    return '$count 条评论';
  }

  @override
  String get postDeleteConfirm => '确定删除这条动态吗？';

  @override
  String get postDeleted => '动态已删除';

  @override
  String get appLaunchConsentTitle => '欢迎使用 VerveForge';

  @override
  String get appLaunchConsentDesc => '在使用我们的服务前，请了解我们如何处理您的数据：';

  @override
  String get appLaunchConsentItem1 => '账号信息：邮箱、Apple ID、昵称、头像';

  @override
  String get appLaunchConsentItem2 => '训练数据：训练日志、Apple Health 同步、照片';

  @override
  String get appLaunchConsentItem3 => '位置信息：用于发现附近训练馆和训练伙伴';

  @override
  String get appLaunchConsentItem4 => '您的数据加密存储，可随时导出或删除';

  @override
  String get appLaunchConsentReadFull => '查看完整隐私政策';

  @override
  String get profileNoBio => '还没有设置简介';

  @override
  String get profileRegisterFirst => '请先完成注册';

  @override
  String get profileGoRegister => '去注册';

  @override
  String get profileMyChallenges => '我的挑战';

  @override
  String get profileMyBuddies => '我的伙伴';

  @override
  String get profileSectionTraining => '训练';

  @override
  String get profileSectionSocial => '社交';

  @override
  String get profileSectionAccount => '账户';

  @override
  String get buddyListTitle => '好友列表';

  @override
  String get buddyRequests => '好友请求';

  @override
  String get buddyReceived => '收到的';

  @override
  String get buddySent => '发出的';

  @override
  String get buddyAccept => '接受';

  @override
  String get buddyReject => '拒绝';

  @override
  String get buddyCancel => '撤回';

  @override
  String get buddyRemove => '删除好友';

  @override
  String get buddyPending => '等待回复';

  @override
  String get buddyAccepted => '已成为好友';

  @override
  String get buddyNoRequests => '暂无好友请求';

  @override
  String get buddyNoRequestsTip => '去附近页面发现更多运动伙伴';

  @override
  String get buddyNoSentRequests => '暂无发出的请求';

  @override
  String get buddyNoBuddies => '还没有好友';

  @override
  String get buddyNoBuddiesTip => '去附近页面发现运动伙伴吧';

  @override
  String get buddyRemoveConfirm => '删除好友';

  @override
  String get buddyRemoveConfirmDesc => '确定删除该好友吗？删除后需要重新发送请求';

  @override
  String get buddyRemoved => '已删除好友';

  @override
  String get profileMyDrafts => '训练草稿';

  @override
  String get profilePrivacy => '隐私设置';

  @override
  String get settingsFollowSystem => '跟随系统';

  @override
  String get settingsOpenSource => '开源协议';

  @override
  String get settingsLogoutConfirm => '确认退出登录？';

  @override
  String get settingsLogoutDesc => '退出后需要重新登录';

  @override
  String get aiAvatarTitle => '我的 AI 分身';

  @override
  String get aiAvatarCreate => '创建 AI 分身';

  @override
  String get aiAvatarEdit => '编辑分身';

  @override
  String get aiAvatarDelete => '删除分身';

  @override
  String get aiAvatarDeleteConfirm => '确定删除 AI 分身吗？此操作不可恢复。';

  @override
  String get aiAvatarDeleted => 'AI 分身已删除';

  @override
  String get aiAvatarSaved => 'AI 分身已保存';

  @override
  String get aiAvatarEmpty => '还没有 AI 分身';

  @override
  String get aiAvatarEmptyTip => '创建一个代表你的 AI 虚拟分身';

  @override
  String get aiAvatarStepName => '名称和风格';

  @override
  String get aiAvatarStepPersonality => '性格特征';

  @override
  String get aiAvatarStepStyle => '选择外貌';

  @override
  String get aiAvatarName => '分身名称';

  @override
  String get aiAvatarNameHint => '给你的分身取个名字';

  @override
  String get aiAvatarPhoto => '分身头像';

  @override
  String get aiAvatarCustomPrompt => '自定义指令';

  @override
  String get aiAvatarCustomPromptHint => '可选：添加特别指令来调整分身行为';

  @override
  String get aiAvatarPickPreset => '选择一个预设头像';

  @override
  String get aiAvatarOrUpload => '或上传自定义头像';

  @override
  String get aiAvatarPreviewTitle => '风格预览';

  @override
  String get aiAvatarPreviewHint => '你的分身会这样回复：';

  @override
  String get aiAvatarSelectTraitsHint => '选择符合你的标签（最多 5 个）';

  @override
  String get presetRunner => '跑者';

  @override
  String get presetYogi => '瑜伽人';

  @override
  String get presetLifter => '举铁人';

  @override
  String get presetSwimmer => '游泳者';

  @override
  String get presetCyclist => '骑行者';

  @override
  String get presetBoxer => '拳击手';

  @override
  String get presetClimber => '攀岩者';

  @override
  String get presetDancer => '舞者';

  @override
  String get presetMartial => '武术家';

  @override
  String get presetSkier => '滑雪者';

  @override
  String get presetSurfer => '冲浪者';

  @override
  String get presetTennis => '网球手';

  @override
  String get presetBasketball => '篮球手';

  @override
  String get presetSoccer => '足球迷';

  @override
  String get presetHiker => '徒步者';

  @override
  String get presetGymnast => '体操人';

  @override
  String get presetRower => '划船者';

  @override
  String get presetSkater => '滑冰者';

  @override
  String get presetNinja => '忍者';

  @override
  String get presetRobot => '机器人';

  @override
  String get presetFire => '火焰';

  @override
  String get presetLightning => '闪电';

  @override
  String get presetStar => '星星';

  @override
  String get presetDiamond => '钻石';

  @override
  String get aiTraitEarlyRunner => '晨跑达人';

  @override
  String get aiTraitYogaMaster => '瑜伽达人';

  @override
  String get aiTraitIronAddict => '举铁狂魔';

  @override
  String get aiTraitCrossfitFanatic => 'CrossFit 狂热粉';

  @override
  String get aiTraitMarathoner => '马拉松跑者';

  @override
  String get aiTraitGymRat => '健身房常客';

  @override
  String get aiTraitOutdoorExplorer => '户外探险家';

  @override
  String get aiTraitFlexibilityPro => '柔韧性达人';

  @override
  String get aiTraitTeamPlayer => '团队合作者';

  @override
  String get aiTraitSoloWarrior => '独行侠';

  @override
  String get aiTraitTechGeek => '科技极客';

  @override
  String get aiTraitNutritionNerd => '营养学家';

  @override
  String get aiTraitRestDayHater => '不需要休息日';

  @override
  String get aiTraitWarmupSkipper => '跳过热身';

  @override
  String get aiTraitPrBeast => 'PR 猛兽';

  @override
  String get aiTraitCheerleader => '啦啦队长';

  @override
  String get aiTraitEnthusiastic => '热情';

  @override
  String get aiTraitProfessional => '专业';

  @override
  String get aiTraitHumorous => '幽默';

  @override
  String get aiTraitEncouraging => '鼓励';

  @override
  String get aiTraitCalm => '沉稳';

  @override
  String get aiTraitFriendly => '友好';

  @override
  String get aiTraitDirect => '直接';

  @override
  String get aiTraitCurious => '好奇';

  @override
  String get aiStyleLively => '活泼';

  @override
  String get aiStyleLivelyDesc => '充满活力、热情洋溢，喜欢用感叹号';

  @override
  String get aiStyleLivelyPreview => '太棒了！！今早刚跑完 5 公里 🏃💨 天气超好！下次一起跑呀？';

  @override
  String get aiStyleSteady => '沉稳';

  @override
  String get aiStyleSteadyDesc => '冷静且理性，言简意赅、就事论事';

  @override
  String get aiStyleSteadyPreview => '晨跑完毕。5 公里用时 24 分钟，配速稳定。天气不错。';

  @override
  String get aiStyleHumorous => '幽默';

  @override
  String get aiStyleHumorousDesc => '风趣且俏皮，擅长自嘲和段子';

  @override
  String get aiStyleHumorousPreview => '今天跑了 5 公里…嗯，腿跑了，脑子还在被窝里 😂 还好歌单在线！';

  @override
  String get aiStyleFriendly => '友好随意';

  @override
  String get aiStyleProfessional => '专业简洁';

  @override
  String get aiStyleEncouraging => '温暖鼓励';

  @override
  String get aiAutoReply => '离线自动回复';

  @override
  String get aiAutoReplyDesc => '当你离线超过 5 分钟时，分身自动代替你回复';

  @override
  String get aiAutoReplyEnabled => '自动回复已开启';

  @override
  String get aiAutoReplyDisabled => '自动回复已关闭';

  @override
  String get aiGeneratedLabel => '由 AI 分身回复';

  @override
  String get aiAvatarChat => '与分身聊天';

  @override
  String get aiAvatarChatHint => '对你的分身说点什么...';

  @override
  String get aiAvatarChatIntro => '和你的 AI 分身聊聊，看看它的回复效果';

  @override
  String get aiAvatarThinking => '分身思考中...';

  @override
  String get aiConsentTitle => 'AI 数据处理授权';

  @override
  String get aiConsentDesc => '创建 AI 分身需要处理以下数据：';

  @override
  String get aiConsentItem1 => '您的个人资料（昵称、简介、运动类型、城市）';

  @override
  String get aiConsentItem2 => '最近的聊天消息（最近 10 条）用于上下文';

  @override
  String get aiConsentItem3 => '您最近的公开动态（最近 5 条）';

  @override
  String get aiConsentItem4 => '数据通过 AI 处理，不会永久存储';

  @override
  String get aiConsentItem5 => '对方会看到「AI 分身回复」的标记';

  @override
  String get aiConsentAgree => '同意并继续';

  @override
  String get aiConsentDisagree => '取消';

  @override
  String get aiChatQuickLegDay => '今天练腿了';

  @override
  String get aiChatQuickRan5k => '刚跑完 5km';

  @override
  String get aiChatQuickFeelSore => '全身酸痛';

  @override
  String get aiChatQuickRestDay => '今天休息日';

  @override
  String get aiChatQuickNewPR => '破了 PR！';

  @override
  String get aiChatStartChat => '立即聊天';

  @override
  String get aiChatNoMessages => '还没有消息';

  @override
  String get aiChatNoMessagesTip => '发送第一条消息开始聊天吧';

  @override
  String get aiChatSendFailed => '发送失败，请重试';

  @override
  String get aiChatLoadingHistory => '加载历史消息...';

  @override
  String aiChatMessageTime(String time) {
    return '$time';
  }

  @override
  String get aiChatDisclaimer => 'AI 回复仅供参考，不代表本人意见';

  @override
  String get aiChatThinkingWorkout => '分身正在思考你今天的训练…';

  @override
  String get aiChatThinkingReply => '分身正在组织回复…';

  @override
  String get aiChatThinkingAnalyze => '分身正在分析你的状态…';

  @override
  String get aiChatEmptyLearning => '分身正在学习你的习惯…';

  @override
  String get aiChatSmartRecommend => '智能推荐';

  @override
  String get aiAutoReplyActive => 'AI 分身正在替你回复消息';

  @override
  String get aiAutoReplyBadge => 'AI 分身代回复';

  @override
  String get aiAutoReplyConsentRequired => '请先完成 AI 数据处理授权';

  @override
  String get aiAutoReplyStatusOn => '自动回复已开启，离线时分身将代你回复';

  @override
  String get aiAutoReplyStatusOff => '自动回复已关闭';

  @override
  String get aiProfileUpdate => '画像学习';

  @override
  String get aiProfileUpdateBtn => '更新画像';

  @override
  String get aiProfileUpdating => '分身正在学习你的习惯…';

  @override
  String get aiProfileUpdateSuccess => '画像更新完成';

  @override
  String get aiProfileLastUpdated => '上次更新';

  @override
  String get aiProfileNeverUpdated => '尚未更新画像';

  @override
  String get aiProfileAutoRefresh => '对话后自动学习';

  @override
  String get aiProfileManualUpdateBtn => '更新我的画像';

  @override
  String get aiProfileUpdateConfirmTitle => '更新 AI 分身画像？';

  @override
  String get aiProfileUpdateConfirmDesc =>
      '将基于最近对话和训练记录更新分身的性格、习惯和说话风格。数据仅用于回复，不用于其他目的。确定更新吗？';

  @override
  String get aiProfileUpdateConfirmBtn => '确认更新';

  @override
  String get aiProfileUpdateFailed => '画像更新失败，请重试';

  @override
  String get aiProfileUpdateHint => '已记录，可在分身详情页更新画像';

  @override
  String get aiChatCopied => '已复制';

  @override
  String get aiChatCopyMessage => '复制消息';

  @override
  String get aiChatVoiceComingSoon => '语音输入即将上线';

  @override
  String get aiReplyFilteredHint => '分身回复被过滤（内容不合适）';

  @override
  String get aiReplyFilteredSystem => '此回复已被内容审核过滤';

  @override
  String get aiReplyFilteredNotice => '分身回复因安全原因被拦截';

  @override
  String get aiReplyFilteredFallback => '分身暂时无法回复，请稍后尝试。';

  @override
  String get aiContentSafetyTitle => '内容安全';

  @override
  String get aiShareTitle => '分享分身';

  @override
  String get aiShareBtn => '分享我的分身';

  @override
  String get aiShareSubtitle => '将你的 AI 分身分享给好友';

  @override
  String get aiShareToFeed => '分享到动态';

  @override
  String get aiShareToFeedDesc => '在动态中展示你的分身';

  @override
  String get aiShareToChallenge => '分享到挑战赛';

  @override
  String get aiShareToChallengeDesc => '在挑战赛中展示你的分身';

  @override
  String get aiShareToGroup => '分享到群聊';

  @override
  String get aiShareToGroupDesc => '发送你的分身到群聊';

  @override
  String get aiShareCopyLink => '复制分享链接';

  @override
  String get aiShareConfirmTitle => '分享你的分身？';

  @override
  String get aiShareConfirmDesc => '你的分身公开信息（名称、头像、个性标签、说话风格）将对他人可见。私人数据不会被分享。';

  @override
  String get aiShareConfirmBtn => '确认分享';

  @override
  String get aiShareSuccess => '分身分享成功';

  @override
  String get aiShareFailed => '分享失败，请重试';

  @override
  String get aiShareLimitReached => '今日分享次数已达上限（每日最多 5 次）';

  @override
  String get aiShareLinkCopied => '分享链接已复制';

  @override
  String get aiShareViewTitle => 'AI 分身';

  @override
  String get aiShareNotFound => '分身不存在';

  @override
  String get aiShareNotFoundDesc => '该分享链接可能已过期或分身已被删除';

  @override
  String get notificationTitle => '通知';

  @override
  String get notificationMarkAllRead => '全部已读';

  @override
  String get notificationEmpty => '暂无通知';

  @override
  String get notificationEmptyTip => '有人与你互动时，通知会出现在这里';
}

/// The translations for Chinese, as used in China (`zh_CN`).
class AppLocalizationsZhCn extends AppLocalizationsZh {
  AppLocalizationsZhCn() : super('zh_CN');

  @override
  String get appName => 'VerveForge';

  @override
  String get tabFeed => '动态';

  @override
  String get tabGyms => '训练馆';

  @override
  String get tabChallenge => '挑战';

  @override
  String get tabProfile => '我的';

  @override
  String get tabNearby => '附近';

  @override
  String get loginTitle => '登录 VerveForge';

  @override
  String get loginSubtitle => '记录训练·发现伙伴·挑战自我';

  @override
  String get emailLabel => '邮箱';

  @override
  String get emailHint => '请输入邮箱地址';

  @override
  String get passwordLabel => '密码';

  @override
  String get passwordHint => '请输入密码';

  @override
  String get login => '登录';

  @override
  String get register => '注册';

  @override
  String get switchToRegister => '没有账号？立即注册';

  @override
  String get switchToLogin => '已有账号？直接登录';

  @override
  String get orLoginWith => '或使用以下方式登录';

  @override
  String get signInWithApple => '通过 Apple 登录';

  @override
  String get privacyAgreement => '登录即表示您同意我们的';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get termsOfService => '服务条款';

  @override
  String get and => '和';

  @override
  String get onboardingStep1Title => '选择你的运动';

  @override
  String get onboardingStep1Subtitle => '选择你感兴趣的运动类型（可多选）';

  @override
  String get onboardingStep2Title => '选择你的城市';

  @override
  String get onboardingStep2Subtitle => '我们会推荐附近的训练馆和伙伴';

  @override
  String get onboardingStep3Title => '完善个人资料';

  @override
  String get onboardingStep3Subtitle => '设置头像和昵称，让伙伴认识你';

  @override
  String get next => '下一步';

  @override
  String get done => '完成';

  @override
  String get skip => '跳过';

  @override
  String get sportHyrox => 'HYROX';

  @override
  String get sportCrossfit => 'CrossFit';

  @override
  String get sportYoga => '瑜伽';

  @override
  String get sportPilates => '普拉提';

  @override
  String get sportRunning => '跑步';

  @override
  String get sportSwimming => '游泳';

  @override
  String get sportStrength => '力量训练';

  @override
  String get sportOther => '其他';

  @override
  String get cityBeijing => '北京';

  @override
  String get cityShanghai => '上海';

  @override
  String get cityGuangzhou => '广州';

  @override
  String get cityShenzhen => '深圳';

  @override
  String get cityHongkong => '香港';

  @override
  String get levelBeginner => '入门';

  @override
  String get levelIntermediate => '进阶';

  @override
  String get levelAdvanced => '高级';

  @override
  String get levelElite => '精英';

  @override
  String get feedTitle => '动态';

  @override
  String get feedTabFollowing => '关注';

  @override
  String get feedTabNearby => '附近';

  @override
  String get feedTabLatest => '最新';

  @override
  String get feedTabRecommend => '推荐';

  @override
  String get discoverTitle => '发现';

  @override
  String get discoverNearbyPeople => '附近的人';

  @override
  String get discoverNearbyGyms => '附近训练馆';

  @override
  String get sendBuddyRequest => '约练';

  @override
  String get nearbyTitle => '附近';

  @override
  String get nearbyBuddies => '附近伙伴';

  @override
  String get nearbyGymsRecommend => '推荐训练馆';

  @override
  String get nearbyNoBuddies => '附近暂无伙伴';

  @override
  String get nearbyNoBuddiesTip => '试试扩大搜索范围';

  @override
  String get nearbyNoGyms => '附近暂无训练馆';

  @override
  String get nearbyNoGymsTip => '可以提交一个你常去的训练馆';

  @override
  String get workoutCreate => '记录训练';

  @override
  String get workoutType => '运动类型';

  @override
  String get workoutDuration => '训练时长（分钟）';

  @override
  String get workoutIntensity => '训练强度';

  @override
  String get workoutNotes => '备注';

  @override
  String get workoutPhotos => '训练照片';

  @override
  String get workoutSave => '保存';

  @override
  String get workoutShareAsPost => '同时发布为动态？';

  @override
  String get workoutCalendar => '训练日历';

  @override
  String get workoutDetail => '训练详情';

  @override
  String get workoutHistory => '训练历史';

  @override
  String get workoutDraft => '草稿';

  @override
  String get workoutDrafts => '训练草稿';

  @override
  String get workoutDate => '训练日期';

  @override
  String get workoutTime => '训练时间';

  @override
  String get workoutSaveDraft => '保存草稿';

  @override
  String get workoutDeleteConfirm => '确定删除这条训练记录吗？';

  @override
  String workoutMinutes(int count) {
    return '$count 分钟';
  }

  @override
  String workoutIntensityLevel(int level) {
    return '强度 $level/10';
  }

  @override
  String get workoutThisWeek => '本周训练';

  @override
  String get workoutThisMonth => '本月训练';

  @override
  String get workoutTotalHours => '总时长';

  @override
  String get workoutFilterAll => '全部';

  @override
  String get workoutNoRecords => '还没有训练记录';

  @override
  String get workoutStartFirst => '去记录第一次训练吧';

  @override
  String get healthSync => 'Apple Health 同步';

  @override
  String get healthSyncDescription => '自动同步 Apple Health 中的训练数据';

  @override
  String get healthSyncNow => '立即同步';

  @override
  String get healthSyncing => '同步中...';

  @override
  String get healthSyncSuccess => '同步完成';

  @override
  String get healthSyncError => '同步失败';

  @override
  String get healthPermissionDenied => '请在设置中允许 VerveForge 访问健康数据';

  @override
  String get metricsTitle => '运动专项成绩（可选）';

  @override
  String get metricsStation => '分站';

  @override
  String get metricsTime => '用时';

  @override
  String get metricsTotalTime => '总成绩';

  @override
  String get metricsWod => 'WOD 名称';

  @override
  String get metricsScore => '成绩';

  @override
  String get metricsWodType => 'WOD 类型';

  @override
  String get metricsMovement => '动作列表';

  @override
  String get metricsDistance => '距离（公里）';

  @override
  String get metricsPace => '配速（分钟/公里）';

  @override
  String get metricsElevation => '爬升（米）';

  @override
  String get metricsFocusArea => '专注区域';

  @override
  String get metricsDifficulty => '难度';

  @override
  String get metricsClassName => '课程名称';

  @override
  String get dataCollectionConsent => '训练数据采集授权';

  @override
  String get dataCollectionDesc =>
      '为了提供训练数据分析服务，VerveForge 需要采集以下信息：\n\n• 运动成绩数据（用时、得分、配速等）\n• Apple Health 健康数据（心率、卡路里、步数）\n• 训练照片和视频\n\n您的数据将加密存储，可随时在设置中导出或删除。';

  @override
  String get challengeTitle => '挑战';

  @override
  String get challengeCreate => '创建挑战';

  @override
  String get challengeJoin => '参加';

  @override
  String get challengeLeave => '退出';

  @override
  String get challengeLeaderboard => '排行榜';

  @override
  String get challengeCheckIn => '打卡';

  @override
  String get challengeProgress => '进度';

  @override
  String get challengeDetail => '挑战详情';

  @override
  String get challengeStartDate => '开始日期';

  @override
  String get challengeEndDate => '结束日期';

  @override
  String get challengeGoalType => '目标类型';

  @override
  String get challengeGoalValue => '目标值';

  @override
  String get challengeGoalSessions => '总次数';

  @override
  String get challengeGoalMinutes => '总时长(分钟)';

  @override
  String get challengeGoalDays => '总天数';

  @override
  String get challengeCity => '城市';

  @override
  String get challengeCityAll => '全部城市';

  @override
  String get challengeSportType => '运动类型';

  @override
  String get challengeMaxParticipants => '最大参与人数';

  @override
  String get challengeDescription => '描述';

  @override
  String challengeParticipants(int count) {
    return '$count 人参加';
  }

  @override
  String challengeRemainingDays(int days) {
    return '还剩 $days 天';
  }

  @override
  String get challengeStatusActive => '进行中';

  @override
  String get challengeStatusCompleted => '已结束';

  @override
  String get challengeStatusCancelled => '已取消';

  @override
  String get challengeFull => '已满员';

  @override
  String get challengeNoRecords => '暂无挑战';

  @override
  String get challengeStartFirst => '创建或参加运动挑战，与伙伴一起进步';

  @override
  String get challengeCreateSuccess => '挑战创建成功';

  @override
  String get challengeJoinSuccess => '已加入挑战';

  @override
  String get challengeLeaveSuccess => '已退出挑战';

  @override
  String get challengeLeaveConfirm => '确定退出这个挑战吗？';

  @override
  String get challengeRank => '排名';

  @override
  String get challengeCheckInCount => '打卡次数';

  @override
  String get challengeRealtime => '实时';

  @override
  String get challengeNewAvailable => '挑战赛有更新，点击刷新';

  @override
  String get profileTitle => '我的';

  @override
  String get profileEdit => '编辑资料';

  @override
  String get profileWorkoutLog => '训练日志';

  @override
  String get profileSettings => '设置';

  @override
  String get profileNickname => '昵称';

  @override
  String get profileBio => '简介';

  @override
  String get profileAvatar => '头像';

  @override
  String get profileBioHint => '介绍一下你自己';

  @override
  String get profileGender => '性别';

  @override
  String get profileGenderMale => '男';

  @override
  String get profileGenderFemale => '女';

  @override
  String get profileGenderOther => '其他';

  @override
  String get profileGenderPreferNotToSay => '不愿透露';

  @override
  String get profileCity => '城市';

  @override
  String get profileExperienceLevel => '运动经验';

  @override
  String get profileSportPreference => '运动偏好';

  @override
  String get profileNicknameError => '请输入有效昵称（2-20字符）';

  @override
  String get profileSportSelectionError => '请至少选择一项运动';

  @override
  String get profileSaveSuccess => '保存成功';

  @override
  String get profileUserNotFound => '用户不存在';

  @override
  String get avatarPickerGallery => '从相册选择';

  @override
  String get avatarPickerCamera => '拍照';

  @override
  String get avatarPickerCropTitle => '裁剪头像';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsTheme => '主题';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsThemeSystem => '跟随系统';

  @override
  String get settingsPrivacy => '隐私设置';

  @override
  String get settingsAbout => '关于';

  @override
  String get settingsLogout => '退出登录';

  @override
  String get settingsDeleteAccount => '注销账号';

  @override
  String get settingsExportData => '导出我的数据';

  @override
  String get privacyTitle => '隐私政策';

  @override
  String get privacyAgree => '我已阅读并同意';

  @override
  String get privacyDisagree => '不同意';

  @override
  String get commonCancel => '取消';

  @override
  String get commonConfirm => '确认';

  @override
  String get commonSave => '保存';

  @override
  String get commonDelete => '删除';

  @override
  String get commonEdit => '编辑';

  @override
  String get commonShare => '分享';

  @override
  String get commonReport => '举报';

  @override
  String get commonBlock => '屏蔽';

  @override
  String get commonRetry => '重试';

  @override
  String get commonLoading => '加载中...';

  @override
  String get commonEmpty => '暂无数据';

  @override
  String get commonError => '出错了，请重试';

  @override
  String get commonSuccess => '操作成功';

  @override
  String get commonNoNetwork => '网络连接失败，请检查网络';

  @override
  String get commonDone => '完成';

  @override
  String get chatTitle => '私信';

  @override
  String get chatNoConversations => '暂无消息';

  @override
  String get chatNoConversationsTip => '和好友聊聊天吧';

  @override
  String get chatEmpty => '发送第一条消息吧';

  @override
  String get chatInputHint => '输入消息...';

  @override
  String get gymTitle => '训练馆';

  @override
  String get gymNearby => '附近训练馆';

  @override
  String get gymSearch => '搜索训练馆...';

  @override
  String get gymDetail => '训练馆详情';

  @override
  String get gymSubmit => '提交训练馆';

  @override
  String get gymAddress => '地址';

  @override
  String get gymPhone => '电话';

  @override
  String get gymWebsite => '网站';

  @override
  String get gymOpeningHours => '营业时间';

  @override
  String get gymSportTypes => '运动类型';

  @override
  String get gymReviews => '评价';

  @override
  String get gymWriteReview => '写评价';

  @override
  String get gymRating => '评分';

  @override
  String get gymNoReviews => '暂无评价';

  @override
  String get gymSubmitSuccess => '训练馆已提交，等待审核';

  @override
  String get gymPending => '待审核';

  @override
  String get gymVerified => '已认证';

  @override
  String get gymFavorite => '收藏';

  @override
  String get gymFavorited => '已收藏';

  @override
  String get gymFavoriteAdded => '已添加收藏';

  @override
  String get gymFavoriteRemoved => '已取消收藏';

  @override
  String get gymMyFavorites => '我的收藏训练馆';

  @override
  String get gymNoFavorites => '暂无收藏';

  @override
  String get gymClaimThis => '认领此场馆';

  @override
  String get gymClaimConfirm => '认领场馆';

  @override
  String get gymClaimConfirmDesc => '您是此训练馆的馆主或管理员吗？提交认领后将进入审核流程。';

  @override
  String get gymClaimSubmit => '提交认领';

  @override
  String get gymClaimSuccess => '认领申请已提交，等待审核';

  @override
  String get gymClaimStatus => '认领状态';

  @override
  String get gymClaimPending => '审核中';

  @override
  String get gymClaimApproved => '已通过';

  @override
  String get gymClaimRejected => '已拒绝';

  @override
  String get postCreate => '发布动态';

  @override
  String get postPublish => '发布';

  @override
  String get postPublishSuccess => '动态发布成功';

  @override
  String get postContentHint => '分享你的训练或想法...';

  @override
  String get postCity => '城市';

  @override
  String get postCreateSubtitle => '分享你的训练瞬间';

  @override
  String get postEmpty => '暂无动态';

  @override
  String get postEmptyTip => '成为第一个分享动态的人';

  @override
  String get postNewAvailable => '有新动态，点击刷新';

  @override
  String get postNoFollowing => '暂无关注动态';

  @override
  String get postFollowTip => '关注运动伙伴，查看他们的训练动态';

  @override
  String postLikes(int count) {
    return '$count 个赞';
  }

  @override
  String postComments(int count) {
    return '$count 条评论';
  }

  @override
  String get postDeleteConfirm => '确定删除这条动态吗？';

  @override
  String get postDeleted => '动态已删除';

  @override
  String get appLaunchConsentTitle => '欢迎使用 VerveForge';

  @override
  String get appLaunchConsentDesc => '在使用我们的服务前，请了解我们如何处理您的数据：';

  @override
  String get appLaunchConsentItem1 => '账号信息：邮箱、Apple ID、昵称、头像';

  @override
  String get appLaunchConsentItem2 => '训练数据：训练日志、Apple Health 同步、照片';

  @override
  String get appLaunchConsentItem3 => '位置信息：用于发现附近训练馆和训练伙伴';

  @override
  String get appLaunchConsentItem4 => '您的数据加密存储，可随时导出或删除';

  @override
  String get appLaunchConsentReadFull => '查看完整隐私政策';

  @override
  String get profileNoBio => '还没有设置简介';

  @override
  String get profileRegisterFirst => '请先完成注册';

  @override
  String get profileGoRegister => '去注册';

  @override
  String get profileMyChallenges => '我的挑战';

  @override
  String get profileMyBuddies => '我的伙伴';

  @override
  String get profileSectionTraining => '训练';

  @override
  String get profileSectionSocial => '社交';

  @override
  String get profileSectionAccount => '账户';

  @override
  String get buddyListTitle => '好友列表';

  @override
  String get buddyRequests => '好友请求';

  @override
  String get buddyReceived => '收到的';

  @override
  String get buddySent => '发出的';

  @override
  String get buddyAccept => '接受';

  @override
  String get buddyReject => '拒绝';

  @override
  String get buddyCancel => '撤回';

  @override
  String get buddyRemove => '删除好友';

  @override
  String get buddyPending => '等待回复';

  @override
  String get buddyAccepted => '已成为好友';

  @override
  String get buddyNoRequests => '暂无好友请求';

  @override
  String get buddyNoRequestsTip => '去附近页面发现更多运动伙伴';

  @override
  String get buddyNoSentRequests => '暂无发出的请求';

  @override
  String get buddyNoBuddies => '还没有好友';

  @override
  String get buddyNoBuddiesTip => '去附近页面发现运动伙伴吧';

  @override
  String get buddyRemoveConfirm => '删除好友';

  @override
  String get buddyRemoveConfirmDesc => '确定删除该好友吗？删除后需要重新发送请求';

  @override
  String get buddyRemoved => '已删除好友';

  @override
  String get profileMyDrafts => '训练草稿';

  @override
  String get profilePrivacy => '隐私设置';

  @override
  String get settingsFollowSystem => '跟随系统';

  @override
  String get settingsOpenSource => '开源协议';

  @override
  String get settingsLogoutConfirm => '确认退出登录？';

  @override
  String get settingsLogoutDesc => '退出后需要重新登录';

  @override
  String get aiAvatarTitle => '我的 AI 分身';

  @override
  String get aiAvatarCreate => '创建 AI 分身';

  @override
  String get aiAvatarEdit => '编辑分身';

  @override
  String get aiAvatarDelete => '删除分身';

  @override
  String get aiAvatarDeleteConfirm => '确定删除 AI 分身吗？此操作不可恢复。';

  @override
  String get aiAvatarDeleted => 'AI 分身已删除';

  @override
  String get aiAvatarSaved => 'AI 分身已保存';

  @override
  String get aiAvatarEmpty => '还没有 AI 分身';

  @override
  String get aiAvatarEmptyTip => '创建一个代表你的 AI 虚拟分身';

  @override
  String get aiAvatarStepName => '名称和风格';

  @override
  String get aiAvatarStepPersonality => '性格特征';

  @override
  String get aiAvatarStepStyle => '选择外貌';

  @override
  String get aiAvatarName => '分身名称';

  @override
  String get aiAvatarNameHint => '给你的分身取个名字';

  @override
  String get aiAvatarPhoto => '分身头像';

  @override
  String get aiAvatarCustomPrompt => '自定义指令';

  @override
  String get aiAvatarCustomPromptHint => '可选：添加特别指令来调整分身行为';

  @override
  String get aiAvatarPickPreset => '选择一个预设头像';

  @override
  String get aiAvatarOrUpload => '或上传自定义头像';

  @override
  String get aiAvatarPreviewTitle => '风格预览';

  @override
  String get aiAvatarPreviewHint => '你的分身会这样回复：';

  @override
  String get aiAvatarSelectTraitsHint => '选择符合你的标签（最多 5 个）';

  @override
  String get presetRunner => '跑者';

  @override
  String get presetYogi => '瑜伽人';

  @override
  String get presetLifter => '举铁人';

  @override
  String get presetSwimmer => '游泳者';

  @override
  String get presetCyclist => '骑行者';

  @override
  String get presetBoxer => '拳击手';

  @override
  String get presetClimber => '攀岩者';

  @override
  String get presetDancer => '舞者';

  @override
  String get presetMartial => '武术家';

  @override
  String get presetSkier => '滑雪者';

  @override
  String get presetSurfer => '冲浪者';

  @override
  String get presetTennis => '网球手';

  @override
  String get presetBasketball => '篮球手';

  @override
  String get presetSoccer => '足球迷';

  @override
  String get presetHiker => '徒步者';

  @override
  String get presetGymnast => '体操人';

  @override
  String get presetRower => '划船者';

  @override
  String get presetSkater => '滑冰者';

  @override
  String get presetNinja => '忍者';

  @override
  String get presetRobot => '机器人';

  @override
  String get presetFire => '火焰';

  @override
  String get presetLightning => '闪电';

  @override
  String get presetStar => '星星';

  @override
  String get presetDiamond => '钻石';

  @override
  String get aiTraitEarlyRunner => '晨跑达人';

  @override
  String get aiTraitYogaMaster => '瑜伽达人';

  @override
  String get aiTraitIronAddict => '举铁狂魔';

  @override
  String get aiTraitCrossfitFanatic => 'CrossFit 狂热粉';

  @override
  String get aiTraitMarathoner => '马拉松跑者';

  @override
  String get aiTraitGymRat => '健身房常客';

  @override
  String get aiTraitOutdoorExplorer => '户外探险家';

  @override
  String get aiTraitFlexibilityPro => '柔韧性达人';

  @override
  String get aiTraitTeamPlayer => '团队合作者';

  @override
  String get aiTraitSoloWarrior => '独行侠';

  @override
  String get aiTraitTechGeek => '科技极客';

  @override
  String get aiTraitNutritionNerd => '营养学家';

  @override
  String get aiTraitRestDayHater => '不需要休息日';

  @override
  String get aiTraitWarmupSkipper => '跳过热身';

  @override
  String get aiTraitPrBeast => 'PR 猛兽';

  @override
  String get aiTraitCheerleader => '啦啦队长';

  @override
  String get aiTraitEnthusiastic => '热情';

  @override
  String get aiTraitProfessional => '专业';

  @override
  String get aiTraitHumorous => '幽默';

  @override
  String get aiTraitEncouraging => '鼓励';

  @override
  String get aiTraitCalm => '沉稳';

  @override
  String get aiTraitFriendly => '友好';

  @override
  String get aiTraitDirect => '直接';

  @override
  String get aiTraitCurious => '好奇';

  @override
  String get aiStyleLively => '活泼';

  @override
  String get aiStyleLivelyDesc => '充满活力、热情洋溢，喜欢用感叹号';

  @override
  String get aiStyleLivelyPreview => '太棒了！！今早刚跑完 5 公里 🏃💨 天气超好！下次一起跑呀？';

  @override
  String get aiStyleSteady => '沉稳';

  @override
  String get aiStyleSteadyDesc => '冷静且理性，言简意赅、就事论事';

  @override
  String get aiStyleSteadyPreview => '晨跑完毕。5 公里用时 24 分钟，配速稳定。天气不错。';

  @override
  String get aiStyleHumorous => '幽默';

  @override
  String get aiStyleHumorousDesc => '风趣且俏皮，擅长自嘲和段子';

  @override
  String get aiStyleHumorousPreview => '今天跑了 5 公里…嗯，腿跑了，脑子还在被窝里 😂 还好歌单在线！';

  @override
  String get aiStyleFriendly => '友好随意';

  @override
  String get aiStyleProfessional => '专业简洁';

  @override
  String get aiStyleEncouraging => '温暖鼓励';

  @override
  String get aiAutoReply => '离线自动回复';

  @override
  String get aiAutoReplyDesc => '当你离线超过 5 分钟时，分身自动代替你回复';

  @override
  String get aiAutoReplyEnabled => '自动回复已开启';

  @override
  String get aiAutoReplyDisabled => '自动回复已关闭';

  @override
  String get aiGeneratedLabel => '由 AI 分身回复';

  @override
  String get aiAvatarChat => '与分身聊天';

  @override
  String get aiAvatarChatHint => '对你的分身说点什么...';

  @override
  String get aiAvatarChatIntro => '和你的 AI 分身聊聊，看看它的回复效果';

  @override
  String get aiAvatarThinking => '分身思考中...';

  @override
  String get aiConsentTitle => 'AI 数据处理授权';

  @override
  String get aiConsentDesc => '创建 AI 分身需要处理以下数据：';

  @override
  String get aiConsentItem1 => '您的个人资料（昵称、简介、运动类型、城市）';

  @override
  String get aiConsentItem2 => '最近的聊天消息（最近 10 条）用于上下文';

  @override
  String get aiConsentItem3 => '您最近的公开动态（最近 5 条）';

  @override
  String get aiConsentItem4 => '数据通过 AI 处理，不会永久存储';

  @override
  String get aiConsentItem5 => '对方会看到「AI 分身回复」的标记';

  @override
  String get aiConsentAgree => '同意并继续';

  @override
  String get aiConsentDisagree => '取消';

  @override
  String get aiChatQuickLegDay => '今天练腿了';

  @override
  String get aiChatQuickRan5k => '刚跑完 5km';

  @override
  String get aiChatQuickFeelSore => '全身酸痛';

  @override
  String get aiChatQuickRestDay => '今天休息日';

  @override
  String get aiChatQuickNewPR => '破了 PR！';

  @override
  String get aiChatStartChat => '立即聊天';

  @override
  String get aiChatNoMessages => '还没有消息';

  @override
  String get aiChatNoMessagesTip => '发送第一条消息开始聊天吧';

  @override
  String get aiChatSendFailed => '发送失败，请重试';

  @override
  String get aiChatLoadingHistory => '加载历史消息...';

  @override
  String aiChatMessageTime(String time) {
    return '$time';
  }

  @override
  String get aiChatDisclaimer => 'AI 回复仅供参考，不代表本人意见';

  @override
  String get aiChatThinkingWorkout => '分身正在思考你今天的训练…';

  @override
  String get aiChatThinkingReply => '分身正在组织回复…';

  @override
  String get aiChatThinkingAnalyze => '分身正在分析你的状态…';

  @override
  String get aiChatEmptyLearning => '分身正在学习你的习惯…';

  @override
  String get aiChatSmartRecommend => '智能推荐';

  @override
  String get aiAutoReplyActive => 'AI 分身正在替你回复消息';

  @override
  String get aiAutoReplyBadge => 'AI 分身代回复';

  @override
  String get aiAutoReplyConsentRequired => '请先完成 AI 数据处理授权';

  @override
  String get aiAutoReplyStatusOn => '自动回复已开启，离线时分身将代你回复';

  @override
  String get aiAutoReplyStatusOff => '自动回复已关闭';

  @override
  String get aiProfileUpdate => '画像学习';

  @override
  String get aiProfileUpdateBtn => '更新画像';

  @override
  String get aiProfileUpdating => '分身正在学习你的习惯…';

  @override
  String get aiProfileUpdateSuccess => '画像更新完成';

  @override
  String get aiProfileLastUpdated => '上次更新';

  @override
  String get aiProfileNeverUpdated => '尚未更新画像';

  @override
  String get aiProfileAutoRefresh => '对话后自动学习';

  @override
  String get aiProfileManualUpdateBtn => '更新我的画像';

  @override
  String get aiProfileUpdateConfirmTitle => '更新 AI 分身画像？';

  @override
  String get aiProfileUpdateConfirmDesc =>
      '将基于最近对话和训练记录更新分身的性格、习惯和说话风格。数据仅用于回复，不用于其他目的。确定更新吗？';

  @override
  String get aiProfileUpdateConfirmBtn => '确认更新';

  @override
  String get aiProfileUpdateFailed => '画像更新失败，请重试';

  @override
  String get aiProfileUpdateHint => '已记录，可在分身详情页更新画像';

  @override
  String get aiChatCopied => '已复制';

  @override
  String get aiChatCopyMessage => '复制消息';

  @override
  String get aiChatVoiceComingSoon => '语音输入即将上线';

  @override
  String get aiReplyFilteredHint => '分身回复被过滤（内容不合适）';

  @override
  String get aiReplyFilteredSystem => '此回复已被内容审核过滤';

  @override
  String get aiReplyFilteredNotice => '分身回复因安全原因被拦截';

  @override
  String get aiReplyFilteredFallback => '分身暂时无法回复，请稍后尝试。';

  @override
  String get aiContentSafetyTitle => '内容安全';

  @override
  String get aiShareTitle => '分享分身';

  @override
  String get aiShareBtn => '分享我的分身';

  @override
  String get aiShareSubtitle => '将你的 AI 分身分享给好友';

  @override
  String get aiShareToFeed => '分享到动态';

  @override
  String get aiShareToFeedDesc => '在动态中展示你的分身';

  @override
  String get aiShareToChallenge => '分享到挑战赛';

  @override
  String get aiShareToChallengeDesc => '在挑战赛中展示你的分身';

  @override
  String get aiShareToGroup => '分享到群聊';

  @override
  String get aiShareToGroupDesc => '发送你的分身到群聊';

  @override
  String get aiShareCopyLink => '复制分享链接';

  @override
  String get aiShareConfirmTitle => '分享你的分身？';

  @override
  String get aiShareConfirmDesc => '你的分身公开信息（名称、头像、个性标签、说话风格）将对他人可见。私人数据不会被分享。';

  @override
  String get aiShareConfirmBtn => '确认分享';

  @override
  String get aiShareSuccess => '分身分享成功';

  @override
  String get aiShareFailed => '分享失败，请重试';

  @override
  String get aiShareLimitReached => '今日分享次数已达上限（每日最多 5 次）';

  @override
  String get aiShareLinkCopied => '分享链接已复制';

  @override
  String get aiShareViewTitle => 'AI 分身';

  @override
  String get aiShareNotFound => '分身不存在';

  @override
  String get aiShareNotFoundDesc => '该分享链接可能已过期或分身已被删除';

  @override
  String get notificationTitle => '通知';

  @override
  String get notificationMarkAllRead => '全部已读';

  @override
  String get notificationEmpty => '暂无通知';

  @override
  String get notificationEmptyTip => '有人与你互动时，通知会出现在这里';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appName => 'VerveForge';

  @override
  String get tabFeed => '動態';

  @override
  String get tabGyms => '訓練館';

  @override
  String get tabChallenge => '挑戰';

  @override
  String get tabProfile => '我的';

  @override
  String get tabNearby => '附近';

  @override
  String get loginTitle => '登入 VerveForge';

  @override
  String get loginSubtitle => '記錄訓練·發現夥伴·挑戰自我';

  @override
  String get emailLabel => '電子郵件';

  @override
  String get emailHint => '請輸入電子郵件地址';

  @override
  String get passwordLabel => '密碼';

  @override
  String get passwordHint => '請輸入密碼';

  @override
  String get login => '登入';

  @override
  String get register => '註冊';

  @override
  String get switchToRegister => '沒有帳號？立即註冊';

  @override
  String get switchToLogin => '已有帳號？直接登入';

  @override
  String get orLoginWith => '或使用以下方式登入';

  @override
  String get signInWithApple => '透過 Apple 登入';

  @override
  String get privacyAgreement => '登入即表示您同意我們的';

  @override
  String get privacyPolicy => '私隱政策';

  @override
  String get termsOfService => '服務條款';

  @override
  String get and => '和';

  @override
  String get onboardingStep1Title => '選擇你的運動';

  @override
  String get onboardingStep1Subtitle => '選擇你感興趣的運動類型（可多選）';

  @override
  String get onboardingStep2Title => '選擇你的城市';

  @override
  String get onboardingStep2Subtitle => '我們會推薦附近的訓練館和夥伴';

  @override
  String get onboardingStep3Title => '完善個人資料';

  @override
  String get onboardingStep3Subtitle => '設定頭像和暱稱，讓夥伴認識你';

  @override
  String get next => '下一步';

  @override
  String get done => '完成';

  @override
  String get skip => '略過';

  @override
  String get sportHyrox => 'HYROX';

  @override
  String get sportCrossfit => 'CrossFit';

  @override
  String get sportYoga => '瑜伽';

  @override
  String get sportPilates => '普拉提';

  @override
  String get sportRunning => '跑步';

  @override
  String get sportSwimming => '游泳';

  @override
  String get sportStrength => '力量訓練';

  @override
  String get sportOther => '其他';

  @override
  String get cityBeijing => '北京';

  @override
  String get cityShanghai => '上海';

  @override
  String get cityGuangzhou => '廣州';

  @override
  String get cityShenzhen => '深圳';

  @override
  String get cityHongkong => '香港';

  @override
  String get levelBeginner => '入門';

  @override
  String get levelIntermediate => '進階';

  @override
  String get levelAdvanced => '高級';

  @override
  String get levelElite => '精英';

  @override
  String get feedTitle => '動態';

  @override
  String get feedTabFollowing => '關注';

  @override
  String get feedTabNearby => '附近';

  @override
  String get feedTabLatest => '最新';

  @override
  String get feedTabRecommend => '推薦';

  @override
  String get discoverTitle => '發現';

  @override
  String get discoverNearbyPeople => '附近的人';

  @override
  String get discoverNearbyGyms => '附近訓練館';

  @override
  String get sendBuddyRequest => '約練';

  @override
  String get nearbyTitle => '附近';

  @override
  String get nearbyBuddies => '附近夥伴';

  @override
  String get nearbyGymsRecommend => '推薦訓練館';

  @override
  String get nearbyNoBuddies => '附近暫無夥伴';

  @override
  String get nearbyNoBuddiesTip => '試試擴大搜尋範圍';

  @override
  String get nearbyNoGyms => '附近暫無訓練館';

  @override
  String get nearbyNoGymsTip => '可以提交一個你常去的訓練館';

  @override
  String get workoutCreate => '記錄訓練';

  @override
  String get workoutType => '運動類型';

  @override
  String get workoutDuration => '訓練時長（分鐘）';

  @override
  String get workoutIntensity => '訓練強度';

  @override
  String get workoutNotes => '備註';

  @override
  String get workoutPhotos => '訓練照片';

  @override
  String get workoutSave => '儲存';

  @override
  String get workoutShareAsPost => '同時發佈為動態？';

  @override
  String get workoutCalendar => '訓練日曆';

  @override
  String get workoutDetail => '訓練詳情';

  @override
  String get workoutHistory => '訓練歷史';

  @override
  String get workoutDraft => '草稿';

  @override
  String get workoutDrafts => '訓練草稿';

  @override
  String get workoutDate => '訓練日期';

  @override
  String get workoutTime => '訓練時間';

  @override
  String get workoutSaveDraft => '儲存草稿';

  @override
  String get workoutDeleteConfirm => '確定刪除這條訓練記錄嗎？';

  @override
  String workoutMinutes(int count) {
    return '$count 分鐘';
  }

  @override
  String workoutIntensityLevel(int level) {
    return '強度 $level/10';
  }

  @override
  String get workoutThisWeek => '本週訓練';

  @override
  String get workoutThisMonth => '本月訓練';

  @override
  String get workoutTotalHours => '總時長';

  @override
  String get workoutFilterAll => '全部';

  @override
  String get workoutNoRecords => '還沒有訓練記錄';

  @override
  String get workoutStartFirst => '去記錄第一次訓練吧';

  @override
  String get healthSync => 'Apple Health 同步';

  @override
  String get healthSyncDescription => '自動同步 Apple Health 中的訓練資料';

  @override
  String get healthSyncNow => '立即同步';

  @override
  String get healthSyncing => '同步中...';

  @override
  String get healthSyncSuccess => '同步完成';

  @override
  String get healthSyncError => '同步失敗';

  @override
  String get healthPermissionDenied => '請在設定中允許 VerveForge 存取健康資料';

  @override
  String get metricsTitle => '運動專項成績（可選）';

  @override
  String get metricsStation => '分站';

  @override
  String get metricsTime => '用時';

  @override
  String get metricsTotalTime => '總成績';

  @override
  String get metricsWod => 'WOD 名稱';

  @override
  String get metricsScore => '成績';

  @override
  String get metricsWodType => 'WOD 類型';

  @override
  String get metricsMovement => '動作列表';

  @override
  String get metricsDistance => '距離（公里）';

  @override
  String get metricsPace => '配速（分鐘/公里）';

  @override
  String get metricsElevation => '爬升（公尺）';

  @override
  String get metricsFocusArea => '專注區域';

  @override
  String get metricsDifficulty => '難度';

  @override
  String get metricsClassName => '課程名稱';

  @override
  String get dataCollectionConsent => '訓練資料採集授權';

  @override
  String get dataCollectionDesc =>
      '為了提供訓練資料分析服務，VerveForge 需要採集以下資訊：\n\n• 運動成績資料（用時、得分、配速等）\n• Apple Health 健康資料（心率、卡路里、步數）\n• 訓練照片和影片\n\n您的資料將加密儲存，可隨時在設定中匯出或刪除。';

  @override
  String get challengeTitle => '挑戰';

  @override
  String get challengeCreate => '建立挑戰';

  @override
  String get challengeJoin => '參加';

  @override
  String get challengeLeave => '退出';

  @override
  String get challengeLeaderboard => '排行榜';

  @override
  String get challengeCheckIn => '打卡';

  @override
  String get challengeProgress => '進度';

  @override
  String get challengeDetail => '挑戰詳情';

  @override
  String get challengeStartDate => '開始日期';

  @override
  String get challengeEndDate => '結束日期';

  @override
  String get challengeGoalType => '目標類型';

  @override
  String get challengeGoalValue => '目標值';

  @override
  String get challengeGoalSessions => '總次數';

  @override
  String get challengeGoalMinutes => '總時長(分鐘)';

  @override
  String get challengeGoalDays => '總天數';

  @override
  String get challengeCity => '城市';

  @override
  String get challengeCityAll => '全部城市';

  @override
  String get challengeSportType => '運動類型';

  @override
  String get challengeMaxParticipants => '最大參與人數';

  @override
  String get challengeDescription => '描述';

  @override
  String challengeParticipants(int count) {
    return '$count 人參加';
  }

  @override
  String challengeRemainingDays(int days) {
    return '還剩 $days 天';
  }

  @override
  String get challengeStatusActive => '進行中';

  @override
  String get challengeStatusCompleted => '已結束';

  @override
  String get challengeStatusCancelled => '已取消';

  @override
  String get challengeFull => '已滿員';

  @override
  String get challengeNoRecords => '暫無挑戰';

  @override
  String get challengeStartFirst => '建立或參加運動挑戰，與夥伴一起進步';

  @override
  String get challengeCreateSuccess => '挑戰建立成功';

  @override
  String get challengeJoinSuccess => '已加入挑戰';

  @override
  String get challengeLeaveSuccess => '已退出挑戰';

  @override
  String get challengeLeaveConfirm => '確定退出這個挑戰嗎？';

  @override
  String get challengeRank => '排名';

  @override
  String get challengeCheckInCount => '打卡次數';

  @override
  String get challengeRealtime => '即時';

  @override
  String get challengeNewAvailable => '挑戰賽有更新，點擊刷新';

  @override
  String get profileTitle => '我的';

  @override
  String get profileEdit => '編輯資料';

  @override
  String get profileWorkoutLog => '訓練日誌';

  @override
  String get profileSettings => '設定';

  @override
  String get profileNickname => '暱稱';

  @override
  String get profileBio => '簡介';

  @override
  String get profileAvatar => '頭像';

  @override
  String get profileBioHint => '介紹一下你自己';

  @override
  String get profileGender => '性別';

  @override
  String get profileGenderMale => '男';

  @override
  String get profileGenderFemale => '女';

  @override
  String get profileGenderOther => '其他';

  @override
  String get profileGenderPreferNotToSay => '不願透露';

  @override
  String get profileCity => '城市';

  @override
  String get profileExperienceLevel => '運動經驗';

  @override
  String get profileSportPreference => '運動偏好';

  @override
  String get profileNicknameError => '請輸入有效暱稱（2-20字元）';

  @override
  String get profileSportSelectionError => '請至少選擇一項運動';

  @override
  String get profileSaveSuccess => '儲存成功';

  @override
  String get profileUserNotFound => '用戶不存在';

  @override
  String get avatarPickerGallery => '從相簿選擇';

  @override
  String get avatarPickerCamera => '拍照';

  @override
  String get avatarPickerCropTitle => '裁剪頭像';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsLanguage => '語言';

  @override
  String get settingsTheme => '主題';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsThemeLight => '淺色';

  @override
  String get settingsThemeSystem => '跟隨系統';

  @override
  String get settingsPrivacy => '私隱設定';

  @override
  String get settingsAbout => '關於';

  @override
  String get settingsLogout => '登出';

  @override
  String get settingsDeleteAccount => '註銷賬號';

  @override
  String get settingsExportData => '匯出我的資料';

  @override
  String get privacyTitle => '私隱政策';

  @override
  String get privacyAgree => '我已閱讀並同意';

  @override
  String get privacyDisagree => '不同意';

  @override
  String get commonCancel => '取消';

  @override
  String get commonConfirm => '確認';

  @override
  String get commonSave => '儲存';

  @override
  String get commonDelete => '刪除';

  @override
  String get commonEdit => '編輯';

  @override
  String get commonShare => '分享';

  @override
  String get commonReport => '舉報';

  @override
  String get commonBlock => '封鎖';

  @override
  String get commonRetry => '重試';

  @override
  String get commonLoading => '載入中...';

  @override
  String get commonEmpty => '暫無資料';

  @override
  String get commonError => '出錯了，請重試';

  @override
  String get commonSuccess => '操作成功';

  @override
  String get commonNoNetwork => '網絡連線失敗，請檢查網絡';

  @override
  String get commonDone => '完成';

  @override
  String get chatTitle => '私訊';

  @override
  String get chatNoConversations => '暫無訊息';

  @override
  String get chatNoConversationsTip => '和好友聊聊天吧';

  @override
  String get chatEmpty => '發送第一則訊息吧';

  @override
  String get chatInputHint => '輸入訊息...';

  @override
  String get gymTitle => '訓練館';

  @override
  String get gymNearby => '附近訓練館';

  @override
  String get gymSearch => '搜尋訓練館...';

  @override
  String get gymDetail => '訓練館詳情';

  @override
  String get gymSubmit => '提交訓練館';

  @override
  String get gymAddress => '地址';

  @override
  String get gymPhone => '電話';

  @override
  String get gymWebsite => '網站';

  @override
  String get gymOpeningHours => '營業時間';

  @override
  String get gymSportTypes => '運動類型';

  @override
  String get gymReviews => '評價';

  @override
  String get gymWriteReview => '寫評價';

  @override
  String get gymRating => '評分';

  @override
  String get gymNoReviews => '暫無評價';

  @override
  String get gymSubmitSuccess => '訓練館已提交，等待審核';

  @override
  String get gymPending => '待審核';

  @override
  String get gymVerified => '已認證';

  @override
  String get gymFavorite => '收藏';

  @override
  String get gymFavorited => '已收藏';

  @override
  String get gymFavoriteAdded => '已添加收藏';

  @override
  String get gymFavoriteRemoved => '已取消收藏';

  @override
  String get gymMyFavorites => '我的收藏訓練館';

  @override
  String get gymNoFavorites => '暫無收藏';

  @override
  String get gymClaimThis => '認領此場館';

  @override
  String get gymClaimConfirm => '認領場館';

  @override
  String get gymClaimConfirmDesc => '您是此訓練館的館主或管理員嗎？提交認領後將進入審核流程。';

  @override
  String get gymClaimSubmit => '提交認領';

  @override
  String get gymClaimSuccess => '認領申請已提交，等待審核';

  @override
  String get gymClaimStatus => '認領狀態';

  @override
  String get gymClaimPending => '審核中';

  @override
  String get gymClaimApproved => '已通過';

  @override
  String get gymClaimRejected => '已拒絕';

  @override
  String get postCreate => '發佈動態';

  @override
  String get postPublish => '發佈';

  @override
  String get postPublishSuccess => '動態發佈成功';

  @override
  String get postContentHint => '分享你的訓練或想法...';

  @override
  String get postCity => '城市';

  @override
  String get postCreateSubtitle => '分享你的訓練瞬間';

  @override
  String get postEmpty => '暫無動態';

  @override
  String get postEmptyTip => '成為第一個分享動態的人';

  @override
  String get postNewAvailable => '有新動態，點擊刷新';

  @override
  String get postNoFollowing => '暫無關注動態';

  @override
  String get postFollowTip => '關注運動夥伴，查看他們的訓練動態';

  @override
  String postLikes(int count) {
    return '$count 個讚';
  }

  @override
  String postComments(int count) {
    return '$count 則留言';
  }

  @override
  String get postDeleteConfirm => '確定刪除這則動態嗎？';

  @override
  String get postDeleted => '動態已刪除';

  @override
  String get appLaunchConsentTitle => '歡迎使用 VerveForge';

  @override
  String get appLaunchConsentDesc => '在使用我們的服務前，請了解我們如何處理您的資料：';

  @override
  String get appLaunchConsentItem1 => '帳號資訊：電子郵件、Apple ID、暱稱、頭像';

  @override
  String get appLaunchConsentItem2 => '訓練資料：訓練日誌、Apple Health 同步、照片';

  @override
  String get appLaunchConsentItem3 => '位置資訊：用於發現附近訓練館和訓練夥伴';

  @override
  String get appLaunchConsentItem4 => '您的資料加密儲存，可隨時匯出或刪除';

  @override
  String get appLaunchConsentReadFull => '查看完整私隱政策';

  @override
  String get profileNoBio => '還沒有設定簡介';

  @override
  String get profileRegisterFirst => '請先完成註冊';

  @override
  String get profileGoRegister => '去註冊';

  @override
  String get profileMyChallenges => '我的挑戰';

  @override
  String get profileMyBuddies => '我的夥伴';

  @override
  String get profileSectionTraining => '訓練';

  @override
  String get profileSectionSocial => '社交';

  @override
  String get profileSectionAccount => '帳戶';

  @override
  String get buddyListTitle => '好友列表';

  @override
  String get buddyRequests => '好友請求';

  @override
  String get buddyReceived => '收到的';

  @override
  String get buddySent => '發出的';

  @override
  String get buddyAccept => '接受';

  @override
  String get buddyReject => '拒絕';

  @override
  String get buddyCancel => '撤回';

  @override
  String get buddyRemove => '刪除好友';

  @override
  String get buddyPending => '等待回覆';

  @override
  String get buddyAccepted => '已成為好友';

  @override
  String get buddyNoRequests => '暫無好友請求';

  @override
  String get buddyNoRequestsTip => '去附近頁面發現更多運動夥伴';

  @override
  String get buddyNoSentRequests => '暫無發出的請求';

  @override
  String get buddyNoBuddies => '還沒有好友';

  @override
  String get buddyNoBuddiesTip => '去附近頁面發現運動夥伴吧';

  @override
  String get buddyRemoveConfirm => '刪除好友';

  @override
  String get buddyRemoveConfirmDesc => '確定刪除該好友嗎？刪除後需要重新發送請求';

  @override
  String get buddyRemoved => '已刪除好友';

  @override
  String get profileMyDrafts => '訓練草稿';

  @override
  String get profilePrivacy => '私隱設定';

  @override
  String get settingsFollowSystem => '跟隨系統';

  @override
  String get settingsOpenSource => '開源協議';

  @override
  String get settingsLogoutConfirm => '確認登出？';

  @override
  String get settingsLogoutDesc => '登出後需要重新登入';

  @override
  String get aiAvatarTitle => '我的 AI 分身';

  @override
  String get aiAvatarCreate => '建立 AI 分身';

  @override
  String get aiAvatarEdit => '編輯分身';

  @override
  String get aiAvatarDelete => '刪除分身';

  @override
  String get aiAvatarDeleteConfirm => '確定刪除 AI 分身嗎？此操作不可復原。';

  @override
  String get aiAvatarDeleted => 'AI 分身已刪除';

  @override
  String get aiAvatarSaved => 'AI 分身已儲存';

  @override
  String get aiAvatarEmpty => '還沒有 AI 分身';

  @override
  String get aiAvatarEmptyTip => '建立一個代表你的 AI 虛擬分身';

  @override
  String get aiAvatarStepName => '名稱和風格';

  @override
  String get aiAvatarStepPersonality => '性格特徵';

  @override
  String get aiAvatarStepStyle => '選擇外貌';

  @override
  String get aiAvatarName => '分身名稱';

  @override
  String get aiAvatarNameHint => '給你的分身取個名字';

  @override
  String get aiAvatarPhoto => '分身頭像';

  @override
  String get aiAvatarCustomPrompt => '自訂指令';

  @override
  String get aiAvatarCustomPromptHint => '可選：新增特別指令來調整分身行為';

  @override
  String get aiAvatarPickPreset => '選擇一個預設頭像';

  @override
  String get aiAvatarOrUpload => '或上傳自訂頭像';

  @override
  String get aiAvatarPreviewTitle => '風格預覽';

  @override
  String get aiAvatarPreviewHint => '你的分身會這樣回覆：';

  @override
  String get aiAvatarSelectTraitsHint => '選擇符合你的標籤（最多 5 個）';

  @override
  String get presetRunner => '跑者';

  @override
  String get presetYogi => '瑜伽人';

  @override
  String get presetLifter => '舉鐵人';

  @override
  String get presetSwimmer => '游泳者';

  @override
  String get presetCyclist => '騎行者';

  @override
  String get presetBoxer => '拳擊手';

  @override
  String get presetClimber => '攀岩者';

  @override
  String get presetDancer => '舞者';

  @override
  String get presetMartial => '武術家';

  @override
  String get presetSkier => '滑雪者';

  @override
  String get presetSurfer => '衝浪者';

  @override
  String get presetTennis => '網球手';

  @override
  String get presetBasketball => '籃球手';

  @override
  String get presetSoccer => '足球迷';

  @override
  String get presetHiker => '徒步者';

  @override
  String get presetGymnast => '體操人';

  @override
  String get presetRower => '划船者';

  @override
  String get presetSkater => '溜冰者';

  @override
  String get presetNinja => '忍者';

  @override
  String get presetRobot => '機器人';

  @override
  String get presetFire => '火焰';

  @override
  String get presetLightning => '閃電';

  @override
  String get presetStar => '星星';

  @override
  String get presetDiamond => '鑽石';

  @override
  String get aiTraitEarlyRunner => '晨跑達人';

  @override
  String get aiTraitYogaMaster => '瑜伽達人';

  @override
  String get aiTraitIronAddict => '舉鐵狂魔';

  @override
  String get aiTraitCrossfitFanatic => 'CrossFit 狂熱粉';

  @override
  String get aiTraitMarathoner => '馬拉松跑者';

  @override
  String get aiTraitGymRat => '健身房常客';

  @override
  String get aiTraitOutdoorExplorer => '戶外探險家';

  @override
  String get aiTraitFlexibilityPro => '柔韌性達人';

  @override
  String get aiTraitTeamPlayer => '團隊合作者';

  @override
  String get aiTraitSoloWarrior => '獨行俠';

  @override
  String get aiTraitTechGeek => '科技極客';

  @override
  String get aiTraitNutritionNerd => '營養學家';

  @override
  String get aiTraitRestDayHater => '不需要休息日';

  @override
  String get aiTraitWarmupSkipper => '跳過熱身';

  @override
  String get aiTraitPrBeast => 'PR 猛獸';

  @override
  String get aiTraitCheerleader => '啦啦隊長';

  @override
  String get aiTraitEnthusiastic => '熱情';

  @override
  String get aiTraitProfessional => '專業';

  @override
  String get aiTraitHumorous => '幽默';

  @override
  String get aiTraitEncouraging => '鼓勵';

  @override
  String get aiTraitCalm => '沉穩';

  @override
  String get aiTraitFriendly => '友好';

  @override
  String get aiTraitDirect => '直接';

  @override
  String get aiTraitCurious => '好奇';

  @override
  String get aiStyleLively => '活潑';

  @override
  String get aiStyleLivelyDesc => '充滿活力、熱情洋溢，喜歡用驚嘆號';

  @override
  String get aiStyleLivelyPreview => '太棒了！！今早剛跑完 5 公里 🏃💨 天氣超好！下次一起跑呀？';

  @override
  String get aiStyleSteady => '沉穩';

  @override
  String get aiStyleSteadyDesc => '冷靜且理性，言簡意賅、就事論事';

  @override
  String get aiStyleSteadyPreview => '晨跑完畢。5 公里用時 24 分鐘，配速穩定。天氣不錯。';

  @override
  String get aiStyleHumorous => '幽默';

  @override
  String get aiStyleHumorousDesc => '風趣且俏皮，擅長自嘲和段子';

  @override
  String get aiStyleHumorousPreview => '今天跑了 5 公里…嗯，腿跑了，腦子還在被窩裡 😂 還好歌單在線！';

  @override
  String get aiStyleFriendly => '友好隨意';

  @override
  String get aiStyleProfessional => '專業簡潔';

  @override
  String get aiStyleEncouraging => '溫暖鼓勵';

  @override
  String get aiAutoReply => '離線自動回覆';

  @override
  String get aiAutoReplyDesc => '當你離線超過 5 分鐘時，分身自動代替你回覆';

  @override
  String get aiAutoReplyEnabled => '自動回覆已開啟';

  @override
  String get aiAutoReplyDisabled => '自動回覆已關閉';

  @override
  String get aiGeneratedLabel => '由 AI 分身回覆';

  @override
  String get aiAvatarChat => '與分身聊天';

  @override
  String get aiAvatarChatHint => '對你的分身說點什麼...';

  @override
  String get aiAvatarChatIntro => '和你的 AI 分身聊聊，看看它的回覆效果';

  @override
  String get aiAvatarThinking => '分身思考中...';

  @override
  String get aiConsentTitle => 'AI 資料處理授權';

  @override
  String get aiConsentDesc => '建立 AI 分身需要處理以下資料：';

  @override
  String get aiConsentItem1 => '您的個人資料（暱稱、簡介、運動類型、城市）';

  @override
  String get aiConsentItem2 => '最近的聊天訊息（最近 10 則）用於上下文';

  @override
  String get aiConsentItem3 => '您最近的公開動態（最近 5 則）';

  @override
  String get aiConsentItem4 => '資料透過 AI 處理，不會永久儲存';

  @override
  String get aiConsentItem5 => '對方會看到「AI 分身回覆」的標記';

  @override
  String get aiConsentAgree => '同意並繼續';

  @override
  String get aiConsentDisagree => '取消';

  @override
  String get aiChatQuickLegDay => '今天練腿了';

  @override
  String get aiChatQuickRan5k => '剛跑完 5km';

  @override
  String get aiChatQuickFeelSore => '全身痠痛';

  @override
  String get aiChatQuickRestDay => '今天休息日';

  @override
  String get aiChatQuickNewPR => '破了 PR！';

  @override
  String get aiChatStartChat => '立即聊天';

  @override
  String get aiChatNoMessages => '還沒有訊息';

  @override
  String get aiChatNoMessagesTip => '發送第一則訊息開始聊天吧';

  @override
  String get aiChatSendFailed => '傳送失敗，請重試';

  @override
  String get aiChatLoadingHistory => '載入歷史訊息...';

  @override
  String aiChatMessageTime(String time) {
    return '$time';
  }

  @override
  String get aiChatDisclaimer => 'AI 回覆僅供參考，不代表本人意見';

  @override
  String get aiChatThinkingWorkout => '分身正在思考你今天的訓練…';

  @override
  String get aiChatThinkingReply => '分身正在組織回覆…';

  @override
  String get aiChatThinkingAnalyze => '分身正在分析你的狀態…';

  @override
  String get aiChatEmptyLearning => '分身正在學習你的習慣…';

  @override
  String get aiChatSmartRecommend => '智慧推薦';

  @override
  String get aiAutoReplyActive => 'AI 分身正在替你回覆訊息';

  @override
  String get aiAutoReplyBadge => 'AI 分身代回覆';

  @override
  String get aiAutoReplyConsentRequired => '請先完成 AI 資料處理授權';

  @override
  String get aiAutoReplyStatusOn => '自動回覆已開啟，離線時分身將代你回覆';

  @override
  String get aiAutoReplyStatusOff => '自動回覆已關閉';

  @override
  String get aiProfileUpdate => '畫像學習';

  @override
  String get aiProfileUpdateBtn => '更新畫像';

  @override
  String get aiProfileUpdating => '分身正在學習你的習慣…';

  @override
  String get aiProfileUpdateSuccess => '畫像更新完成';

  @override
  String get aiProfileLastUpdated => '上次更新';

  @override
  String get aiProfileNeverUpdated => '尚未更新畫像';

  @override
  String get aiProfileAutoRefresh => '對話後自動學習';

  @override
  String get aiProfileManualUpdateBtn => '更新我的畫像';

  @override
  String get aiProfileUpdateConfirmTitle => '更新 AI 分身畫像？';

  @override
  String get aiProfileUpdateConfirmDesc =>
      '將基於最近對話和訓練記錄更新分身的性格、習慣和說話風格。資料僅用於回覆，不用於其他目的。確定更新嗎？';

  @override
  String get aiProfileUpdateConfirmBtn => '確認更新';

  @override
  String get aiProfileUpdateFailed => '畫像更新失敗，請重試';

  @override
  String get aiProfileUpdateHint => '已記錄，可在分身詳情頁更新畫像';

  @override
  String get aiChatCopied => '已複製';

  @override
  String get aiChatCopyMessage => '複製訊息';

  @override
  String get aiChatVoiceComingSoon => '語音輸入即將上線';

  @override
  String get aiReplyFilteredHint => '分身回覆被過濾（內容不合適）';

  @override
  String get aiReplyFilteredSystem => '此回覆已被內容審核過濾';

  @override
  String get aiReplyFilteredNotice => '分身回覆因安全原因被攔截';

  @override
  String get aiReplyFilteredFallback => '分身暫時無法回覆，請稍後嘗試。';

  @override
  String get aiContentSafetyTitle => '內容安全';

  @override
  String get aiShareTitle => '分享分身';

  @override
  String get aiShareBtn => '分享我的分身';

  @override
  String get aiShareSubtitle => '將你的 AI 分身分享給好友';

  @override
  String get aiShareToFeed => '分享到動態';

  @override
  String get aiShareToFeedDesc => '在動態中展示你的分身';

  @override
  String get aiShareToChallenge => '分享到挑戰賽';

  @override
  String get aiShareToChallengeDesc => '在挑戰賽中展示你的分身';

  @override
  String get aiShareToGroup => '分享到群聊';

  @override
  String get aiShareToGroupDesc => '發送你的分身到群聊';

  @override
  String get aiShareCopyLink => '複製分享連結';

  @override
  String get aiShareConfirmTitle => '分享你的分身？';

  @override
  String get aiShareConfirmDesc => '你的分身公開資訊（名稱、頭像、個性標籤、說話風格）將對他人可見。私人資料不會被分享。';

  @override
  String get aiShareConfirmBtn => '確認分享';

  @override
  String get aiShareSuccess => '分身分享成功';

  @override
  String get aiShareFailed => '分享失敗，請重試';

  @override
  String get aiShareLimitReached => '今日分享次數已達上限（每日最多 5 次）';

  @override
  String get aiShareLinkCopied => '分享連結已複製';

  @override
  String get aiShareViewTitle => 'AI 分身';

  @override
  String get aiShareNotFound => '分身不存在';

  @override
  String get aiShareNotFoundDesc => '該分享連結可能已過期或分身已被刪除';

  @override
  String get notificationTitle => '通知';

  @override
  String get notificationMarkAllRead => '全部已讀';

  @override
  String get notificationEmpty => '暫無通知';

  @override
  String get notificationEmptyTip => '有人與你互動時，通知會出現在這裡';
}
