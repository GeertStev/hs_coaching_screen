import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/core/providers/display_device_ids_provider.dart';
import 'package:hs_coaching_core/core/providers/firebase_providers.dart';
import 'package:hs_coaching_core/tabata/tabata.dart';
import 'package:hs_coaching_core/tabata/tabata_repository.dart';

/// Provider for the tabata repository. This screen never writes, so it uses
/// core's read-only base directly instead of a local subclass. Saved
/// presets (`clubs/{clubId}/tabataPresets`) are a control-app-only library
/// feature and aren't read here.
final tabataRepositoryProvider = Provider<DisplayTabataRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final ids = ref.watch(displayDeviceIdsProvider);
  return DisplayTabataRepository(
    firestore: firestore,
    clubId: ids.clubId,
    displayId: ids.displayDeviceId,
  );
});

/// A stream provider that watches for tabata changes.
final tabataProvider = StreamProvider.autoDispose<Tabata>((ref) {
  return ref.watch(tabataRepositoryProvider).watchTabata();
});
