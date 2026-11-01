/// Vaste maten van het zwembadscherm voor Training (spec §4). De layout,
/// de zones en de vijf-kolommen-grid van een lijnrij zijn op elk scherm
/// identiek; dat is het hoofdpunt van het ontwerp. Kleuren en fonts staan
/// apart in `pool_display_theme.dart`.
abstract final class PoolLayout {
  /// Ontwerpcanvas; het scherm schaalt dit als geheel in zijn content-vak.
  static const double width = 624;
  static const double height = 416;

  static const double padTop = 20;
  static const double padSide = 16;
  static const double padBottom = 14;
  static const double zoneGap = 10;

  static const double progressBarHeight = 6;
  static const double lengthsLabelTop = 12;
  static const double lengthsLabelSize = 13;

  static const double breadcrumbHeight = 60;
  static const double middleHeight = 196;
  static const double nextHeight = 106;

  /// Breedte van de linkerkolom (timervak, Daarna-label) en de ruimte
  /// ernaast.
  static const double leftColumn = 226;
  static const double columnGap = 14;

  /// De vijf kolommen van elke lijnrij: aantal, afstand, techniek,
  /// inspanning, omgeving.
  static const List<int> lineColumnFlex = [9, 13, 9, 7, 11];

  static const double titleSize = 17;
}

/// Maten van een lijnrij in één context (spec §4.4).
class LineRowMetrics {
  const LineRowMetrics({
    required this.height,
    required this.number,
    required this.chip,
    required this.effort,
    required this.bordered,
    required this.radius,
    required this.horizontalPadding,
  });

  /// 2 lijnen in het lijnenvak.
  static const large = LineRowMetrics(
    height: 76,
    number: 44,
    chip: 22,
    effort: 34,
    bordered: true,
    radius: 12,
    horizontalPadding: 8,
  );

  /// 4 lijnen (warmup) en group split, nu.
  static const medium = LineRowMetrics(
    height: 36,
    number: 28,
    chip: 17,
    effort: 24,
    bordered: true,
    radius: 10,
    horizontalPadding: 8,
  );

  /// Daarna, gewone oefening.
  static const next = LineRowMetrics(
    height: 26,
    number: 20,
    chip: 13,
    effort: 17,
    bordered: false,
    radius: 8,
    horizontalPadding: 6,
  );

  /// Daarna, group split (twee kolommen).
  static const nextSplit = LineRowMetrics(
    height: 26,
    number: 17,
    chip: 11.5,
    effort: 15,
    bordered: false,
    radius: 8,
    horizontalPadding: 4,
  );

  final double height;
  final double number;
  final double chip;
  final double effort;
  final bool bordered;
  final double radius;
  final double horizontalPadding;

  /// Rijen in het lijnenvak: tussen [medium] (36) en [large] (76) volgens de
  /// beschikbare hoogte; lettergroottes schalen lineair mee.
  static LineRowMetrics forHeight(double height) {
    if (height >= large.height) return large;
    if (height <= medium.height) return medium._scaled(height);
    final t = (height - medium.height) / (large.height - medium.height);
    double mix(double a, double b) => a + (b - a) * t;
    return LineRowMetrics(
      height: height,
      number: mix(medium.number, large.number),
      chip: mix(medium.chip, large.chip),
      effort: mix(medium.effort, large.effort),
      bordered: true,
      radius: mix(medium.radius, large.radius),
      horizontalPadding: 8,
    );
  }

  /// Kleiner dan de ontwerpmaat (meer lijnen dan voorzien): alles schaalt.
  LineRowMetrics fitHeight(double available) =>
      available >= height ? this : _scaled(available);

  LineRowMetrics _scaled(double newHeight) {
    final f = newHeight / height;
    return LineRowMetrics(
      height: newHeight,
      number: number * f,
      chip: chip * f,
      effort: effort * f,
      bordered: bordered,
      radius: radius * f,
      horizontalPadding: horizontalPadding,
    );
  }
}
