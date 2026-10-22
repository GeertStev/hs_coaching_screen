import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_screen/common/widgets/async_content.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

Widget _content(AsyncValue<String> value) =>
    _wrap(AsyncContent<String>(value: value, data: (s) => Text(s)));

void main() {
  testWidgets('toont data', (tester) async {
    await tester.pumpWidget(_content(const AsyncData('hallo')));
    expect(find.text('hallo'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsNothing);
  });

  testWidgets('fout zonder data: nette melding, geen ruwe fout', (
    tester,
  ) async {
    await tester.pumpWidget(
      _content(AsyncError(Exception('geheim detail'), StackTrace.empty)),
    );
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.textContaining('geheim'), findsNothing);
    expect(find.text('Something went wrong. Please try again.'), findsOneWidget);
  });

  testWidgets('fout na data: laatst goede inhoud blijft staan', (
    tester,
  ) async {
    final controller = StreamController<String>();
    addTearDown(controller.close);
    final provider = StreamProvider<String>(
      (ref) => controller.stream,
      retry: (_, _) => null,
    );
    await tester.pumpWidget(
      ProviderScope(
        child: _wrap(
          Consumer(
            builder: (context, ref, _) => AsyncContent<String>(
              value: ref.watch(provider),
              data: (s) => Text(s),
            ),
          ),
        ),
      ),
    );
    controller.add('oud');
    await tester.pump();
    controller.addError(Exception('x'));
    await tester.pump();
    expect(find.text('oud'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('herlaadt na aanhoudende fout, niet als die verdwijnt', (
    tester,
  ) async {
    var reloads = 0;
    await tester.pumpWidget(
      _wrap(ScreenErrorIndicator(error: Exception('x'), onReload: () => reloads++)),
    );
    await tester.pump(const Duration(minutes: 4));
    expect(reloads, 0);
    await tester.pump(const Duration(minutes: 1));
    expect(reloads, 1);

    reloads = 0;
    await tester.pumpWidget(
      _wrap(ScreenErrorIndicator(error: Exception('x'), onReload: () => reloads++)),
    );
    await tester.pumpWidget(_wrap(const SizedBox()));
    await tester.pump(const Duration(minutes: 10));
    expect(reloads, 0);
  });
}
