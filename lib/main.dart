import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/core/errors/error_reporting.dart';
import 'package:hs_coaching_core/core/providers/riverpod_config.dart';

import 'package:hs_coaching_screen/common/theme/app_theme.dart';
import 'package:hs_coaching_screen/features/display_limits.dart';
import 'package:hs_coaching_screen/features/match/presentation/scoreboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  installGlobalErrorHandlers();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    const ProviderScope(
      retry: appProviderRetry,
      observers: [AppProviderObserver()],
      child: MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Een url met ?match=<id> of ?field=<id> opent het wedstrijdscorebord.
    final scoreboard = ScoreboardRoute.fromUri(Uri.base);
    return MaterialApp(
      title: 'Holy Squid Coaching screen',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,

      // Restrain the display
      home: scoreboard != null
          ? ScoreboardPage(route: scoreboard)
          : const DisplayLimits(),
    );
  }
}
