import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'CN'),
    Locale('zh', 'TW')
  ];

  /// No description provided for @appName.
  ///
  /// In zh_CN, this message translates to:
  /// **'VerveForge'**
  String get appName;

  /// No description provided for @tabFeed.
  ///
  /// In zh_CN, this message translates to:
  /// **'动态'**
  String get tabFeed;

  /// No description provided for @tabGyms.
  ///
  /// In zh_CN, this message translates to:
  /// **'训练馆'**
  String get tabGyms;

  /// No description provided for @tabChallenge.
  ///
  /// In zh_CN, this message translates to:
  /// **'挑战'**
  String get tabChallenge;

  /// No description provided for @tabProfile.
  ///
  /// In zh_CN, this message translates to:
  /// **'我的'**
  String get tabProfile;

  /// No description provided for @tabNearby.
  ///
  /// In zh_CN, this message translates to:
  /// **'附近'**
  String get tabNearby;

  /// No description provided for @loginTitle.
  ///
  /// In zh_CN, this message translates to:
  /// **'登录 VerveForge'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In zh_CN, this message translates to:
  /// **'记录训练·发现伙伴·挑战自我'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In zh_CN, this message translates to:
  /// **'邮箱'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In zh_CN, this message translates to:
  /// **'请输入邮箱地址'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In zh_CN, this message translates to:
  /// **'密码'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In zh_CN, this message translates to:
  /// **'请输入密码'**
  String get passwordHint;

  /// No description provided for @login.
  ///
  /// In zh_CN, this message translates to:
  /// **'登录'**
  String get login;

  /// No description provided for @register.
  ///
  /// In zh_CN, this message translates to:
  /// **'注册'**
  String get register;

  /// No description provided for @switchToRegister.
  ///
  /// In zh_CN, this message translates to:
  /// **'没有账号？立即注册'**
  String get switchToRegister;

  /// No description provided for @switchToLogin.
  ///
  /// In zh_CN, this message translates to:
  /// **'已有账号？直接登录'**
  String get switchToLogin;

  /// No description provided for @orLoginWith.
  ///
  /// In zh_CN, this message translates to:
  /// **'或使用以下方式登录'**
  String get orLoginWith;

  /// No description provided for @signInWithApple.
  ///
  /// In zh_CN, this message translates to:
  /// **'通过 Apple 登录'**
  String get signInWithApple;

  /// No description provided for @privacyAgreement.
  ///
  /// In zh_CN, this message translates to:
  /// **'登录即表示您同意我们的'**
  String get privacyAgreement;

  /// No description provided for @privacyPolicy.
  ///
  /// In zh_CN, this message translates to:
  /// **'隐私政策'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In zh_CN, this message translates to:
  /// **'服务条款'**
  String get termsOfService;

  /// No description provided for @and.
  ///
  /// In zh_CN, this message translates to:
  /// **'和'**
  String get and;

  /// No description provided for @onboardingStep1Title.
  ///
  /// In zh_CN, this message translates to:
  /// **'选择你的运动'**
  String get onboardingStep1Title;

  /// No description provided for @onboardingStep1Subtitle.
  ///
  /// In zh_CN, this message translates to:
  /// **'选择你感兴趣的运动类型（可多选）'**
  String get onboardingStep1Subtitle;

  /// No description provided for @onboardingStep2Title.
  ///
  /// In zh_CN, this message translates to:
  /// **'选择你的城市'**
  String get onboardingStep2Title;

  /// No description provided for @onboardingStep2Subtitle.
  ///
  /// In zh_CN, this message translates to:
  /// **'我们会推荐附近的训练馆和伙伴'**
  String get onboardingStep2Subtitle;

  /// No description provided for @onboardingStep3Title.
  ///
  /// In zh_CN, this message translates to:
  /// **'完善个人资料'**
  String get onboardingStep3Title;

  /// No description provided for @onboardingStep3Subtitle.
  ///
  /// In zh_CN, this message translates to:
  /// **'设置头像和昵称，让伙伴认识你'**
  String get onboardingStep3Subtitle;

  /// No description provided for @next.
  ///
  /// In zh_CN, this message translates to:
  /// **'下一步'**
  String get next;

  /// No description provided for @done.
  ///
  /// In zh_CN, this message translates to:
  /// **'完成'**
  String get done;

  /// No description provided for @skip.
  ///
  /// In zh_CN, this message translates to:
  /// **'跳过'**
  String get skip;

  /// No description provided for @sportHyrox.
  ///
  /// In zh_CN, this message translates to:
  /// **'HYROX'**
  String get sportHyrox;

  /// No description provided for @sportCrossfit.
  ///
  /// In zh_CN, this message translates to:
  /// **'CrossFit'**
  String get sportCrossfit;

  /// No description provided for @sportYoga.
  ///
  /// In zh_CN, this message translates to:
  /// **'瑜伽'**
  String get sportYoga;

  /// No description provided for @sportPilates.
  ///
  /// In zh_CN, this message translates to:
  /// **'普拉提'**
  String get sportPilates;

  /// No description provided for @sportRunning.
  ///
  /// In zh_CN, this message translates to:
  /// **'跑步'**
  String get sportRunning;

  /// No description provided for @sportSwimming.
  ///
  /// In zh_CN, this message translates to:
  /// **'游泳'**
  String get sportSwimming;

  /// No description provided for @sportStrength.
  ///
  /// In zh_CN, this message translates to:
  /// **'力量训练'**
  String get sportStrength;

  /// No description provided for @sportOther.
  ///
  /// In zh_CN, this message translates to:
  /// **'其他'**
  String get sportOther;

  /// No description provided for @cityBeijing.
  ///
  /// In zh_CN, this message translates to:
  /// **'北京'**
  String get cityBeijing;

  /// No description provided for @cityShanghai.
  ///
  /// In zh_CN, this message translates to:
  /// **'上海'**
  String get cityShanghai;

  /// No description provided for @cityGuangzhou.
  ///
  /// In zh_CN, this message translates to:
  /// **'广州'**
  String get cityGuangzhou;

  /// No description provided for @cityShenzhen.
  ///
  /// In zh_CN, this message translates to:
  /// **'深圳'**
  String get cityShenzhen;

  /// No description provided for @cityHongkong.
  ///
  /// In zh_CN, this message translates to:
  /// **'香港'**
  String get cityHongkong;

  /// No description provided for @levelBeginner.
  ///
  /// In zh_CN, this message translates to:
  /// **'入门'**
  String get levelBeginner;

  /// No description provided for @levelIntermediate.
  ///
  /// In zh_CN, this message translates to:
  /// **'进阶'**
  String get levelIntermediate;

  /// No description provided for @levelAdvanced.
  ///
  /// In zh_CN, this message translates to:
  /// **'高级'**
  String get levelAdvanced;

  /// No description provided for @levelElite.
  ///
  /// In zh_CN, this message translates to:
  /// **'精英'**
  String get levelElite;

  /// No description provided for @feedTitle.
  ///
  /// In zh_CN, this message translates to:
  /// **'动态'**
  String get feedTitle;

  /// No description provided for @feedTabFollowing.
  ///
  /// In zh_CN, this message translates to:
  /// **'关注'**
  String get feedTabFollowing;

  /// No description provided for @feedTabNearby.
  ///
  /// In zh_CN, this message translates to:
  /// **'附近'**
  String get feedTabNearby;

  /// No description provided for @feedTabLatest.
  ///
  /// In zh_CN, this message translates to:
  /// **'最新'**
  String get feedTabLatest;

  /// No description provided for @feedTabRecommend.
  ///
  /// In zh_CN, this message translates to:
  /// **'推荐'**
  String get feedTabRecommend;

  /// No description provided for @discoverTitle.
  ///
  /// In zh_CN, this message translates to:
  /// **'发现'**
  String get discoverTitle;

  /// No description provided for @discoverNearbyPeople.
  ///
  /// In zh_CN, this message translates to:
  /// **'附近的人'**
  String get discoverNearbyPeople;

  /// No description provided for @discoverNearbyGyms.
  ///
  /// In zh_CN, this message translates to:
  /// **'附近训练馆'**
  String get discoverNearbyGyms;

  /// No description provided for @sendBuddyRequest.
  ///
  /// In zh_CN, this message translates to:
  /// **'约练'**
  String get sendBuddyRequest;

  /// No description provided for @nearbyTitle.
  ///
  /// In zh_CN, this message translates to:
  /// **'附近'**
  String get nearbyTitle;

  /// No description provided for @nearbyBuddies.
  ///
  /// In zh_CN, this message translates to:
  /// **'附近伙伴'**
  String get nearbyBuddies;

  /// No description provided for @nearbyGymsRecommend.
  ///
  /// In zh_CN, this message translates to:
  /// **'推荐训练馆'**
  String get nearbyGymsRecommend;

  /// No description provided for @nearbyNoBuddies.
  ///
  /// In zh_CN, this message translates to:
  /// **'附近暂无伙伴'**
  String get nearbyNoBuddies;

  /// No description provided for @nearbyNoBuddiesTip.
  ///
  /// In zh_CN, this message translates to:
  /// **'试试扩大搜索范围'**
  String get nearbyNoBuddiesTip;

  /// No description provided for @nearbyNoGyms.
  ///
  /// In zh_CN, this message translates to:
  /// **'附近暂无训练馆'**
  String get nearbyNoGyms;

  /// No description provided for @nearbyNoGymsTip.
  ///
  /// In zh_CN, this message translates to:
  /// **'可以提交一个你常去的训练馆'**
  String get nearbyNoGymsTip;

  /// No description provided for @workoutCreate.
  ///
  /// In zh_CN, this message translates to:
  /// **'记录训练'**
  String get workoutCreate;

  /// No description provided for @workoutType.
  ///
  /// In zh_CN, this message translates to:
  /// **'运动类型'**
  String get workoutType;

  /// No description provided for @workoutDuration.
  ///
  /// In zh_CN, this message translates to:
  /// **'训练时长（分钟）'**
  String get workoutDuration;

  /// No description provided for @workoutIntensity.
  ///
  /// In zh_CN, this message translates to:
  /// **'训练强度'**
  String get workoutIntensity;

  /// No description provided for @workoutNotes.
  ///
  /// In zh_CN, this message translates to:
  /// **'备注'**
  String get workoutNotes;

  /// No description provided for @workoutPhotos.
  ///
  /// In zh_CN, this message translates to:
  /// **'训练照片'**
  String get workoutPhotos;

  /// No description provided for @workoutSave.
  ///
  /// In zh_CN, this message translates to:
  /// **'保存'**
  String get workoutSave;

  /// No description provided for @workoutShareAsPost.
  ///
  /// In zh_CN, this message translates to:
  /// **'同时发布为动态？'**
  String get workoutShareAsPost;

  /// No description provided for @workoutCalendar.
  ///
  /// In zh_CN, this message translates to:
  /// **'训练日历'**
  String get workoutCalendar;

  /// No description provided for @workoutDetail.
  ///
  /// In zh_CN, this message translates to:
  /// **'训练详情'**
  String get workoutDetail;

  /// No description provided for @workoutHistory.
  ///
  /// In zh_CN, this message translates to:
  /// **'训练历史'**
  String get workoutHistory;

  /// No description provided for @workoutDraft.
  ///
  /// In zh_CN, this message translates to:
  /// **'草稿'**
  String get workoutDraft;

  /// No description provided for @workoutDrafts.
  ///
  /// In zh_CN, this message translates to:
  /// **'训练草稿'**
  String get workoutDrafts;

  /// No description provided for @workoutDate.
  ///
  /// In zh_CN, this message translates to:
  /// **'训练日期'**
  String get workoutDate;

  /// No description provided for @workoutTime.
  ///
  /// In zh_CN, this message translates to:
  /// **'训练时间'**
  String get workoutTime;

  /// No description provided for @workoutSaveDraft.
  ///
  /// In zh_CN, this message translates to:
  /// **'保存草稿'**
  String get workoutSaveDraft;

  /// No description provided for @workoutDeleteConfirm.
  ///
  /// In zh_CN, this message translates to:
  /// **'确定删除这条训练记录吗？'**
  String get workoutDeleteConfirm;

  /// No description provided for @workoutMinutes.
  ///
  /// In zh_CN, this message translates to:
  /// **'{count} 分钟'**
  String workoutMinutes(int count);

  /// No description provided for @workoutIntensityLevel.
  ///
  /// In zh_CN, this message translates to:
  /// **'强度 {level}/10'**
  String workoutIntensityLevel(int level);

  /// No description provided for @workoutThisWeek.
  ///
  /// In zh_CN, this message translates to:
  /// **'本周训练'**
  String get workoutThisWeek;

  /// No description provided for @workoutThisMonth.
  ///
  /// In zh_CN, this message translates to:
  /// **'本月训练'**
  String get workoutThisMonth;

  /// No description provided for @workoutTotalHours.
  ///
  /// In zh_CN, this message translates to:
  /// **'总时长'**
  String get workoutTotalHours;

  /// No description provided for @workoutFilterAll.
  ///
  /// In zh_CN, this message translates to:
  /// **'全部'**
  String get workoutFilterAll;

  /// No description provided for @workoutNoRecords.
  ///
  /// In zh_CN, this message translates to:
  /// **'还没有训练记录'**
  String get workoutNoRecords;

  /// No description provided for @workoutStartFirst.
  ///
  /// In zh_CN, this message translates to:
  /// **'去记录第一次训练吧'**
  String get workoutStartFirst;

  /// No description provided for @healthSync.
  ///
  /// In zh_CN, this message translates to:
  /// **'Apple Health 同步'**
  String get healthSync;

  /// No description provided for @healthSyncDescription.
  ///
  /// In zh_CN, this message translates to:
  /// **'自动同步 Apple Health 中的训练数据'**
  String get healthSyncDescription;

  /// No description provided for @healthSyncNow.
  ///
  /// In zh_CN, this message translates to:
  /// **'立即同步'**
  String get healthSyncNow;

  /// No description provided for @healthSyncing.
  ///
  /// In zh_CN, this message translates to:
  /// **'同步中...'**
  String get healthSyncing;

  /// No description provided for @healthSyncSuccess.
  ///
  /// In zh_CN, this message translates to:
  /// **'同步完成'**
  String get healthSyncSuccess;

  /// No description provided for @healthSyncError.
  ///
  /// In zh_CN, this message translates to:
  /// **'同步失败'**
  String get healthSyncError;

  /// No description provided for @healthPermissionDenied.
  ///
  /// In zh_CN, this message translates to:
  /// **'请在设置中允许 VerveForge 访问健康数据'**
  String get healthPermissionDenied;

  /// No description provided for @metricsTitle.
  ///
  /// In zh_CN, this message translates to:
  /// **'运动专项成绩（可选）'**
  String get metricsTitle;

  /// No description provided for @metricsStation.
  ///
  /// In zh_CN, this message translates to:
  /// **'分站'**
  String get metricsStation;

  /// No description provided for @metricsTime.
  ///
  /// In zh_CN, this message translates to:
  /// **'用时'**
  String get metricsTime;

  /// No description provided for @metricsTotalTime.
  ///
  /// In zh_CN, this message translates to:
  /// **'总成绩'**
  String get metricsTotalTime;

  /// No description provided for @metricsWod.
  ///
  /// In zh_CN, this message translates to:
  /// **'WOD 名称'**
  String get metricsWod;

  /// No description provided for @metricsScore.
  ///
  /// In zh_CN, this message translates to:
  /// **'成绩'**
  String get metricsScore;

  /// No description provided for @metricsWodType.
  ///
  /// In zh_CN, this message translates to:
  /// **'WOD 类型'**
  String get metricsWodType;

  /// No description provided for @metricsMovement.
  ///
  /// In zh_CN, this message translates to:
  /// **'动作列表'**
  String get metricsMovement;

  /// No description provided for @metricsDistance.
  ///
  /// In zh_CN, this message translates to:
  /// **'距离（公里）'**
  String get metricsDistance;

  /// No description provided for @metricsPace.
  ///
  /// In zh_CN, this message translates to:
  /// **'配速（分钟/公里）'**
  String get metricsPace;

  /// No description provided for @metricsElevation.
  ///
  /// In zh_CN, this message translates to:
  /// **'爬升（米）'**
  String get metricsElevation;

  /// No description provided for @metricsFocusArea.
  ///
  /// In zh_CN, this message translates to:
  /// **'专注区域'**
  String get metricsFocusArea;

  /// No description provided for @metricsDifficulty.
  ///
  /// In zh_CN, this message translates to:
  /// **'难度'**
  String get metricsDifficulty;

  /// No description provided for @metricsClassName.
  ///
  /// In zh_CN, this message translates to:
  /// **'课程名称'**
  String get metricsClassName;

  /// No description provided for @dataCollectionConsent.
  ///
  /// In zh_CN, this message translates to:
  /// **'训练数据采集授权'**
  String get dataCollectionConsent;

  /// No description provided for @dataCollectionDesc.
  ///
  /// In zh_CN, this message translates to:
  /// **'为了提供训练数据分析服务，VerveForge 需要采集以下信息：\n\n• 运动成绩数据（用时、得分、配速等）\n• Apple Health 健康数据（心率、卡路里、步数）\n• 训练照片和视频\n\n您的数据将加密存储，可随时在设置中导出或删除。'**
  String get dataCollectionDesc;

  /// No description provided for @challengeTitle.
  ///
  /// In zh_CN, this message translates to:
  /// **'挑战'**
  String get challengeTitle;

  /// No description provided for @challengeCreate.
  ///
  /// In zh_CN, this message translates to:
  /// **'创建挑战'**
  String get challengeCreate;

  /// No description provided for @challengeJoin.
  ///
  /// In zh_CN, this message translates to:
  /// **'参加'**
  String get challengeJoin;

  /// No description provided for @challengeLeave.
  ///
  /// In zh_CN, this message translates to:
  /// **'退出'**
  String get challengeLeave;

  /// No description provided for @challengeLeaderboard.
  ///
  /// In zh_CN, this message translates to:
  /// **'排行榜'**
  String get challengeLeaderboard;

  /// No description provided for @challengeCheckIn.
  ///
  /// In zh_CN, this message translates to:
  /// **'打卡'**
  String get challengeCheckIn;

  /// No description provided for @challengeProgress.
  ///
  /// In zh_CN, this message translates to:
  /// **'进度'**
  String get challengeProgress;

  /// No description provided for @challengeDetail.
  ///
  /// In zh_CN, this message translates to:
  /// **'挑战详情'**
  String get challengeDetail;

  /// No description provided for @challengeStartDate.
  ///
  /// In zh_CN, this message translates to:
  /// **'开始日期'**
  String get challengeStartDate;

  /// No description provided for @challengeEndDate.
  ///
  /// In zh_CN, this message translates to:
  /// **'结束日期'**
  String get challengeEndDate;

  /// No description provided for @challengeGoalType.
  ///
  /// In zh_CN, this message translates to:
  /// **'目标类型'**
  String get challengeGoalType;

  /// No description provided for @challengeGoalValue.
  ///
  /// In zh_CN, this message translates to:
  /// **'目标值'**
  String get challengeGoalValue;

  /// No description provided for @challengeGoalSessions.
  ///
  /// In zh_CN, this message translates to:
  /// **'总次数'**
  String get challengeGoalSessions;

  /// No description provided for @challengeGoalMinutes.
  ///
  /// In zh_CN, this message translates to:
  /// **'总时长(分钟)'**
  String get challengeGoalMinutes;

  /// No description provided for @challengeGoalDays.
  ///
  /// In zh_CN, this message translates to:
  /// **'总天数'**
  String get challengeGoalDays;

  /// No description provided for @challengeCity.
  ///
  /// In zh_CN, this message translates to:
  /// **'城市'**
  String get challengeCity;

  /// No description provided for @challengeCityAll.
  ///
  /// In zh_CN, this message translates to:
  /// **'全部城市'**
  String get challengeCityAll;

  /// No description provided for @challengeSportType.
  ///
  /// In zh_CN, this message translates to:
  /// **'运动类型'**
  String get challengeSportType;

  /// No description provided for @challengeMaxParticipants.
  ///
  /// In zh_CN, this message translates to:
  /// **'最大参与人数'**
  String get challengeMaxParticipants;

  /// No description provided for @challengeDescription.
  ///
  /// In zh_CN, this message translates to:
  /// **'描述'**
  String get challengeDescription;

  /// No description provided for @challengeParticipants.
  ///
  /// In zh_CN, this message translates to:
  /// **'{count} 人参加'**
  String challengeParticipants(int count);

  /// No description provided for @challengeRemainingDays.
  ///
  /// In zh_CN, this message translates to:
  /// **'还剩 {days} 天'**
  String challengeRemainingDays(int days);

  /// No description provided for @challengeStatusActive.
  ///
  /// In zh_CN, this message translates to:
  /// **'进行中'**
  String get challengeStatusActive;

  /// No description provided for @challengeStatusCompleted.
  ///
  /// In zh_CN, this message translates to:
  /// **'已结束'**
  String get challengeStatusCompleted;

  /// No description provided for @challengeStatusCancelled.
  ///
  /// In zh_CN, this message translates to:
  /// **'已取消'**
  String get challengeStatusCancelled;

  /// No description provided for @challengeFull.
  ///
  /// In zh_CN, this message translates to:
  /// **'已满员'**
  String get challengeFull;

  /// No description provided for @challengeNoRecords.
  ///
  /// In zh_CN, this message translates to:
  /// **'暂无挑战'**
  String get challengeNoRecords;

  /// No description provided for @challengeStartFirst.
  ///
  /// In zh_CN, this message translates to:
  /// **'创建或参加运动挑战，与伙伴一起进步'**
  String get challengeStartFirst;

  /// No description provided for @challengeCreateSuccess.
  ///
  /// In zh_CN, this message translates to:
  /// **'挑战创建成功'**
  String get challengeCreateSuccess;

  /// No description provided for @challengeJoinSuccess.
  ///
  /// In zh_CN, this message translates to:
  /// **'已加入挑战'**
  String get challengeJoinSuccess;

  /// No description provided for @challengeLeaveSuccess.
  ///
  /// In zh_CN, this message translates to:
  /// **'已退出挑战'**
  String get challengeLeaveSuccess;

  /// No description provided for @challengeLeaveConfirm.
  ///
  /// In zh_CN, this message translates to:
  /// **'确定退出这个挑战吗？'**
  String get challengeLeaveConfirm;

  /// No description provided for @challengeRank.
  ///
  /// In zh_CN, this message translates to:
  /// **'排名'**
  String get challengeRank;

  /// No description provided for @challengeCheckInCount.
  ///
  /// In zh_CN, this message translates to:
  /// **'打卡次数'**
  String get challengeCheckInCount;

  /// No description provided for @challengeRealtime.
  ///
  /// In zh_CN, this message translates to:
  /// **'实时'**
  String get challengeRealtime;

  /// No description provided for @challengeNewAvailable.
  ///
  /// In zh_CN, this message translates to:
  /// **'挑战赛有更新，点击刷新'**
  String get challengeNewAvailable;

  /// No description provided for @profileTitle.
  ///
  /// In zh_CN, this message translates to:
  /// **'我的'**
  String get profileTitle;

  /// No description provided for @profileEdit.
  ///
  /// In zh_CN, this message translates to:
  /// **'编辑资料'**
  String get profileEdit;

  /// No description provided for @profileWorkoutLog.
  ///
  /// In zh_CN, this message translates to:
  /// **'训练日志'**
  String get profileWorkoutLog;

  /// No description provided for @profileSettings.
  ///
  /// In zh_CN, this message translates to:
  /// **'设置'**
  String get profileSettings;

  /// No description provided for @profileNickname.
  ///
  /// In zh_CN, this message translates to:
  /// **'昵称'**
  String get profileNickname;

  /// No description provided for @profileBio.
  ///
  /// In zh_CN, this message translates to:
  /// **'简介'**
  String get profileBio;

  /// No description provided for @profileAvatar.
  ///
  /// In zh_CN, this message translates to:
  /// **'头像'**
  String get profileAvatar;

  /// No description provided for @profileBioHint.
  ///
  /// In zh_CN, this message translates to:
  /// **'介绍一下你自己'**
  String get profileBioHint;

  /// No description provided for @profileGender.
  ///
  /// In zh_CN, this message translates to:
  /// **'性别'**
  String get profileGender;

  /// No description provided for @profileGenderMale.
  ///
  /// In zh_CN, this message translates to:
  /// **'男'**
  String get profileGenderMale;

  /// No description provided for @profileGenderFemale.
  ///
  /// In zh_CN, this message translates to:
  /// **'女'**
  String get profileGenderFemale;

  /// No description provided for @profileGenderOther.
  ///
  /// In zh_CN, this message translates to:
  /// **'其他'**
  String get profileGenderOther;

  /// No description provided for @profileGenderPreferNotToSay.
  ///
  /// In zh_CN, this message translates to:
  /// **'不愿透露'**
  String get profileGenderPreferNotToSay;

  /// No description provided for @profileCity.
  ///
  /// In zh_CN, this message translates to:
  /// **'城市'**
  String get profileCity;

  /// No description provided for @profileExperienceLevel.
  ///
  /// In zh_CN, this message translates to:
  /// **'运动经验'**
  String get profileExperienceLevel;

  /// No description provided for @profileSportPreference.
  ///
  /// In zh_CN, this message translates to:
  /// **'运动偏好'**
  String get profileSportPreference;

  /// No description provided for @profileNicknameError.
  ///
  /// In zh_CN, this message translates to:
  /// **'请输入有效昵称（2-20字符）'**
  String get profileNicknameError;

  /// No description provided for @profileSportSelectionError.
  ///
  /// In zh_CN, this message translates to:
  /// **'请至少选择一项运动'**
  String get profileSportSelectionError;

  /// No description provided for @profileSaveSuccess.
  ///
  /// In zh_CN, this message translates to:
  /// **'保存成功'**
  String get profileSaveSuccess;

  /// No description provided for @profileUserNotFound.
  ///
  /// In zh_CN, this message translates to:
  /// **'用户不存在'**
  String get profileUserNotFound;

  /// No description provided for @avatarPickerGallery.
  ///
  /// In zh_CN, this message translates to:
  /// **'从相册选择'**
  String get avatarPickerGallery;

  /// No description provided for @avatarPickerCamera.
  ///
  /// In zh_CN, this message translates to:
  /// **'拍照'**
  String get avatarPickerCamera;

  /// No description provided for @avatarPickerCropTitle.
  ///
  /// In zh_CN, this message translates to:
  /// **'裁剪头像'**
  String get avatarPickerCropTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In zh_CN, this message translates to:
  /// **'设置'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In zh_CN, this message translates to:
  /// **'语言'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In zh_CN, this message translates to:
  /// **'主题'**
  String get settingsTheme;

  /// No description provided for @settingsThemeDark.
  ///
  /// In zh_CN, this message translates to:
  /// **'深色'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeLight.
  ///
  /// In zh_CN, this message translates to:
  /// **'浅色'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In zh_CN, this message translates to:
  /// **'跟随系统'**
  String get settingsThemeSystem;

  /// No description provided for @settingsPrivacy.
  ///
  /// In zh_CN, this message translates to:
  /// **'隐私设置'**
  String get settingsPrivacy;

  /// No description provided for @settingsAbout.
  ///
  /// In zh_CN, this message translates to:
  /// **'关于'**
  String get settingsAbout;

  /// No description provided for @settingsLogout.
  ///
  /// In zh_CN, this message translates to:
  /// **'退出登录'**
  String get settingsLogout;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In zh_CN, this message translates to:
  /// **'注销账号'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsExportData.
  ///
  /// In zh_CN, this message translates to:
  /// **'导出我的数据'**
  String get settingsExportData;

  /// No description provided for @privacyTitle.
  ///
  /// In zh_CN, this message translates to:
  /// **'隐私政策'**
  String get privacyTitle;

  /// No description provided for @privacyAgree.
  ///
  /// In zh_CN, this message translates to:
  /// **'我已阅读并同意'**
  String get privacyAgree;

  /// No description provided for @privacyDisagree.
  ///
  /// In zh_CN, this message translates to:
  /// **'不同意'**
  String get privacyDisagree;

  /// No description provided for @commonCancel.
  ///
  /// In zh_CN, this message translates to:
  /// **'取消'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In zh_CN, this message translates to:
  /// **'确认'**
  String get commonConfirm;

  /// No description provided for @commonSave.
  ///
  /// In zh_CN, this message translates to:
  /// **'保存'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In zh_CN, this message translates to:
  /// **'删除'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In zh_CN, this message translates to:
  /// **'编辑'**
  String get commonEdit;

  /// No description provided for @commonShare.
  ///
  /// In zh_CN, this message translates to:
  /// **'分享'**
  String get commonShare;

  /// No description provided for @commonReport.
  ///
  /// In zh_CN, this message translates to:
  /// **'举报'**
  String get commonReport;

  /// No description provided for @commonBlock.
  ///
  /// In zh_CN, this message translates to:
  /// **'屏蔽'**
  String get commonBlock;

  /// No description provided for @commonRetry.
  ///
  /// In zh_CN, this message translates to:
  /// **'重试'**
  String get commonRetry;

  /// No description provided for @commonLoading.
  ///
  /// In zh_CN, this message translates to:
  /// **'加载中...'**
  String get commonLoading;

  /// No description provided for @commonEmpty.
  ///
  /// In zh_CN, this message translates to:
  /// **'暂无数据'**
  String get commonEmpty;

  /// No description provided for @commonError.
  ///
  /// In zh_CN, this message translates to:
  /// **'出错了，请重试'**
  String get commonError;

  /// No description provided for @commonSuccess.
  ///
  /// In zh_CN, this message translates to:
  /// **'操作成功'**
  String get commonSuccess;

  /// No description provided for @commonNoNetwork.
  ///
  /// In zh_CN, this message translates to:
  /// **'网络连接失败，请检查网络'**
  String get commonNoNetwork;

  /// No description provided for @commonDone.
  ///
  /// In zh_CN, this message translates to:
  /// **'完成'**
  String get commonDone;

  /// No description provided for @chatTitle.
  ///
  /// In zh_CN, this message translates to:
  /// **'私信'**
  String get chatTitle;

  /// No description provided for @chatNoConversations.
  ///
  /// In zh_CN, this message translates to:
  /// **'暂无消息'**
  String get chatNoConversations;

  /// No description provided for @chatNoConversationsTip.
  ///
  /// In zh_CN, this message translates to:
  /// **'和好友聊聊天吧'**
  String get chatNoConversationsTip;

  /// No description provided for @chatEmpty.
  ///
  /// In zh_CN, this message translates to:
  /// **'发送第一条消息吧'**
  String get chatEmpty;

  /// No description provided for @chatInputHint.
  ///
  /// In zh_CN, this message translates to:
  /// **'输入消息...'**
  String get chatInputHint;

  /// No description provided for @gymTitle.
  ///
  /// In zh_CN, this message translates to:
  /// **'训练馆'**
  String get gymTitle;

  /// No description provided for @gymNearby.
  ///
  /// In zh_CN, this message translates to:
  /// **'附近训练馆'**
  String get gymNearby;

  /// No description provided for @gymSearch.
  ///
  /// In zh_CN, this message translates to:
  /// **'搜索训练馆...'**
  String get gymSearch;

  /// No description provided for @gymDetail.
  ///
  /// In zh_CN, this message translates to:
  /// **'训练馆详情'**
  String get gymDetail;

  /// No description provided for @gymSubmit.
  ///
  /// In zh_CN, this message translates to:
  /// **'提交训练馆'**
  String get gymSubmit;

  /// No description provided for @gymAddress.
  ///
  /// In zh_CN, this message translates to:
  /// **'地址'**
  String get gymAddress;

  /// No description provided for @gymPhone.
  ///
  /// In zh_CN, this message translates to:
  /// **'电话'**
  String get gymPhone;

  /// No description provided for @gymWebsite.
  ///
  /// In zh_CN, this message translates to:
  /// **'网站'**
  String get gymWebsite;

  /// No description provided for @gymOpeningHours.
  ///
  /// In zh_CN, this message translates to:
  /// **'营业时间'**
  String get gymOpeningHours;

  /// No description provided for @gymSportTypes.
  ///
  /// In zh_CN, this message translates to:
  /// **'运动类型'**
  String get gymSportTypes;

  /// No description provided for @gymReviews.
  ///
  /// In zh_CN, this message translates to:
  /// **'评价'**
  String get gymReviews;

  /// No description provided for @gymWriteReview.
  ///
  /// In zh_CN, this message translates to:
  /// **'写评价'**
  String get gymWriteReview;

  /// No description provided for @gymRating.
  ///
  /// In zh_CN, this message translates to:
  /// **'评分'**
  String get gymRating;

  /// No description provided for @gymNoReviews.
  ///
  /// In zh_CN, this message translates to:
  /// **'暂无评价'**
  String get gymNoReviews;

  /// No description provided for @gymSubmitSuccess.
  ///
  /// In zh_CN, this message translates to:
  /// **'训练馆已提交，等待审核'**
  String get gymSubmitSuccess;

  /// No description provided for @gymPending.
  ///
  /// In zh_CN, this message translates to:
  /// **'待审核'**
  String get gymPending;

  /// No description provided for @gymVerified.
  ///
  /// In zh_CN, this message translates to:
  /// **'已认证'**
  String get gymVerified;

  /// No description provided for @gymFavorite.
  ///
  /// In zh_CN, this message translates to:
  /// **'收藏'**
  String get gymFavorite;

  /// No description provided for @gymFavorited.
  ///
  /// In zh_CN, this message translates to:
  /// **'已收藏'**
  String get gymFavorited;

  /// No description provided for @gymFavoriteAdded.
  ///
  /// In zh_CN, this message translates to:
  /// **'已添加收藏'**
  String get gymFavoriteAdded;

  /// No description provided for @gymFavoriteRemoved.
  ///
  /// In zh_CN, this message translates to:
  /// **'已取消收藏'**
  String get gymFavoriteRemoved;

  /// No description provided for @gymMyFavorites.
  ///
  /// In zh_CN, this message translates to:
  /// **'我的收藏训练馆'**
  String get gymMyFavorites;

  /// No description provided for @gymNoFavorites.
  ///
  /// In zh_CN, this message translates to:
  /// **'暂无收藏'**
  String get gymNoFavorites;

  /// No description provided for @gymClaimThis.
  ///
  /// In zh_CN, this message translates to:
  /// **'认领此场馆'**
  String get gymClaimThis;

  /// No description provided for @gymClaimConfirm.
  ///
  /// In zh_CN, this message translates to:
  /// **'认领场馆'**
  String get gymClaimConfirm;

  /// No description provided for @gymClaimConfirmDesc.
  ///
  /// In zh_CN, this message translates to:
  /// **'您是此训练馆的馆主或管理员吗？提交认领后将进入审核流程。'**
  String get gymClaimConfirmDesc;

  /// No description provided for @gymClaimSubmit.
  ///
  /// In zh_CN, this message translates to:
  /// **'提交认领'**
  String get gymClaimSubmit;

  /// No description provided for @gymClaimSuccess.
  ///
  /// In zh_CN, this message translates to:
  /// **'认领申请已提交，等待审核'**
  String get gymClaimSuccess;

  /// No description provided for @gymClaimStatus.
  ///
  /// In zh_CN, this message translates to:
  /// **'认领状态'**
  String get gymClaimStatus;

  /// No description provided for @gymClaimPending.
  ///
  /// In zh_CN, this message translates to:
  /// **'审核中'**
  String get gymClaimPending;

  /// No description provided for @gymClaimApproved.
  ///
  /// In zh_CN, this message translates to:
  /// **'已通过'**
  String get gymClaimApproved;

  /// No description provided for @gymClaimRejected.
  ///
  /// In zh_CN, this message translates to:
  /// **'已拒绝'**
  String get gymClaimRejected;

  /// No description provided for @postCreate.
  ///
  /// In zh_CN, this message translates to:
  /// **'发布动态'**
  String get postCreate;

  /// No description provided for @postPublish.
  ///
  /// In zh_CN, this message translates to:
  /// **'发布'**
  String get postPublish;

  /// No description provided for @postPublishSuccess.
  ///
  /// In zh_CN, this message translates to:
  /// **'动态发布成功'**
  String get postPublishSuccess;

  /// No description provided for @postContentHint.
  ///
  /// In zh_CN, this message translates to:
  /// **'分享你的训练或想法...'**
  String get postContentHint;

  /// No description provided for @postCity.
  ///
  /// In zh_CN, this message translates to:
  /// **'城市'**
  String get postCity;

  /// No description provided for @postCreateSubtitle.
  ///
  /// In zh_CN, this message translates to:
  /// **'分享你的训练瞬间'**
  String get postCreateSubtitle;

  /// No description provided for @postEmpty.
  ///
  /// In zh_CN, this message translates to:
  /// **'暂无动态'**
  String get postEmpty;

  /// No description provided for @postEmptyTip.
  ///
  /// In zh_CN, this message translates to:
  /// **'成为第一个分享动态的人'**
  String get postEmptyTip;

  /// No description provided for @postNewAvailable.
  ///
  /// In zh_CN, this message translates to:
  /// **'有新动态，点击刷新'**
  String get postNewAvailable;

  /// No description provided for @postNoFollowing.
  ///
  /// In zh_CN, this message translates to:
  /// **'暂无关注动态'**
  String get postNoFollowing;

  /// No description provided for @postFollowTip.
  ///
  /// In zh_CN, this message translates to:
  /// **'关注运动伙伴，查看他们的训练动态'**
  String get postFollowTip;

  /// No description provided for @postLikes.
  ///
  /// In zh_CN, this message translates to:
  /// **'{count} 个赞'**
  String postLikes(int count);

  /// No description provided for @postComments.
  ///
  /// In zh_CN, this message translates to:
  /// **'{count} 条评论'**
  String postComments(int count);

  /// No description provided for @postDeleteConfirm.
  ///
  /// In zh_CN, this message translates to:
  /// **'确定删除这条动态吗？'**
  String get postDeleteConfirm;

  /// No description provided for @postDeleted.
  ///
  /// In zh_CN, this message translates to:
  /// **'动态已删除'**
  String get postDeleted;

  /// No description provided for @appLaunchConsentTitle.
  ///
  /// In zh_CN, this message translates to:
  /// **'欢迎使用 VerveForge'**
  String get appLaunchConsentTitle;

  /// No description provided for @appLaunchConsentDesc.
  ///
  /// In zh_CN, this message translates to:
  /// **'在使用我们的服务前，请了解我们如何处理您的数据：'**
  String get appLaunchConsentDesc;

  /// No description provided for @appLaunchConsentItem1.
  ///
  /// In zh_CN, this message translates to:
  /// **'账号信息：邮箱、Apple ID、昵称、头像'**
  String get appLaunchConsentItem1;

  /// No description provided for @appLaunchConsentItem2.
  ///
  /// In zh_CN, this message translates to:
  /// **'训练数据：训练日志、Apple Health 同步、照片'**
  String get appLaunchConsentItem2;

  /// No description provided for @appLaunchConsentItem3.
  ///
  /// In zh_CN, this message translates to:
  /// **'位置信息：用于发现附近训练馆和训练伙伴'**
  String get appLaunchConsentItem3;

  /// No description provided for @appLaunchConsentItem4.
  ///
  /// In zh_CN, this message translates to:
  /// **'您的数据加密存储，可随时导出或删除'**
  String get appLaunchConsentItem4;

  /// No description provided for @appLaunchConsentReadFull.
  ///
  /// In zh_CN, this message translates to:
  /// **'查看完整隐私政策'**
  String get appLaunchConsentReadFull;

  /// No description provided for @profileNoBio.
  ///
  /// In zh_CN, this message translates to:
  /// **'还没有设置简介'**
  String get profileNoBio;

  /// No description provided for @profileRegisterFirst.
  ///
  /// In zh_CN, this message translates to:
  /// **'请先完成注册'**
  String get profileRegisterFirst;

  /// No description provided for @profileGoRegister.
  ///
  /// In zh_CN, this message translates to:
  /// **'去注册'**
  String get profileGoRegister;

  /// No description provided for @profileMyChallenges.
  ///
  /// In zh_CN, this message translates to:
  /// **'我的挑战'**
  String get profileMyChallenges;

  /// No description provided for @profileMyBuddies.
  ///
  /// In zh_CN, this message translates to:
  /// **'我的伙伴'**
  String get profileMyBuddies;

  /// No description provided for @profileSectionTraining.
  ///
  /// In en, this message translates to:
  /// **'TRAINING'**
  String get profileSectionTraining;

  /// No description provided for @profileSectionSocial.
  ///
  /// In en, this message translates to:
  /// **'SOCIAL'**
  String get profileSectionSocial;

  /// No description provided for @profileSectionAccount.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get profileSectionAccount;

  /// No description provided for @buddyListTitle.
  ///
  /// In zh_CN, this message translates to:
  /// **'好友列表'**
  String get buddyListTitle;

  /// No description provided for @buddyRequests.
  ///
  /// In zh_CN, this message translates to:
  /// **'好友请求'**
  String get buddyRequests;

  /// No description provided for @buddyReceived.
  ///
  /// In zh_CN, this message translates to:
  /// **'收到的'**
  String get buddyReceived;

  /// No description provided for @buddySent.
  ///
  /// In zh_CN, this message translates to:
  /// **'发出的'**
  String get buddySent;

  /// No description provided for @buddyAccept.
  ///
  /// In zh_CN, this message translates to:
  /// **'接受'**
  String get buddyAccept;

  /// No description provided for @buddyReject.
  ///
  /// In zh_CN, this message translates to:
  /// **'拒绝'**
  String get buddyReject;

  /// No description provided for @buddyCancel.
  ///
  /// In zh_CN, this message translates to:
  /// **'撤回'**
  String get buddyCancel;

  /// No description provided for @buddyRemove.
  ///
  /// In zh_CN, this message translates to:
  /// **'删除好友'**
  String get buddyRemove;

  /// No description provided for @buddyPending.
  ///
  /// In zh_CN, this message translates to:
  /// **'等待回复'**
  String get buddyPending;

  /// No description provided for @buddyAccepted.
  ///
  /// In zh_CN, this message translates to:
  /// **'已成为好友'**
  String get buddyAccepted;

  /// No description provided for @buddyNoRequests.
  ///
  /// In zh_CN, this message translates to:
  /// **'暂无好友请求'**
  String get buddyNoRequests;

  /// No description provided for @buddyNoRequestsTip.
  ///
  /// In zh_CN, this message translates to:
  /// **'去附近页面发现更多运动伙伴'**
  String get buddyNoRequestsTip;

  /// No description provided for @buddyNoSentRequests.
  ///
  /// In zh_CN, this message translates to:
  /// **'暂无发出的请求'**
  String get buddyNoSentRequests;

  /// No description provided for @buddyNoBuddies.
  ///
  /// In zh_CN, this message translates to:
  /// **'还没有好友'**
  String get buddyNoBuddies;

  /// No description provided for @buddyNoBuddiesTip.
  ///
  /// In zh_CN, this message translates to:
  /// **'去附近页面发现运动伙伴吧'**
  String get buddyNoBuddiesTip;

  /// No description provided for @buddyRemoveConfirm.
  ///
  /// In zh_CN, this message translates to:
  /// **'删除好友'**
  String get buddyRemoveConfirm;

  /// No description provided for @buddyRemoveConfirmDesc.
  ///
  /// In zh_CN, this message translates to:
  /// **'确定删除该好友吗？删除后需要重新发送请求'**
  String get buddyRemoveConfirmDesc;

  /// No description provided for @buddyRemoved.
  ///
  /// In zh_CN, this message translates to:
  /// **'已删除好友'**
  String get buddyRemoved;

  /// No description provided for @profileMyDrafts.
  ///
  /// In zh_CN, this message translates to:
  /// **'训练草稿'**
  String get profileMyDrafts;

  /// No description provided for @profilePrivacy.
  ///
  /// In zh_CN, this message translates to:
  /// **'隐私设置'**
  String get profilePrivacy;

  /// No description provided for @settingsFollowSystem.
  ///
  /// In zh_CN, this message translates to:
  /// **'跟随系统'**
  String get settingsFollowSystem;

  /// No description provided for @settingsOpenSource.
  ///
  /// In zh_CN, this message translates to:
  /// **'开源协议'**
  String get settingsOpenSource;

  /// No description provided for @settingsLogoutConfirm.
  ///
  /// In zh_CN, this message translates to:
  /// **'确认退出登录？'**
  String get settingsLogoutConfirm;

  /// No description provided for @settingsLogoutDesc.
  ///
  /// In zh_CN, this message translates to:
  /// **'退出后需要重新登录'**
  String get settingsLogoutDesc;

  /// No description provided for @aiAvatarTitle.
  ///
  /// In zh_CN, this message translates to:
  /// **'我的 AI 分身'**
  String get aiAvatarTitle;

  /// No description provided for @aiAvatarCreate.
  ///
  /// In zh_CN, this message translates to:
  /// **'创建 AI 分身'**
  String get aiAvatarCreate;

  /// No description provided for @aiAvatarEdit.
  ///
  /// In zh_CN, this message translates to:
  /// **'编辑分身'**
  String get aiAvatarEdit;

  /// No description provided for @aiAvatarDelete.
  ///
  /// In zh_CN, this message translates to:
  /// **'删除分身'**
  String get aiAvatarDelete;

  /// No description provided for @aiAvatarDeleteConfirm.
  ///
  /// In zh_CN, this message translates to:
  /// **'确定删除 AI 分身吗？此操作不可恢复。'**
  String get aiAvatarDeleteConfirm;

  /// No description provided for @aiAvatarDeleted.
  ///
  /// In zh_CN, this message translates to:
  /// **'AI 分身已删除'**
  String get aiAvatarDeleted;

  /// No description provided for @aiAvatarSaved.
  ///
  /// In zh_CN, this message translates to:
  /// **'AI 分身已保存'**
  String get aiAvatarSaved;

  /// No description provided for @aiAvatarEmpty.
  ///
  /// In zh_CN, this message translates to:
  /// **'还没有 AI 分身'**
  String get aiAvatarEmpty;

  /// No description provided for @aiAvatarEmptyTip.
  ///
  /// In zh_CN, this message translates to:
  /// **'创建一个代表你的 AI 虚拟分身'**
  String get aiAvatarEmptyTip;

  /// No description provided for @aiAvatarStepName.
  ///
  /// In zh_CN, this message translates to:
  /// **'名称和风格'**
  String get aiAvatarStepName;

  /// No description provided for @aiAvatarStepPersonality.
  ///
  /// In zh_CN, this message translates to:
  /// **'性格特征'**
  String get aiAvatarStepPersonality;

  /// No description provided for @aiAvatarStepStyle.
  ///
  /// In zh_CN, this message translates to:
  /// **'选择外貌'**
  String get aiAvatarStepStyle;

  /// No description provided for @aiAvatarName.
  ///
  /// In zh_CN, this message translates to:
  /// **'分身名称'**
  String get aiAvatarName;

  /// No description provided for @aiAvatarNameHint.
  ///
  /// In zh_CN, this message translates to:
  /// **'给你的分身取个名字'**
  String get aiAvatarNameHint;

  /// No description provided for @aiAvatarPhoto.
  ///
  /// In zh_CN, this message translates to:
  /// **'分身头像'**
  String get aiAvatarPhoto;

  /// No description provided for @aiAvatarCustomPrompt.
  ///
  /// In zh_CN, this message translates to:
  /// **'自定义指令'**
  String get aiAvatarCustomPrompt;

  /// No description provided for @aiAvatarCustomPromptHint.
  ///
  /// In zh_CN, this message translates to:
  /// **'可选：添加特别指令来调整分身行为'**
  String get aiAvatarCustomPromptHint;

  /// No description provided for @aiAvatarPickPreset.
  ///
  /// In zh_CN, this message translates to:
  /// **'选择一个预设头像'**
  String get aiAvatarPickPreset;

  /// No description provided for @aiAvatarOrUpload.
  ///
  /// In zh_CN, this message translates to:
  /// **'或上传自定义头像'**
  String get aiAvatarOrUpload;

  /// No description provided for @aiAvatarPreviewTitle.
  ///
  /// In zh_CN, this message translates to:
  /// **'风格预览'**
  String get aiAvatarPreviewTitle;

  /// No description provided for @aiAvatarPreviewHint.
  ///
  /// In zh_CN, this message translates to:
  /// **'你的分身会这样回复：'**
  String get aiAvatarPreviewHint;

  /// No description provided for @aiAvatarSelectTraitsHint.
  ///
  /// In zh_CN, this message translates to:
  /// **'选择符合你的标签（最多 5 个）'**
  String get aiAvatarSelectTraitsHint;

  /// No description provided for @presetRunner.
  ///
  /// In zh_CN, this message translates to:
  /// **'跑者'**
  String get presetRunner;

  /// No description provided for @presetYogi.
  ///
  /// In zh_CN, this message translates to:
  /// **'瑜伽人'**
  String get presetYogi;

  /// No description provided for @presetLifter.
  ///
  /// In zh_CN, this message translates to:
  /// **'举铁人'**
  String get presetLifter;

  /// No description provided for @presetSwimmer.
  ///
  /// In zh_CN, this message translates to:
  /// **'游泳者'**
  String get presetSwimmer;

  /// No description provided for @presetCyclist.
  ///
  /// In zh_CN, this message translates to:
  /// **'骑行者'**
  String get presetCyclist;

  /// No description provided for @presetBoxer.
  ///
  /// In zh_CN, this message translates to:
  /// **'拳击手'**
  String get presetBoxer;

  /// No description provided for @presetClimber.
  ///
  /// In zh_CN, this message translates to:
  /// **'攀岩者'**
  String get presetClimber;

  /// No description provided for @presetDancer.
  ///
  /// In zh_CN, this message translates to:
  /// **'舞者'**
  String get presetDancer;

  /// No description provided for @presetMartial.
  ///
  /// In zh_CN, this message translates to:
  /// **'武术家'**
  String get presetMartial;

  /// No description provided for @presetSkier.
  ///
  /// In zh_CN, this message translates to:
  /// **'滑雪者'**
  String get presetSkier;

  /// No description provided for @presetSurfer.
  ///
  /// In zh_CN, this message translates to:
  /// **'冲浪者'**
  String get presetSurfer;

  /// No description provided for @presetTennis.
  ///
  /// In zh_CN, this message translates to:
  /// **'网球手'**
  String get presetTennis;

  /// No description provided for @presetBasketball.
  ///
  /// In zh_CN, this message translates to:
  /// **'篮球手'**
  String get presetBasketball;

  /// No description provided for @presetSoccer.
  ///
  /// In zh_CN, this message translates to:
  /// **'足球迷'**
  String get presetSoccer;

  /// No description provided for @presetHiker.
  ///
  /// In zh_CN, this message translates to:
  /// **'徒步者'**
  String get presetHiker;

  /// No description provided for @presetGymnast.
  ///
  /// In zh_CN, this message translates to:
  /// **'体操人'**
  String get presetGymnast;

  /// No description provided for @presetRower.
  ///
  /// In zh_CN, this message translates to:
  /// **'划船者'**
  String get presetRower;

  /// No description provided for @presetSkater.
  ///
  /// In zh_CN, this message translates to:
  /// **'滑冰者'**
  String get presetSkater;

  /// No description provided for @presetNinja.
  ///
  /// In zh_CN, this message translates to:
  /// **'忍者'**
  String get presetNinja;

  /// No description provided for @presetRobot.
  ///
  /// In zh_CN, this message translates to:
  /// **'机器人'**
  String get presetRobot;

  /// No description provided for @presetFire.
  ///
  /// In zh_CN, this message translates to:
  /// **'火焰'**
  String get presetFire;

  /// No description provided for @presetLightning.
  ///
  /// In zh_CN, this message translates to:
  /// **'闪电'**
  String get presetLightning;

  /// No description provided for @presetStar.
  ///
  /// In zh_CN, this message translates to:
  /// **'星星'**
  String get presetStar;

  /// No description provided for @presetDiamond.
  ///
  /// In zh_CN, this message translates to:
  /// **'钻石'**
  String get presetDiamond;

  /// No description provided for @aiTraitEarlyRunner.
  ///
  /// In zh_CN, this message translates to:
  /// **'晨跑达人'**
  String get aiTraitEarlyRunner;

  /// No description provided for @aiTraitYogaMaster.
  ///
  /// In zh_CN, this message translates to:
  /// **'瑜伽达人'**
  String get aiTraitYogaMaster;

  /// No description provided for @aiTraitIronAddict.
  ///
  /// In zh_CN, this message translates to:
  /// **'举铁狂魔'**
  String get aiTraitIronAddict;

  /// No description provided for @aiTraitCrossfitFanatic.
  ///
  /// In zh_CN, this message translates to:
  /// **'CrossFit 狂热粉'**
  String get aiTraitCrossfitFanatic;

  /// No description provided for @aiTraitMarathoner.
  ///
  /// In zh_CN, this message translates to:
  /// **'马拉松跑者'**
  String get aiTraitMarathoner;

  /// No description provided for @aiTraitGymRat.
  ///
  /// In zh_CN, this message translates to:
  /// **'健身房常客'**
  String get aiTraitGymRat;

  /// No description provided for @aiTraitOutdoorExplorer.
  ///
  /// In zh_CN, this message translates to:
  /// **'户外探险家'**
  String get aiTraitOutdoorExplorer;

  /// No description provided for @aiTraitFlexibilityPro.
  ///
  /// In zh_CN, this message translates to:
  /// **'柔韧性达人'**
  String get aiTraitFlexibilityPro;

  /// No description provided for @aiTraitTeamPlayer.
  ///
  /// In zh_CN, this message translates to:
  /// **'团队合作者'**
  String get aiTraitTeamPlayer;

  /// No description provided for @aiTraitSoloWarrior.
  ///
  /// In zh_CN, this message translates to:
  /// **'独行侠'**
  String get aiTraitSoloWarrior;

  /// No description provided for @aiTraitTechGeek.
  ///
  /// In zh_CN, this message translates to:
  /// **'科技极客'**
  String get aiTraitTechGeek;

  /// No description provided for @aiTraitNutritionNerd.
  ///
  /// In zh_CN, this message translates to:
  /// **'营养学家'**
  String get aiTraitNutritionNerd;

  /// No description provided for @aiTraitRestDayHater.
  ///
  /// In zh_CN, this message translates to:
  /// **'不需要休息日'**
  String get aiTraitRestDayHater;

  /// No description provided for @aiTraitWarmupSkipper.
  ///
  /// In zh_CN, this message translates to:
  /// **'跳过热身'**
  String get aiTraitWarmupSkipper;

  /// No description provided for @aiTraitPrBeast.
  ///
  /// In zh_CN, this message translates to:
  /// **'PR 猛兽'**
  String get aiTraitPrBeast;

  /// No description provided for @aiTraitCheerleader.
  ///
  /// In zh_CN, this message translates to:
  /// **'啦啦队长'**
  String get aiTraitCheerleader;

  /// No description provided for @aiTraitEnthusiastic.
  ///
  /// In zh_CN, this message translates to:
  /// **'热情'**
  String get aiTraitEnthusiastic;

  /// No description provided for @aiTraitProfessional.
  ///
  /// In zh_CN, this message translates to:
  /// **'专业'**
  String get aiTraitProfessional;

  /// No description provided for @aiTraitHumorous.
  ///
  /// In zh_CN, this message translates to:
  /// **'幽默'**
  String get aiTraitHumorous;

  /// No description provided for @aiTraitEncouraging.
  ///
  /// In zh_CN, this message translates to:
  /// **'鼓励'**
  String get aiTraitEncouraging;

  /// No description provided for @aiTraitCalm.
  ///
  /// In zh_CN, this message translates to:
  /// **'沉稳'**
  String get aiTraitCalm;

  /// No description provided for @aiTraitFriendly.
  ///
  /// In zh_CN, this message translates to:
  /// **'友好'**
  String get aiTraitFriendly;

  /// No description provided for @aiTraitDirect.
  ///
  /// In zh_CN, this message translates to:
  /// **'直接'**
  String get aiTraitDirect;

  /// No description provided for @aiTraitCurious.
  ///
  /// In zh_CN, this message translates to:
  /// **'好奇'**
  String get aiTraitCurious;

  /// No description provided for @aiStyleLively.
  ///
  /// In zh_CN, this message translates to:
  /// **'活泼'**
  String get aiStyleLively;

  /// No description provided for @aiStyleLivelyDesc.
  ///
  /// In zh_CN, this message translates to:
  /// **'充满活力、热情洋溢，喜欢用感叹号'**
  String get aiStyleLivelyDesc;

  /// No description provided for @aiStyleLivelyPreview.
  ///
  /// In zh_CN, this message translates to:
  /// **'太棒了！！今早刚跑完 5 公里 🏃💨 天气超好！下次一起跑呀？'**
  String get aiStyleLivelyPreview;

  /// No description provided for @aiStyleSteady.
  ///
  /// In zh_CN, this message translates to:
  /// **'沉稳'**
  String get aiStyleSteady;

  /// No description provided for @aiStyleSteadyDesc.
  ///
  /// In zh_CN, this message translates to:
  /// **'冷静且理性，言简意赅、就事论事'**
  String get aiStyleSteadyDesc;

  /// No description provided for @aiStyleSteadyPreview.
  ///
  /// In zh_CN, this message translates to:
  /// **'晨跑完毕。5 公里用时 24 分钟，配速稳定。天气不错。'**
  String get aiStyleSteadyPreview;

  /// No description provided for @aiStyleHumorous.
  ///
  /// In zh_CN, this message translates to:
  /// **'幽默'**
  String get aiStyleHumorous;

  /// No description provided for @aiStyleHumorousDesc.
  ///
  /// In zh_CN, this message translates to:
  /// **'风趣且俏皮，擅长自嘲和段子'**
  String get aiStyleHumorousDesc;

  /// No description provided for @aiStyleHumorousPreview.
  ///
  /// In zh_CN, this message translates to:
  /// **'今天跑了 5 公里…嗯，腿跑了，脑子还在被窝里 😂 还好歌单在线！'**
  String get aiStyleHumorousPreview;

  /// No description provided for @aiStyleFriendly.
  ///
  /// In zh_CN, this message translates to:
  /// **'友好随意'**
  String get aiStyleFriendly;

  /// No description provided for @aiStyleProfessional.
  ///
  /// In zh_CN, this message translates to:
  /// **'专业简洁'**
  String get aiStyleProfessional;

  /// No description provided for @aiStyleEncouraging.
  ///
  /// In zh_CN, this message translates to:
  /// **'温暖鼓励'**
  String get aiStyleEncouraging;

  /// No description provided for @aiAutoReply.
  ///
  /// In zh_CN, this message translates to:
  /// **'离线自动回复'**
  String get aiAutoReply;

  /// No description provided for @aiAutoReplyDesc.
  ///
  /// In zh_CN, this message translates to:
  /// **'当你离线超过 5 分钟时，分身自动代替你回复'**
  String get aiAutoReplyDesc;

  /// No description provided for @aiAutoReplyEnabled.
  ///
  /// In zh_CN, this message translates to:
  /// **'自动回复已开启'**
  String get aiAutoReplyEnabled;

  /// No description provided for @aiAutoReplyDisabled.
  ///
  /// In zh_CN, this message translates to:
  /// **'自动回复已关闭'**
  String get aiAutoReplyDisabled;

  /// No description provided for @aiGeneratedLabel.
  ///
  /// In zh_CN, this message translates to:
  /// **'由 AI 分身回复'**
  String get aiGeneratedLabel;

  /// No description provided for @aiAvatarChat.
  ///
  /// In zh_CN, this message translates to:
  /// **'与分身聊天'**
  String get aiAvatarChat;

  /// No description provided for @aiAvatarChatHint.
  ///
  /// In zh_CN, this message translates to:
  /// **'对你的分身说点什么...'**
  String get aiAvatarChatHint;

  /// No description provided for @aiAvatarChatIntro.
  ///
  /// In zh_CN, this message translates to:
  /// **'和你的 AI 分身聊聊，看看它的回复效果'**
  String get aiAvatarChatIntro;

  /// No description provided for @aiAvatarThinking.
  ///
  /// In zh_CN, this message translates to:
  /// **'分身思考中...'**
  String get aiAvatarThinking;

  /// No description provided for @aiConsentTitle.
  ///
  /// In zh_CN, this message translates to:
  /// **'AI 数据处理授权'**
  String get aiConsentTitle;

  /// No description provided for @aiConsentDesc.
  ///
  /// In zh_CN, this message translates to:
  /// **'创建 AI 分身需要处理以下数据：'**
  String get aiConsentDesc;

  /// No description provided for @aiConsentItem1.
  ///
  /// In zh_CN, this message translates to:
  /// **'您的个人资料（昵称、简介、运动类型、城市）'**
  String get aiConsentItem1;

  /// No description provided for @aiConsentItem2.
  ///
  /// In zh_CN, this message translates to:
  /// **'最近的聊天消息（最近 10 条）用于上下文'**
  String get aiConsentItem2;

  /// No description provided for @aiConsentItem3.
  ///
  /// In zh_CN, this message translates to:
  /// **'您最近的公开动态（最近 5 条）'**
  String get aiConsentItem3;

  /// No description provided for @aiConsentItem4.
  ///
  /// In zh_CN, this message translates to:
  /// **'数据通过 AI 处理，不会永久存储'**
  String get aiConsentItem4;

  /// No description provided for @aiConsentItem5.
  ///
  /// In zh_CN, this message translates to:
  /// **'对方会看到「AI 分身回复」的标记'**
  String get aiConsentItem5;

  /// No description provided for @aiConsentAgree.
  ///
  /// In zh_CN, this message translates to:
  /// **'同意并继续'**
  String get aiConsentAgree;

  /// No description provided for @aiConsentDisagree.
  ///
  /// In zh_CN, this message translates to:
  /// **'取消'**
  String get aiConsentDisagree;

  /// No description provided for @aiChatQuickLegDay.
  ///
  /// In zh_CN, this message translates to:
  /// **'今天练腿了'**
  String get aiChatQuickLegDay;

  /// No description provided for @aiChatQuickRan5k.
  ///
  /// In zh_CN, this message translates to:
  /// **'刚跑完 5km'**
  String get aiChatQuickRan5k;

  /// No description provided for @aiChatQuickFeelSore.
  ///
  /// In zh_CN, this message translates to:
  /// **'全身酸痛'**
  String get aiChatQuickFeelSore;

  /// No description provided for @aiChatQuickRestDay.
  ///
  /// In zh_CN, this message translates to:
  /// **'今天休息日'**
  String get aiChatQuickRestDay;

  /// No description provided for @aiChatQuickNewPR.
  ///
  /// In zh_CN, this message translates to:
  /// **'破了 PR！'**
  String get aiChatQuickNewPR;

  /// No description provided for @aiChatStartChat.
  ///
  /// In zh_CN, this message translates to:
  /// **'立即聊天'**
  String get aiChatStartChat;

  /// No description provided for @aiChatNoMessages.
  ///
  /// In zh_CN, this message translates to:
  /// **'还没有消息'**
  String get aiChatNoMessages;

  /// No description provided for @aiChatNoMessagesTip.
  ///
  /// In zh_CN, this message translates to:
  /// **'发送第一条消息开始聊天吧'**
  String get aiChatNoMessagesTip;

  /// No description provided for @aiChatSendFailed.
  ///
  /// In zh_CN, this message translates to:
  /// **'发送失败，请重试'**
  String get aiChatSendFailed;

  /// No description provided for @aiChatLoadingHistory.
  ///
  /// In zh_CN, this message translates to:
  /// **'加载历史消息...'**
  String get aiChatLoadingHistory;

  /// No description provided for @aiChatMessageTime.
  ///
  /// In zh_CN, this message translates to:
  /// **'{time}'**
  String aiChatMessageTime(String time);

  /// No description provided for @aiChatDisclaimer.
  ///
  /// In zh_CN, this message translates to:
  /// **'AI 回复仅供参考，不代表本人意见'**
  String get aiChatDisclaimer;

  /// No description provided for @aiChatThinkingWorkout.
  ///
  /// In zh_CN, this message translates to:
  /// **'分身正在思考你今天的训练…'**
  String get aiChatThinkingWorkout;

  /// No description provided for @aiChatThinkingReply.
  ///
  /// In zh_CN, this message translates to:
  /// **'分身正在组织回复…'**
  String get aiChatThinkingReply;

  /// No description provided for @aiChatThinkingAnalyze.
  ///
  /// In zh_CN, this message translates to:
  /// **'分身正在分析你的状态…'**
  String get aiChatThinkingAnalyze;

  /// No description provided for @aiChatEmptyLearning.
  ///
  /// In zh_CN, this message translates to:
  /// **'分身正在学习你的习惯…'**
  String get aiChatEmptyLearning;

  /// No description provided for @aiChatSmartRecommend.
  ///
  /// In zh_CN, this message translates to:
  /// **'智能推荐'**
  String get aiChatSmartRecommend;

  /// No description provided for @aiAutoReplyActive.
  ///
  /// In zh_CN, this message translates to:
  /// **'AI 分身正在替你回复消息'**
  String get aiAutoReplyActive;

  /// No description provided for @aiAutoReplyBadge.
  ///
  /// In zh_CN, this message translates to:
  /// **'AI 分身代回复'**
  String get aiAutoReplyBadge;

  /// No description provided for @aiAutoReplyConsentRequired.
  ///
  /// In zh_CN, this message translates to:
  /// **'请先完成 AI 数据处理授权'**
  String get aiAutoReplyConsentRequired;

  /// No description provided for @aiAutoReplyStatusOn.
  ///
  /// In zh_CN, this message translates to:
  /// **'自动回复已开启，离线时分身将代你回复'**
  String get aiAutoReplyStatusOn;

  /// No description provided for @aiAutoReplyStatusOff.
  ///
  /// In zh_CN, this message translates to:
  /// **'自动回复已关闭'**
  String get aiAutoReplyStatusOff;

  /// No description provided for @aiProfileUpdate.
  ///
  /// In zh_CN, this message translates to:
  /// **'画像学习'**
  String get aiProfileUpdate;

  /// No description provided for @aiProfileUpdateBtn.
  ///
  /// In zh_CN, this message translates to:
  /// **'更新画像'**
  String get aiProfileUpdateBtn;

  /// No description provided for @aiProfileUpdating.
  ///
  /// In zh_CN, this message translates to:
  /// **'分身正在学习你的习惯…'**
  String get aiProfileUpdating;

  /// No description provided for @aiProfileUpdateSuccess.
  ///
  /// In zh_CN, this message translates to:
  /// **'画像更新完成'**
  String get aiProfileUpdateSuccess;

  /// No description provided for @aiProfileLastUpdated.
  ///
  /// In zh_CN, this message translates to:
  /// **'上次更新'**
  String get aiProfileLastUpdated;

  /// No description provided for @aiProfileNeverUpdated.
  ///
  /// In zh_CN, this message translates to:
  /// **'尚未更新画像'**
  String get aiProfileNeverUpdated;

  /// No description provided for @aiProfileAutoRefresh.
  ///
  /// In zh_CN, this message translates to:
  /// **'对话后自动学习'**
  String get aiProfileAutoRefresh;

  /// No description provided for @aiProfileManualUpdateBtn.
  ///
  /// In zh_CN, this message translates to:
  /// **'更新我的画像'**
  String get aiProfileManualUpdateBtn;

  /// No description provided for @aiProfileUpdateConfirmTitle.
  ///
  /// In zh_CN, this message translates to:
  /// **'更新 AI 分身画像？'**
  String get aiProfileUpdateConfirmTitle;

  /// No description provided for @aiProfileUpdateConfirmDesc.
  ///
  /// In zh_CN, this message translates to:
  /// **'将基于最近对话和训练记录更新分身的性格、习惯和说话风格。数据仅用于回复，不用于其他目的。确定更新吗？'**
  String get aiProfileUpdateConfirmDesc;

  /// No description provided for @aiProfileUpdateConfirmBtn.
  ///
  /// In zh_CN, this message translates to:
  /// **'确认更新'**
  String get aiProfileUpdateConfirmBtn;

  /// No description provided for @aiProfileUpdateFailed.
  ///
  /// In zh_CN, this message translates to:
  /// **'画像更新失败，请重试'**
  String get aiProfileUpdateFailed;

  /// No description provided for @aiProfileUpdateHint.
  ///
  /// In zh_CN, this message translates to:
  /// **'已记录，可在分身详情页更新画像'**
  String get aiProfileUpdateHint;

  /// No description provided for @aiChatCopied.
  ///
  /// In zh_CN, this message translates to:
  /// **'已复制'**
  String get aiChatCopied;

  /// No description provided for @aiChatCopyMessage.
  ///
  /// In zh_CN, this message translates to:
  /// **'复制消息'**
  String get aiChatCopyMessage;

  /// No description provided for @aiChatVoiceComingSoon.
  ///
  /// In zh_CN, this message translates to:
  /// **'语音输入即将上线'**
  String get aiChatVoiceComingSoon;

  /// No description provided for @aiReplyFilteredHint.
  ///
  /// In zh_CN, this message translates to:
  /// **'分身回复被过滤（内容不合适）'**
  String get aiReplyFilteredHint;

  /// No description provided for @aiReplyFilteredSystem.
  ///
  /// In zh_CN, this message translates to:
  /// **'此回复已被内容审核过滤'**
  String get aiReplyFilteredSystem;

  /// No description provided for @aiReplyFilteredNotice.
  ///
  /// In zh_CN, this message translates to:
  /// **'分身回复因安全原因被拦截'**
  String get aiReplyFilteredNotice;

  /// No description provided for @aiReplyFilteredFallback.
  ///
  /// In zh_CN, this message translates to:
  /// **'分身暂时无法回复，请稍后尝试。'**
  String get aiReplyFilteredFallback;

  /// No description provided for @aiContentSafetyTitle.
  ///
  /// In zh_CN, this message translates to:
  /// **'内容安全'**
  String get aiContentSafetyTitle;

  /// No description provided for @aiShareTitle.
  ///
  /// In zh_CN, this message translates to:
  /// **'分享分身'**
  String get aiShareTitle;

  /// No description provided for @aiShareBtn.
  ///
  /// In zh_CN, this message translates to:
  /// **'分享我的分身'**
  String get aiShareBtn;

  /// No description provided for @aiShareSubtitle.
  ///
  /// In zh_CN, this message translates to:
  /// **'将你的 AI 分身分享给好友'**
  String get aiShareSubtitle;

  /// No description provided for @aiShareToFeed.
  ///
  /// In zh_CN, this message translates to:
  /// **'分享到动态'**
  String get aiShareToFeed;

  /// No description provided for @aiShareToFeedDesc.
  ///
  /// In zh_CN, this message translates to:
  /// **'在动态中展示你的分身'**
  String get aiShareToFeedDesc;

  /// No description provided for @aiShareToChallenge.
  ///
  /// In zh_CN, this message translates to:
  /// **'分享到挑战赛'**
  String get aiShareToChallenge;

  /// No description provided for @aiShareToChallengeDesc.
  ///
  /// In zh_CN, this message translates to:
  /// **'在挑战赛中展示你的分身'**
  String get aiShareToChallengeDesc;

  /// No description provided for @aiShareToGroup.
  ///
  /// In zh_CN, this message translates to:
  /// **'分享到群聊'**
  String get aiShareToGroup;

  /// No description provided for @aiShareToGroupDesc.
  ///
  /// In zh_CN, this message translates to:
  /// **'发送你的分身到群聊'**
  String get aiShareToGroupDesc;

  /// No description provided for @aiShareCopyLink.
  ///
  /// In zh_CN, this message translates to:
  /// **'复制分享链接'**
  String get aiShareCopyLink;

  /// No description provided for @aiShareConfirmTitle.
  ///
  /// In zh_CN, this message translates to:
  /// **'分享你的分身？'**
  String get aiShareConfirmTitle;

  /// No description provided for @aiShareConfirmDesc.
  ///
  /// In zh_CN, this message translates to:
  /// **'你的分身公开信息（名称、头像、个性标签、说话风格）将对他人可见。私人数据不会被分享。'**
  String get aiShareConfirmDesc;

  /// No description provided for @aiShareConfirmBtn.
  ///
  /// In zh_CN, this message translates to:
  /// **'确认分享'**
  String get aiShareConfirmBtn;

  /// No description provided for @aiShareSuccess.
  ///
  /// In zh_CN, this message translates to:
  /// **'分身分享成功'**
  String get aiShareSuccess;

  /// No description provided for @aiShareFailed.
  ///
  /// In zh_CN, this message translates to:
  /// **'分享失败，请重试'**
  String get aiShareFailed;

  /// No description provided for @aiShareLimitReached.
  ///
  /// In zh_CN, this message translates to:
  /// **'今日分享次数已达上限（每日最多 5 次）'**
  String get aiShareLimitReached;

  /// No description provided for @aiShareLinkCopied.
  ///
  /// In zh_CN, this message translates to:
  /// **'分享链接已复制'**
  String get aiShareLinkCopied;

  /// No description provided for @aiShareViewTitle.
  ///
  /// In zh_CN, this message translates to:
  /// **'AI 分身'**
  String get aiShareViewTitle;

  /// No description provided for @aiShareNotFound.
  ///
  /// In zh_CN, this message translates to:
  /// **'分身不存在'**
  String get aiShareNotFound;

  /// No description provided for @aiShareNotFoundDesc.
  ///
  /// In zh_CN, this message translates to:
  /// **'该分享链接可能已过期或分身已被删除'**
  String get aiShareNotFoundDesc;

  /// No description provided for @notificationTitle.
  ///
  /// In zh_CN, this message translates to:
  /// **'通知'**
  String get notificationTitle;

  /// No description provided for @notificationMarkAllRead.
  ///
  /// In zh_CN, this message translates to:
  /// **'全部已读'**
  String get notificationMarkAllRead;

  /// No description provided for @notificationEmpty.
  ///
  /// In zh_CN, this message translates to:
  /// **'暂无通知'**
  String get notificationEmpty;

  /// No description provided for @notificationEmptyTip.
  ///
  /// In zh_CN, this message translates to:
  /// **'有人与你互动时，通知会出现在这里'**
  String get notificationEmptyTip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'CN':
            return AppLocalizationsZhCn();
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
