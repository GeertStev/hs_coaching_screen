import 'package:flutter/foundation.dart';
import 'package:hs_coaching_core/match/engine/clock_view.dart';
import 'package:hs_coaching_core/match/engine/match_phase.dart';
import 'package:hs_coaching_core/match/engine/match_state.dart';
import 'package:hs_coaching_core/team/team_model.dart';

/// Hoeveel strafklokken per team zichtbaar zijn; de rest wordt "+n"
/// (03-wedstrijdtafel-ui.md §4.1).
const int maxVisiblePenalties = 3;

/// Wat de grote klok van het scorebord op dit moment aftelt.
enum ScoreboardClockMode {
  /// Vóór de wedstrijd: de klok toont de duur van de eerste periode.
  idle,
  running,
  stopped,

  /// Aftelling van een team time-out, in plaats van de wedstrijdklok.
  timeOut,

  /// Aftelling van de rust of een andere pauze.
  breakTime,
  finished,
}

/// Eén strafklok op het scorebord.
@immutable
class ScoreboardPenalty {
  const ScoreboardPenalty({
    required this.cap,
    required this.text,
    required this.waiting,
  });

  final int cap;

  /// Resterende tijd, of `OUT` voor een uitsluiting.
  final String text;

  /// De straf is om, maar de speler wacht nog op vrijgave.
  final bool waiting;

  @override
  bool operator ==(Object other) =>
      other is ScoreboardPenalty &&
      other.cap == cap &&
      other.text == text &&
      other.waiting == waiting;

  @override
  int get hashCode => Object.hash(cap, text, waiting);
}

/// Eén team op het scorebord.
@immutable
class ScoreboardTeam {
  const ScoreboardTeam({
    required this.color,
    required this.name,
    required this.score,
    required this.penalties,
    required this.hiddenPenalties,
  });

  final TeamColor color;
  final String name;
  final int score;

  /// Hooguit [maxVisiblePenalties] strafklokken.
  final List<ScoreboardPenalty> penalties;

  /// Aantal straffen dat niet meer getoond wordt ("+n").
  final int hiddenPenalties;

  @override
  bool operator ==(Object other) =>
      other is ScoreboardTeam &&
      other.color == color &&
      other.name == name &&
      other.score == score &&
      other.hiddenPenalties == hiddenPenalties &&
      listEquals(other.penalties, penalties);

  @override
  int get hashCode => Object.hash(
    color,
    name,
    score,
    hiddenPenalties,
    Object.hashAll(penalties),
  );
}

/// Alles wat het detailscorebord van één wedstrijd toont, als kant-en-klare
/// teksten. Puur afgeleid uit een [ClockView]: de klok wordt nooit hier
/// bijgehouden. Twee modellen zijn gelijk als het scherm er hetzelfde uitziet,
/// zodat de ticker alleen hertekent als er iets verandert.
@immutable
class ScoreboardModel {
  const ScoreboardModel({
    required this.created,
    required this.phaseLabel,
    required this.clockText,
    required this.clockMode,
    required this.statusLabel,
    required this.left,
    required this.right,
  });

  factory ScoreboardModel.from(ClockView clock) {
    final state = clock.state;
    final (mode, text) = _clock(clock);
    final leftColor = state.whiteOnLeft ? TeamColor.white : TeamColor.black;
    final rightColor = state.whiteOnLeft ? TeamColor.black : TeamColor.white;
    return ScoreboardModel(
      created: state.created,
      phaseLabel: scoreboardPhaseLabel(state.phase),
      clockText: text,
      clockMode: mode,
      statusLabel: _status(clock),
      left: _team(clock, leftColor),
      right: _team(clock, rightColor),
    );
  }

  /// `false` zolang de wedstrijd nog geen `MatchCreated` heeft.
  final bool created;
  final String phaseLabel;
  final String clockText;
  final ScoreboardClockMode clockMode;

  /// Korte regel onder de klok (time-out, strafworp, klok gestopt), of `null`.
  final String? statusLabel;

  /// Het team dat nu aan de linkerkant speelt; na de rust wisselen de teams
  /// van kant (14.2.2).
  final ScoreboardTeam left;
  final ScoreboardTeam right;

  @override
  bool operator ==(Object other) =>
      other is ScoreboardModel &&
      other.created == created &&
      other.phaseLabel == phaseLabel &&
      other.clockText == clockText &&
      other.clockMode == clockMode &&
      other.statusLabel == statusLabel &&
      other.left == left &&
      other.right == right;

  @override
  int get hashCode => Object.hash(
    created,
    phaseLabel,
    clockText,
    clockMode,
    statusLabel,
    left,
    right,
  );
}

/// `m:ss`, naar boven afgerond zodat een aftelling pas 0:00 toont als ze om
/// is (zelfde afronding als de wedstrijdtafel in de app).
String formatScoreboardClock(Duration duration, {bool countingDown = true}) {
  final millis = duration.inMilliseconds < 0 ? 0 : duration.inMilliseconds;
  final seconds = countingDown ? (millis + 999) ~/ 1000 : millis ~/ 1000;
  return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
}

String scoreboardPhaseLabel(MatchPhase phase) => switch (phase) {
  MatchPhase.notStarted => 'NOT STARTED',
  MatchPhase.p1 => 'PERIOD 1',
  MatchPhase.halfTime => 'HALF-TIME',
  MatchPhase.p2 => 'PERIOD 2',
  MatchPhase.otBreak || MatchPhase.otInterval || MatchPhase.sdBreak => 'BREAK',
  MatchPhase.ot1 => 'OVERTIME 1',
  MatchPhase.ot2 => 'OVERTIME 2',
  MatchPhase.suddenDeath => 'SUDDEN DEATH',
  MatchPhase.awaitingSignOff || MatchPhase.finalized => 'FULL TIME',
};

String _teamLabel(TeamColor team) =>
    team == TeamColor.white ? 'WHITE' : 'BLACK';

(ScoreboardClockMode, String) _clock(ClockView clock) {
  final state = clock.state;
  if (state.phase.isOver) return (ScoreboardClockMode.finished, 'FINAL');

  // Een team time-out vervangt de wedstrijdklok door haar aftelling.
  final timeOutRemaining = clock.timeOut?.remaining;
  if (timeOutRemaining != null) {
    return (
      ScoreboardClockMode.timeOut,
      formatScoreboardClock(timeOutRemaining),
    );
  }

  final breakRemaining = clock.breakRemaining;
  if (state.phase.isBreak && breakRemaining != null) {
    return (
      ScoreboardClockMode.breakTime,
      formatScoreboardClock(breakRemaining),
    );
  }

  if (state.phase == MatchPhase.notStarted) {
    final countdown = clock.periodStartCountdown;
    if (countdown != null) {
      return (ScoreboardClockMode.breakTime, formatScoreboardClock(countdown));
    }
    final length = state.config?.playLength(MatchPhase.p1);
    return (
      ScoreboardClockMode.idle,
      length == null ? '-:--' : formatScoreboardClock(length),
    );
  }

  final remaining = clock.periodRemaining;
  return (
    clock.running ? ScoreboardClockMode.running : ScoreboardClockMode.stopped,
    remaining != null
        ? formatScoreboardClock(remaining)
        // Sudden death telt op.
        : formatScoreboardClock(clock.periodElapsed, countingDown: false),
  );
}

String? _status(ClockView clock) {
  final state = clock.state;
  if (state.phase.isOver) {
    return switch (state.outcomeKind) {
      MatchOutcomeKind.forfeited => 'FORFEIT',
      MatchOutcomeKind.abandoned => 'ABANDONED',
      _ => null,
    };
  }
  final timeOut = clock.timeOut;
  if (timeOut != null) {
    final team = timeOut.team;
    return timeOut.kind == TimeOutKind.team && team != null
        ? 'TIME-OUT ${_teamLabel(team)}'
        : "OFFICIALS' TIME-OUT";
  }
  final shot = state.pendingPenaltyShot;
  if (shot != null) return 'PENALTY SHOT ${_teamLabel(shot)}';
  if (!state.phase.isPlay) return null;
  if (clock.periodExpired) return 'TIME UP';
  if (!clock.running) return 'CLOCK STOPPED';
  return null;
}

ScoreboardTeam _team(ClockView clock, TeamColor color) {
  final state = clock.state;
  final score = state.resultOverride ?? state.score;
  // In de strafbank, of voor de rest van de wedstrijd uitgesloten.
  final penalties = [
    for (final penalty in clock.penalties)
      if (penalty.team == color &&
          (penalty.inPenaltyBox || penalty.status == PenaltyStatus.dismissal))
        ScoreboardPenalty(
          cap: penalty.cap,
          text: penalty.status == PenaltyStatus.dismissal
              ? 'OUT'
              : formatScoreboardClock(penalty.remaining),
          waiting: penalty.status == PenaltyStatus.expiredWaiting,
        ),
  ];
  final visible = penalties.take(maxVisiblePenalties).toList();
  return ScoreboardTeam(
    color: color,
    name: color == TeamColor.white ? state.teamWhite : state.teamBlack,
    score: score.of(color),
    penalties: visible,
    hiddenPenalties: penalties.length - visible.length,
  );
}
