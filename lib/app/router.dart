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
import '../features/workout/presentation/workout_create_page.dart';
import '../features/workout/presentation/workout_detail_page.dart';
import '../features/workout/presentation/workout_list_page.dart';
import '../features/workout/presentation/workout_calendar_page.dart';
import '../features/challenge/presentation/challenges_page.dart';
import '../features/profile/presentation/profile_page.dart';

/// 路由路径常量
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String feed = '/feed';
  static const String discover = '/discover';
  static const String createWorkout = '/create-workout';
  static const String challenges = '/challenges';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String workoutLog = '/workout-log';
  static const String workoutDetail = '/workout-detail';
  static const String workoutHistory = '/workout-history';
  static const String workoutCalendar = '/workout-calendar';
  static const String gymMap = '/gym-map';
  static const String notifications = '/notifications';
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

      // 主框架 — 底部导航栏 Shell
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

          // Tab 2: 发现
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.discover,
                builder: (context, state) => const DiscoverPage(),
              ),
            ],
          ),

          // Tab 3: 记录训练（空壳，点击弹出模态）
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.createWorkout,
                builder: (context, state) => const WorkoutCreatePage(),
              ),
            ],
          ),

          // Tab 4: 挑战
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.challenges,
                builder: (context, state) => const ChallengesPage(),
              ),
            ],
          ),

          // Tab 5: 我的
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
