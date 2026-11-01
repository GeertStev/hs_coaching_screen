import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_core/training/display/display_position.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_display_theme.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_layout.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_training_view.dart';

/// Laadt Roboto uit de Flutter-SDK, zodat goldens echte tekst tonen in
/// plaats van het blokjes-testfont. Zonder SDK-fonts blijven de goldens
/// bruikbaar voor layout, maar onleesbaar.
Future<void> loadPoolFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) return;
  final dir = Directory('$root/bin/cache/artifacts/material_fonts');
  if (!dir.existsSync()) return;
  final loader = FontLoader('Roboto');
  for (final name in ['Regular', 'Medium', 'Bold']) {
    final file = File('${dir.path}/Roboto-$name.ttf');
    if (file.existsSync()) {
      final bytes = file.readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
  }
  await loader.load();
}

/// Golden-vergelijking met tolerantie voor kleine font-renderverschillen
/// tussen machines (spec §8).
class TolerantGoldenComparator extends LocalFileComparator {
  TolerantGoldenComparator(super.testFile, {this.tolerance = 0.005});

  final double tolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= tolerance) {
      result.dispose();
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}

/// Zet het scherm op het ontwerpcanvas (624×416) met [position].
Future<void> pumpPoolView(
  WidgetTester tester,
  TrainingDisplayPosition position,
) async {
  tester.view.physicalSize = const Size(PoolLayout.width, PoolLayout.height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        extensions: const [PoolDisplayTheme.standard],
      ),
      home: Scaffold(body: PoolTrainingView(position: position)),
    ),
  );
}
