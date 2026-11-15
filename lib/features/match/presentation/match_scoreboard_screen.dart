import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/match/engine/clock_view.dart';
import 'package:hs_coaching_core/match/engine/match_state.dart';
import 'package:hs_coaching_screen/common/widgets/async_content.dart';
import 'package:hs_coaching_screen/features/match/data/match_repository.dart';
import 'package:hs_coaching_screen/features/match/presentation/scoreboard_model.dart';
import 'package:hs_coaching_screen/features/match/presentation/scoreboard_view.dart';

/// Layout `matchScoreboard(matchId)`: één wedstrijd in detail, alleen lezen
/// (03-wedstrijdtafel-ui.md §4.1). Vult de ruimte die het krijgt.
class MatchScoreboardScreen extends ConsumerWidget {
  const MatchScoreboardScreen({super.key, required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncContent(
      value: ref.watch(matchStateProvider(matchId)),
      data: (state) => ScaledScoreboard(
        builder: (_) => state.created
            ? LiveScoreboard(state: state)
            : const ScoreboardMessage(title: 'Waiting for the match'),
      ),
    );
  }
}

/// Layout `fieldScoreboard(fieldId)`: volgt vanzelf de wedstrijd die live is
/// op het veld. Is er geen meer live, dan blijft de laatste wedstrijd (met
/// haar eindstand) staan tot de volgende begint.
class FieldScoreboardScreen extends ConsumerStatefulWidget {
  const FieldScoreboardScreen({super.key, required this.fieldId});

  final String fieldId;

  @override
  ConsumerState<FieldScoreboardScreen> createState() =>
      _FieldScoreboardScreenState();
}

class _FieldScoreboardScreenState extends ConsumerState<FieldScoreboardScreen> {
  String? _lastMatchId;

  @override
  void didUpdateWidget(FieldScoreboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fieldId != widget.fieldId) _lastMatchId = null;
  }

  @override
  Widget build(BuildContext context) {
    return AsyncContent(
      value: ref.watch(liveMatchIdProvider(widget.fieldId)),
      data: (liveMatchId) {
        final matchId = _lastMatchId = liveMatchId ?? _lastMatchId;
        if (matchId == null) {
          return ScaledScoreboard(
            builder: (_) =>
                const ScoreboardMessage(title: 'Waiting for the next match'),
          );
        }
        return MatchScoreboardScreen(key: ValueKey(matchId), matchId: matchId);
      },
    );
  }
}

/// Hertekent het scorebord met een [Ticker]. De tijd wordt bij elke tik
/// opnieuw **berekend** met core's `clockViewAt` (events + server-tijd) en
/// nooit zelf bijgehouden; er wordt alleen hertekend als het beeld verandert.
class LiveScoreboard extends ConsumerStatefulWidget {
  const LiveScoreboard({super.key, required this.state});

  final MatchState state;

  @override
  ConsumerState<LiveScoreboard> createState() => _LiveScoreboardState();
}

class _LiveScoreboardState extends ConsumerState<LiveScoreboard>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  ScoreboardModel? _model;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      final next = _compute();
      if (next != _model) setState(() => _model = next);
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  ScoreboardModel _compute() {
    final now = ref.read(matchNowProvider)();
    return ScoreboardModel.from(clockViewAt(widget.state, now));
  }

  @override
  Widget build(BuildContext context) {
    // Luistert naar de server-tijd, zodat de offset binnenkomt en bijblijft.
    ref.watch(matchNowProvider);
    return ScoreboardView(model: _model = _compute());
  }
}
