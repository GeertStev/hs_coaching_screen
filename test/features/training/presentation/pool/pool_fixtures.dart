import 'package:hs_coaching_core/training/display/display_position.dart';
import 'package:hs_coaching_core/training/display/display_timeline.dart';
import 'package:hs_coaching_core/training/training.dart';
import 'package:hs_coaching_core/training/training_flatten.dart';
import 'package:hs_coaching_core/training/training_session_progress.dart';
import 'package:hs_coaching_core/training/training_status.dart';
import 'package:hs_coaching_core/training/training_exercise.dart';
import 'package:hs_coaching_core/training/training_exercise_group.dart';
import 'package:hs_coaching_core/training/training_group.dart';
import 'package:hs_coaching_core/training/training_node.dart';
import 'package:hs_coaching_core/training/training_parameter_row.dart';

/// Kopie van core's `test/training/display/example_training.dart`.
/// De voorbeeldstructuur uit de pool-display spec (§2): warmup, dan een set
/// 2× met een group split en een subset 2× met twee oefeningen (d−, d+).
TrainingParameterRow line(String id, int reps, String stroke, String zone) =>
    TrainingParameterRow(
      id: id,
      reps: reps,
      distance: 25,
      stroke: stroke,
      zone: zone,
    );

TrainingNode exerciseNode(
  String id,
  String title, {
  int repeatCount = 1,
  List<TrainingExerciseGroup> groups = const [],
}) => TrainingNode.exercise(
  exercise: TrainingExercise(
    id: id,
    title: title,
    repeatCount: repeatCount,
    groups: groups,
  ),
);

TrainingNode groupNode(
  String id,
  String title,
  List<TrainingNode> children, {
  int repeatCount = 1,
}) => TrainingNode.group(
  group: TrainingGroup(
    id: id,
    title: title,
    repeatCount: repeatCount,
    children: children,
  ),
);

final exampleTraining = Training(
  children: [
    exerciseNode(
      'warmup',
      'Warmup',
      groups: [
        TrainingExerciseGroup(
          id: 'w',
          workSeconds: 10,
          restSeconds: 10,
          parameterRows: [
            line('w1', 10, 'AB', 'Bov'),
            line('w2', 10, 'B', 'Bov'),
            line('w3', 10, 'AB', 'HaBo'),
            line('w4', 5, 'B', 'Ond'),
          ],
        ),
      ],
    ),
    groupNode('set', 'Set', repeatCount: 2, [
      exerciseNode(
        'gs',
        'Group split',
        groups: [
          TrainingExerciseGroup(
            id: 'hard',
            name: 'Hard',
            workSeconds: 15,
            restSeconds: 10,
            parameterRows: [
              line('h1', 20, 'AB', 'Bov'),
              line('h2', 5, 'B', 'Ond'),
            ],
          ),
          TrainingExerciseGroup(
            id: 'easy',
            name: 'Easy',
            workSeconds: 10,
            restSeconds: 10,
            parameterRows: [
              line('e1', 15, 'AB', 'Bov'),
              line('e2', 5, 'B', 'Ond'),
            ],
          ),
        ],
      ),
      groupNode('sub', 'Subset', repeatCount: 2, [
        exerciseNode(
          'ex1',
          '1 d-',
          repeatCount: 2,
          groups: [
            TrainingExerciseGroup(
              id: 'x1',
              workSeconds: 10,
              restSeconds: 10,
              deltaSeconds: -5,
              parameterRows: [
                line('a', 1, 'AB', 'Bov'),
                line('b', 1, 'AB', 'Ond'),
              ],
            ),
          ],
        ),
        exerciseNode(
          'ex2',
          '2 d+',
          repeatCount: 2,
          groups: [
            TrainingExerciseGroup(
              id: 'x2',
              workSeconds: 10,
              restSeconds: 10,
              deltaSeconds: 5,
              parameterRows: [
                line('c', 1, 'AB', 'Bov'),
                line('d', 1, 'AB', 'Bov'),
              ],
            ),
          ],
        ),
      ]),
    ]),
  ],
);

/// Oefening, dan een oefening met enkel rust (rust tussen sets), dan weer
/// een oefening.
final restOnlyTraining = Training(
  children: [
    exerciseNode(
      'a',
      'A',
      groups: [
        TrainingExerciseGroup(
          id: 'a',
          workSeconds: 20,
          parameterRows: [line('a1', 4, 'AB', 'Bov')],
        ),
      ],
    ),
    exerciseNode(
      'rest',
      'Rest',
      groups: const [TrainingExerciseGroup(id: 'r', restSeconds: 30)],
    ),
    exerciseNode(
      'b',
      'B',
      groups: [
        TrainingExerciseGroup(
          id: 'b',
          workSeconds: 10,
          parameterRows: [line('b1', 2, 'B', 'Ond')],
        ),
      ],
    ),
  ],
);

/// Oefening (20 s), dan een ongetimede oefening 2× (wacht op de coach), dan
/// weer een oefening.
final waitTraining = Training(
  children: [
    exerciseNode(
      'a',
      'A',
      groups: [
        TrainingExerciseGroup(
          id: 'a',
          workSeconds: 20,
          parameterRows: [line('a1', 4, 'AB', 'Bov')],
        ),
      ],
    ),
    exerciseNode(
      'talk',
      'Talk',
      repeatCount: 2,
      groups: [
        TrainingExerciseGroup(
          id: 't',
          parameterRows: [line('t1', 2, 'B', 'Bov')],
        ),
      ],
    ),
    exerciseNode(
      'b',
      'B',
      groups: [
        TrainingExerciseGroup(
          id: 'b',
          workSeconds: 10,
          parameterRows: [line('b1', 2, 'B', 'Ond')],
        ),
      ],
    ),
  ],
);

/// Positie in [training] op [elapsedSeconds] na de start.
TrainingDisplayPosition trainingPositionAt(
  Training training,
  int elapsedSeconds,
) => displayPositionAt(
  buildDisplayTimeline(training),
  computeTrainingProgress(
    steps: flattenTraining(training),
    status: TrainingStatus.running,
    anchorStepIndex: 0,
    elapsedSinceAnchorMillis: elapsedSeconds * 1000,
  ),
);

/// Positie in [exampleTraining]: [elapsedSeconds] na het begin van
/// weergavestap [displayIndex] (0-gebaseerd).
TrainingDisplayPosition examplePosition(
  int displayIndex,
  int elapsedSeconds, {
  TrainingStatus status = TrainingStatus.running,
}) {
  final timeline = buildDisplayTimeline(exampleTraining);
  return displayPositionAt(
    timeline,
    computeTrainingProgress(
      steps: flattenTraining(exampleTraining),
      status: status,
      anchorStepIndex: displayIndex < 0
          ? -1
          : displayIndex >= timeline.steps.length
          ? timeline.displayIndexByStep.length
          : timeline.steps[displayIndex].firstStepIndex,
      elapsedSinceAnchorMillis: elapsedSeconds * 1000,
    ),
  );
}
