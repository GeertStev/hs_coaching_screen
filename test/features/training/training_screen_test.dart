import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hs_coaching_core/training/training_parameter_row.dart';
import 'package:hs_coaching_core/training/training_session_progress.dart';
import 'package:hs_coaching_core/training/training_status.dart';
import 'package:hs_coaching_core/training/training_step.dart';
import 'package:hs_coaching_core/training/training_step_phase.dart';
import 'package:hs_coaching_screen/features/training/presentation/training_screen.dart';
import 'package:hs_coaching_screen/features/training/presentation/training_screen_controller.dart';

class _FixedController extends TrainingScreenController {
  _FixedController(this.progress);
  final TrainingSessionProgress progress;

  @override
  TrainingSessionProgress build() => progress;
}

void main() {
  testWidgets('lange oefening past binnen een klein scherm', (tester) async {
    tester.view.physicalSize = const Size(630, 430);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    const step = TrainingStep(
      path: [0, 3],
      groupIndex: 0,
      phase: TrainingStepPhase.work,
      durationMillis: 105000,
      exerciseId: 'e4',
      exerciseTitle: '100 und up up und',
      groupName: '',
      parameterRows: [
        TrainingParameterRow(id: 'r1', reps: 1, distance: 25, stroke: 'B'),
        TrainingParameterRow(id: 'r2', reps: 1, distance: 25, stroke: 'AB'),
        TrainingParameterRow(id: 'r3', reps: 1, distance: 25, stroke: 'B'),
        TrainingParameterRow(id: 'r4', reps: 1, distance: 25, stroke: 'B'),
      ],
      repeats: [
        TrainingStepRepeat(
          groupId: 's1',
          groupTitle: 'Batuhan makes you work hard',
          iteration: 2,
          repeatCount: 14,
        ),
      ],
      siblingIndex: 3,
      siblingCount: 4,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          trainingScreenControllerProvider.overrideWith(
            () => _FixedController(
              const TrainingSessionProgress(
                status: TrainingStatus.running,
                currentStep: step,
                stepIndex: 7,
                totalSteps: 56,
                remaining: Duration(milliseconds: 30200),
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: TrainingScreen())),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Batuhan makes you work hard 2/14'), findsOneWidget);
    expect(find.text('Step 4/4'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
    expect(find.text('00:31'), findsOneWidget);
  });
}
