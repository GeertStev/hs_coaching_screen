import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hs_coaching_core/training/display/display_progress.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_display_theme.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_layout.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/pool_labels.dart';

// Maten binnen de voortgangsbalk.
const double _barHeight = 18;
const double _counterSize = 11;
const double _gap = 6;
const double _innerGap = 4;
const double _boxPadding = 2.5;
const double _boxBorder = 1.5;

/// Kleinste breedte van een balkje, als deel van de totale breedte: ook een
/// oefening zonder of met weinig banen blijft zichtbaar met haar teller.
const double _minShare = 0.045;

/// Voortgangsbalk bovenaan (vervangt de kruimelrij): één balkje per oefening,
/// een kader per set/subset, niet uitgerold. Bij een oefening staat de teller
/// `x/y` in het balkje zelf; bij een set/subset op de kaderlijn. De breedte volgt het aantal banen (core's `ProgressItem.lengths`).
/// Past de balk niet in de hoogte (diepe nesting), dan schaalt hij kleiner.
class TrainingProgressBar extends StatelessWidget {
  const TrainingProgressBar({super.key, required this.items});

  final List<ProgressItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final total = items.fold(0, (sum, item) => sum + item.lengths);
    final weights = _Weights(math.max(1, total * _minShare));
    return SizedBox(
      height: PoolLayout.progressHeight,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: PoolLayout.width - 2 * PoolLayout.padSide,
            child: _ItemRow(items: items, weights: weights, gap: _gap),
          ),
        ),
      ),
    );
  }
}

/// Breedtegewichten met een minimum per oefening; een groep is de som van
/// haar kinderen.
class _Weights {
  _Weights(this.minimum);

  final double minimum;

  double of(ProgressItem item) => switch (item) {
    ProgressExercise(:final lengths) => math.max(lengths.toDouble(), minimum),
    ProgressGroup(:final children) => children.fold(
      0.0,
      (sum, child) => sum + of(child),
    ),
  };
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.items,
    required this.weights,
    required this.gap,
  });

  final List<ProgressItem> items;
  final _Weights weights;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final total = items.fold(0.0, (sum, item) => sum + weights.of(item));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          Expanded(
            flex: math.max(1, (weights.of(items[i]) / total * 1000).round()),
            child: switch (items[i]) {
              final ProgressExercise exercise => _ExerciseBar(item: exercise),
              final ProgressGroup group => _GroupBox(
                item: group,
                weights: weights,
              ),
            },
          ),
        ],
      ],
    );
  }
}

class _ExerciseBar extends StatelessWidget {
  const _ExerciseBar({required this.item});

  final ProgressExercise item;

  @override
  Widget build(BuildContext context) {
    final theme = PoolDisplayTheme.of(context);
    final filled = item.state != ProgressItemState.upcoming;
    final decoration = switch (item.state) {
      ProgressItemState.done => BoxDecoration(
        color: theme.done,
        borderRadius: BorderRadius.circular(4),
      ),
      ProgressItemState.current => BoxDecoration(
        color: theme.now,
        borderRadius: BorderRadius.circular(4),
      ),
      ProgressItemState.upcoming => BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.upcoming, width: 1.5),
      ),
    };
    return Container(
      key: ValueKey('progress-${item.nodeId}'),
      height: _barHeight,
      decoration: decoration,
      alignment: Alignment.center,
      child: _Counter(
        item: item,
        color: filled ? theme.background : theme.textFaint,
        text: '${item.count}x',
      ),
    );
  }
}

class _GroupBox extends StatelessWidget {
  const _GroupBox({required this.item, required this.weights});

  final ProgressGroup item;
  final _Weights weights;

  @override
  Widget build(BuildContext context) {
    final theme = PoolDisplayTheme.of(context);
    final current = item.state == ProgressItemState.current;
    final borderColor = current ? theme.now : theme.rowBorder;
    return Stack(
      key: ValueKey('progress-${item.nodeId}'),
      children: [
        Padding(
          // Ruimte voor de onderste helft van het label op de onderrand.
          padding: const EdgeInsets.only(bottom: _counterSize / 2),
          child: Container(
            width: double.infinity,
            // Geen bovenrand: de balkjes staan op één hoogte, het kader
            // sluit ze alleen links, rechts en onder in.
            padding: const EdgeInsets.fromLTRB(
              _boxPadding,
              0,
              _boxPadding,
              _boxPadding + _counterSize / 2,
            ),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: borderColor, width: _boxBorder),
                right: BorderSide(color: borderColor, width: _boxBorder),
                bottom: BorderSide(color: borderColor, width: _boxBorder),
              ),
            ),
            child: _ItemRow(
              items: item.children,
              weights: weights,
              gap: _innerGap,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Center(
            child: Container(
              height: _counterSize,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              color: theme.background,
              child: _Counter(item: item),
            ),
          ),
        ),
      ],
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({required this.item, this.color, this.text});

  final ProgressItem item;

  /// Vaste kleur (in een gevuld balkje); anders volgt de kleur de status.
  final Color? color;

  /// Vaste tekst in plaats van `x/y`.
  final String? text;

  @override
  Widget build(BuildContext context) {
    final theme = PoolDisplayTheme.of(context);
    final (stateColor, weight) = switch (item.state) {
      ProgressItemState.current => (theme.now, FontWeight.w700),
      ProgressItemState.done => (theme.textMuted, FontWeight.w600),
      ProgressItemState.upcoming => (theme.textFaint, FontWeight.w600),
    };
    return SizedBox(
      height: _counterSize,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text ?? formatCounter(item.counter, item.count),
          style: theme
              .number(_counterSize, color: color ?? stateColor)
              .copyWith(fontWeight: weight),
        ),
      ),
    );
  }
}
