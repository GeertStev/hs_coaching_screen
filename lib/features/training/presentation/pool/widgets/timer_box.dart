import 'package:flutter/material.dart';
import 'package:hs_coaching_core/training/display/display_position.dart';
import 'package:hs_coaching_core/training/display/display_step.dart';
import 'package:hs_coaching_core/training/training_status.dart';
import 'package:hs_coaching_core/training/training_step_phase.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_display_theme.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_layout.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/pool_chip.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/pool_labels.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/repetition_track.dart';

/// Wat een timer toont: fase-label en de kleuren daarvan.
class _PhaseStyle {
  const _PhaseStyle(this.label, this.color, this.onColor, this.timerColor);

  final String label;
  final Color color;
  final Color onColor;
  final Color timerColor;

  static _PhaseStyle of(
    PoolDisplayTheme theme,
    DisplayGroupTimer timer,
    TrainingStatus status,
  ) {
    if (status == TrainingStatus.paused) {
      return _PhaseStyle(
        PoolLabels.paused,
        theme.paused,
        theme.onPaused,
        theme.textMuted,
      );
    }
    if (timer.remainingSeconds == null) {
      return _PhaseStyle(
        PoolLabels.untimed,
        theme.work,
        theme.onWork,
        theme.textMuted,
      );
    }
    return timer.phase == TrainingStepPhase.rest
        ? _PhaseStyle(PoolLabels.rest, theme.rest, theme.onRest, theme.rest)
        : _PhaseStyle(PoolLabels.work, theme.work, theme.onWork, theme.work);
  }
}

/// Timervak van een gewone oefening (226×196): fase-pill, grote timer,
/// herhalingstrack.
class TimerBox extends StatelessWidget {
  const TimerBox({
    super.key,
    required this.step,
    required this.timer,
    required this.status,
  });

  final DisplayStep step;
  final DisplayGroupTimer timer;
  final TrainingStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = PoolDisplayTheme.of(context);
    final phase = _PhaseStyle.of(theme, timer, status);
    return Container(
      width: PoolLayout.leftColumn,
      height: PoolLayout.middleHeight,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PoolPill(
            text: phase.label,
            style: theme.label(
              18,
              weight: FontWeight.w700,
              color: phase.onColor,
              letterSpacing: 0.08,
            ),
            color: phase.color,
            filled: true,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
          SizedBox(
            height: 72,
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                formatTimer(timer.remainingSeconds),
                key: const ValueKey('timer'),
                style: theme.number(80, color: phase.timerColor),
              ),
            ),
          ),
          RepetitionTrack(
            workSeconds: step.repetitionWorkSeconds,
            currentIndex: step.path.repetition.index,
          ),
        ],
      ),
    );
  }
}

/// Timervak van één groep van een group split (226×94).
class GroupTimerBox extends StatelessWidget {
  const GroupTimerBox({
    super.key,
    required this.group,
    required this.groupIndex,
    required this.timer,
    required this.status,
    required this.height,
  });

  final DisplayGroup group;
  final int groupIndex;
  final DisplayGroupTimer timer;
  final TrainingStatus status;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = PoolDisplayTheme.of(context);
    final phase = _PhaseStyle.of(theme, timer, status);
    return Container(
      width: PoolLayout.leftColumn,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: GroupPill(name: group.name, index: groupIndex),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatWorkRest(group.workSeconds, group.restSeconds),
                style: theme.label(
                  15,
                  weight: FontWeight.w700,
                  color: theme.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              PoolPill(
                text: phase.label,
                style: theme.label(
                  12,
                  weight: FontWeight.w700,
                  color: phase.onColor,
                  letterSpacing: 0.08,
                ),
                color: phase.color,
                filled: true,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              ),
            ],
          ),
          SizedBox(
            height: 46,
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                formatTimer(timer.remainingSeconds),
                style: theme.number(50, color: phase.timerColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gekleurde pill met de groepsnaam (HARD, EASY). Kleur volgt de volgorde
/// van de groep; de naam komt uit de data.
class GroupPill extends StatelessWidget {
  const GroupPill({
    super.key,
    required this.name,
    required this.index,
    this.small = false,
  });

  final String name;
  final int index;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final theme = PoolDisplayTheme.of(context);
    final text = name.trim().isEmpty ? 'GROUP ${index + 1}' : name;
    return PoolChip(
      text: text.toUpperCase(),
      style: theme.label(
        small ? 12 : 14,
        weight: FontWeight.w700,
        color: theme.onGroup,
        letterSpacing: 0.08,
      ),
      background: theme.groupColor(index),
      padding: EdgeInsets.symmetric(horizontal: small ? 9 : 12, vertical: 3),
      radius: small ? 6 : 7,
    );
  }
}
