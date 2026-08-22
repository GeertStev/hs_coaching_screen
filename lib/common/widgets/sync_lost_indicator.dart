import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/core/providers/server_connection_provider.dart';

/// Toont een waarschuwing zodra de verbinding met Firebase wegvalt.
/// Onzichtbaar zolang [serverConnectionProvider] `true` is.
class SyncLostIndicator extends ConsumerWidget {
  const SyncLostIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connected = ref.watch(serverConnectionProvider).value ?? false;
    if (connected) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2b2e),
        border: Border.all(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sync_problem, color: Colors.red, size: 20),
          SizedBox(width: 6),
          Text(
            'Sync lost',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
