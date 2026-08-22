import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_screen/features/chrono/presentation/chrono_screen_controller.dart';

class ChronoScreen extends ConsumerWidget {
  const ChronoScreen({super.key});

  String _formatDuration(Duration d) {
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
    final elapsed = ref.watch(chronoScreenControllerProvider);

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
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _formatDuration(elapsed),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontFamily: 'monospace',
              fontSize: 120,
              fontWeight: FontWeight.bold,
              color: (elapsed.isNegative) ? Colors.red : Color(0xFFFEBA2F),
            ),
          ),
        ),
      ),
    );
  }
}
