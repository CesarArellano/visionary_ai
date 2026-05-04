import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:visionary_ai/core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        context.go('/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.visibility,
              size: 80,
              color: AppTheme.accentColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'Visionary AI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppTheme.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'See the world through AI',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}