import 'package:flutter/material.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/pool_display_theme.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/pool_chip.dart';
import 'package:hs_coaching_screen/features/training/presentation/pool/widgets/pool_labels.dart';

/// Rij boven de lijnen (spec §4.3): herhalingen links, werk/rust van de
/// huidige herhaling in het midden, Δ rechts. Een kolom blijft leeg als ze
/// niet van toepassing is.
class SpecRow extends StatelessWidget {
  const SpecRow({
    super.key,
    required this.repetitions,
    required this.workSeconds,
    required this.restSeconds,
    required this.deltaSeconds,
    this.small = false,
  });

  final int repetitions;
  final int workSeconds;
  final int restSeconds;
  final int deltaSeconds;

  /// Kleine variant in de Daarna-kaart.
  final bool small;

  @override
  Widget build(BuildContext context) {
    final theme = PoolDisplayTheme.of(context);
    final texts = [
      repetitions > 1 ? '$repetitions×' : '',
      formatWorkRest(workSeconds, restSeconds),
      formatDelta(deltaSeconds),
    ];
    const alignments = [
      Alignment.centerLeft,
      Alignment.center,
      Alignment.centerRight,
    ];
    return SizedBox(
      height: small ? 24 : 28,
      child: Row(
        children: [
          for (var i = 0; i < 3; i++)
            Expanded(
              child: Align(
                alignment: alignments[i],
                child: texts[i].isEmpty
                    ? null
                    : PoolChip(
                        text: texts[i],
                        style: theme.label(
                          small ? 16 : 21,
                          weight: FontWeight.w700,
                        ),
                        background: theme.chipSurface,
                        borderColor: theme.chipBorder,
                        padding: EdgeInsets.symmetric(
                          horizontal: small ? 10 : 12,
                          vertical: small ? 3 : 2.5,
                        ),
                        radius: small ? 7 : 8,
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
