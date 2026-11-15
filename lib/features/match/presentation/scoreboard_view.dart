import 'package:flutter/material.dart';
import 'package:hs_coaching_core/team/team_model.dart';
import 'package:hs_coaching_screen/features/match/presentation/scoreboard_model.dart';
import 'package:hs_coaching_screen/features/match/presentation/scoreboard_theme.dart';

/// Vaste maten van het scorebord. Het wordt getekend op een canvas van 416
/// hoog met de breedte volgens de verhouding van het scherm, en schaalt dan
/// als geheel: 624×416 en 1920×1080 tonen dus dezelfde layout.
abstract final class ScoreboardLayout {
  static const double height = 416;

  /// Breedte bij 3:2 (het zwembaddisplay).
  static const double designWidth = 624;
  static const double minWidth = 560;
  static const double maxWidth = 1000;

  static double canvasWidthFor(Size area) {
    if (area.width <= 0 || area.height <= 0) return designWidth;
    return (height * area.width / area.height).clamp(minWidth, maxWidth);
  }

  static const double pad = 12;
  static const double frameWidth = 4;
  static const double frameRadius = 12;

  static const double headerHeight = 52;

  /// De klokrij neemt de rest van de hoogte (≥ 35 % van het scherm, 03 §4.1):
  /// 416 − 2×12 − 52 − 36 − 84 − 3×6 = 202.
  static const double statusHeight = 36;
  static const double penaltyHeight = 84;
  static const double gap = 6;

  /// Breedte van een scorekolom links en rechts van de klok.
  static const double scoreWidth = 108;
  static const double capSize = 30;
  static const double penaltyGap = 5;
  static const double penaltyRadius = 10;
  static const double clockRadius = 14;
}

/// Past het scorebord in de beschikbare ruimte: canvas van 416 hoog, breedte
/// volgens de verhouding, als geheel geschaald.
class ScaledScoreboard extends StatelessWidget {
  const ScaledScoreboard({super.key, required this.builder});

  final Widget Function(double canvasWidth) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = ScoreboardLayout.canvasWidthFor(constraints.biggest);
        return SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: width,
              height: ScoreboardLayout.height,
              child: builder(width),
            ),
          ),
        );
      },
    );
  }
}

/// Kader en achtergrond van het canvas.
class ScoreboardFrame extends StatelessWidget {
  const ScoreboardFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = ScoreboardTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.background,
        border: Border.all(
          color: theme.frame,
          width: ScoreboardLayout.frameWidth,
        ),
        borderRadius: BorderRadius.circular(ScoreboardLayout.frameRadius),
      ),
      padding: const EdgeInsets.all(ScoreboardLayout.pad),
      child: child,
    );
  }
}

/// Eén regel tekst in het midden van het canvas (bv. tussen twee wedstrijden).
class ScoreboardMessage extends StatelessWidget {
  const ScoreboardMessage({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = ScoreboardTheme.of(context);
    final subtitle = this.subtitle;
    return ScoreboardFrame(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.label(theme.messageSize, theme.textPrimary),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: ScoreboardLayout.gap),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: theme.label(theme.statusSize, theme.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Het detailscorebord van één wedstrijd (03-wedstrijdtafel-ui.md §4.1), op
/// het canvas van [ScoreboardLayout]. Tekent alleen wat in [model] staat.
class ScoreboardView extends StatelessWidget {
  const ScoreboardView({super.key, required this.model});

  final ScoreboardModel model;

  @override
  Widget build(BuildContext context) {
    final theme = ScoreboardTheme.of(context);
    return ScoreboardFrame(
      child: Column(
        children: [
          SizedBox(
            height: ScoreboardLayout.headerHeight,
            child: Row(
              children: [
                Expanded(child: _TeamName(team: model.left, onLeft: true)),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ScoreboardLayout.gap * 2,
                  ),
                  child: Text(
                    model.phaseLabel,
                    style: theme.label(theme.phaseSize, theme.textMuted),
                  ),
                ),
                Expanded(child: _TeamName(team: model.right, onLeft: false)),
              ],
            ),
          ),
          const SizedBox(height: ScoreboardLayout.gap),
          Expanded(
            child: Row(
              children: [
                _Score(model.left.score),
                Expanded(child: _Clock(model: model)),
                _Score(model.right.score),
              ],
            ),
          ),
          const SizedBox(height: ScoreboardLayout.gap),
          SizedBox(
            height: ScoreboardLayout.statusHeight,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  model.statusLabel ?? '',
                  key: const ValueKey('scoreboard-status'),
                  style: theme.label(theme.statusSize, theme.status),
                ),
              ),
            ),
          ),
          const SizedBox(height: ScoreboardLayout.gap),
          SizedBox(
            height: ScoreboardLayout.penaltyHeight,
            child: Row(
              children: [
                Expanded(child: _Penalties(team: model.left, onLeft: true)),
                const SizedBox(width: ScoreboardLayout.gap * 2),
                Expanded(child: _Penalties(team: model.right, onLeft: false)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamName extends StatelessWidget {
  const _TeamName({required this.team, required this.onLeft});

  final ScoreboardTeam team;
  final bool onLeft;

  @override
  Widget build(BuildContext context) {
    final theme = ScoreboardTheme.of(context);
    final white = team.color == TeamColor.white;
    final cap = Container(
      width: ScoreboardLayout.capSize,
      height: ScoreboardLayout.capSize,
      decoration: BoxDecoration(
        color: theme.capColor(white: white),
        shape: BoxShape.circle,
        border: Border.all(color: theme.capBorder, width: 2),
      ),
    );
    final name = Flexible(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: onLeft ? Alignment.centerLeft : Alignment.centerRight,
        child: Text(
          team.name,
          maxLines: 1,
          style: theme.label(theme.teamNameSize, theme.textPrimary),
        ),
      ),
    );
    const space = SizedBox(width: ScoreboardLayout.gap + 2);
    return Row(
      mainAxisAlignment: onLeft
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      children: onLeft ? [cap, space, name] : [name, space, cap],
    );
  }
}

class _Score extends StatelessWidget {
  const _Score(this.score);

  final int score;

  @override
  Widget build(BuildContext context) {
    final theme = ScoreboardTheme.of(context);
    return SizedBox(
      width: ScoreboardLayout.scoreWidth,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          '$score',
          style: theme.numbers(theme.scoreSize, theme.textPrimary),
        ),
      ),
    );
  }
}

class _Clock extends StatelessWidget {
  const _Clock({required this.model});

  final ScoreboardModel model;

  @override
  Widget build(BuildContext context) {
    final theme = ScoreboardTheme.of(context);
    final color = switch (model.clockMode) {
      ScoreboardClockMode.running => theme.clockRunning,
      ScoreboardClockMode.timeOut => theme.clockTimeOut,
      ScoreboardClockMode.breakTime => theme.clockBreak,
      ScoreboardClockMode.idle ||
      ScoreboardClockMode.stopped ||
      ScoreboardClockMode.finished => theme.clockStopped,
    };
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: ScoreboardLayout.gap),
      padding: const EdgeInsets.symmetric(horizontal: ScoreboardLayout.gap * 2),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(ScoreboardLayout.clockRadius),
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          model.clockText,
          key: const ValueKey('scoreboard-clock'),
          style: theme.numbers(theme.clockSize, color),
        ),
      ),
    );
  }
}

class _Penalties extends StatelessWidget {
  const _Penalties({required this.team, required this.onLeft});

  final ScoreboardTeam team;
  final bool onLeft;

  @override
  Widget build(BuildContext context) {
    final theme = ScoreboardTheme.of(context);
    final chips = <Widget>[
      for (final penalty in team.penalties)
        Expanded(
          child: _PenaltyChip(penalty: penalty, teamColor: team.color),
        ),
      // Lege plaatsen, zodat een strafklok altijd even breed is.
      for (var i = team.penalties.length; i < maxVisiblePenalties; i++)
        const Expanded(child: SizedBox.shrink()),
    ];
    final more = SizedBox(
      width: team.hiddenPenalties > 0 ? 44 : 0,
      child: team.hiddenPenalties > 0
          ? FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '+${team.hiddenPenalties}',
                style: theme.numbers(theme.penaltyTimeSize, theme.textPrimary),
              ),
            )
          : null,
    );
    // De strafklokken staan aan de buitenkant, bij hun team.
    final ordered = onLeft ? chips : chips.reversed.toList();
    final children = <Widget>[];
    for (final chip in ordered) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(width: ScoreboardLayout.penaltyGap));
      }
      children.add(chip);
    }
    return Row(children: onLeft ? [...children, more] : [more, ...children]);
  }
}

class _PenaltyChip extends StatelessWidget {
  const _PenaltyChip({required this.penalty, required this.teamColor});

  final ScoreboardPenalty penalty;
  final TeamColor teamColor;

  @override
  Widget build(BuildContext context) {
    final theme = ScoreboardTheme.of(context);
    final white = teamColor == TeamColor.white;
    final waiting = penalty.waiting;
    return Container(
      decoration: BoxDecoration(
        color: waiting ? theme.penaltyWaiting : theme.penaltySurface,
        border: Border.all(
          color: waiting ? theme.penaltyWaiting : theme.penaltyBorder,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(ScoreboardLayout.penaltyRadius),
      ),
      padding: const EdgeInsets.all(4),
      alignment: Alignment.center,
      // Kap boven, tijd onder: zo blijft de tijd groot in een smal vakje.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: ScoreboardLayout.capSize,
              height: ScoreboardLayout.capSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.capColor(white: white),
                shape: BoxShape.circle,
                border: Border.all(color: theme.capBorder, width: 2),
              ),
              child: Text(
                '${penalty.cap}',
                style: theme.numbers(
                  theme.penaltyCapSize,
                  theme.onCapColor(white: white),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              penalty.text,
              style: theme.numbers(
                theme.penaltyTimeSize,
                waiting ? theme.onPenaltyWaiting : theme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
