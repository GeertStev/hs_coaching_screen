import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/tabata/tabata_progress.dart';
import 'package:hs_coaching_screen/features/tabata/presentation/tabata_screen_controller.dart';

class TabataScreen extends ConsumerWidget {
  const TabataScreen({super.key});

  String _phaseLabel(TabataPhase phase) {
    switch (phase) {
      case TabataPhase.prepare:
        return 'Prepare';
      case TabataPhase.work:
        return 'Work';
      case TabataPhase.rest:
      case TabataPhase.restBetweenSets:
        return 'Rest';
      case TabataPhase.finished:
        return 'Finished';
    }
  }

  Color _phaseColor(TabataPhase phase) {
    switch (phase) {
      case TabataPhase.prepare:
        return Colors.amber;
      case TabataPhase.work:
        return Colors.greenAccent;
      case TabataPhase.rest:
      case TabataPhase.restBetweenSets:
        return Colors.redAccent;
      case TabataPhase.finished:
        return Colors.white;
    }
  }

  String _formatSeconds(Duration d) {
    final totalSeconds = (d.inMilliseconds / 1000).ceil();
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(tabataScreenControllerProvider);
    final phaseColor = _phaseColor(progress.phase);

    return Center(
      child: Container(
        decoration: BoxDecoration(
          //#77767B
          color: Color(0xFF2a2b2e),
          border: Border.all(
            color: ColorScheme.of(context).onSurface,
            width: 4,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _phaseLabel(progress.phase),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: phaseColor,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _formatSeconds(progress.phaseRemaining),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              if (progress.phase != TabataPhase.finished &&
                  progress.phase != TabataPhase.prepare) ...[
                Text(
                  'Round ${progress.round}/${progress.totalRounds}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (progress.totalSets > 1)
                  Text(
                    'Set ${progress.set}/${progress.totalSets}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: 480,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: 1 - progress.phaseRemainingFraction,
                    minHeight: 12,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation(phaseColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
