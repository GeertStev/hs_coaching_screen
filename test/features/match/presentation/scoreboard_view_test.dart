import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_core/match/in_memory_match_repository.dart';
import 'package:hs_coaching_core/match/match_repository.dart';
import 'package:hs_coaching_screen/features/match/data/demo_match.dart';
import 'package:hs_coaching_screen/features/match/data/match_repository.dart';
import 'package:hs_coaching_screen/features/match/presentation/match_scoreboard_screen.dart';
import 'package:hs_coaching_screen/features/match/presentation/scoreboard_theme.dart';

import '../../training/presentation/pool/pool_test_harness.dart';

const _now = 1800000000000;

/// Zet een scorebord op een scherm van [size], met de demowedstrijden en een
/// klok die de test zelf verzet.
Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(624, 416),
  int Function()? now,
  MatchRepository? repository,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        matchRepositoryProvider.overrideWithValue(
          repository ??
              DemoMatchRepository(
                inner: InMemoryMatchRepository(),
                nowServerMs: () => _now,
              ),
        ),
        matchNowProvider.overrideWithValue(now ?? () => _now),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          extensions: const [ScoreboardTheme.standard],
        ),
        home: Scaffold(
          backgroundColor: ScoreboardTheme.standard.background,
          body: child,
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

/// Haalt het scorebord weg, zodat de ticker stopt vóór de test eindigt.
Future<void> _unmount(WidgetTester tester) =>
    tester.pumpWidget(const SizedBox.shrink());

String _clockText(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const ValueKey('scoreboard-clock'))).data!;

void main() {
  setUpAll(() async {
    await loadPoolFonts();
    final testFile = (goldenFileComparator as LocalFileComparator).basedir
        .resolve('scoreboard_view_test.dart');
    goldenFileComparator = TolerantGoldenComparator(testFile);
  });

  group('goldens', () {
    const sizes = {'624x416': Size(624, 416), '1920x1080': Size(1920, 1080)};

    for (final demo in DemoMatch.values) {
      for (final MapEntry(key: label, value: size) in sizes.entries) {
        testWidgets('${demo.id} op $label', (tester) async {
          await _pump(
            tester,
            MatchScoreboardScreen(matchId: demo.id),
            size: size,
          );

          expect(tester.takeException(), isNull);
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/${demo.id}_$label.png'),
          );
          await _unmount(tester);
        });
      }
    }
  });

  testWidgets('de klok loopt mee met de server-tijd, zonder nieuwe events', (
    tester,
  ) async {
    var now = _now;
    await _pump(
      tester,
      const MatchScoreboardScreen(matchId: 'demo'),
      now: () => now,
    );
    final before = _clockText(tester);

    now += 5000;
    await tester.pump(const Duration(milliseconds: 16));

    expect(before, '8:03');
    expect(_clockText(tester), '7:58');
    await _unmount(tester);
  });

  testWidgets('een wedstrijd zonder events wacht', (tester) async {
    await _pump(tester, const MatchScoreboardScreen(matchId: 'onbekend'));

    expect(find.text('Waiting for the match'), findsOneWidget);
    await _unmount(tester);
  });

  testWidgets(
    'fieldScoreboard volgt de live wedstrijd en houdt de laatste vast',
    (tester) async {
      final live = StreamController<String?>();
      addTearDown(live.close);
      final repository = _FieldRepository(
        DemoMatchRepository(
          inner: InMemoryMatchRepository(),
          nowServerMs: () => _now,
        ),
        live.stream,
      );
      await _pump(
        tester,
        const FieldScoreboardScreen(fieldId: 'veld-1'),
        repository: repository,
      );

      live.add(null);
      await tester.pump();
      await tester.pump();
      expect(find.text('Waiting for the next match'), findsOneWidget);

      live.add('demo');
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(find.text('Holy Squid'), findsOneWidget);
      expect(find.text('PERIOD 2'), findsOneWidget);

      // De wedstrijd gaat van het veld: de eindstand blijft staan.
      live.add(null);
      await tester.pump();
      await tester.pump();
      expect(find.text('Holy Squid'), findsOneWidget);

      live.add('demo-halftime');
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(find.text('HALF-TIME'), findsOneWidget);
      await _unmount(tester);
    },
  );
}

/// Demowedstrijden, met een veld waarvan de test de live wedstrijd bepaalt.
class _FieldRepository extends DemoMatchRepository {
  _FieldRepository(DemoMatchRepository demo, this._live)
    : super(inner: demo.inner, nowServerMs: demo.nowServerMs);

  final Stream<String?> _live;

  @override
  Stream<String?> watchLiveMatchId(String fieldId) => _live;
}
