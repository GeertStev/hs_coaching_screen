import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/core/providers/server_time_offset_provider.dart';
import 'package:hs_coaching_core/training/training.dart';
import 'package:hs_coaching_core/training/training_flatten.dart';
import 'package:hs_coaching_core/training/training_navigation.dart';
import 'package:hs_coaching_core/training/training_session_progress.dart';
import 'package:hs_coaching_core/training/training_status.dart';
import 'package:hs_coaching_screen/features/training/data/training_repository.dart';

/// Vertaalt de gesynchroniseerde [Training] state naar een lokaal tikkende
/// [TrainingSessionProgress], klokdrift-gecorrigeerd via RTDB's
/// `.info/serverTimeOffset` — zelfde principe als de chrono/tabata-
/// controllers. Puur lezend: in tegenstelling tot de coach-app's
/// `TrainingScreenController` schrijft deze nooit `next()` — de display-app
/// leest `autoAdvanceDue` alleen informatief (zie
/// `DisplayTrainingRepository`'s doc comment); het is aan de coach-app om de
/// pointer daadwerkelijk te verzetten.
class TrainingScreenController extends Notifier<TrainingSessionProgress> {
  Timer? _timer;

  @override
  TrainingSessionProgress build() {
    final training = ref.watch(trainingProvider).value ?? const Training();
    final offsetMillis = ref.watch(serverTimeOffsetProvider).value ?? 0;

    ref.onDispose(() => _timer?.cancel());
    _timer?.cancel();

    final steps = flattenTraining(training);
    final pointer = pointerFor(
      steps,
      path: training.currentPath,
      groupIndex: training.currentGroupIndex,
      phase: training.currentPhase,
    );

    final progress = computeTrainingProgress(
      steps: steps,
      status: training.status,
      pointer: pointer,
      elapsedInStepMillis: _elapsedInStepMillis(training, offsetMillis),
    );

    if (training.status == TrainingStatus.running &&
        progress.currentStep?.isTimed == true) {
      _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        final currentOffset = ref.read(serverTimeOffsetProvider).value ?? 0;
        state = computeTrainingProgress(
          steps: steps,
          status: training.status,
          pointer: pointer,
          elapsedInStepMillis: _elapsedInStepMillis(training, currentOffset),
        );
      });
    }

    return progress;
  }

  int _elapsedInStepMillis(Training training, double offsetMillis) {
    var elapsed = training.accumulatedElapsedMillis;
    if (training.status == TrainingStatus.running) {
      elapsed +=
          serverNowMillis(offsetMillis) -
          training.authoritativeStartTimeMillis;
    }
    return elapsed;
  }
}

final trainingScreenControllerProvider =
    NotifierProvider<TrainingScreenController, TrainingSessionProgress>(
      TrainingScreenController.new,
    );
