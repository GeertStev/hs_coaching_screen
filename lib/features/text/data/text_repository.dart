import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/core/providers/display_device_ids_provider.dart';
import 'package:hs_coaching_core/core/providers/firebase_providers.dart';
import 'package:hs_coaching_core/text/display_text.dart';
import 'package:hs_coaching_core/text/display_text_repository.dart';

/// Provider for the text repository. This screen never writes, so it uses
/// core's read-only base directly instead of a local subclass.
final textRepositoryProvider = Provider<DisplayTextRepositoryBase>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final ids = ref.watch(displayDeviceIdsProvider);
  return DisplayTextRepositoryBase(
    firestore: firestore,
    clubId: ids.clubId,
    displayId: ids.displayDeviceId,
  );
});

/// A provider that streams the current text to be displayed.
final textProvider = StreamProvider.autoDispose<DisplayText?>((ref) {
  return ref.watch(textRepositoryProvider).watchCurrentText();
});
