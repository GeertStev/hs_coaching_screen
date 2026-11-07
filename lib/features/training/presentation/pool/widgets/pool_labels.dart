import 'package:hs_coaching_core/training/display/display_transition.dart';

/// UI-teksten van het zwembadscherm (Engels, zoals de rest van de UI).
abstract final class PoolLabels {
  static const work = 'WORK';
  static const rest = 'REST';
  static const paused = 'PAUSED';
  static const untimed = 'GO';
  static const next = 'NEXT';
  static const repetition = 'REPETITION';
  static const set = 'SET';
  static const subset = 'SUBSET';
  static const exercise = 'EXERCISE';
  static const ready = 'READY';
  static const waitingForStart = 'Waiting for the coach to start';
  static const trainingDone = 'Training done';
  static const start = 'Start';
  static const end = 'END';

  static String lengths(int done, int total) => '$done / $total laps';

  static String transition(DisplayTransition? transition) =>
      switch (transition) {
        null => start,
        DisplayTransition.enterSet || DisplayTransition.newSet => 'New set',
        DisplayTransition.repeatSet => 'Set again',
        DisplayTransition.enterSubset ||
        DisplayTransition.newSubset => 'New subset',
        DisplayTransition.repeatSubset => 'Subset again',
        DisplayTransition.newExercise => 'New exercise',
        DisplayTransition.nextRepetition => 'Next repetition',
        DisplayTransition.done => trainingDone,
      };
}

/// `00:07`, `01:30`; `--:--` als er geen tijd is (ongetimed).
String formatTimer(int? seconds) {
  if (seconds == null) return '--:--';
  final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
  final rest = (seconds % 60).toString().padLeft(2, '0');
  return '$minutes:$rest';
}

/// `10 / 10 s`; leeg als de stap ongetimed is.
String formatWorkRest(int workSeconds, int restSeconds) =>
    workSeconds <= 0 ? '' : '$workSeconds / $restSeconds s';

/// `Δ −5s` / `Δ +5s`; leeg zonder delta.
String formatDelta(int deltaSeconds) {
  if (deltaSeconds == 0) return '';
  final sign = deltaSeconds < 0 ? '−' : '+';
  return 'Δ $sign${deltaSeconds.abs()}s';
}

/// `W: 00:05 (−5s)`: werktijd van deze herhaling, met de delta als die er
/// is; leeg als de stap ongetimed is.
String formatWorkLine(int workSeconds, int deltaSeconds) {
  if (workSeconds <= 0) return '';
  final delta = deltaSeconds == 0
      ? ''
      : ' (${deltaSeconds < 0 ? '−' : '+'}${deltaSeconds.abs()}s)';
  return 'W: ${formatTimer(workSeconds)}$delta';
}

/// `R: 00:10`; leeg als de stap ongetimed is.
String formatRestLine(int workSeconds, int restSeconds) =>
    workSeconds <= 0 ? '' : 'R: ${formatTimer(restSeconds)}';

/// `1/2`: herhaling (1-gebaseerd) van het aantal.
String formatCounter(int value, int count) => '$value/$count';
