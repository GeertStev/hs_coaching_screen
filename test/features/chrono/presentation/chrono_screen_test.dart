import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_core/chrono/chrono.dart';
import 'package:hs_coaching_core/core/providers/server_time_offset_provider.dart';
import 'package:hs_coaching_screen/features/chrono/data/chrono_repository.dart';
import 'package:hs_coaching_screen/features/chrono/presentation/chrono_screen.dart';

void main() {
  testWidgets('toont de laatste 8 tijden zonder overflow', (tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final chrono = Chrono(
      status: ChronoStatus.paused,
      accumulatedElapsedMillis: 90000,
      maxLaps: 3,
      lapTimes: [
        for (var i = 1; i <= 10; i++)
          ChronoLap(elapsedMillis: i * 7000, lane: (i - 1) % 4 + 1),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chronoProvider.overrideWith((ref) => Stream.value(chrono)),
          serverTimeOffsetProvider.overrideWith((ref) => Stream.value(0)),
        ],
        child: const MaterialApp(home: Scaffold(body: ChronoScreen())),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Lane '), findsNWidgets(8));
    expect(find.text('Lane 1 · 1/3'), findsNothing); // valt buiten de 8
    expect(find.text('Lane 2 · Final'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
