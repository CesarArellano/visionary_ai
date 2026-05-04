import 'package:go_router/go_router.dart';
import 'package:visionary_ai/features/history/presentation/screens/history_screen.dart';
import 'package:visionary_ai/features/info/presentation/screens/app_information_screen.dart';
import 'package:visionary_ai/features/vision/presentation/screens/home_screen.dart';
import 'package:visionary_ai/features/vision/presentation/screens/splash_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/info',
      builder: (context, state) => const AppInformationScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
  ],
);