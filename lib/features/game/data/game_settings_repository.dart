import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/core/providers/display_device_ids_provider.dart';
import 'package:hs_coaching_core/core/providers/firebase_providers.dart';
import 'package:hs_coaching_core/game/game_settings.dart';
import 'package:hs_coaching_core/game/game_settings_repository.dart';

/// Provider for the game settings repository.
final gameSettingsRepositoryProvider = Provider<DisplayGameSettingsRepository>(
  (ref) {
    final firestore = ref.watch(firebaseFirestoreProvider);
    final ids = ref.watch(displayDeviceIdsProvider);
    return DisplayGameSettingsRepository(
      firestore: firestore,
      clubId: ids.clubId,
      displayId: ids.displayDeviceId,
    );
  },
);

/// A stream provider that watches for game settings changes.
final gameSettingsProvider = StreamProvider.autoDispose<GameSettings>((ref) {
  return ref.watch(gameSettingsRepositoryProvider).watchGameSettings();
});
