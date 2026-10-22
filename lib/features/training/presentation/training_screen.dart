import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/training/training_parameter_row.dart';
import 'package:hs_coaching_core/training/training_status.dart';
import 'package:hs_coaching_core/training/training_step.dart';
import 'package:hs_coaching_core/training/training_step_phase.dart';
import 'package:hs_coaching_screen/features/training/presentation/training_screen_controller.dart';

class TrainingScreen extends ConsumerWidget {
  const TrainingScreen({super.key});

  String _formatSeconds(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _parameterSummary(TrainingParameterRow row) {
    final parts = <String>[
      if (row.reps != null) '${row.reps}x',
      if (row.distance != null) '${row.distance}m',
      if (row.stroke != null) row.stroke!,
      if (row.intensity != null) '${row.intensity}%',
      if (row.zone != null) row.zone!,
    ];
    return parts.join(' ');
  }

  String _repeatSummary(TrainingStep step) {
    if (step.repeats.isEmpty) return '';
    return step.repeats
        .map((r) => '${r.groupTitle ?? 'Set'} ${r.iteration}/${r.repeatCount}')
        .join(' • ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(trainingScreenControllerProvider);
    final step = progress.currentStep;

    if (progress.isFinished || step == null) {
      return Center(
        child: Text(
          progress.isFinished ? 'Finished' : 'Waiting to start',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: Colors.white70,
            letterSpacing: 4,
          ),
        ),
      );
    }

    final isPaused = progress.status == TrainingStatus.paused;
    final phaseColor = isPaused
        ? Colors.white54
        : step.phase == TrainingStepPhase.rest
        ? Colors.redAccent
        : Colors.greenAccent;
    final repeatSummary = _repeatSummary(step);
    final remaining = progress.remaining;
    final remainingSeconds = progress.remainingSeconds;

    // FittedBox schaalt de hele kaart kleiner zodra er te veel regels zijn
    // (bv. vier parameter-rijen), i.p.v. tekst onder de kaart te laten
    // uitlopen.
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2a2b2e),
              border: Border.all(
                color: ColorScheme.of(context).onSurface,
                width: 4,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (repeatSummary.isNotEmpty)
                    Text(
                      repeatSummary,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.white70),
                    ),
                  Text(
                    'Step ${step.siblingIndex + 1}/${step.siblingCount}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.white54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step.exerciseTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.displayMedium?.copyWith(color: Colors.white),
                  ),
                  if (step.groupName.isNotEmpty)
                    Text(
                      step.groupName,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    isPaused
                        ? 'Paused'
                        : step.phase == TrainingStepPhase.rest
                        ? 'Rest'
                        : 'Work',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: phaseColor,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (remainingSeconds != null)
                    Text(
                      _formatSeconds(remainingSeconds),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  else
                    Text(
                      'Manual',
                      style: Theme.of(
                        context,
                      ).textTheme.displaySmall?.copyWith(color: Colors.white70),
                    ),
                  const SizedBox(height: 12),
                  for (final row in step.parameterRows)
                    Text(
                      _parameterSummary(row),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                    ),
                  if (step.durationMillis != null && remaining != null) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 480,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value:
                              1 -
                              (remaining.inMilliseconds / step.durationMillis!)
                                  .clamp(0.0, 1.0),
                          minHeight: 12,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation(phaseColor),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
