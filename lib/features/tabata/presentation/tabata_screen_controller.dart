import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/core/providers/server_time_offset_provider.dart';
import 'package:hs_coaching_core/tabata/tabata.dart';
import 'package:hs_coaching_core/tabata/tabata_progress.dart';
import 'package:hs_coaching_screen/features/tabata/data/tabata_repository.dart';

/// Vertaalt de gesynchroniseerde [Tabata] state naar een lokaal tikkende
/// [TabataProgress], klokdrift-gecorrigeerd via RTDB's
/// `.info/serverTimeOffset`. Puur lezend — deze app schrijft nooit naar
/// `settings/tabata`.
class TabataScreenController extends Notifier<TabataProgress> {
  Timer? _timer;

  @override
  TabataProgress build() {
    final tabata = ref.watch(tabataProvider).value ?? const Tabata();
    final offsetMillis = ref.watch(serverTimeOffsetProvider).value ?? 0;

    ref.onDispose(() => _timer?.cancel());
    _timer?.cancel();

    final progress = tabata.progressAt(_elapsedMillis(tabata, offsetMillis));

    if (tabata.status == TabataStatus.running &&
        progress.phase != TabataPhase.finished) {
      _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        final currentOffset = ref.read(serverTimeOffsetProvider).value ?? 0;
        final tickProgress = tabata.progressAt(
          _elapsedMillis(tabata, currentOffset),
        );
        state = tickProgress;
        if (tickProgress.phase == TabataPhase.finished) {
          _timer?.cancel();
        }
      });
    }

    return progress;
  }

  int _elapsedMillis(Tabata tabata, double offsetMillis) {
    var elapsedMillis = tabata.accumulatedElapsedMillis;
    if (tabata.status == TabataStatus.running) {
      elapsedMillis +=
          serverNowMillis(offsetMillis) - tabata.authoritativeStartTimeMillis;
    }
    return elapsedMillis;
  }
}

final tabataScreenControllerProvider =
    NotifierProvider<TabataScreenController, TabataProgress>(
      TabataScreenController.new,
    );
