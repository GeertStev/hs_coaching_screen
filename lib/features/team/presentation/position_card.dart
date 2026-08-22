import 'package:flutter/material.dart';
import 'package:hs_coaching_core/team/player_model.dart';

class PositionCard extends StatelessWidget {
  const PositionCard({super.key, required this.players});

  final List<Player> players;

  Widget _buildPlayerName(BuildContext context, Player player) {
    // Using a theme for styling is better for consistency.
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2a2b2e),
        border: Border.all(
          color: ColorScheme.of(context).onSurface,
          width: 1,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        borderRadius: BorderRadius.circular(12),
      ),

      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          player.name,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge!.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLayout(BuildContext context) {
    switch (players.length) {
      case 1:
        return Center(child: _buildPlayerName(context, players[0]));
      case 2:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: players.map((p) => _buildPlayerName(context, p)).toList(),
        );
      case 3:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPlayerName(context, players[0]),
                _buildPlayerName(context, players[1]),
              ],
            ),
            const SizedBox(height: 8),
            _buildPlayerName(context, players[2]),
          ],
        );
      case 4:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPlayerName(context, players[0]),
                _buildPlayerName(context, players[1]),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPlayerName(context, players[2]),
                _buildPlayerName(context, players[3]),
              ],
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(child: _buildLayout(context));
  }
}
