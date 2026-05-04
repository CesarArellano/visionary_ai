import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionary_ai/core/injection/injection_container.dart';
import 'package:visionary_ai/core/router/app_router.dart';
import 'package:visionary_ai/core/theme/app_theme.dart';
import 'package:visionary_ai/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  await initDependencies();
  runApp(const ProviderScope(child: VisionaryApp()));
}

class VisionaryApp extends StatelessWidget {
  const VisionaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Visionary AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}