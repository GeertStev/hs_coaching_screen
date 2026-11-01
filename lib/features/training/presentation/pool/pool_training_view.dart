import 'package:flutter/material.dart';
import 'package:hs_coaching_core/training/display/display_position.dart';
import 'package:hs_coaching_core/training/display/display_step.dart';
import 'package:hs_coaching_core/training/training_step_phase.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_display_theme.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_layout.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/breadcrumb.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/line_row.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/next_card.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/pool_labels.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/spec_row.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/timer_box.dart';

/// Het zwembadscherm voor Training op het vaste ontwerpcanvas (624×416):
/// voortgangsbalk + banen, kruimelrij, midden (timer + lijnen), Daarna.
/// Zuiver: tekent enkel [position]; schalen naar het content-vak doet
/// `TrainingScreen`.
class PoolTrainingView extends StatelessWidget {
  const PoolTrainingView({super.key, required this.position});

  final TrainingDisplayPosition position;

  @override
  Widget build(BuildContext context) {
    final theme = PoolDisplayTheme.of(context);
    final current = position.current;
    final next = position.next;
    final total = position.lengthsTotal;

    final Widget top;
    if (position.isFinished) {
      top = _Message(title: PoolLabels.trainingDone);
    } else if (current == null) {
      top = _Message(
        title: PoolLabels.ready,
        subtitle: PoolLabels.waitingForStart,
      );
    } else {
      top = Column(
        children: [
          BreadcrumbRow(position: position),
          const SizedBox(height: PoolLayout.zoneGap),
          SizedBox(
            height: PoolLayout.middleHeight,
            child: current.isGroupSplit
                ? _SplitMiddle(position: position, step: current)
                : _Middle(position: position, step: current),
          ),
        ],
      );
    }

    return Container(
      width: PoolLayout.width,
      height: PoolLayout.height,
      color: theme.background,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PoolLayout.padSide,
              PoolLayout.padTop,
              PoolLayout.padSide,
              PoolLayout.padBottom,
            ),
            child: Column(
              children: [
                SizedBox(
                  height:
                      PoolLayout.breadcrumbHeight +
                      PoolLayout.zoneGap +
                      PoolLayout.middleHeight,
                  child: top,
                ),
                const SizedBox(height: PoolLayout.zoneGap),
                SizedBox(
                  height: PoolLayout.nextHeight,
                  child: next == null || position.isFinished
                      ? null
                      : NextCard(step: next, transition: position.transition),
                ),
              ],
            ),
          ),
          // Boven de zones getekend: het banenlabel valt anders onder het
          // READY-vak.
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: PoolLayout.progressBarHeight,
            child: ColoredBox(
              color: theme.progressTrack,
              child: FractionallySizedBox(
                key: const ValueKey('progress-bar'),
                alignment: Alignment.centerLeft,
                widthFactor: total == 0
                    ? 0
                    : (position.lengthsDone / total).clamp(0.0, 1.0),
                child: ColoredBox(color: theme.now),
              ),
            ),
          ),
          if (total > 0)
            Positioned(
              right: PoolLayout.padSide,
              top: PoolLayout.lengthsLabelTop,
              child: Text(
                PoolLabels.lengths(position.lengthsDone, total),
                style: theme.label(
                  PoolLayout.lengthsLabelSize,
                  color: theme.textMuted,
                  letterSpacing: 0.04,
                ),
              ),
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
    const specHeight = 28.0;
    const specGap = 8.0;
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
          child: Column(
            children: [
              SpecRow(
                repetitions: step.path.repetition.count,
                workSeconds: group?.workSeconds ?? 0,
                restSeconds: group?.restSeconds ?? 0,
                deltaSeconds: group?.deltaSeconds ?? 0,
              ),
              const SizedBox(height: specGap),
              LineList(
                lines: lines,
                height: PoolLayout.middleHeight - specHeight - specGap,
                maxMetrics: LineRowMetrics.large,
                gap: lines.length > 2 ? 5 : 8,
                grow: true,
              ),
            ],
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
                group: step.groups[i],
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
                    maxMetrics: LineRowMetrics.medium,
                    gap: 4,
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
