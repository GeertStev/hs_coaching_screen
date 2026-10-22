import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/core/providers/server_time_offset_provider.dart';
import 'package:hs_coaching_core/training/training.dart';
import 'package:hs_coaching_core/training/training_flatten.dart';
import 'package:hs_coaching_core/training/training_session_progress.dart';
import 'package:hs_coaching_screen/features/training/data/training_repository.dart';

/// Vertaalt de gesynchroniseerde [Training] state naar een lokaal tikkende
/// [TrainingSessionProgress], klokdrift-gecorrigeerd via RTDB's
/// `.info/serverTimeOffset` — zelfde principe als de chrono/tabata-
/// controllers. De positie wordt vanaf het anker (`currentStepIndex`) met de
/// verstreken tijd doorgerekend (`trainingProgressAt`), precies zoals in de
/// coach-app: getimede stappen schuiven hier dus vanzelf door, ook als de
/// tablet slaapt. Puur lezend: alleen de coach-app verzet het anker.
class TrainingScreenController extends Notifier<TrainingSessionProgress> {
  Timer? _timer;

  @override
  TrainingSessionProgress build() {
    final training = ref.watch(trainingProvider).value ?? const Training();
    final offsetMillis = ref.watch(serverTimeOffsetProvider).value ?? 0;

    ref.onDispose(() => _timer?.cancel());
    _timer?.cancel();

    final steps = flattenTraining(training);
    final progress = trainingProgressAt(
      training,
      steps,
      nowServerMillis: serverNowMillis(offsetMillis),
    );

    if (progress.isTicking) {
      _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        final currentOffset = ref.read(serverTimeOffsetProvider).value ?? 0;
        final tickProgress = trainingProgressAt(
          training,
          steps,
          nowServerMillis: serverNowMillis(currentOffset),
        );
        state = tickProgress;
        if (!tickProgress.isTicking) _timer?.cancel();
      });
    }

    return progress;
  }
}

final trainingScreenControllerProvider =
    NotifierProvider<TrainingScreenController, TrainingSessionProgress>(
      TrainingScreenController.new,
    );
