import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/chrono/chrono.dart';
import 'package:hs_coaching_core/core/providers/server_time_offset_provider.dart';
import 'package:hs_coaching_screen/features/chrono/data/chrono_repository.dart';

/// Vertaalt de gesynchroniseerde [Chrono] state naar een lokaal tikkende
/// [Duration], klokdrift-gecorrigeerd via RTDB's `.info/serverTimeOffset`
/// (zelfde principe als de tabata-controller). Puur lezend — deze app
/// schrijft nooit naar `settings/chrono`.
class ChronoScreenController extends Notifier<Duration> {
  Timer? _timer;

  @override
  Duration build() {
    final chrono = ref.watch(chronoProvider).value ?? const Chrono();
    final offsetMillis = ref.watch(serverTimeOffsetProvider).value ?? 0;

    ref.onDispose(() => _timer?.cancel());
    _timer?.cancel();

    if (chrono.status == ChronoStatus.running) {
      _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
        final currentOffset = ref.read(serverTimeOffsetProvider).value ?? 0;
        state = _elapsed(chrono, currentOffset);
      });
    }

    return _elapsed(chrono, offsetMillis);
  }

  Duration _elapsed(Chrono chrono, double offsetMillis) {
    var elapsedMillis = chrono.accumulatedElapsedMillis;
    if (chrono.status == ChronoStatus.running) {
      elapsedMillis +=
          serverNowMillis(offsetMillis) - chrono.authoritativeStartTimeMillis;
    }
    return Duration(milliseconds: elapsedMillis);
  }
}

final chronoScreenControllerProvider =
    NotifierProvider<ChronoScreenController, Duration>(
      ChronoScreenController.new,
    );
