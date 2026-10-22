import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/chrono/chrono.dart';
import 'package:hs_coaching_core/chrono/chrono_laps.dart';
import 'package:hs_coaching_screen/common/widgets/async_content.dart';
import 'package:hs_coaching_screen/features/chrono/data/chrono_repository.dart';
import 'package:hs_coaching_screen/features/chrono/presentation/chrono_screen_controller.dart';

class ChronoScreen extends ConsumerWidget {
  const ChronoScreen({super.key});

  static String _formatDuration(Duration d) {
    if (d.isNegative) {
      final secondsLeft = (d.inMilliseconds.abs() / 1000).ceil();
      return '- ${secondsLeft.toString().padLeft(2, '0')}';
    }

    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hundredths = (d.inMilliseconds.remainder(1000) ~/ 10)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds.$hundredths';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncContent(
      value: ref.watch(chronoProvider),
      data: (chrono) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _ChronoTime(),
            if (chrono.lapTimes.isNotEmpty) ...[
              const SizedBox(height: 32),
              // Schaalt mee als het scherm smaller is dan de kolommen.
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _LapColumns(chrono: chrono),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Apart widget: alleen dit deel herbouwt bij elke tik van de chrono.
class _ChronoTime extends ConsumerWidget {
  const _ChronoTime();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elapsed = ref.watch(chronoScreenControllerProvider);

    return Container(
      decoration: BoxDecoration(
        //#77767B
        color: Color(0xFF2a2b2e),
        border: Border.all(color: ColorScheme.of(context).onSurface, width: 4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          ChronoScreen._formatDuration(elapsed),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontFamily: 'monospace',
            fontSize: 120,
            fontWeight: FontWeight.bold,
            color: (elapsed.isNegative) ? Colors.red : Color(0xFFFEBA2F),
          ),
        ),
      ),
    );
  }
}

/// De laatste 8 tijden in twee kolommen: links 1-4, rechts 5-8.
class _LapColumns extends StatelessWidget {
  const _LapColumns({required this.chrono});

  final Chrono chrono;

  @override
  Widget build(BuildContext context) {
    final rows = visibleChronoLapRows(chrono.lapTimes, maxLaps: chrono.maxLaps);
    const perColumn = chronoVisibleLapCount ~/ 2;
    final left = rows.take(perColumn).toList();
    final right = rows.skip(perColumn).toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _column(left),
        if (right.isNotEmpty) ...[const SizedBox(width: 64), _column(right)],
      ],
    );
  }

  Widget _column(List<ChronoLapRow> rows) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final row in rows) _LapLine(row: row, maxLaps: chrono.maxLaps),
      ],
    );
  }
}

class _LapLine extends StatelessWidget {
  const _LapLine({required this.row, required this.maxLaps});

  final ChronoLapRow row;
  final int? maxLaps;

  @override
  Widget build(BuildContext context) {
    final color = row.isFinal ? Color(0xFFFEBA2F) : Colors.white;
    final style = Theme.of(context).textTheme.headlineLarge?.copyWith(
      fontFamily: 'monospace',
      fontSize: 40,
      fontWeight: FontWeight.bold,
      color: color,
    );
    // Totaaltijd alleen als die verschilt van de rondetijd.
    final showTotal = row.totalMillis != row.splitMillis;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          SizedBox(
            width: 340,
            child: Text(chronoLapLabel(row, maxLaps: maxLaps), style: style),
          ),
          Text(
            ChronoScreen._formatDuration(
              Duration(milliseconds: row.splitMillis),
            ),
            style: style,
          ),
          if (showTotal) ...[
            const SizedBox(width: 16),
            Text(
              '(${ChronoScreen._formatDuration(Duration(milliseconds: row.totalMillis))})',
              style: style?.copyWith(
                fontSize: 24,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
