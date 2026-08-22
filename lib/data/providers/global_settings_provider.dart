import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/core/providers/display_device_ids_provider.dart';
import 'package:hs_coaching_core/core/providers/firebase_providers.dart';
import 'package:hs_coaching_core/global_settings/display_global_settings.dart';

/// Read-only repository for `clubs/{clubId}/displays/{displayId}/settings/global`.
///
/// `hs_coaching_core` ships the [DisplayGlobalSettings] model but no
/// repository for it (unlike chrono/tabata/game/...) — every feature's
/// repository lives in the consuming app, so this one does too.
class GlobalSettingsRepository {
  GlobalSettingsRepository({
    required this.firestore,
    required this.clubId,
    required this.displayId,
  });

  @protected
  final FirebaseFirestore firestore;
  @protected
  final String clubId;
  @protected
  final String displayId;

  /// Reference to the 'global' settings document for a specific display.
  /// Path: /clubs/{clubId}/displays/{displayDeviceId}/settings/global
  @protected
  DocumentReference get globalSettingsRef {
    return firestore
        .collection('clubs')
        .doc(clubId)
        .collection('displays')
        .doc(displayId)
        .collection('settings')
        .doc('global');
  }

  /// Returns a stream of the current global settings.
  Stream<DisplayGlobalSettings> watchGlobalSettings() {
    return globalSettingsRef.snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        // Alle velden hebben een converter/@Default die een lege map opvangt.
        return DisplayGlobalSettings.fromJson(const {});
      }
      return DisplayGlobalSettings.fromJson(
        snapshot.data() as Map<String, dynamic>,
      );
    });
  }
}

final globalSettingsRepositoryProvider = Provider<GlobalSettingsRepository>((
  ref,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final ids = ref.watch(displayDeviceIdsProvider);
  return GlobalSettingsRepository(
    firestore: firestore,
    clubId: ids.clubId,
    displayId: ids.displayDeviceId,
  );
});

/// A stream provider that watches for global settings changes.
final globalSettingsProvider = StreamProvider<DisplayGlobalSettings>((ref) {
  return ref.watch(globalSettingsRepositoryProvider).watchGlobalSettings();
});
