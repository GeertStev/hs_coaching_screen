import 'package:hs_coaching_core/match/engine/match_config.dart';
import 'package:hs_coaching_core/match/engine/match_event.dart';
import 'package:hs_coaching_core/match/engine/match_phase.dart';
import 'package:hs_coaching_core/match/match_meta.dart';
import 'package:hs_coaching_core/match/match_repository.dart';
import 'package:hs_coaching_core/team/team_model.dart';

/// Demowedstrijden om het scorebord te bekijken zonder zwembad en zonder
/// Firebase: de url `?match=demo` (of een van de andere ids hieronder) toont
/// een wedstrijd die "nu" bezig is. Niets hiervan komt uit of gaat naar
/// Firestore.
enum DemoMatch {
  /// Periode 2 loopt, met straffen aan beide kanten.
  play('demo'),

  /// Team time-out van wit.
  timeOut('demo-timeout'),

  /// Rust.
  halfTime('demo-halftime'),

  /// Stilgezette klok in de laatste twee minuten, vier straffen bij zwart.
  stopped('demo-stopped'),

  /// Afgelopen wedstrijd.
  finished('demo-final');

  const DemoMatch(this.id);

  final String id;

  static DemoMatch? byId(String id) {
    for (final demo in values) {
      if (demo.id == id) return demo;
    }
    return null;
  }
}

/// Veld-id waarop de demowedstrijd [DemoMatch.play] "live" is.
const demoFieldId = 'demo';

/// Het event log van [demo], zo gedateerd dat het laatste event
/// [sinceLastEvent] vóór [nowServerMs] viel.
List<MatchEvent> demoMatchEvents(
  DemoMatch demo, {
  required int nowServerMs,
  Duration sinceLastEvent = const Duration(seconds: 7),
}) {
  final script = _DemoScript(demo.id);
  const white = TeamColor.white;
  const black = TeamColor.black;

  void firstPeriod() {
    script
      ..add(const MatchEventData.playStarted())
      ..wait(const Duration(minutes: 4, seconds: 10))
      ..add(const MatchEventData.goalScored(team: white, scorerCap: 7))
      ..wait(const Duration(seconds: 20))
      ..add(const MatchEventData.playStarted())
      ..wait(const Duration(minutes: 6))
      ..add(const MatchEventData.goalScored(team: black, scorerCap: 3))
      ..wait(const Duration(seconds: 15))
      ..add(const MatchEventData.playStarted())
      ..wait(const Duration(minutes: 4, seconds: 15))
      ..add(const MatchEventData.periodEnded(phase: MatchPhase.p1));
  }

  void penalty(TeamColor team, int cap, int minutes) {
    script.add(
      MatchEventData.timePenaltyGiven(
        team: team,
        cap: cap,
        minutes: minutes,
        infringementCode: 'demo',
      ),
    );
  }

  void stopAndRestart(void Function() during) {
    script.add(const MatchEventData.playStopped());
    during();
    script
      ..wait(const Duration(seconds: 10))
      ..add(
        const MatchEventData.playStarted(restartType: RestartType.equalPuck),
      );
  }

  firstPeriod();
  switch (demo) {
    case DemoMatch.halfTime:
      script.wait(const Duration(seconds: 50));
    case DemoMatch.play:
      script
        ..wait(const Duration(minutes: 3))
        ..add(const MatchEventData.playStarted())
        ..wait(const Duration(minutes: 3))
        ..add(const MatchEventData.goalScored(team: white, scorerCap: 4))
        ..wait(const Duration(seconds: 20))
        ..add(const MatchEventData.playStarted())
        ..wait(const Duration(minutes: 2));
      stopAndRestart(() => penalty(white, 9, 2));
      script.wait(const Duration(seconds: 50));
      stopAndRestart(() => penalty(black, 12, 1));
      script.wait(const Duration(seconds: 20));
    case DemoMatch.timeOut:
      script
        ..wait(const Duration(minutes: 3))
        ..add(const MatchEventData.playStarted())
        ..wait(const Duration(minutes: 5));
      stopAndRestart(() => penalty(black, 5, 2));
      script
        ..wait(const Duration(seconds: 40))
        ..add(const MatchEventData.playStopped())
        ..add(const MatchEventData.teamTimeOutRequested(team: white))
        ..wait(const Duration(seconds: 15));
    case DemoMatch.stopped:
      script
        ..wait(const Duration(minutes: 3))
        ..add(const MatchEventData.playStarted())
        ..wait(const Duration(minutes: 11, seconds: 40));
      stopAndRestart(() {
        penalty(black, 2, 2);
        penalty(black, 6, 2);
      });
      script.wait(const Duration(seconds: 50));
      stopAndRestart(() {
        penalty(black, 8, 5);
        penalty(black, 11, 1);
        penalty(white, 1, 1);
      });
      script
        ..wait(const Duration(seconds: 40))
        ..add(const MatchEventData.playStopped());
    case DemoMatch.finished:
      script
        ..wait(const Duration(minutes: 3))
        ..add(const MatchEventData.playStarted())
        ..wait(const Duration(minutes: 9))
        ..add(const MatchEventData.goalScored(team: black, scorerCap: 10))
        ..wait(const Duration(seconds: 20))
        ..add(const MatchEventData.playStarted())
        ..wait(const Duration(minutes: 6))
        ..add(const MatchEventData.periodEnded(phase: MatchPhase.p2));
  }
  return script.eventsEndingAt(nowServerMs - sinceLastEvent.inMilliseconds);
}

/// Schrijft events met een relatieve klok en dateert ze achteraf.
class _DemoScript {
  _DemoScript(this.matchId) {
    add(
      const MatchEventData.matchCreated(
        config: MatchConfig(presetName: 'Demo'),
        teamWhite: 'Holy Squid',
        teamBlack: 'Orcas',
      ),
    );
  }

  final String matchId;
  final List<({int offsetMillis, MatchEventData data})> _entries = [];
  int _offsetMillis = 0;

  void add(MatchEventData data) =>
      _entries.add((offsetMillis: _offsetMillis, data: data));

  void wait(Duration duration) => _offsetMillis += duration.inMilliseconds;

  List<MatchEvent> eventsEndingAt(int lastEventMillis) {
    final start = lastEventMillis - _offsetMillis;
    return [
      for (final (index, entry) in _entries.indexed)
        MatchEvent(
          id: '$matchId-${index + 1}',
          matchId: matchId,
          seq: index + 1,
          serverTimeMillis: start + entry.offsetMillis,
          deviceId: 'demo',
          data: entry.data,
        ),
    ];
  }
}

/// Zet de demowedstrijden vóór een echte [MatchRepository]: een demo-id komt
/// uit het geheugen, al de rest gaat naar [inner].
class DemoMatchRepository implements MatchRepository {
  DemoMatchRepository({required this.inner, required this.nowServerMs});

  final MatchRepository inner;
  final int Function() nowServerMs;

  @override
  Stream<List<MatchEvent>> watchEvents(String matchId) {
    final demo = DemoMatch.byId(matchId);
    if (demo == null) return inner.watchEvents(matchId);
    return Stream.value(demoMatchEvents(demo, nowServerMs: nowServerMs()));
  }

  @override
  Stream<MatchMeta?> watchMeta(String matchId) {
    if (DemoMatch.byId(matchId) == null) return inner.watchMeta(matchId);
    return Stream.value(
      MatchMeta(createdAtMillis: nowServerMs(), liveFieldId: demoFieldId),
    );
  }

  @override
  Stream<String?> watchLiveMatchId(String fieldId) {
    if (fieldId != demoFieldId) return inner.watchLiveMatchId(fieldId);
    return Stream.value(DemoMatch.play.id);
  }
}
