import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/training/display/display_position.dart';
import 'package:hs_coaching_core/training/display/display_timeline.dart';
import 'package:hs_coaching_core/training/training.dart';
import 'package:hs_coaching_screen/features/training/data/training_repository.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_layout.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_training_view.dart';
import 'package:hs_coaching_screen/features/training/presentation/training_screen_controller.dart';

/// Weergavestappen van de huidige training; alleen herberekend als het
/// Firestore-document verandert, niet bij elke tik.
final trainingDisplayTimelineProvider = Provider<TrainingDisplayTimeline>((
  ref,
) {
  final training = ref.watch(trainingProvider).value ?? const Training();
  return buildDisplayTimeline(training);
});

/// Wat het scherm nu toont, afgeleid uit de tikkende voortgang van
/// [trainingScreenControllerProvider].
final trainingDisplayPositionProvider = Provider<TrainingDisplayPosition>((
  ref,
) {
  return displayPositionAt(
    ref.watch(trainingDisplayTimelineProvider),
    ref.watch(trainingScreenControllerProvider),
  );
});

/// Training op het zwembadscherm: het vaste ontwerpcanvas (624×416) schaalt
/// als geheel in het content-vak, zodat de layout overal identiek blijft.
class TrainingScreen extends ConsumerWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(trainingDisplayPositionProvider);
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: PoolLayout.width,
        height: PoolLayout.height,
        child: PoolTrainingView(position: position),
      ),
    );
  }
}
