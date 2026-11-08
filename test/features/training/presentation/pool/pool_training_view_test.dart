import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_core/training/training_status.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_layout.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_training_view.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/breadcrumb.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/level_dots.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/line_row.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/upcoming_card.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/timer_box.dart';

import 'pool_fixtures.dart';
import 'pool_test_harness.dart';

/// De vier referentieschermen uit de spec (§5), plus vóór de start en klaar.
final _scenes = {
  // stap 1: warmup, 3 s ver → nog 7 s werk
  'step01_warmup': () => examplePosition(0, 3),
  // stap 2: group split, 6 s ver → Hard nog 9, Easy nog 4
  'step02_group_split': () => examplePosition(1, 6),
  // stap 3: oefening 1 d−, herhaling 1 → onderste vak niet gehighlight
  'step03_first_repetition': () => examplePosition(2, 2),
  // stap 4: oefening 1 d−, herhaling 2 (5 s werk), 2 s ver → nog 3
  'step04_exercise': () => examplePosition(3, 2),
  // stap 10: oefening 2 d+, herhaling 2 (15 s werk), rust nog 4 s
  'step10_rest_set_again': () => examplePosition(9, 21),
  // stap 18: laatste herhaling van de laatste oefening → END
  'step19_last': () => examplePosition(18, 2),
  'before_start': () => examplePosition(-1, 0, status: TrainingStatus.idle),
  // 5 s voor het einde, volgende = oefening met enkel rust
  'next_rest_only': () => trainingPositionAt(restOnlyTraining, 15),
  // oefening met enkel rust loopt
  'rest_only': () => trainingPositionAt(restOnlyTraining, 22),
  'finished': () => examplePosition(19, 0),
};

void main() {
  setUpAll(() async {
    await loadPoolFonts();
    goldenFileComparator = TolerantGoldenComparator(
      Uri.parse(
        'test/features/training/presentation/pool/'
        'pool_training_view_test.dart',
      ),
    );
  });

  group('golden 624×416', () {
    for (final entry in _scenes.entries) {
      testWidgets(entry.key, (tester) async {
        await pumpPoolView(tester, entry.value());
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(PoolTrainingView),
          matchesGoldenFile('goldens/${entry.key}.png'),
        );
      });
    }
  });

  group('fullscreen 16:9 (breder canvas)', () {
    final width = PoolLayout.canvasWidthFor(const Size(1920, 1080));
    for (final name in ['step02_group_split', 'step04_exercise']) {
      testWidgets(name, (tester) async {
        await pumpPoolView(tester, _scenes[name]!(), width: width);
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(PoolTrainingView),
          matchesGoldenFile('goldens/wide_$name.png'),
        );
      });
    }
  });

  test('canvasbreedte volgt de verhouding van het content-vak, begrensd', () {
    expect(PoolLayout.canvasWidthFor(const Size(540, 360)), 624);
    expect(
      PoolLayout.canvasWidthFor(const Size(1920, 1080)),
      closeTo(416 * 16 / 9, 0.01),
    );
    expect(
      PoolLayout.canvasWidthFor(const Size(400, 600)),
      PoolLayout.minWidth,
    );
    expect(
      PoolLayout.canvasWidthFor(const Size(3000, 500)),
      PoolLayout.maxWidth,
    );
  });

  testWidgets('de vijf kolommen staan op elk scherm op dezelfde plek', (
    tester,
  ) async {
    List<double>? reference;
    for (final scene in _scenes.values) {
      await pumpPoolView(tester, scene());
      for (final row in find.byType(LineRow).evaluate()) {
        final rects = [
          for (var i = 0; i < 5; i++)
            tester.getRect(
              find.descendant(
                of: find.byWidget(row.widget),
                matching: find.byKey(ValueKey('line-column-$i')),
              ),
            ),
        ];
        final left = rects.first.left;
        final width = rects.last.right - left;
        final relative = [for (final r in rects) (r.center.dx - left) / width];
        reference ??= relative;
        for (var i = 0; i < 5; i++) {
          expect(relative[i], closeTo(reference[i], 0.001));
        }
      }
    }
    expect(reference, isNotNull);
  });

  testWidgets(
    'laatste herhaling: onderste vak gehighlight met de volgende oefening',
    (tester) async {
      // stap 10: laatste herhaling van de subset; daarna de group split.
      await pumpPoolView(tester, examplePosition(9, 21));
      final card = find.byKey(const ValueKey('upcoming-highlighted'));
      expect(card, findsOneWidget);
      expect(
        find.descendant(of: card, matching: find.byType(GroupPill)),
        findsNWidgets(2),
      );
      // Geen titels en geen overgangslabels meer.
      expect(find.text('Group split'), findsNothing);
      expect(find.text('2 d+'), findsNothing);
    },
  );

  testWidgets(
    'eerste van twee herhalingen: volgende oefening, niet gehighlight',
    (tester) async {
      await pumpPoolView(tester, examplePosition(2, 2));
      expect(find.byKey(const ValueKey('upcoming')), findsOneWidget);
      expect(find.text('1/2'), findsWidgets);
      expect(find.text('W: 00:10 (−5s)'), findsOneWidget);
      expect(find.text('W: 00:10 (+5s)'), findsOneWidget);
      expect(find.text('R: 00:10'), findsNWidgets(2));
    },
  );

  testWidgets('tweede herhaling toont de werktijd van die herhaling', (
    tester,
  ) async {
    await pumpPoolView(tester, examplePosition(3, 2));
    expect(find.text('W: 00:05 (−5s)'), findsOneWidget);
    // onderaan: oefening 2, eerste herhaling
    expect(find.text('W: 00:10 (+5s)'), findsOneWidget);
  });

  testWidgets('focus: huidige oefening tot de rust van de laatste herhaling', (
    tester,
  ) async {
    // stap 10, werk: focus op de huidige oefening.
    await pumpPoolView(tester, examplePosition(9, 3));
    expect(find.byKey(const ValueKey('current-focused')), findsOneWidget);
    expect(find.byKey(const ValueKey('upcoming')), findsOneWidget);
    // stap 10, rust: focus op de volgende.
    await pumpPoolView(tester, examplePosition(9, 21));
    expect(find.byKey(const ValueKey('current')), findsOneWidget);
    expect(find.byKey(const ValueKey('upcoming-highlighted')), findsOneWidget);
  });

  testWidgets('oefening met enkel rust: onderaan REST met de rusttijd', (
    tester,
  ) async {
    await pumpPoolView(tester, trainingPositionAt(restOnlyTraining, 10));
    expect(find.byKey(const ValueKey('upcoming-rest')), findsOneWidget);
    expect(find.text('R: 00:30'), findsOneWidget);
    // Zonder rust: focus pas 5 s voor het einde.
    expect(find.byKey(const ValueKey('current-focused')), findsOneWidget);
    await pumpPoolView(tester, trainingPositionAt(restOnlyTraining, 15));
    expect(find.byKey(const ValueKey('upcoming-highlighted')), findsOneWidget);
  });

  testWidgets('oefening met enkel rust loopt vanzelf af', (tester) async {
    await pumpPoolView(tester, trainingPositionAt(restOnlyTraining, 22));
    expect(find.text('REST'), findsWidgets);
    expect(find.text('00:28'), findsOneWidget);
    expect(find.text('R: 00:30'), findsOneWidget);
    await pumpPoolView(tester, trainingPositionAt(restOnlyTraining, 51));
    expect(find.text('00:09'), findsOneWidget);
  });

  testWidgets('na de laatste oefening: END', (tester) async {
    await pumpPoolView(tester, examplePosition(18, 2));
    expect(find.text('END'), findsOneWidget);
    expect(find.byType(UpcomingCard), findsOneWidget);
  });

  testWidgets('lijnen hebben een vaste hoogte, ook bij twee lijnen', (
    tester,
  ) async {
    await pumpPoolView(tester, examplePosition(0, 3));
    final four = tester.widget<LineRow>(find.byType(LineRow).first);
    await pumpPoolView(tester, examplePosition(3, 2));
    final two = tester.widget<LineRow>(find.byType(LineRow).first);
    expect(two.metrics.height, closeTo(four.metrics.height, 0.01));
  });

  test('warmup: SET is een spookchip, geen aparte warmup-chip', () {
    final chips = breadcrumbChips(examplePosition(0, 3));
    expect(chips.map((c) => c.kind), [
      BreadcrumbChipKind.ghost,
      BreadcrumbChipKind.inactive,
      BreadcrumbChipKind.present,
    ]);
    expect(chips[0].dots, [DotState.next, DotState.upcoming]);
  });

  testWidgets('geen markering per lijn: alle lijnen zien er gelijk uit', (
    tester,
  ) async {
    await pumpPoolView(tester, examplePosition(0, 3));
    final rows = tester.widgetList<LineRow>(find.byType(LineRow)).toList();
    final current = rows.where((r) => !r.muted).toList();
    expect(current, hasLength(4));
    expect(current.map((r) => r.metrics.height).toSet(), hasLength(1));
  });
}
