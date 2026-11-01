import 'package:flutter/material.dart';
import 'package:hs_coaching_core/training/training_parameter_row.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_display_theme.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_layout.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/pool_chip.dart';

/// Eén lijn van een oefening in de vaste vijf kolommen (spec §4.4): aantal,
/// afstand, techniek, inspanning, omgeving. Overal dezelfde verhoudingen;
/// alleen [metrics] verschilt per context. Alle lijnen zijn gelijkwaardig:
/// geen markering van een "huidige" lijn.
class LineRow extends StatelessWidget {
  const LineRow({
    super.key,
    required this.line,
    required this.metrics,
    this.muted = false,
  });

  final TrainingParameterRow line;
  final LineRowMetrics metrics;

  /// In de Daarna-kaart: gedempte achtergrond en tekst, geen rand.
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = PoolDisplayTheme.of(context);
    final textColor = muted ? theme.nextRowText : theme.textPrimary;
    final numberStyle = theme.number(metrics.number, color: textColor);
    final chipStyle = theme.label(
      metrics.chip,
      weight: FontWeight.w700,
      color: textColor,
    );
    final chipBorder = metrics.bordered
        ? theme.chipBorderStrong
        : theme.chipBorder;
    final chipPadding = EdgeInsets.symmetric(
      horizontal: metrics.chip * 0.45,
      vertical: metrics.chip * 0.08,
    );
    final chipRadius = metrics.chip * 0.36;

    Widget faintDash(double size) =>
        Text('–', style: theme.number(size, color: theme.textFaint));

    final stroke = line.stroke?.trim() ?? '';
    final zone = line.zone?.trim() ?? '';
    final isUnder = zone.toUpperCase() == 'OND';

    final cells = <Widget>[
      line.reps == null
          ? faintDash(metrics.number)
          : Text('${line.reps}×', style: numberStyle),
      line.distance == null
          ? faintDash(metrics.number)
          : Text('${line.distance} m', style: numberStyle),
      stroke.isEmpty
          ? faintDash(metrics.effort)
          : PoolChip(
              text: stroke.toUpperCase(),
              style: chipStyle,
              background: theme.chipSurface,
              borderColor: chipBorder,
              padding: chipPadding,
              radius: chipRadius,
            ),
      line.intensity == null
          ? faintDash(metrics.effort)
          : Text(
              '${line.intensity}%',
              style: theme.number(metrics.effort, color: theme.textSecondary),
            ),
      zone.isEmpty
          ? faintDash(metrics.effort)
          : PoolChip(
              text: zone.toUpperCase(),
              style: chipStyle.copyWith(
                color: isUnder ? theme.onEnvUnder : theme.onEnvAbove,
              ),
              background: isUnder ? theme.envUnder : theme.envAbove,
              borderColor: isUnder ? theme.envUnderBorder : chipBorder,
              padding: chipPadding,
              radius: chipRadius,
            ),
    ];

    return Container(
      height: metrics.height,
      padding: EdgeInsets.symmetric(horizontal: metrics.horizontalPadding),
      decoration: BoxDecoration(
        color: muted ? theme.nextRow : theme.surfaceRow,
        borderRadius: BorderRadius.circular(metrics.radius),
        border: metrics.bordered
            ? Border.all(color: theme.rowBorder, width: 2)
            : null,
      ),
      child: Row(
        children: [
          for (var i = 0; i < cells.length; i++)
            Expanded(
              key: ValueKey('line-column-$i'),
              flex: PoolLayout.lineColumnFlex[i],
              child: Center(
                child: FittedBox(fit: BoxFit.scaleDown, child: cells[i]),
              ),
            ),
        ],
      ),
    );
  }
}

/// Een kolom lijnen die [height] vult: rijhoogte volgt uit het aantal lijnen,
/// begrensd door [maxMetrics].
class LineList extends StatelessWidget {
  const LineList({
    super.key,
    required this.lines,
    required this.height,
    required this.maxMetrics,
    required this.gap,
    this.muted = false,
    this.grow = false,
  });

  final List<TrainingParameterRow> lines;
  final double height;
  final LineRowMetrics maxMetrics;
  final double gap;
  final bool muted;

  /// `true`: rijen tussen medium en [maxMetrics] volgens de ruimte (het
  /// lijnenvak); `false`: [maxMetrics] of kleiner als het niet past.
  final bool grow;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) return SizedBox(height: height);
    final rowHeight = (height - gap * (lines.length - 1)) / lines.length;
    final metrics = grow
        ? LineRowMetrics.forHeight(rowHeight.clamp(0, maxMetrics.height))
        : maxMetrics.fitHeight(rowHeight);
    return SizedBox(
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < lines.length; i++) ...[
            if (i > 0) SizedBox(height: gap),
            LineRow(line: lines[i], metrics: metrics, muted: muted),
          ],
        ],
      ),
    );
  }
}
