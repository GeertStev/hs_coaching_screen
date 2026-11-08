import 'package:flutter/material.dart';
import 'package:hs_coaching_core/training/display/display_step.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_display_theme.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_layout.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/line_row.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/pool_labels.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/timer_box.dart';

const double _padH = 12;
const double _padV = 6;
const double _border = 1.5;
const double _highlightBorder = 2.5;

// Binnenhoogte: 106 − 2 × 6 padding − 2 × de dikste rand (zodat niets
// verspringt als de rand dikker wordt).
const double _innerHeight =
    PoolLayout.upcomingHeight - 2 * _padV - 2 * _highlightBorder;

/// Het brede vak onderaan met de volgende oefening (de herhalingen van de
/// huidige overgeslagen), in haar eerste herhaling: links `N×` en W/R,
/// rechts de lijnen (altijd 5 plaatsen, niet groter bij minder lijnen).
/// Gedempt, met een oranje rand bij de laatste herhaling van de huidige
/// oefening ([highlighted]). [step] `null` = na de laatste oefening: `END`.
class UpcomingCard extends StatelessWidget {
  const UpcomingCard({super.key, required this.step, this.highlighted = false});

  final DisplayStep? step;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = PoolDisplayTheme.of(context);
    final step = this.step;
    final borderWidth = highlighted ? _highlightBorder : _border;
    return Container(
      key: ValueKey(highlighted ? 'upcoming-highlighted' : 'upcoming'),
      height: PoolLayout.upcomingHeight,
      padding: EdgeInsets.symmetric(
        horizontal: _padH + _highlightBorder - borderWidth,
        vertical: _padV + _highlightBorder - borderWidth,
      ),
      decoration: BoxDecoration(
        color: theme.nextSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlighted ? theme.now : theme.nextBorder,
          width: borderWidth,
        ),
      ),
      child: step == null
          ? Center(
              child: Text(
                PoolLabels.end,
                style: theme.label(
                  28,
                  weight: FontWeight.w700,
                  color: theme.textFaint,
                  letterSpacing: 0.2,
                ),
              ),
            )
          : step.isGroupSplit
          ? _SplitContent(step: step)
          : _Content(step: step),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.step});

  final DisplayStep step;

  @override
  Widget build(BuildContext context) {
    final theme = PoolDisplayTheme.of(context);
    final group = step.groups.isEmpty ? null : step.groups.first;
    return Row(
      children: [
        SizedBox(
          width: PoolLayout.upcomingLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${step.path.repetition.count}×',
                style: theme.number(24, color: theme.textPrimary),
              ),
              const SizedBox(height: 8),
              WorkRestText(
                workSeconds: group?.workSeconds ?? 0,
                restSeconds: group?.restSeconds ?? 0,
                deltaSeconds: group?.deltaSeconds ?? 0,
                size: 16,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _isRestOnly(group)
              ? Center(
                  child: Text(
                    PoolLabels.rest,
                    key: const ValueKey('upcoming-rest'),
                    style: theme.label(
                      28,
                      weight: FontWeight.w700,
                      color: theme.rest,
                      letterSpacing: 0.2,
                    ),
                  ),
                )
              : LineList(
                  lines: group?.lines ?? const [],
                  height: _innerHeight,
                  maxMetrics: LineRowMetrics.next,
                  gap: PoolLayout.upcomingLineGap,
                  muted: true,
                ),
        ),
      ],
    );
  }
}

/// Een oefening met enkel rust en zonder lijnen (bv. rust tussen twee
/// sets): in plaats van een leeg lijnenvak staat er `REST`.
bool _isRestOnly(DisplayGroup? group) =>
    group != null &&
    group.lines.isEmpty &&
    group.workSeconds <= 0 &&
    group.restSeconds > 0;

/// Group split als volgende oefening: twee helften, elk met groepspill, W/R
/// en de lijnen van die groep.
class _SplitContent extends StatelessWidget {
  const _SplitContent({required this.step});

  final DisplayStep step;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < step.groups.length; i++) ...[
          if (i > 0) const SizedBox(width: 14),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 92,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: GroupPill(
                          name: step.groups[i].name,
                          index: i,
                          small: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      WorkRestText(
                        workSeconds: step.groups[i].workSeconds,
                        restSeconds: step.groups[i].restSeconds,
                        deltaSeconds: step.groups[i].deltaSeconds,
                        size: 13,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: LineList(
                    lines: step.groups[i].lines,
                    height: _innerHeight,
                    maxMetrics: LineRowMetrics.nextSplit,
                    gap: PoolLayout.upcomingLineGap,
                    muted: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
