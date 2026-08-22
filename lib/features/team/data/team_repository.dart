import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/core/providers/display_device_ids_provider.dart';
import 'package:hs_coaching_core/core/providers/firebase_providers.dart';
import 'package:hs_coaching_core/team/team_repository.dart';

/// Display-only: listens for `settings/team.timestamp` writes (from
/// `hs_coaching_app`'s `DisplayTeamRepository.triggerTeamUpdate`) and
/// invalidates [teamsProvider] so the roster is refetched from the Google
/// Script source. This screen never writes that timestamp itself.
final teamUpdateListenerProvider = Provider.autoDispose<void>((ref) {
  final ids = ref.watch(displayDeviceIdsProvider);
  final firestore = ref.watch(firebaseFirestoreProvider);

  // Gebruik .snapshots() om een continue stream te openen, NIET .get()
  final stream = firestore
      .collection('clubs')
      .doc(ids.clubId)
      .collection('displays')
      .doc(ids.displayDeviceId)
      .collection('settings')
      .doc('team')
      .snapshots();

  // Onthoudt lokaal de laatst geziene timestamp — geen Firestore-write nodig
  // om een cast te "bevestigen", dit scherm is read-only.
  DateTime? lastSeenTimestamp;
  var isFirstSnapshot = true;

  final subscription = stream.listen((snapshot) {
    if (!snapshot.exists) return;

    final timestamp = (snapshot.data()?['timestamp'] as Timestamp?)?.toDate();
    if (timestamp == null) return;

    // Eerste snapshot is de bestaande stand bij het opstarten van de listener;
    // teamsProvider haalt die al zelf op, dus enkel onthouden, niet opnieuw fetchen.
    if (isFirstSnapshot) {
      isFirstSnapshot = false;
      lastSeenTimestamp = timestamp;
      return;
    }

    if (lastSeenTimestamp == null || timestamp.isAfter(lastSeenTimestamp!)) {
      lastSeenTimestamp = timestamp;
      ref.invalidate(teamsProvider);
    }
  });

  // Zorg ervoor dat de stream netjes wordt afgesloten als deze provider wordt vernietigd
  ref.onDispose(() {
    subscription.cancel();
  });
});
