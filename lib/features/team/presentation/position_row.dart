import 'package:flutter/material.dart';
import 'package:hs_coaching_core/team/player_model.dart';
import 'package:hs_coaching_screen/features/team/presentation/position_card.dart';

class PositionRow extends StatelessWidget {
  const PositionRow({
    super.key,
    required this.label,
    required this.whitePlayers,
    required this.blackPlayers,
  });

  final String label;
  final List<Player> whitePlayers;
  final List<Player> blackPlayers;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            PositionCard(players: whitePlayers),
            Card(
              color: Theme.of(context).colorScheme.onPrimary,
              child: SizedBox(
                width: 75,
                height: 40,
                child: Center(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
              ),
            ),
            PositionCard(players: blackPlayers),
          ],
        ),
      ],
    );
  }
}
