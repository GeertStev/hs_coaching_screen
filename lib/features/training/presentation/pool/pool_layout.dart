import 'dart:ui' show Size;

/// Vaste maten van het zwembadscherm voor Training (spec §4). De layout,
/// de zones en de vijf-kolommen-grid van een lijnrij zijn op elk scherm
/// identiek; dat is het hoofdpunt van het ontwerp. Kleuren en fonts staan
/// apart in `pool_display_theme.dart`.
abstract final class PoolLayout {
  /// Ontwerpcanvas. De hoogte ligt vast (alle zones hebben een vaste
  /// hoogte); de breedte volgt de verhouding van het content-vak, zodat een
  /// breder vak (bv. fullscreen 16:9) volledig benut wordt. Het canvas
  /// schaalt daarna als geheel naar de echte pixels.
  static const double height = 416;

  /// Breedte van het oorspronkelijke ontwerp (3:2).
  static const double designWidth = 624;

  /// Smaller past de layout niet (timervak + lijnen); breder worden de
  /// lijnen onleesbaar lang. Daarbuiten komen er randen naast/boven.
  static const double minWidth = 560;
  static const double maxWidth = 1000;

  /// Canvasbreedte voor een content-vak van [area] (in eender welke
  /// eenheid): dezelfde verhouding, begrensd tot [minWidth]..[maxWidth].
  static double canvasWidthFor(Size area) {
    if (area.width <= 0 || area.height <= 0) return designWidth;
    return (height * area.width / area.height).clamp(minWidth, maxWidth);
  }

  static const double padTop = 12;
  static const double padSide = 16;
  static const double padBottom = 12;
  static const double zoneGap = 10;

  /// Kader rond het canvas, over de padding heen getekend.
  static const double frameWidth = 4;
  static const double frameRadius = 12;

  /// Voortgangsbalk met balkjes per oefening, gegroepeerd per set/subset.
  static const double progressHeight = 70;
  static const double middleHeight = 196;

  /// Het brede vak onderaan met de volgende oefening.
  static const double upcomingHeight = 106;

  /// Kruimelrij van [BreadcrumbRow]; die widget wordt nu niet getoond.
  static const double breadcrumbHeight = 60;
  static const double titleSize = 17;

  /// Lijnen hebben een vaste hoogte alsof er zoveel lijnen zijn; pas bij
  /// meer lijnen schalen ze kleiner.
  static const int lineSlots = 5;
  static const double lineGap = 6;
  static const double upcomingLineGap = 3;

  /// Linkerdeel van het onderste vak (herhalingen, W en R).
  static const double upcomingLeft = 150;

  /// Breedte van de linkerkolom (timervak, Daarna-label) en de ruimte
  /// ernaast.
  static const double leftColumn = 226;
  static const double columnGap = 14;

  /// De vijf kolommen van elke lijnrij: aantal, afstand, techniek,
  /// inspanning, omgeving.
  static const List<int> lineColumnFlex = [9, 13, 9, 7, 11];
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
