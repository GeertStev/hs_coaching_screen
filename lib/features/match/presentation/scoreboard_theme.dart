import 'package:flutter/material.dart';

/// Alle kleuren en typografie van het wedstrijdscorebord op één plek
/// (03-wedstrijdtafel-ui.md §4.1). Ze zijn **voorlopig**: om ze later af te
/// stemmen op het stijlbestand van de app verander je alleen de waarden hier,
/// niet de layout (`scoreboard_view.dart`). Widgets van het scorebord
/// gebruiken nooit een losse kleur of lettergrootte.
///
/// De waarden volgen nu het trainingsscherm (`PoolDisplayTheme`): grijze
/// vlakken, goud voor wat loopt, lichtblauw voor pauzes. Geen groen.
@immutable
class ScoreboardTheme extends ThemeExtension<ScoreboardTheme> {
  const ScoreboardTheme({
    required this.background,
    required this.frame,
    required this.surface,
    required this.textPrimary,
    required this.textMuted,
    required this.clockRunning,
    required this.clockStopped,
    required this.clockTimeOut,
    required this.clockBreak,
    required this.status,
    required this.capWhite,
    required this.onCapWhite,
    required this.capBlack,
    required this.onCapBlack,
    required this.capBorder,
    required this.penaltySurface,
    required this.penaltyBorder,
    required this.penaltyWaiting,
    required this.onPenaltyWaiting,
    this.fontFamily,
    this.teamNameSize = 30,
    this.phaseSize = 24,
    this.scoreSize = 120,
    this.clockSize = 156,
    this.statusSize = 24,
    this.penaltyCapSize = 19,
    this.penaltyTimeSize = 32,
    this.messageSize = 30,
  });

  static const standard = ScoreboardTheme(
    background: Color(0xFF1E2020),
    frame: Color(0xFF444653),
    surface: Color(0xFF2A2B2E),
    textPrimary: Color(0xFFF2F2F2),
    textMuted: Color(0xFF8E909F),
    clockRunning: Color(0xFFFEBA2F),
    clockStopped: Color(0xFFF2F2F2),
    clockTimeOut: Color(0xFFB7C4FF),
    clockBreak: Color(0xFFB7C4FF),
    status: Color(0xFFB7C4FF),
    capWhite: Color(0xFFFFFFFF),
    onCapWhite: Color(0xFF121414),
    capBlack: Color(0xFF000000),
    onCapBlack: Color(0xFFFFFFFF),
    capBorder: Color(0xFF8E909F),
    penaltySurface: Color(0xFF333535),
    penaltyBorder: Color(0xFF444653),
    penaltyWaiting: Color(0xFFFEBA2F),
    onPenaltyWaiting: Color(0xFF422C00),
  );

  static ScoreboardTheme of(BuildContext context) =>
      Theme.of(context).extension<ScoreboardTheme>() ?? standard;

  final Color background;

  /// Kader rond het scorebord.
  final Color frame;

  /// Vak achter de klok.
  final Color surface;
  final Color textPrimary;
  final Color textMuted;

  /// Kleur van de grote klok per toestand.
  final Color clockRunning;
  final Color clockStopped;
  final Color clockTimeOut;
  final Color clockBreak;

  /// Statusregel onder de klok (time-out, strafworp, klok gestopt).
  final Color status;

  /// Kapkleur van de teams en de tekst erop.
  final Color capWhite;
  final Color onCapWhite;
  final Color capBlack;
  final Color onCapBlack;
  final Color capBorder;

  /// Strafklok; [penaltyWaiting] als de speler op vrijgave wacht.
  final Color penaltySurface;
  final Color penaltyBorder;
  final Color penaltyWaiting;
  final Color onPenaltyWaiting;

  /// `null` = het standaardfont van het scherm.
  final String? fontFamily;

  /// Lettergroottes op het ontwerpcanvas van 416 hoog.
  final double teamNameSize;
  final double phaseSize;
  final double scoreSize;
  final double clockSize;
  final double statusSize;
  final double penaltyCapSize;
  final double penaltyTimeSize;
  final double messageSize;

  /// Cijfers met een vaste breedte, zodat de klok niet verspringt.
  TextStyle numbers(double size, Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: size,
    height: 1,
    fontWeight: FontWeight.w700,
    color: color,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  TextStyle label(double size, Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: size,
    height: 1.1,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: color,
  );

  Color capColor({required bool white}) => white ? capWhite : capBlack;
  Color onCapColor({required bool white}) => white ? onCapWhite : onCapBlack;

  @override
  ScoreboardTheme copyWith({String? fontFamily}) => ScoreboardTheme(
    background: background,
    frame: frame,
    surface: surface,
    textPrimary: textPrimary,
    textMuted: textMuted,
    clockRunning: clockRunning,
    clockStopped: clockStopped,
    clockTimeOut: clockTimeOut,
    clockBreak: clockBreak,
    status: status,
    capWhite: capWhite,
    onCapWhite: onCapWhite,
    capBlack: capBlack,
    onCapBlack: onCapBlack,
    capBorder: capBorder,
    penaltySurface: penaltySurface,
    penaltyBorder: penaltyBorder,
    penaltyWaiting: penaltyWaiting,
    onPenaltyWaiting: onPenaltyWaiting,
    fontFamily: fontFamily ?? this.fontFamily,
    teamNameSize: teamNameSize,
    phaseSize: phaseSize,
    scoreSize: scoreSize,
    clockSize: clockSize,
    statusSize: statusSize,
    penaltyCapSize: penaltyCapSize,
    penaltyTimeSize: penaltyTimeSize,
    messageSize: messageSize,
  );

  // Er is maar één thema: geen overgang nodig.
  @override
  ScoreboardTheme lerp(ScoreboardTheme? other, double t) =>
      other == null || t < 0.5 ? this : other;
}
