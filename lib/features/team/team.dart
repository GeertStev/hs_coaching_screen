import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/team/team_repository.dart';
import 'package:hs_coaching_screen/features/team/data/team_repository.dart';
import 'package:hs_coaching_screen/features/team/presentation/position_row.dart';
import 'package:hs_coaching_screen/common/widgets/async_content.dart';

/// A widget to display the team compositions, fetched via a provider.
class TeamDisplay extends ConsumerWidget {
  const TeamDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(teamUpdateListenerProvider);
    final teamsAsync = ref.watch(teamsProvider);
    return AsyncContent(
      value: teamsAsync,
      skipLoadingOnRefresh: false,
      data: (teams) {
        final whiteTeam = teams[0];
        final blackTeam = teams[1];
        return Padding(
          // ToDo Check top, bottom padding of 40
          // ToDo Colors!
          padding: const EdgeInsets.only(top: 0, bottom: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Divider(height: 6),
              PositionRow(
                label: 'Front',
                whitePlayers: whiteTeam.front,
                blackPlayers: blackTeam.front,
              ),
              const Divider(height: 6),
              PositionRow(
                label: 'Center',
                whitePlayers: whiteTeam.center,
                blackPlayers: blackTeam.center,
              ),
              const Divider(height: 6),
              PositionRow(
                label: 'Wing',
                whitePlayers: whiteTeam.wing,
                blackPlayers: blackTeam.wing,
              ),
              const Divider(height: 6),
              PositionRow(
                label: 'Goalie',
                whitePlayers: whiteTeam.goalie,
                blackPlayers: blackTeam.goalie,
              ),
              const Divider(height: 6),
            ],
          ),
        );
      },
      loading: () => const Center(child: LinearProgressIndicator()),
    );
  }
}
