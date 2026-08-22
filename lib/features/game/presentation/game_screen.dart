import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_screen/features/game/data/game_settings_repository.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameSettings = ref.watch(gameSettingsProvider);

    return gameSettings.when(
      data: (settings) {
        return Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ScoreDisplay(
                teamName: 'White',
                score: settings.whiteScore,
                teamColor: Colors.white,
                textColor: Colors.black,
              ),
              SizedBox(width: 100),
              _ScoreDisplay(
                teamName: 'Black',
                score: settings.blackScore,
                teamColor: Colors.black,
                textColor: Colors.white,
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
      ),
    );
  }
}

class _ScoreDisplay extends StatelessWidget {
  const _ScoreDisplay({
    required this.teamName,
    required this.score,
    required this.teamColor,
    required this.textColor,
  });

  final String teamName;
  final int score;
  final Color teamColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: 240,
      width: 150,
      decoration: BoxDecoration(
        color: teamColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor, width: 4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            teamName,
            style: textTheme.displaySmall?.copyWith(color: textColor),
          ),
          Text(
            score.toString(),
            style: textTheme.displayLarge?.copyWith(
              fontSize: 100,
              color: textColor,
              letterSpacing: -4,
            ),
          ),
        ],
      ),
    );
  }
}
