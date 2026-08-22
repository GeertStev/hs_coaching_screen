import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/chrono/chrono.dart';
import 'package:hs_coaching_core/chrono/chrono_repository.dart';
import 'package:hs_coaching_core/core/providers/display_device_ids_provider.dart';
import 'package:hs_coaching_core/core/providers/firebase_providers.dart';

/// Provider for the chrono repository.
final chronoRepositoryProvider = Provider<DisplayChronoRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final ids = ref.watch(displayDeviceIdsProvider);
  return DisplayChronoRepository(
    firestore: firestore,
    clubId: ids.clubId,
    displayId: ids.displayDeviceId,
  );
});

/// A stream provider that watches for chrono changes.
final chronoProvider = StreamProvider.autoDispose<Chrono>((ref) {
  return ref.watch(chronoRepositoryProvider).watchChrono();
});
