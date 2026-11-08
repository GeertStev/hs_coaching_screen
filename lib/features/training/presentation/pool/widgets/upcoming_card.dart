import 'package:flutter/material.dart';
import 'package:hs_coaching_core/training/display/display_step.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_display_theme.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_layout.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/line_row.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/pool_labels.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/timer_box.dart';

const double _padH = PoolLayout.upcomingPadH;
const double _padV = PoolLayout.upcomingPadV;
const double _border = 1.5;
const double _highlightBorder = PoolLayout.upcomingBorderMax;

// Binnenhoogte: vakhoogte − 2 × padding − 2 × de dikste rand (zodat niets
// verspringt als de rand dikker wordt).
const double _innerHeight =
    PoolLayout.upcomingHeight - 2 * _padV - 2 * _highlightBorder;

/// Het brede vak onderaan met de volgende oefening (de herhalingen van de
/// huidige overgeslagen), in haar eerste herhaling: links `N×` (of
/// `WAIT COACH` bij een ongetimede oefening) en W/R, rechts de lijnen
/// (altijd [PoolLayout.lineSlots] plaatsen, niet groter bij minder lijnen),
/// even breed en op dezelfde plaats als de lijnen van de huidige oefening.
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
      // De rand telt mee in de marge, zodat de inhoud niet verspringt.
      padding: EdgeInsets.fromLTRB(
        _padH + _highlightBorder - borderWidth,
        _padV + _highlightBorder - borderWidth,
        PoolLayout.upcomingPadRight - borderWidth,
        _padV + _highlightBorder - borderWidth,
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
              if (_isUntimed(group))
                Text(
                  PoolLabels.waitCoach,
                  key: const ValueKey('upcoming-wait'),
                  style: theme.label(
                    22,
                    weight: FontWeight.w700,
                    color: theme.textPrimary,
                    letterSpacing: 0.08,
                  ),
                )
              else
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
        const SizedBox(width: PoolLayout.upcomingLeftGap),
        Expanded(
          child: isRestOnly(group)
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
                  lines: visibleLines(group),
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

/// Een ongetimede oefening (geen werk en geen rust): wacht op de coach.
bool _isUntimed(DisplayGroup? group) =>
    group != null && group.workSeconds <= 0 && group.restSeconds <= 0;

/// Group split als volgende oefening: twee helften, elk met groepspill, W/R
/// en de lijnen van die groep.
class _SplitContent extends StatelessWidget {
  const _SplitContent({required this.step});

  final DisplayStep step;

  @override
  Widget build(BuildContext context) {
    final theme = PoolDisplayTheme.of(context);
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
                      if (_isUntimed(step.groups[i]))
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            PoolLabels.waitCoach,
                            style: theme.label(
                              13,
                              weight: FontWeight.w700,
                              color: theme.textSecondary,
                            ),
                          ),
                        ),
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
                    lines: visibleLines(step.groups[i]),
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
