import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/core/providers/display_device_ids_provider.dart';
import 'package:hs_coaching_core/core/providers/firebase_providers.dart';
import 'package:hs_coaching_core/training/display_training_repository.dart';
import 'package:hs_coaching_core/training/training.dart';

/// Provider for the training repository.
final trainingRepositoryProvider = Provider<DisplayTrainingRepository>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final ids = ref.watch(displayDeviceIdsProvider);
  return DisplayTrainingRepository(
    firestore: firestore,
    clubId: ids.clubId,
    displayId: ids.displayDeviceId,
  );
});

/// A stream provider that watches for training changes.
final trainingProvider = StreamProvider.autoDispose<Training>((ref) {
  return ref.watch(trainingRepositoryProvider).watchTraining();
});
