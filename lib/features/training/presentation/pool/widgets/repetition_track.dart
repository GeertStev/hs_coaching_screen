import 'package:flutter/material.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_display_theme.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/level_dots.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/pool_labels.dart';

/// Herhalingstrack in het timervak (spec §3.3): één node per herhaling van
/// de oefening, met de werktijd eronder. Ook bij één herhaling staat er één
/// node, zodat de plek op elk scherm gelijk blijft.
class RepetitionTrack extends StatelessWidget {
  const RepetitionTrack({
    super.key,
    required this.workSeconds,
    required this.currentIndex,
  });

  /// Werktijd per herhaling.
  final List<int> workSeconds;
  final int currentIndex;

  static const _nodeWidth = 40.0;
  static const _maxConnector = 44.0;
  static const _minConnector = 8.0;
  static const _available = 194.0;

  @override
  Widget build(BuildContext context) {
    final theme = PoolDisplayTheme.of(context);
    final count = workSeconds.length;
    final connector = count < 2
        ? 0.0
        : ((_available - count * _nodeWidth) / (count - 1)).clamp(
            _minConnector,
            _maxConnector,
          );

    DotState stateOf(int i) => i < currentIndex
        ? DotState.done
        : i == currentIndex
        ? DotState.now
        : DotState.upcoming;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          PoolLabels.repetition,
          style: theme.label(
            11,
            weight: FontWeight.w700,
            color: theme.textMuted,
            letterSpacing: 0.12,
          ),
        ),
        const SizedBox(height: 9),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < count; i++) ...[
                  if (i > 0)
                    Container(
                      width: connector,
                      height: 3,
                      margin: const EdgeInsets.only(top: 10.5),
                      decoration: BoxDecoration(
                        color: i <= currentIndex ? theme.done : theme.rowBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  SizedBox(
                    width: _nodeWidth,
                    child: Column(
                      children: [
                        LevelDot(
                          state: stateOf(i),
                          size: 24,
                          ringGapColor: theme.surface,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          workSeconds[i] > 0 ? '${workSeconds[i]} s' : '–',
                          maxLines: 1,
                          softWrap: false,
                          style: i == currentIndex
                              ? theme.label(
                                  17,
                                  weight: FontWeight.w700,
                                  color: theme.now,
                                )
                              : theme.label(15, color: theme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
