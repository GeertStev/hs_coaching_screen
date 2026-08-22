import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_screen/data/providers/clock_provider.dart';

/// A widget that displays the current time, updated every second.
///
/// It consumes the [clockProvider] to get the time string, making it a
/// simple, stateless, and efficient widget.
class Clock extends ConsumerWidget {
  const Clock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(clockProvider, (previous, next) {
      if (next.hasValue) {
        SchedulerBinding.instance.ensureVisualUpdate();
      }
    });

    // Watch the clock provider to get the current time string.
    final timeValue = ref.watch(clockProvider);

    // The `when` clause handles the different states of the stream.
    // We provide a fallback for the initial loading state.
    return timeValue.when(
      data: (timeString) =>
          Text(timeString, style: Theme.of(context).textTheme.titleLarge),
      loading: () => Text(
        '23:59:59', //ToDo Implement styling from settings
        style: Theme.of(context).textTheme.titleLarge,
      ), // Placeholder while the first tick arrives
      error: (err, stack) => const Text('Error'), // Fallback for any errors
    );
  }
}
