import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/onboarding_page.dart';
import '../features/auth/providers/auth_provider.dart';
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
    debugLogDiagnostics: true,

    // 路由重定向 — 认证守卫 + 引导流守卫
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoginRoute = state.matchedLocation == AppRoutes.login;
      final isOnboardingRoute = state.matchedLocation == AppRoutes.onboarding;
      final isOnboardingComplete = ref.read(isOnboardingCompleteProvider);

      // 未登录 → 跳转登录页
      if (!isLoggedIn && !isLoginRoute) {
        return AppRoutes.login;
      }

      // 已登录但在登录页 → 检查引导流
      if (isLoggedIn && isLoginRoute) {
        return isOnboardingComplete ? AppRoutes.home : AppRoutes.onboarding;
      }

      // 已登录 + 未完成引导 → 强制跳转引导页
      if (isLoggedIn && !isOnboardingComplete && !isOnboardingRoute) {
        return AppRoutes.onboarding;
      }

      // 已登录 + 已完成引导 + 在引导页 → 跳转首页
      if (isLoggedIn && isOnboardingComplete && isOnboardingRoute) {
        return AppRoutes.home;
      }

      return null;
    },

    routes: [
      // 登录页
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),

      // 注册引导页
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),

      // ==============================
      // 独立页面（不在 BottomNav 内）
      // ==============================

      // 创建训练页（FAB 或模态触发）
      GoRoute(
        path: AppRoutes.createWorkout,
        builder: (context, state) => const WorkoutCreatePage(),
      ),

      // 训练详情页
      GoRoute(
        path: '${AppRoutes.workoutDetail}/:id',
        builder: (context, state) => WorkoutDetailPage(
          workoutId: state.pathParameters['id']!,
        ),
      ),

      // 训练历史列表页
      GoRoute(
        path: AppRoutes.workoutHistory,
        builder: (context, state) => const WorkoutListPage(),
      ),

      // 训练日历页
      GoRoute(
        path: AppRoutes.workoutCalendar,
        builder: (context, state) => const WorkoutCalendarPage(),
      ),

      // 训练馆地图页
      GoRoute(
        path: AppRoutes.gymMap,
        builder: (context, state) => const GymMapPage(),
      ),

      // 训练馆搜索列表页
      GoRoute(
        path: AppRoutes.gymList,
        builder: (context, state) => const GymListPage(),
      ),

      // 训练馆详情页
      GoRoute(
        path: '${AppRoutes.gymDetail}/:id',
        builder: (context, state) => GymDetailPage(
          gymId: state.pathParameters['id']!,
        ),
      ),

      // 提交训练馆页
      GoRoute(
        path: AppRoutes.gymSubmit,
        builder: (context, state) => const GymSubmitPage(),
      ),

      // 写评价页
      GoRoute(
        path: '${AppRoutes.gymReview}/:gymId',
        builder: (context, state) => GymReviewPage(
          gymId: state.pathParameters['gymId']!,
        ),
      ),

      // 挑战赛详情（排行榜）页
      GoRoute(
        path: '${AppRoutes.challengeDetail}/:id',
        builder: (context, state) => ChallengeRankPage(
          challengeId: state.pathParameters['id']!,
        ),
      ),

      // 创建挑战赛页
      GoRoute(
        path: AppRoutes.challengeCreate,
        builder: (context, state) => const ChallengeCreatePage(),
      ),

      // 收藏训练馆列表页
      GoRoute(
        path: AppRoutes.gymFavorites,
        builder: (context, state) => const GymFavoritesPage(),
      ),

      // 发布动态页
      GoRoute(
        path: AppRoutes.postCreate,
        builder: (context, state) => const PostCreatePage(),
      ),

      // 隐私政策页
      GoRoute(
        path: AppRoutes.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyPage(),
      ),

      // 设置页
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),

      // 编辑个人资料页（通过 extra 传递 ProfileModel）
      GoRoute(
        path: AppRoutes.profileEdit,
        builder: (context, state) => ProfileEditPage(
          profile: state.extra! as ProfileModel,
        ),
      ),

      // ==============================
      // 主框架 — 底部导航栏 Shell（5 个 Tab）
      // Tab 1: 动态 (Feed)
      // Tab 2: 训练馆 (Gyms)
      // Tab 3: 挑战 (Challenges)
      // Tab 4: 我的 (Profile)
      // Tab 5: 附近 (Nearby)
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

          // Tab 2: 训练馆（原「发现」→ 改为训练馆列表入口）
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

          // Tab 5: 附近（LBS 伙伴 + 训练馆推荐）
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
