import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hs_coaching_screen/data/providers/content_settings_provider.dart';
import 'package:hs_coaching_screen/data/models/display_content_settings.dart';
import 'package:hs_coaching_screen/features/chrono/presentation/chrono_screen.dart';
import 'package:hs_coaching_screen/features/game/presentation/game_screen.dart';
import 'package:hs_coaching_screen/features/sketch/presentation/sketch_screen.dart';
import 'package:hs_coaching_screen/features/tabata/presentation/tabata_screen.dart';
import 'package:hs_coaching_screen/features/team/team.dart';
import 'package:hs_coaching_screen/features/image/image.dart';
import 'package:hs_coaching_screen/features/text/text.dart';
import 'package:hs_coaching_screen/features/training/presentation/training_screen.dart';
import 'package:hs_coaching_screen/common/widgets/async_content.dart';

/// A widget that only rebuilds when the content settings change.
class ContentSwitcher extends ConsumerWidget {
  const ContentSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Luister naar veranderingen en forceer een update aan het einde van het huidige frame
    ref.listen(contentSettingsProvider, (previous, next) {
      if (next.hasValue) {
        SchedulerBinding.instance.ensureVisualUpdate();
      }
    });
    // Watch the provider that streams dynamic content settings.
    final contentSettings = ref.watch(contentSettingsProvider);

    return AsyncContent(value: contentSettings, data: _buildContent);
  }

  /// Builds the specific content widget based on the contentType.
  ///
  /// `settings/content` only carries `contentType` now — which *item* of that
  /// type is current is resolved by each feature itself from its own
  /// `settings/{feature}.currentId`, so no key needs to be threaded through here.
  Widget _buildContent(DisplayContentSettings content) {
    switch (content.contentType) {
      case DisplayContentType.sketch:
        return const SketchScreen();
      case DisplayContentType.game:
        return const GameScreen();
      case DisplayContentType.image:
        return const ImageDisplay();
      case DisplayContentType.team:
        return const TeamDisplay();
      case DisplayContentType.text:
        return const TextDisplay();
      case DisplayContentType.chrono:
        return const ChronoScreen();
      case DisplayContentType.tabata:
        return const TabataScreen();
      case DisplayContentType.training:
        return const TrainingScreen();
      case DisplayContentType.main:
        return SizedBox.shrink();
    }
  }
}
