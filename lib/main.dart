import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hs_coaching_screen/common/theme/app_theme.dart';
import 'package:hs_coaching_screen/features/display_limits.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Holy Squid Coaching screen',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,

      // Restrain the display
      home: const DisplayLimits(),
    );
  }
}
