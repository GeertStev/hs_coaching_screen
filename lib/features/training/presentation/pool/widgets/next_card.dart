import 'package:flutter/material.dart';
import 'package:hs_coaching_core/training/display/display_step.dart';
import 'package:hs_coaching_core/training/display/display_transition.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_display_theme.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_layout.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/line_row.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/pool_chip.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/pool_icons.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/pool_labels.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/spec_row.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/timer_box.dart';

/// Gedempte Daarna-kaart (spec §4.6): links de overgang en de naam van de
/// volgende oefening, rechts haar specificatie en lijnen (eerste herhaling).
/// [transition] `null` = vóór de start.
class NextCard extends StatelessWidget {
  const NextCard({super.key, required this.step, required this.transition});

  final DisplayStep step;
  final DisplayTransition? transition;

  @override
  Widget build(BuildContext context) {
    final theme = PoolDisplayTheme.of(context);
    final decoration = BoxDecoration(
      color: theme.nextSurface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: theme.nextBorder, width: 1.5),
    );
    final transition = this.transition;
    final repeat = transition != null && isRepeatTransition(transition);
    final set = step.path.set;
    final showSetChip =
        set != null &&
        set.count > 1 &&
        (transition == DisplayTransition.enterSet ||
            transition == DisplayTransition.newSet);

    return SizedBox(
      height: PoolLayout.nextHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            key: const ValueKey('next-card'),
            width: PoolLayout.leftColumn,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: decoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  PoolLabels.next,
                  style: theme.label(
                    12,
                    weight: FontWeight.w700,
                    color: theme.next,
                    letterSpacing: 0.14,
                  ),
                ),
                const SizedBox(height: 7),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: PoolPill(
                    key: ValueKey('transition-${transition?.name ?? 'start'}'),
                    text: PoolLabels.transition(transition),
                    style: theme.label(
                      17,
                      weight: FontWeight.w700,
                      color: theme.next,
                    ),
                    color: theme.next,
                    filled: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    trailing: repeat
                        ? PoolIcon.repeat(size: 18, color: theme.next)
                        : PoolIcon.chevron(size: 14, color: theme.next),
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        step.exerciseTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.label(15, color: theme.textSecondary),
                      ),
                    ),
                    if (showSetChip) ...[
                      const SizedBox(width: 8),
                      PoolChip(
                        text: 'set ${set.count}×',
                        style: theme.label(16, weight: FontWeight.w700),
                        background: theme.chipSurface,
                        borderColor: theme.chipBorder,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 2,
                        ),
                        radius: 7,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: PoolLayout.columnGap),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: decoration,
              child: step.isGroupSplit
                  ? _SplitLines(step: step)
                  : _Lines(step: step),
            ),
          ),
        ],
      ),
    );
  }
}

// Binnenhoogte van de rechterkaart: 106 − 2 × 8 padding − 2 × 1.5 rand.
const double _innerHeight = PoolLayout.nextHeight - 16 - 3;

class _Lines extends StatelessWidget {
  const _Lines({required this.step});

  final DisplayStep step;

  @override
  Widget build(BuildContext context) {
    final group = step.groups.isEmpty ? null : step.groups.first;
    return Column(
      children: [
        SpecRow(
          small: true,
          repetitions: step.path.repetition.count,
          workSeconds: step.repetitionWorkSeconds.first,
          restSeconds: group?.restSeconds ?? 0,
          deltaSeconds: group?.deltaSeconds ?? 0,
        ),
        const SizedBox(height: 4),
        LineList(
          lines: group?.lines ?? const [],
          height: _innerHeight - 24 - 4,
          maxMetrics: LineRowMetrics.next,
          gap: 4,
          muted: true,
        ),
      ],
    );
  }
}

class _SplitLines extends StatelessWidget {
  const _SplitLines({required this.step});

  final DisplayStep step;

  @override
  Widget build(BuildContext context) {
    final theme = PoolDisplayTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < step.groups.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                  child: Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: GroupPill(
                              name: step.groups[i].name,
                              index: i,
                              small: true,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatWorkRest(
                          step.groups[i].workSeconds,
                          step.groups[i].restSeconds,
                        ),
                        style: theme.label(
                          14,
                          weight: FontWeight.w700,
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                LineList(
                  lines: step.groups[i].lines,
                  height: _innerHeight - 20 - 4,
                  maxMetrics: LineRowMetrics.nextSplit,
                  gap: 4,
                  muted: true,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
