import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_screen/common/widgets/async_content.dart';
import 'package:hs_coaching_screen/common/widgets/sync_lost_indicator.dart';
import 'package:hs_coaching_screen/data/providers/global_settings_provider.dart';
import 'package:hs_coaching_screen/features/match/presentation/match_scoreboard_screen.dart';
import 'package:hs_coaching_screen/features/match/presentation/scoreboard_theme.dart';

/// Welk scorebord de url vraagt. De app (of de kiosk) opent het scherm met
/// `?match=<matchId>` of `?field=<fieldId>`; zonder een van beide start het
/// gewone zwembadscherm.
///
/// Met `&display=1` blijft het scorebord binnen de schermmaat uit de
/// instellingen van het zwembaddisplay (linksboven, zoals het gewone scherm);
/// anders vult het het hele browservenster.
@immutable
class ScoreboardRoute {
  const ScoreboardRoute.match(String this.matchId, {this.fitDisplay = false})
    : fieldId = null;
  const ScoreboardRoute.field(String this.fieldId, {this.fitDisplay = false})
    : matchId = null;

  final String? matchId;
  final String? fieldId;
  final bool fitDisplay;

  /// `null` als [uri] geen scorebord vraagt.
  static ScoreboardRoute? fromUri(Uri uri) {
    final query = uri.queryParameters;
    final fitDisplay = query['display'] == '1';
    final matchId = query['match']?.trim() ?? '';
    if (matchId.isNotEmpty) {
      return ScoreboardRoute.match(matchId, fitDisplay: fitDisplay);
    }
    final fieldId = query['field']?.trim() ?? '';
    if (fieldId.isNotEmpty) {
      return ScoreboardRoute.field(fieldId, fitDisplay: fitDisplay);
    }
    return null;
  }
}

/// Het scorebord als volledige pagina, zonder de achtergrond en het
/// content-vak van het gewone zwembadscherm.
class ScoreboardPage extends ConsumerWidget {
  const ScoreboardPage({super.key, required this.route});

  final ScoreboardRoute route;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchId = route.matchId;
    final fieldId = route.fieldId;
    final Widget board = Stack(
      children: [
        Positioned.fill(
          child: matchId != null
              ? MatchScoreboardScreen(matchId: matchId)
              : FieldScoreboardScreen(fieldId: fieldId!),
        ),
        const Positioned(right: 16, bottom: 16, child: SyncLostIndicator()),
      ],
    );

    return Scaffold(
      backgroundColor: ScoreboardTheme.of(context).background,
      body: !route.fitDisplay
          ? board
          : AsyncContent(
              value: ref.watch(globalSettingsProvider),
              data: (settings) => Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: settings.screenWidth.toDouble(),
                  height: settings.screenHeight.toDouble(),
                  child: board,
                ),
              ),
            ),
    );
  }
}
