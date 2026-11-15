import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_core/match/engine/clock_view.dart';
import 'package:hs_coaching_core/match/engine/match_config.dart';
import 'package:hs_coaching_core/match/engine/match_event.dart';
import 'package:hs_coaching_core/match/engine/match_reducer.dart';
import 'package:hs_coaching_core/team/team_model.dart';
import 'package:hs_coaching_screen/features/match/data/demo_match.dart';
import 'package:hs_coaching_screen/features/match/presentation/scoreboard_model.dart';
import 'package:hs_coaching_screen/features/match/presentation/scoreboard_page.dart';

const _now = 1800000000000;

ScoreboardModel _modelOf(DemoMatch demo, {Duration later = Duration.zero}) {
  final state = reduceMatch(demoMatchEvents(demo, nowServerMs: _now));
  return ScoreboardModel.from(clockViewAt(state, _now + later.inMilliseconds));
}

/// Een wedstrijd met alleen `MatchCreated` en wat [events] toevoegt, elk
/// event één seconde na het vorige.
ScoreboardModel _modelAfter(List<MatchEventData> events, {int waitMs = 0}) {
  final all = [
    const MatchEventData.matchCreated(
      config: MatchConfig(),
      teamWhite: 'Wit',
      teamBlack: 'Zwart',
    ),
    ...events,
  ];
  final log = [
    for (final (index, data) in all.indexed)
      MatchEvent(
        id: 'e${index + 1}',
        matchId: 'm',
        seq: index + 1,
        serverTimeMillis: _now + index * 1000,
        data: data,
      ),
  ];
  final state = reduceMatch(log);
  expect(state.rejectedEvents, isEmpty);
  return ScoreboardModel.from(
    clockViewAt(state, log.last.serverTimeMillis + waitMs),
  );
}

void main() {
  group('formatScoreboardClock', () {
    test('rondt een aftelling naar boven af', () {
      expect(formatScoreboardClock(const Duration(minutes: 15)), '15:00');
      expect(
        formatScoreboardClock(const Duration(milliseconds: 59001)),
        '1:00',
      );
      expect(formatScoreboardClock(const Duration(milliseconds: 1)), '0:01');
      expect(formatScoreboardClock(Duration.zero), '0:00');
      expect(formatScoreboardClock(const Duration(seconds: -3)), '0:00');
    });

    test('rondt een optellende klok naar beneden af', () {
      expect(
        formatScoreboardClock(
          const Duration(milliseconds: 61999),
          countingDown: false,
        ),
        '1:01',
      );
    });
  });

  group('ScoreboardModel', () {
    test('vóór de start: wit links, de klok toont de periodeduur', () {
      final model = _modelAfter(const []);

      expect(model.phaseLabel, 'NOT STARTED');
      expect(model.clockMode, ScoreboardClockMode.idle);
      expect(model.clockText, '15:00');
      expect(model.left.color, TeamColor.white);
      expect(model.left.name, 'Wit');
      expect(model.right.name, 'Zwart');
      expect(model.statusLabel, isNull);
    });

    test('periode 1: de klok telt af en loopt', () {
      final model = _modelAfter(const [
        MatchEventData.playStarted(),
      ], waitMs: 61500);

      expect(model.phaseLabel, 'PERIOD 1');
      expect(model.clockMode, ScoreboardClockMode.running);
      expect(model.clockText, '13:59');
    });

    test('14.2.2: na de rust staan de teams aan de andere kant', () {
      final model = _modelOf(DemoMatch.play);

      expect(model.phaseLabel, 'PERIOD 2');
      expect(model.left.color, TeamColor.black);
      expect(model.left.name, 'Orcas');
      expect(model.left.score, 1);
      expect(model.right.color, TeamColor.white);
      expect(model.right.score, 2);
    });

    test('strafklokken per team met kap en resterende tijd', () {
      final model = _modelOf(DemoMatch.play);

      expect(model.right.penalties.single.cap, 9);
      expect(model.left.penalties.single.cap, 12);
      expect(model.left.penalties.single.text, '0:33');
      expect(model.left.hiddenPenalties, 0);
    });

    test('14.2.6: een team time-out vervangt de klok door haar aftelling', () {
      final model = _modelOf(DemoMatch.timeOut);

      expect(model.clockMode, ScoreboardClockMode.timeOut);
      expect(model.clockText, '0:38');
      expect(model.statusLabel, 'TIME-OUT WHITE');
    });

    test('de aftelling van een time-out blijft op 0:00 staan', () {
      final model = _modelOf(
        DemoMatch.timeOut,
        later: const Duration(minutes: 5),
      );

      expect(model.clockMode, ScoreboardClockMode.timeOut);
      expect(model.clockText, '0:00');
    });

    test('rust: aftelling van de pauze', () {
      final model = _modelOf(DemoMatch.halfTime);

      expect(model.phaseLabel, 'HALF-TIME');
      expect(model.clockMode, ScoreboardClockMode.breakTime);
      expect(model.clockText, '2:03');
    });

    test('hooguit 3 strafklokken per team, daarna "+n"', () {
      final model = _modelOf(DemoMatch.stopped);
      final black = model.left;

      expect(black.color, TeamColor.black);
      expect(black.penalties.map((penalty) => penalty.cap), [2, 6, 8]);
      expect(black.hiddenPenalties, 1);
      expect(model.right.penalties.single.cap, 1);
      expect(model.right.hiddenPenalties, 0);
    });

    test('14.2.3.1: stilgezette klok in het laatste venster', () {
      final now = _modelOf(DemoMatch.stopped);
      final later = _modelOf(
        DemoMatch.stopped,
        later: const Duration(minutes: 1),
      );

      expect(now.clockMode, ScoreboardClockMode.stopped);
      expect(now.statusLabel, 'CLOCK STOPPED');
      expect(later.clockText, now.clockText);
      expect(later, now);
    });

    test('afgelopen wedstrijd toont FINAL met de eindstand', () {
      final model = _modelOf(DemoMatch.finished);

      expect(model.phaseLabel, 'FULL TIME');
      expect(model.clockMode, ScoreboardClockMode.finished);
      expect(model.clockText, 'FINAL');
      expect(model.left.score + model.right.score, 3);
    });

    test('een uitsluiting blijft als OUT bij het team staan', () {
      final model = _modelAfter(const [
        MatchEventData.playStarted(),
        MatchEventData.playStopped(),
        MatchEventData.playerDismissed(
          team: TeamColor.white,
          cap: 4,
          infringementCode: 'x',
        ),
      ]);

      expect(model.left.penalties.single.cap, 4);
      expect(model.left.penalties.single.text, 'OUT');
    });

    test('strafworp staat in de statusregel', () {
      final model = _modelAfter(const [
        MatchEventData.playStarted(),
        MatchEventData.playStopped(),
        MatchEventData.penaltyShotAwarded(againstTeam: TeamColor.white),
      ]);

      expect(model.statusLabel, 'PENALTY SHOT BLACK');
    });

    test('gelijke modellen zolang het beeld niet verandert', () {
      final a = _modelOf(DemoMatch.play);
      final b = _modelOf(
        DemoMatch.play,
        later: const Duration(milliseconds: 300),
      );
      final c = _modelOf(DemoMatch.play, later: const Duration(seconds: 2));

      expect(b, a);
      expect(b.hashCode, a.hashCode);
      expect(c, isNot(a));
    });
  });

  group('ScoreboardRoute.fromUri', () {
    test('geen parameters: het gewone zwembadscherm', () {
      expect(ScoreboardRoute.fromUri(Uri.parse('https://x/HSC/')), isNull);
      expect(
        ScoreboardRoute.fromUri(Uri.parse('https://x/HSC/?match=')),
        isNull,
      );
    });

    test('match en field', () {
      final match = ScoreboardRoute.fromUri(
        Uri.parse('https://x/HSC/?match=abc'),
      )!;
      final field = ScoreboardRoute.fromUri(
        Uri.parse('https://x/HSC/?field=veld-1&display=1#/'),
      )!;

      expect(match.matchId, 'abc');
      expect(match.fieldId, isNull);
      expect(match.fitDisplay, isFalse);
      expect(field.fieldId, 'veld-1');
      expect(field.matchId, isNull);
      expect(field.fitDisplay, isTrue);
    });
  });
}
