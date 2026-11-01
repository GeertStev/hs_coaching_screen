import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_core/training/display/display_transition.dart';
import 'package:hs_coaching_core/training/training_status.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_training_view.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/breadcrumb.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/level_dots.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/line_row.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/next_card.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/timer_box.dart';

import 'pool_fixtures.dart';
import 'pool_test_harness.dart';

/// De vier referentieschermen uit de spec (§5), plus vóór de start en klaar.
final _scenes = {
  // stap 1: warmup, 3 s ver → nog 7 s werk
  'step01_warmup': () => examplePosition(0, 3),
  // stap 2: group split, 6 s ver → Hard nog 9, Easy nog 4
  'step02_group_split': () => examplePosition(1, 6),
  // stap 4: oefening 1 d−, herhaling 2 (5 s werk), 2 s ver → nog 3
  'step04_exercise': () => examplePosition(3, 2),
  // stap 10: oefening 2 d+, herhaling 2 (15 s werk), rust nog 4 s
  'step10_rest_set_again': () => examplePosition(9, 21),
  'before_start': () => examplePosition(-1, 0, status: TrainingStatus.idle),
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
    'repeatSet: Daarna toont de group split van set 2, SET krijgt ↻',
    (tester) async {
      final position = examplePosition(9, 21);
      expect(position.transition, DisplayTransition.repeatSet);

      await pumpPoolView(tester, position);
      final nextCard = find.byType(NextCard);
      expect(
        find.descendant(
          of: nextCard,
          matching: find.byKey(const ValueKey('transition-repeatSet')),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: nextCard, matching: find.byType(GroupPill)),
        findsNWidgets(2),
      );
      expect(
        find.descendant(of: nextCard, matching: find.text('Group split')),
        findsOneWidget,
      );

      final chips = breadcrumbChips(position);
      expect(chips.map((c) => c.label), ['SET', 'SUBSET', 'EXERCISE']);
      expect(chips[0].showRepeat, isTrue);
      expect(chips[0].dots, [DotState.now, DotState.next]);
      expect(chips[1].dots, [DotState.done, DotState.now]);
      expect(chips[1].showRepeat, isFalse);
    },
  );

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
