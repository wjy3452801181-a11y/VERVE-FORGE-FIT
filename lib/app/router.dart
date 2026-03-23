import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'mosaic_page.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/onboarding_page.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/buddy/presentation/buddy_list_page.dart';
import '../features/buddy/presentation/buddy_requests_page.dart';
import '../features/chat/presentation/chat_page.dart';
import '../features/chat/presentation/conversations_page.dart';
import '../features/profile/providers/profile_provider.dart';
import '../shared/widgets/app_scaffold.dart';
import '../features/post/presentation/feed_page.dart';
import '../features/buddy/presentation/discover_page.dart';
import '../features/buddy/presentation/nearby_page.dart';
import '../features/workout/presentation/workout_create_page.dart';
import '../features/workout/presentation/workout_detail_page.dart';
import '../features/workout/presentation/workout_list_page.dart';
import '../features/workout/presentation/workout_calendar_page.dart';
import '../features/challenge/presentation/challenges_page.dart';
import '../features/challenge/presentation/challenge_create_page.dart';
import '../features/challenge/presentation/challenge_rank_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/profile/presentation/profile_edit_page.dart';
import '../features/profile/presentation/settings_page.dart';
import '../features/profile/domain/profile_model.dart';
import '../features/gym/presentation/gym_map_page.dart';
import '../features/gym/presentation/gym_list_page.dart';
import '../features/gym/presentation/gym_detail_page.dart';
import '../features/gym/presentation/gym_submit_page.dart';
import '../features/gym/presentation/gym_review_page.dart';
import '../features/gym/presentation/gym_favorites_page.dart';
import '../features/post/presentation/post_create_page.dart';
import '../features/profile/presentation/privacy_policy_page.dart';
import '../features/ai_avatar/presentation/ai_avatar_create_page.dart';
import '../features/ai_avatar/presentation/ai_avatar_detail_page.dart';
import '../features/ai_avatar/presentation/ai_avatar_chat_page.dart';
import '../features/ai_avatar/presentation/ai_avatar_shared_view.dart';
import '../features/notification/presentation/notifications_page.dart';

/// 路由路径常量
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String onboarding = '/onboarding';
  static const String home = '/';

  // 底部导航 Tab 路径
  static const String feed = '/feed';
  static const String gyms = '/gyms';
  static const String challenges = '/challenges';
  static const String profile = '/profile';
  static const String nearby = '/nearby';

  // 独立页面路径
  static const String settings = '/settings';
  static const String createWorkout = '/create-workout';
  static const String workoutLog = '/workout-log';
  static const String workoutDetail = '/workout-detail';
  static const String workoutHistory = '/workout-history';
  static const String workoutCalendar = '/workout-calendar';
  static const String gymMap = '/gym-map';
  static const String gymList = '/gym-list';
  static const String gymDetail = '/gym-detail';
  static const String gymSubmit = '/gym-submit';
  static const String gymReview = '/gym-review';
  static const String gymFavorites = '/gym-favorites';
  static const String challengeDetail = '/challenge-detail';
  static const String challengeCreate = '/challenge-create';
  static const String postCreate = '/post-create';
  static const String profileEdit = '/profile-edit';
  static const String privacyPolicy = '/privacy-policy';
  static const String notifications = '/notifications';
  static const String buddyList = '/buddy-list';
  static const String buddyRequests = '/buddy-requests';
  static const String conversations = '/conversations';
  static const String chat = '/chat';

  // AI 分身页面
  static const String aiAvatar = '/ai-avatar';
  static const String aiAvatarCreate = '/ai-avatar-create';
  static const String aiAvatarChat = '/ai-avatar-chat';
  static const String aiAvatarShared = '/ai-avatar-shared';

  // 旧路由兼容（Discover → Gyms）
  static const String discover = '/discover';
}

/// 底部导航栏路由分支
final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// 路由 Provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: kDebugMode,

    // 路由重定向 — 认证守卫 + 引导流守卫
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoginRoute = state.matchedLocation == AppRoutes.login;
      final isOnboardingRoute = state.matchedLocation == AppRoutes.onboarding;
      // null = profile 仍在加载，此时不跳转，等待下一次 rebuild
      final isOnboardingComplete = ref.read(isOnboardingCompleteProvider);

      // 未登录 → 跳转登录页
      if (!isLoggedIn && !isLoginRoute) {
        return AppRoutes.login;
      }

      // 已登录但在登录页 → 检查引导流（仍在加载则等待）
      if (isLoggedIn && isLoginRoute) {
        if (isOnboardingComplete == null) return null;
        return isOnboardingComplete ? AppRoutes.home : AppRoutes.onboarding;
      }

      // 已登录 + 未完成引导 → 强制跳转引导页（加载中不跳）
      if (isLoggedIn && isOnboardingComplete == false && !isOnboardingRoute) {
        return AppRoutes.onboarding;
      }

      // 已登录 + 已完成引导 + 在引导页 → 跳转首页
      if (isLoggedIn && isOnboardingComplete == true && isOnboardingRoute) {
        return AppRoutes.home;
      }

      return null;
    },

    routes: [
      // 登录页（不使用马赛克过渡）
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),

      // 注册引导页（不使用马赛克过渡）
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),

      // ==============================
      // 独立页面（使用马赛克过渡）
      // ==============================

      // 创建训练页
      GoRoute(
        path: AppRoutes.createWorkout,
        pageBuilder: (context, state) => MosaicPage(
          key: state.pageKey,
          child: const WorkoutCreatePage(),
        ),
      ),

      // 训练详情页
      GoRoute(
        path: '${AppRoutes.workoutDetail}/:id',
        pageBuilder: (context, state) => MosaicPage(
          key: state.pageKey,
          child: WorkoutDetailPage(
            workoutId: state.pathParameters['id']!,
          ),
        ),
      ),

      // 训练历史列表页
      GoRoute(
        path: AppRoutes.workoutHistory,
        pageBuilder: (context, state) => MosaicPage(
          key: state.pageKey,
          child: const WorkoutListPage(),
        ),
      ),

      // 训练日历页
      GoRoute(
        path: AppRoutes.workoutCalendar,
        pageBuilder: (context, state) => MosaicPage(
          key: state.pageKey,
          child: const WorkoutCalendarPage(),
        ),
      ),

      // 训练馆地图页
      GoRoute(
        path: AppRoutes.gymMap,
        pageBuilder: (context, state) => MosaicPage(
          key: state.pageKey,
          child: const GymMapPage(),
        ),
      ),

      // 训练馆搜索列表页
      GoRoute(
        path: AppRoutes.gymList,
        pageBuilder: (context, state) => MosaicPage(
          key: state.pageKey,
          child: const GymListPage(),
        ),
      ),

      // 训练馆详情页
      GoRoute(
        path: '${AppRoutes.gymDetail}/:id',
        pageBuilder: (context, state) => MosaicPage(
          key: state.pageKey,
          child: GymDetailPage(
            gymId: state.pathParameters['id']!,
          ),
        ),
      ),

      // 提交训练馆页
      GoRoute(
        path: AppRoutes.gymSubmit,
        pageBuilder: (context, state) => MosaicPage(
          key: state.pageKey,
          child: const GymSubmitPage(),
        ),
      ),

      // 写评价页
      GoRoute(
        path: '${AppRoutes.gymReview}/:gymId',
        pageBuilder: (context, state) => MosaicPage(
          key: state.pageKey,
          child: GymReviewPage(
            gymId: state.pathParameters['gymId']!,
          ),
        ),
      ),

      // 挑战赛详情（排行榜）页
      GoRoute(
        path: '${AppRoutes.challengeDetail}/:id',
        pageBuilder: (context, state) => MosaicPage(
          key: state.pageKey,
          child: ChallengeRankPage(
            challengeId: state.pathParameters['id']!,
          ),
        ),
      ),

      // 创建挑战赛页
      GoRoute(
        path: AppRoutes.challengeCreate,
        pageBuilder: (context, state) => MosaicPage(
          key: state.pageKey,
          child: const ChallengeCreatePage(),
        ),
      ),

      // 收藏训练馆列表页
      GoRoute(
        path: AppRoutes.gymFavorites,
        pageBuilder: (context, state) => MosaicPage(
          key: state.pageKey,
          child: const GymFavoritesPage(),
        ),
      ),

      // 好友列表页
      GoRoute(
        path: AppRoutes.buddyList,
        pageBuilder: (context, state) => MosaicPage(
          key: state.pageKey,
          child: const BuddyListPage(),
        ),
      ),

      // 好友请求页
      GoRoute(
        path: AppRoutes.buddyRequests,
        pageBuilder: (context, state) => MosaicPage(
          key: state.pageKey,
          child: const BuddyRequestsPage(),
        ),
      ),

      // 私信会话列表页
      GoRoute(
        path: AppRoutes.conversations,
        pageBuilder: (context, state) => MosaicPage(
          key: state.pageKey,
          child: const ConversationsPage(),
        ),
      ),

      // 聊天页
      GoRoute(
        path: '${AppRoutes.chat}/:userId',
        pageBuilder: (context, state) => MosaicPage(
          key: state.pageKey,
          child: ChatPage(
            otherUserId: state.pathParameters['userId']!,
            otherNickname: state.extra as String?,
          ),
        ),
      ),

      // 发布动态页
      GoRoute(
        path: AppRoutes.postCreate,
        pageBuilder: (context, state) => MosaicPage(
          key: state.pageKey,
          child: const PostCreatePage(),
        ),
      ),

      // 隐私政策页
      GoRoute(
        path: AppRoutes.privacyPolicy,
        pageBuilder: (context, state) => MosaicPage(
          key: state.pageKey,
          child: const PrivacyPolicyPage(),
        ),
      ),

      // 设置页
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (context, state) => MosaicPage(
          key: state.pageKey,
          child: const SettingsPage(),
        ),
      ),

      // 通知页
      GoRoute(
        path: AppRoutes.notifications,
        pageBuilder: (context, state) => MosaicPage(
          key: state.pageKey,
          child: const NotificationsPage(),
        ),
      ),

      // AI 分身详情页
      GoRoute(
        path: AppRoutes.aiAvatar,
        pageBuilder: (context, state) => MosaicPage(
          key: state.pageKey,
          child: const AiAvatarDetailPage(),
        ),
      ),

      // AI 分身创建页
      GoRoute(
        path: AppRoutes.aiAvatarCreate,
        pageBuilder: (context, state) => MosaicPage(
          key: state.pageKey,
          child: const AiAvatarCreatePage(),
        ),
      ),

      // AI 分身聊天页（支持 avatarId 路径参数）
      GoRoute(
        path: '${AppRoutes.aiAvatarChat}/:avatarId',
        pageBuilder: (context, state) => MosaicPage(
          key: state.pageKey,
          child: AiAvatarChatPage(
            avatarId: state.pathParameters['avatarId'],
          ),
        ),
      ),

      // AI 分身聊天页（无参数兜底，使用当前分身）
      GoRoute(
        path: AppRoutes.aiAvatarChat,
        pageBuilder: (context, state) => MosaicPage(
          key: state.pageKey,
          child: const AiAvatarChatPage(),
        ),
      ),

      // AI 分身分享展示页（公开链接）
      GoRoute(
        path: '${AppRoutes.aiAvatarShared}/:shareToken',
        pageBuilder: (context, state) => MosaicPage(
          key: state.pageKey,
          child: AiAvatarSharedView(
            shareToken: state.pathParameters['shareToken']!,
          ),
        ),
      ),

      // 编辑个人资料页（通过 extra 传递 ProfileModel）
      GoRoute(
        path: AppRoutes.profileEdit,
        pageBuilder: (context, state) => MosaicPage(
          key: state.pageKey,
          child: ProfileEditPage(
            profile: state.extra! as ProfileModel,
          ),
        ),
      ),

      // ==============================
      // 主框架 — 底部导航栏 Shell（5 个 Tab）
      // Tab 切换不使用马赛克过渡
      // ==============================
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Tab 1: 动态
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.feed,
                builder: (context, state) => const FeedPage(),
              ),
            ],
          ),

          // Tab 2: 训练馆
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.gyms,
                builder: (context, state) => const DiscoverPage(),
              ),
            ],
          ),

          // Tab 3: 挑战
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.challenges,
                builder: (context, state) => const ChallengesPage(),
              ),
            ],
          ),

          // Tab 4: 我的
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),

          // Tab 5: 附近
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.nearby,
                builder: (context, state) => const NearbyPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
