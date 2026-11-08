import 'package:flutter/material.dart';

/// Alle kleuren en lettertypes van het zwembadscherm voor Training, als
/// semantische tokens (spec §7). Widgets lezen **alleen** hieruit — geen
/// losse kleur of font in een widget — zodat het later aligneren met het
/// stijlbestand van de coaching app één wijziging op deze plek is: verander
/// dan de tokenwaarden, niet de layout of de maten (`pool_layout.dart`).
///
/// "Nu", "straks" en "gedaan" verschillen ook in vorm (gevuld, ring, hol,
/// vinkje), niet alleen in kleur; behoud dat bij het herkleuren.
@immutable
class PoolDisplayTheme extends ThemeExtension<PoolDisplayTheme> {
  const PoolDisplayTheme({
    required this.background,
    required this.frame,
    required this.surface,
    required this.surfaceRow,
    required this.rowBorder,
    required this.nextSurface,
    required this.nextBorder,
    required this.nextRow,
    required this.chipSurface,
    required this.chipBorder,
    required this.chipBorderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textFaint,
    required this.nextRowText,
    required this.now,
    required this.next,
    required this.work,
    required this.onWork,
    required this.rest,
    required this.onRest,
    required this.paused,
    required this.onPaused,
    required this.done,
    required this.doneCheck,
    required this.upcoming,
    required this.progressTrack,
    required this.envAbove,
    required this.onEnvAbove,
    required this.envUnder,
    required this.onEnvUnder,
    required this.envUnderBorder,
    required this.groupColors,
    required this.onGroup,
    this.labelFontFamily,
    this.numberFontFamily,
  });

  /// Afgestemd op de rest van het scherm en de app (2026-11-07): neutrale
  /// grijze vlakken zoals de chrono/tabata-kaders en `AppColorsDark` van de
  /// app, goud (`#FEBA2F`, app `secondary`) voor "nu" en werk, lichtblauw
  /// (app `primary`) voor rust, clubblauw (`#0033AA`) voor onder water, een
  /// gouden kader zoals de chrono. Geen groen (app-regel).
  static const standard = PoolDisplayTheme(
    background: Color(0xFF1E2020),
    frame: Color(0xFF444653), //0xFFEDBA20
    surface: Color(0xFF2A2B2E),
    surfaceRow: Color(0xFF333535),
    rowBorder: Color(0xFF444653),
    nextSurface: Color(0xFF1A1C1C),
    nextBorder: Color(0xFF333535),
    nextRow: Color(0xFF282A2B),
    chipSurface: Color(0xFF282A2B),
    chipBorder: Color(0xFF444653),
    chipBorderStrong: Color(0xFF8E909F),
    textPrimary: Color(0xFFF2F2F2),
    textSecondary: Color(0xFFC4C5D6),
    textMuted: Color(0xFF8E909F),
    textFaint: Color(0xFF63656F),
    nextRowText: Color(0xFFE2E2E2),
    now: Color(0xFFFEBA2F),
    next: Color(0xFFB7C4FF),
    work: Color(0xFFFEBA2F),
    onWork: Color(0xFF422C00),
    rest: Color(0xFFB7C4FF),
    onRest: Color(0xFF002583),
    paused: Color(0xFF8E909F),
    onPaused: Color(0xFF121414),
    done: Color(0xFF5C5E6A),
    doneCheck: Color(0xFFE2E2E2),
    upcoming: Color(0xFF8E909F),
    progressTrack: Color(0xFF333535),
    envAbove: Color(0xFF282A2B),
    onEnvAbove: Color(0xFFDDE1FF),
    envUnder: Color(0xFF0033AA),
    onEnvUnder: Color(0xFFFFFFFF),
    envUnderBorder: Color(0xFF3354C8),
    groupColors: [Color(0xFFB3261E), Color(0xFF0F3AB0)],
    onGroup: Color(0xFFFFFFFF),
  );

  static PoolDisplayTheme of(BuildContext context) =>
      Theme.of(context).extension<PoolDisplayTheme>() ?? standard;

  final Color background;

  /// Kader rond het hele canvas (zoals de chrono- en tabata-kaders).
  final Color frame;

  /// Timervak, kruimelchips.
  final Color surface;

  /// Lijnrij (en haar rand).
  final Color surfaceRow;
  final Color rowBorder;

  /// Gedempte Daarna-kaart.
  final Color nextSurface;
  final Color nextBorder;
  final Color nextRow;

  /// Techniek- en specificatiechips; [chipBorderStrong] in de grote rijen.
  final Color chipSurface;
  final Color chipBorder;
  final Color chipBorderStrong;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textFaint;
  final Color nextRowText;

  /// Positie "nu" (bolletjes, track, voortgangsbalk).
  final Color now;

  /// "Straks" (volgend bolletje, spookchip, Daarna-label en -pill).
  final Color next;

  final Color work;
  final Color onWork;
  final Color rest;
  final Color onRest;
  final Color paused;
  final Color onPaused;

  /// Gedaan bolletje en lijntje, met [doneCheck] als vinkje.
  final Color done;
  final Color doneCheck;

  /// Nog te komen (holle bolletjes).
  final Color upcoming;
  final Color progressTrack;

  /// Omgeving: boven water (ook HaBo) en onder water.
  final Color envAbove;
  final Color onEnvAbove;
  final Color envUnder;
  final Color onEnvUnder;
  final Color envUnderBorder;

  /// Kleur per groep van een group split, op volgorde (de namen komen uit de
  /// data; de kleuren hier zijn voorbeeldkleuren).
  final List<Color> groupColors;
  final Color onGroup;

  /// `null` = het standaardlettertype van de app.
  final String? labelFontFamily;
  final String? numberFontFamily;

  Color groupColor(int index) => groupColors[index % groupColors.length];

  /// Tekststijl voor labels en titels.
  TextStyle label(
    double size, {
    FontWeight weight = FontWeight.w600,
    Color? color,
    double letterSpacing = 0,
  }) => TextStyle(
    fontFamily: labelFontFamily,
    fontSize: size,
    fontWeight: weight,
    color: color ?? textPrimary,
    letterSpacing: letterSpacing * size,
    height: 1,
  );

  /// Tekststijl voor cijfers, timers en lijnen.
  TextStyle number(double size, {Color? color}) => TextStyle(
    fontFamily: numberFontFamily,
    fontSize: size,
    fontWeight: FontWeight.w700,
    color: color ?? textPrimary,
    height: 1,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  @override
  PoolDisplayTheme copyWith({
    Color? background,
    Color? surface,
    Color? now,
    Color? next,
    Color? work,
    Color? rest,
    String? labelFontFamily,
    String? numberFontFamily,
  }) => PoolDisplayTheme(
    background: background ?? this.background,
    frame: frame,
    surface: surface ?? this.surface,
    surfaceRow: surfaceRow,
    rowBorder: rowBorder,
    nextSurface: nextSurface,
    nextBorder: nextBorder,
    nextRow: nextRow,
    chipSurface: chipSurface,
    chipBorder: chipBorder,
    chipBorderStrong: chipBorderStrong,
    textPrimary: textPrimary,
    textSecondary: textSecondary,
    textMuted: textMuted,
    textFaint: textFaint,
    nextRowText: nextRowText,
    now: now ?? this.now,
    next: next ?? this.next,
    work: work ?? this.work,
    onWork: onWork,
    rest: rest ?? this.rest,
    onRest: onRest,
    paused: paused,
    onPaused: onPaused,
    done: done,
    doneCheck: doneCheck,
    upcoming: upcoming,
    progressTrack: progressTrack,
    envAbove: envAbove,
    onEnvAbove: onEnvAbove,
    envUnder: envUnder,
    onEnvUnder: onEnvUnder,
    envUnderBorder: envUnderBorder,
    groupColors: groupColors,
    onGroup: onGroup,
    labelFontFamily: labelFontFamily ?? this.labelFontFamily,
    numberFontFamily: numberFontFamily ?? this.numberFontFamily,
  );

  // Het scherm wisselt nooit geanimeerd van thema.
  @override
  PoolDisplayTheme lerp(PoolDisplayTheme? other, double t) =>
      t < 0.5 || other == null ? this : other;
}
