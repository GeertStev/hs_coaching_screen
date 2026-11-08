import 'package:flutter/material.dart';
import 'package:hs_coaching_core/training/display/display_position.dart';
import 'package:hs_coaching_core/training/display/display_step.dart';
import 'package:hs_coaching_core/training/training_step_phase.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_display_theme.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_layout.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/line_row.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/pool_labels.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/progress_bar.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/timer_box.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/upcoming_card.dart';

/// Het zwembadscherm voor Training op het vaste ontwerpcanvas (624×416):
/// voortgangsbalk (balkjes per oefening, gegroepeerd per set/subset), midden
/// (timer + lijnen) en onderaan één breed vak met de volgende oefening.
/// Geen kruimelpad en geen titels. Zuiver: tekent enkel [position]; schalen
/// naar het content-vak doet `TrainingScreen`.
class PoolTrainingView extends StatelessWidget {
  const PoolTrainingView({super.key, required this.position});

  final TrainingDisplayPosition position;

  @override
  Widget build(BuildContext context) {
    final theme = PoolDisplayTheme.of(context);
    final current = position.current;

    final Widget middle;
    if (position.isFinished) {
      middle = _Message(title: PoolLabels.trainingDone);
    } else if (current == null) {
      middle = _Message(
        title: PoolLabels.ready,
        subtitle: PoolLabels.waitingForStart,
      );
    } else if (current.isGroupSplit) {
      middle = _SplitMiddle(position: position, step: current);
    } else {
      middle = _Middle(position: position, step: current);
    }

    return Container(
      width: PoolLayout.width,
      height: PoolLayout.height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(PoolLayout.frameRadius),
      ),
      // Over de inhoud getekend: verschuift de layout niet.
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: theme.frame, width: PoolLayout.frameWidth),
        borderRadius: BorderRadius.circular(PoolLayout.frameRadius),
      ),
      padding: const EdgeInsets.fromLTRB(
        PoolLayout.padSide,
        PoolLayout.padTop,
        PoolLayout.padSide,
        PoolLayout.padBottom,
      ),
      child: Column(
        children: [
          TrainingProgressBar(items: position.progressBar),
          //const SizedBox(height: PoolLayout.zoneGap),
          SizedBox(height: PoolLayout.middleHeight, child: middle),
          const SizedBox(height: PoolLayout.zoneGap),
          UpcomingCard(
            step: position.isFinished ? null : position.nextExercise,
            highlighted:
                current != null &&
                position.isLastRepetition &&
                position.nextExercise != null,
          ),
        ],
      ),
    );
  }
}

class _Middle extends StatelessWidget {
  const _Middle({required this.position, required this.step});

  final TrainingDisplayPosition position;
  final DisplayStep step;

  @override
  Widget build(BuildContext context) {
    final group = step.groups.isEmpty ? null : step.groups.first;
    final lines = group?.lines ?? const [];
    return Row(
      children: [
        TimerBox(
          step: step,
          timer: position.timers.isEmpty
              ? const DisplayGroupTimer(
                  phase: TrainingStepPhase.work,
                  remainingSeconds: null,
                )
              : position.timers.first,
          status: position.status,
        ),
        const SizedBox(width: PoolLayout.columnGap),
        Expanded(
          child: LineList(
            lines: lines,
            height: PoolLayout.middleHeight,
            maxMetrics: LineRowMetrics.large,
            gap: PoolLayout.lineGap,
            grow: true,
          ),
        ),
      ],
    );
  }
}

class _SplitMiddle extends StatelessWidget {
  const _SplitMiddle({required this.position, required this.step});

  final TrainingDisplayPosition position;
  final DisplayStep step;

  @override
  Widget build(BuildContext context) {
    final theme = PoolDisplayTheme.of(context);
    final count = step.groups.length;
    const gap = 8.0;
    final blockHeight = (PoolLayout.middleHeight - gap * (count - 1)) / count;
    return Row(
      children: [
        Column(
          children: [
            for (var i = 0; i < count; i++) ...[
              if (i > 0) const SizedBox(height: gap),
              GroupTimerBox(
                step: step,
                groupIndex: i,
                timer: i < position.timers.length
                    ? position.timers[i]
                    : const DisplayGroupTimer(
                        phase: TrainingStepPhase.work,
                        remainingSeconds: null,
                      ),
                status: position.status,
                height: blockHeight,
              ),
            ],
          ],
        ),
        const SizedBox(width: PoolLayout.columnGap),
        Expanded(
          child: Column(
            children: [
              for (var i = 0; i < count; i++) ...[
                if (i > 0) const SizedBox(height: gap),
                Container(
                  height: blockHeight,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: LineList(
                    lines: step.groups[i].lines,
                    height: blockHeight - 16,
                    maxMetrics: LineRowMetrics.large,
                    gap: PoolLayout.lineGap,
                    slots: 2,
                    grow: true,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Vóór de start en na het einde: één groot bericht in de bovenste zones.
class _Message extends StatelessWidget {
  const _Message({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = PoolDisplayTheme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: theme.number(72, color: theme.work)),
          if (subtitle != null) ...[
            const SizedBox(height: 14),
            Text(subtitle!, style: theme.label(17, color: theme.textMuted)),
          ],
        ],
      ),
    );
  }
}
