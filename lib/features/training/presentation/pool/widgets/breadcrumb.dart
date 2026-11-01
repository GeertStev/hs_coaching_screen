import 'package:flutter/material.dart';
import 'package:hs_coaching_core/training/display/display_position.dart';
import 'package:hs_coaching_core/training/display/display_step.dart';
import 'package:hs_coaching_core/training/display/display_transition.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_display_theme.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_layout.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/level_dots.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/pool_icons.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/pool_labels.dart';

/// Hoe een kruimelchip getoond wordt.
enum BreadcrumbChipKind {
  /// Het niveau zit in het huidige pad.
  present,

  /// Het niveau zit nu niet in het pad maar komt er bij de volgende stap
  /// bij (bv. warmup → set): gestippelde spookchip.
  ghost,

  /// Het niveau is nu en straks niet van toepassing: alleen het label.
  inactive,
}

class BreadcrumbChipModel {
  const BreadcrumbChipModel({
    required this.label,
    required this.kind,
    required this.dots,
    required this.showRepeat,
  });

  final String label;
  final BreadcrumbChipKind kind;
  final List<DotState> dots;
  final bool showRepeat;
}

enum _Level { set, subset, exercise }

/// Altijd drie chips (SET › SUBSET › EXERCISE), zodat het kruimelpad op elk
/// scherm op dezelfde plek staat. "Straks" komt alleen op het hoogste
/// niveau dat verandert; lagere niveaus resetten vanzelf.
List<BreadcrumbChipModel> breadcrumbChips(TrainingDisplayPosition position) {
  final current = position.current;
  if (current == null) return const [];
  final next = position.next;
  final transition = position.transition;
  final highest = switch (transition) {
    DisplayTransition.enterSet ||
    DisplayTransition.newSet ||
    DisplayTransition.repeatSet => _Level.set,
    DisplayTransition.enterSubset ||
    DisplayTransition.newSubset ||
    DisplayTransition.repeatSubset => _Level.subset,
    DisplayTransition.newExercise => _Level.exercise,
    _ => null,
  };

  LevelPosition? levelOf(DisplayStep? step, _Level level) => switch (level) {
    _Level.set => step?.path.set,
    _Level.subset => step?.path.subset,
    _Level.exercise => step?.path.exercise,
  };

  BreadcrumbChipModel chip(_Level level, String label) {
    final now = levelOf(current, level);
    final upcoming = levelOf(next, level);
    final isHighest = highest == level && upcoming != null;

    if (now == null) {
      if (!isHighest) {
        return BreadcrumbChipModel(
          label: label,
          kind: BreadcrumbChipKind.inactive,
          dots: const [],
          showRepeat: false,
        );
      }
      return BreadcrumbChipModel(
        label: label,
        kind: BreadcrumbChipKind.ghost,
        dots: [
          for (var i = 0; i < upcoming.count; i++)
            i == upcoming.index ? DotState.next : DotState.upcoming,
        ],
        showRepeat: false,
      );
    }

    final sameBlock =
        upcoming != null &&
        upcoming.count == now.count &&
        (level == _Level.exercise || upcoming.nodeId == now.nodeId);
    return BreadcrumbChipModel(
      label: label,
      kind: BreadcrumbChipKind.present,
      dots: [
        for (var i = 0; i < now.count; i++)
          if (i < now.index)
            DotState.done
          else if (i == now.index)
            DotState.now
          else if (isHighest && sameBlock && i == upcoming.index)
            DotState.next
          else
            DotState.upcoming,
      ],
      showRepeat:
          (level == _Level.set && transition == DisplayTransition.repeatSet) ||
          (level == _Level.subset &&
              transition == DisplayTransition.repeatSubset),
    );
  }

  return [
    chip(_Level.set, PoolLabels.set),
    chip(_Level.subset, PoolLabels.subset),
    chip(_Level.exercise, PoolLabels.exercise),
  ];
}

/// Kruimelrij (60 hoog): chips links, titel van de oefening rechts.
class BreadcrumbRow extends StatelessWidget {
  const BreadcrumbRow({super.key, required this.position});

  final TrainingDisplayPosition position;

  @override
  Widget build(BuildContext context) {
    final theme = PoolDisplayTheme.of(context);
    final chips = breadcrumbChips(position);
    return SizedBox(
      height: PoolLayout.breadcrumbHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 0,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  for (var i = 0; i < chips.length; i++) ...[
                    if (i > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: PoolIcon.chevron(
                          size: 14,
                          color: theme.textFaint,
                        ),
                      ),
                    BreadcrumbChip(model: chips[i]),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                position.current?.exerciseTitle ?? '',
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme
                    .label(PoolLayout.titleSize, color: theme.textSecondary)
                    .copyWith(height: 1.15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BreadcrumbChip extends StatelessWidget {
  const BreadcrumbChip({super.key, required this.model});

  final BreadcrumbChipModel model;

  @override
  Widget build(BuildContext context) {
    final theme = PoolDisplayTheme.of(context);
    final ghost = model.kind == BreadcrumbChipKind.ghost;
    final inactive = model.kind == BreadcrumbChipKind.inactive;
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            model.label,
            style: theme.label(
              12,
              color: ghost
                  ? theme.next
                  : inactive
                  ? theme.textFaint
                  : theme.textMuted,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 20,
            child: inactive
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: Text(
                      '–',
                      style: theme.label(16, color: theme.textFaint),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LevelDots(states: model.dots),
                        if (model.showRepeat) ...[
                          const SizedBox(width: 10),
                          PoolIcon.repeat(size: 18, color: theme.next),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );

    return Container(
      key: ValueKey('chip-${model.label}-${model.kind.name}'),
      height: PoolLayout.breadcrumbHeight,
      constraints: const BoxConstraints(minWidth: 72),
      decoration: ghost
          ? null
          : BoxDecoration(
              color: inactive ? null : theme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: inactive ? theme.nextBorder : theme.rowBorder,
                width: 1.5,
              ),
            ),
      child: ghost
          ? CustomPaint(
              painter: _DashedBorderPainter(color: theme.next),
              child: content,
            )
          : content,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(0.75),
          const Radius.circular(10),
        ),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 4), paint);
        distance += 7;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color;
}
