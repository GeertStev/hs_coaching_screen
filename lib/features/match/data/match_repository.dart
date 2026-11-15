import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/core/providers/display_device_ids_provider.dart';
import 'package:hs_coaching_core/core/providers/firebase_providers.dart';
import 'package:hs_coaching_core/core/providers/server_time_offset_provider.dart';
import 'package:hs_coaching_core/match/engine/match_state.dart';
import 'package:hs_coaching_core/match/firestore_match_repository.dart';
import 'package:hs_coaching_core/match/match_repository.dart';
import 'package:hs_coaching_screen/features/match/data/demo_match.dart';

/// Leeskant van de wedstrijden: core's `FirestoreMatchRepository` zoals hij
/// is, met de demowedstrijden (`demo...`) ervoor. Dit scherm schrijft nooit.
final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final ids = ref.watch(displayDeviceIdsProvider);
  return DemoMatchRepository(
    inner: FirestoreMatchRepository(firestore: firestore, clubId: ids.clubId),
    nowServerMs: () =>
        serverNowMillis(ref.read(serverTimeOffsetProvider).value ?? 0),
  );
});

/// De toestand van één wedstrijd, lokaal gereduceerd uit haar event log.
/// Een family op `matchId`: er bestaat geen globale "actieve wedstrijd".
final matchStateProvider = StreamProvider.autoDispose
    .family<MatchState, String>((ref, matchId) {
      return ref.watch(matchRepositoryProvider).watch(matchId);
    });

/// De wedstrijd die nu live is op een veld, of `null`.
final liveMatchIdProvider = StreamProvider.autoDispose.family<String?, String>((
  ref,
  fieldId,
) {
  return ref.watch(matchRepositoryProvider).watchLiveMatchId(fieldId);
});

/// "Nu" in server-tijd, voor de klokken van het scorebord. Een provider zodat
/// tests een vaste tijd kunnen meegeven.
final matchNowProvider = Provider<int Function()>((ref) {
  final offset = ref.watch(serverTimeOffsetProvider).value ?? 0;
  return () => serverNowMillis(offset);
});
