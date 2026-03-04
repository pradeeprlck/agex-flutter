import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/diagnosis/presentation/new_diagnosis_screen.dart';
import '../../features/diagnosis/presentation/diagnosis_result_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/community/presentation/community_screen.dart';
import '../../features/community/presentation/ask_question_screen.dart';
import '../../features/community/presentation/question_detail_screen.dart';
import '../../features/mandi/presentation/mandi_prices_screen.dart';
import '../../features/soil_test/presentation/new_soil_test_screen.dart';
import '../../features/soil_test/presentation/soil_test_list_screen.dart';
import '../../features/soil_test/presentation/soil_test_result_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/farm_profile/presentation/farm_profile_screen.dart';
import '../../features/crop_calendar/presentation/crop_calendar_list_screen.dart';
import '../../features/crop_calendar/presentation/crop_calendar_screen.dart';
import '../../features/crop_calendar/presentation/create_calendar_screen.dart';
import '../theme/app_colors.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final loggedIn = auth.isAuthenticated;
      final loggingIn = state.matchedLocation == '/login';

      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/dashboard';
      return null;
    },
    routes: [
      // ── Login ──
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // ── Shell with bottom nav ──
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => _NavShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: '/diagnose',
            pageBuilder: (context, state) => const NoTransitionPage(child: NewDiagnosisScreen()),
          ),
          GoRoute(
            path: '/history',
            pageBuilder: (context, state) => const NoTransitionPage(child: HistoryScreen()),
          ),
          GoRoute(
            path: '/community',
            pageBuilder: (context, state) => const NoTransitionPage(child: CommunityScreen()),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(child: SettingsScreen()),
          ),
        ],
      ),

      // ── Detail / push routes ──
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/diagnosis-result/:id',
        builder: (context, state) => DiagnosisResultScreen(diagnosisId: state.pathParameters['id']!),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/soil-tests',
        builder: (context, state) => const SoilTestListScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/new-soil-test',
        builder: (context, state) => const NewSoilTestScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/soil-test-result/:id',
        builder: (context, state) => SoilTestResultScreen(testId: state.pathParameters['id']!),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/mandi-prices',
        builder: (context, state) => const MandiPricesScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/crop-calendars',
        builder: (context, state) => const CropCalendarListScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/crop-calendar/:id',
        builder: (context, state) => CropCalendarScreen(calendarId: state.pathParameters['id']!),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/create-calendar',
        builder: (context, state) => const CreateCalendarScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/ask-question',
        builder: (context, state) => const AskQuestionScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/question/:id',
        builder: (context, state) => QuestionDetailScreen(questionId: state.pathParameters['id']!),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/farm-profile',
        builder: (context, state) => const FarmProfileScreen(),
      ),
    ],
  );
});

// ── Bottom navigation shell ──
class _NavShell extends StatelessWidget {
  final Widget child;
  const _NavShell({required this.child});

  static const _tabs = [
    '/dashboard',
    '/diagnose',
    '/history',
    '/community',
    '/settings',
  ];

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final idx = _tabs.indexOf(loc);
    return idx >= 0 ? idx : 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -2))],
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => context.go(_tabs[i]),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppColors.brand50,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 64,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, size: 22),
              selectedIcon: Icon(Icons.home_rounded, size: 22, color: AppColors.brand600),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.camera_alt_outlined, size: 22),
              selectedIcon: Icon(Icons.camera_alt_rounded, size: 22, color: AppColors.brand600),
              label: 'Diagnose',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_rounded, size: 22),
              selectedIcon: Icon(Icons.history_rounded, size: 22, color: AppColors.brand600),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.forum_outlined, size: 22),
              selectedIcon: Icon(Icons.forum_rounded, size: 22, color: AppColors.brand600),
              label: 'Community',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, size: 22),
              selectedIcon: Icon(Icons.settings_rounded, size: 22, color: AppColors.brand600),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
