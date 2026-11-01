import 'package:flutter/material.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_display_theme.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/pool_icons.dart';

/// Toestand van een bolletje (kruimelpad) of node (herhalingstrack). Elke
/// toestand verschilt ook in vorm, niet alleen in kleur.
enum DotState {
  /// Gevuld, gedempt, met vinkje.
  done,

  /// Gevuld, met ring.
  now,

  /// Hol, in de "straks"-kleur.
  next,

  /// Hol, neutraal.
  upcoming,
}

/// Eén bolletje van [size] px. De ring van "nu" valt buiten de layout-maat
/// (zoals de box-shadow in het ontwerp), dus de ouder laat er ruimte voor.
class LevelDot extends StatelessWidget {
  const LevelDot({
    super.key,
    required this.state,
    required this.size,
    required this.ringGapColor,
  });

  final DotState state;
  final double size;

  /// Kleur van de 3 px tussenruimte rond de ring (= de ondergrond).
  final Color ringGapColor;

  @override
  Widget build(BuildContext context) {
    final theme = PoolDisplayTheme.of(context);
    return Container(
      key: ValueKey('dot-${state.name}'),
      width: size,
      height: size,
      decoration: switch (state) {
        DotState.done => BoxDecoration(
          color: theme.done,
          shape: BoxShape.circle,
        ),
        DotState.now => BoxDecoration(
          color: theme.now,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: theme.now, spreadRadius: 6),
            BoxShadow(color: ringGapColor, spreadRadius: 3),
          ],
        ),
        DotState.next => BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: theme.next, width: 2.5),
        ),
        DotState.upcoming => BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: theme.upcoming, width: 2.5),
        ),
      },
      child: state == DotState.done
          ? Center(
              child: PoolIcon.check(size: size * 0.6, color: theme.doneCheck),
            )
          : null,
    );
  }
}

/// Bolletjes verbonden door een lijntje (kruimelchip).
class LevelDots extends StatelessWidget {
  const LevelDots({super.key, required this.states});

  final List<DotState> states;

  @override
  Widget build(BuildContext context) {
    final theme = PoolDisplayTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < states.length; i++) ...[
          if (i > 0)
            Container(
              width: 18,
              height: 3,
              decoration: BoxDecoration(
                color: states[i] == DotState.done || states[i] == DotState.now
                    ? theme.done
                    : theme.rowBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          LevelDot(state: states[i], size: 20, ringGapColor: theme.surface),
        ],
      ],
    );
  }
}
