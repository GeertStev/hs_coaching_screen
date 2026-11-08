import 'package:flutter/material.dart';
import 'package:hs_coaching_core/training/display/display_position.dart';
import 'package:hs_coaching_core/training/display/display_step.dart';
import 'package:hs_coaching_core/training/training_status.dart';
import 'package:hs_coaching_core/training/training_step_phase.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_display_theme.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_layout.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/pool_chip.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/pool_labels.dart';

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

/// Timervak van een gewone oefening (226×196): fase-pill, grote timer, en
/// onderaan de herhaling `x/y` met daarnaast W (werk van deze herhaling,
/// met delta) en R (rust).
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
    final group = step.groups.isEmpty ? null : step.groups.first;
    final repetition = step.path.repetition;
    return Container(
      width: PoolLayout.leftColumn,
      height: PoolLayout.middleInnerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _PhasePill(phase: phase, size: 18),
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
          Row(
            children: [
              RepetitionCounter(
                index: repetition.index,
                count: repetition.count,
                size: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: WorkRestText(
                  workSeconds: group?.workSeconds ?? 0,
                  restSeconds: group?.restSeconds ?? 0,
                  deltaSeconds: group?.deltaSeconds ?? 0,
                  size: 17,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Timervak van één groep van een group split: groepspill, herhaling en
/// fase-pill bovenaan, daaronder de timer met W en R ernaast.
class GroupTimerBox extends StatelessWidget {
  const GroupTimerBox({
    super.key,
    required this.step,
    required this.groupIndex,
    required this.timer,
    required this.status,
    required this.height,
  });

  final DisplayStep step;
  final int groupIndex;
  final DisplayGroupTimer timer;
  final TrainingStatus status;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = PoolDisplayTheme.of(context);
    final phase = _PhaseStyle.of(theme, timer, status);
    final group = step.groups[groupIndex];
    final repetition = step.path.repetition;
    return Container(
      width: PoolLayout.leftColumn,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: GroupPill(name: group.name, index: groupIndex),
                ),
              ),
              const SizedBox(width: 8),
              RepetitionCounter(
                index: repetition.index,
                count: repetition.count,
                size: 15,
              ),
              const Spacer(),
              _PhasePill(phase: phase, size: 12),
            ],
          ),
          SizedBox(
            height: 46,
            child: Row(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formatTimer(timer.remainingSeconds),
                    style: theme.number(46, color: phase.timerColor),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: WorkRestText(
                    workSeconds: group.workSeconds,
                    restSeconds: group.restSeconds,
                    deltaSeconds: group.deltaSeconds,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhasePill extends StatelessWidget {
  const _PhasePill({required this.phase, required this.size});

  final _PhaseStyle phase;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = PoolDisplayTheme.of(context);
    return PoolPill(
      text: phase.label,
      style: theme.label(
        size,
        weight: FontWeight.w700,
        color: phase.onColor,
        letterSpacing: 0.08,
      ),
      color: phase.color,
      filled: true,
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.67,
        vertical: size * 0.2,
      ),
    );
  }
}

/// Omkaderde teller `x/y` van de herhalingen van een oefening; ook `1/1`,
/// zodat er niets verspringt.
class RepetitionCounter extends StatelessWidget {
  const RepetitionCounter({
    super.key,
    required this.index,
    required this.count,
    required this.size,
  });

  /// 0-gebaseerd.
  final int index;
  final int count;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = PoolDisplayTheme.of(context);
    return Container(
      key: const ValueKey('repetition-counter'),
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.3,
        vertical: size * 0.12,
      ),
      decoration: BoxDecoration(
        color: theme.chipSurface,
        borderRadius: BorderRadius.circular(size * 0.25),
        border: Border.all(color: theme.chipBorderStrong, width: 1.5),
      ),
      child: Text(
        formatCounter(index + 1, count),
        style: theme.number(size, color: theme.textPrimary),
      ),
    );
  }
}

/// Twee regels: `W: 00:05 (−5s)` en `R: 00:10`. Enkel `R` bij een oefening
/// met enkel rust, niets bij een ongetimede stap.
class WorkRestText extends StatelessWidget {
  const WorkRestText({
    super.key,
    required this.workSeconds,
    required this.restSeconds,
    required this.deltaSeconds,
    required this.size,
    this.color,
  });

  final int workSeconds;
  final int restSeconds;
  final int deltaSeconds;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = PoolDisplayTheme.of(context);
    if (workSeconds <= 0 && restSeconds <= 0) return const SizedBox.shrink();
    final style = theme.label(
      size,
      weight: FontWeight.w700,
      color: color ?? theme.textSecondary,
    );
    Widget line(String text) => FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(text, style: style, maxLines: 1, softWrap: false),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (workSeconds > 0) ...[
          line(formatWorkLine(workSeconds, deltaSeconds)),
          SizedBox(height: size * 0.4),
        ],
        line(formatRestLine(workSeconds, restSeconds)),
      ],
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
