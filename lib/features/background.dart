import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_screen/common/widgets/clock.dart';
import 'package:hs_coaching_screen/common/widgets/club_logo.dart';
import 'package:hs_coaching_screen/common/widgets/sync_lost_indicator.dart';
import 'package:hs_coaching_screen/data/providers/global_settings_provider.dart';
import 'package:hs_coaching_screen/common/widgets/async_content.dart';

class Background extends ConsumerWidget {
  const Background({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalSetting = ref.watch(globalSettingsProvider);

    return AsyncContent(
      value: globalSetting,
      showErrorBadge: false, // al getoond door DisplayLimits
      data: (settings) => Stack(
        children: [
          // Clublogo
          Center(child: ClubLogo(maxWidth: 200, showClubName: true)),

          // Clock
          Align(
            alignment: AlignmentGeometry.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
              child: Clock(),
            ),
          ),

          /*
          // Club name
          Align(
            alignment: AlignmentGeometry.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
              child: Text(
                settings.clubName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          */

          // Website
          Align(
            alignment: AlignmentGeometry.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0, bottom: 4.0),
              child: Text(
                settings.clubWebsite,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),

          // Sync-lost indicator (invisible while connected)
          Align(
            alignment: AlignmentGeometry.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0, top: 12.0),
              child: SyncLostIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}
