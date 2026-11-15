import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_core/match/engine/match_phase.dart';
import 'package:hs_coaching_core/match/engine/match_reducer.dart';
import 'package:hs_coaching_core/match/in_memory_match_repository.dart';
import 'package:hs_coaching_screen/features/match/data/demo_match.dart';

void main() {
  const now = 1800000000000;

  test('elke demowedstrijd is een geldig event log', () {
    for (final demo in DemoMatch.values) {
      final events = demoMatchEvents(demo, nowServerMs: now);
      final state = reduceMatch(events);
      expect(state.created, isTrue, reason: demo.id);
      expect(state.rejectedEvents, isEmpty, reason: demo.id);
      expect(events.last.serverTimeMillis, lessThan(now), reason: demo.id);
    }
  });

  test('de demowedstrijden staan in de bedoelde fase', () {
    MatchPhase phaseOf(DemoMatch demo) =>
        reduceMatch(demoMatchEvents(demo, nowServerMs: now)).phase;

    expect(phaseOf(DemoMatch.play), MatchPhase.p2);
    expect(phaseOf(DemoMatch.timeOut), MatchPhase.p2);
    expect(phaseOf(DemoMatch.halfTime), MatchPhase.halfTime);
    expect(phaseOf(DemoMatch.stopped), MatchPhase.p2);
    expect(phaseOf(DemoMatch.finished).isOver, isTrue);
  });

  test(
    'een demo-id komt uit het geheugen, de rest uit de echte opslag',
    () async {
      final inner = InMemoryMatchRepository();
      final repository = DemoMatchRepository(
        inner: inner,
        nowServerMs: () => now,
      );

      expect(await repository.watchEvents('demo').first, isNotEmpty);
      expect(await repository.watchEvents('echte-wedstrijd').first, isEmpty);
      expect(await repository.watchLiveMatchId(demoFieldId).first, 'demo');
      expect(await repository.watchLiveMatchId('veld-1').first, isNull);
    },
  );
}
