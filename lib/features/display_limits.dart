import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hs_coaching_screen/data/providers/global_settings_provider.dart';

import 'package:hs_coaching_screen/features/main_screen.dart';

class DisplayLimits extends ConsumerWidget {
  const DisplayLimits({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalSettings = ref.watch(globalSettingsProvider);

    return Scaffold(
      body: globalSettings.when(
        data: (settings) {
          double screenWidth = settings.screenWidth.toDouble();
          double screenHeight = settings.screenHeight.toDouble();
          double contentWidth = settings.contentWidth.toDouble();
          double contentHeight = settings.contentHeight.toDouble();

          return Container(
            color: settings.backgroundColor,
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                ),
                width: screenWidth,
                height: screenHeight,
                child: MainScreen(
                  contentWidth: contentWidth,
                  contentHeight: contentHeight,
                ),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            'Error loading global settings: $error',
            style: const TextStyle(color: Colors.red, fontSize: 24),
          ),
        ),
      ),
    );
  }
}
