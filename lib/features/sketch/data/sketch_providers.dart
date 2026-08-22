import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/core/data/switch_map.dart';
import 'package:hs_coaching_core/core/providers/display_device_ids_provider.dart';
import 'package:hs_coaching_core/core/providers/firebase_providers.dart';
import 'package:hs_coaching_core/sketch/sketch.dart';
import 'package:hs_coaching_core/sketch/sketch_element.dart';
import 'package:hs_coaching_core/sketch/sketch_repository.dart';

/// This screen never writes, so it uses core's read-only base directly
/// instead of a local subclass.
final sketchRepositoryProvider = Provider<DisplaySketchRepositoryBase>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final ids = ref.watch(displayDeviceIdsProvider);
  return DisplaySketchRepositoryBase(
    firestore: firestore,
    clubId: ids.clubId,
    displayId: ids.displayDeviceId,
  );
});

final currentSketchIdDocProvider = StreamProvider.autoDispose<String?>((ref) {
  return ref.watch(sketchRepositoryProvider).watchCurrentSketchIdDoc().map((
    snapshot,
  ) {
    final data = snapshot.data() as Map<String, dynamic>?;
    return data?['currentId'] as String?;
  });
});

/// Streamt de actieve sketch. Schakelt via `switchMap` live over naar het
/// content-document van een nieuwe sketchId zodra `currentId` wijzigt, zoals
/// image/text dat doen, in plaats van een losse family-provider per
/// sketchId te laten opstapelen (die zonder autoDispose nooit werd
/// opgeruimd, en dus een Firestore-listener per ooit getoonde sketch open
/// liet staan).
final currentSketchProvider = StreamProvider.autoDispose<Sketch?>((ref) {
  final repository = ref.watch(sketchRepositoryProvider);
  ref.watch(displayDeviceIdsProvider);
  return repository.watchCurrentSketchIdDoc().switchMap((snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?;
    final sketchId = data?['currentId'] as String?;
    if (sketchId == null) {
      return Stream.value(null);
    }
    return repository.watchSketch(sketchId);
  });
});

final sketchElementsStreamProvider =
    StreamProvider.autoDispose<List<SketchElement>>((ref) {
      // We watch these providers to ensure that if the club, display, or
      // sketch ID changes, this stream provider will be re-evaluated,
      // fetching the elements for the new context.
      ref.watch(displayDeviceIdsProvider);
      final sketchId = ref.watch(currentSketchIdDocProvider).value;

      if (sketchId == null) {
        return Stream.value([]);
      }
      return ref.read(sketchRepositoryProvider).watchSketchElements(sketchId);
    });
