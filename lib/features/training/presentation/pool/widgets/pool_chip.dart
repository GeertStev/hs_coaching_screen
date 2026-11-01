import 'package:flutter/material.dart';

/// Afgerond label met achtergrond en rand: techniek/omgeving in een lijnrij,
/// de specificatierij, groepspills. Kleuren komen van de aanroeper (uit
/// `PoolDisplayTheme`).
class PoolChip extends StatelessWidget {
  const PoolChip({
    super.key,
    required this.text,
    required this.style,
    required this.background,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
    this.radius = 8,
  });

  final String text;
  final TextStyle style;
  final Color background;
  final Color? borderColor;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(radius),
      border: borderColor == null
          ? null
          : Border.all(color: borderColor!, width: 1.5),
    ),
    child: Text(text, style: style, maxLines: 1, softWrap: false),
  );
}

/// Omlijnde pill (fase, overgang): gevuld als [filled], anders enkel rand.
class PoolPill extends StatelessWidget {
  const PoolPill({
    super.key,
    required this.text,
    required this.style,
    required this.color,
    required this.filled,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
    this.trailing,
  });

  final String text;
  final TextStyle style;
  final Color color;
  final bool filled;
  final EdgeInsets padding;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: filled ? color : null,
      borderRadius: BorderRadius.circular(999),
      border: filled ? null : Border.all(color: color, width: 1.5),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, style: style, maxLines: 1, softWrap: false),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    ),
  );
}
