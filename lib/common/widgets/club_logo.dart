import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_screen/data/providers/global_settings_provider.dart';

class ClubLogo extends ConsumerWidget {
  final double? maxWidth;
  final double? maxHeight;
  final bool showClubName;
  final bool greyscale;
  final double opacity;
  final double textHeight;

  const ClubLogo({
    super.key,
    this.maxWidth,
    this.maxHeight,
    this.showClubName = false,
    this.greyscale = false,
    this.opacity = 1,
    this.textHeight = 28.0,
  });

  // Standaard luminantie-matrix om het clublogo in grijsschaal te tonen.
  // dart format off
  static const _greyscale = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0,      0,      0,      1, 0,
  ]);
  // dart format on

  Widget _maybeGreyscale(Widget child) {
    if (!greyscale) return child;
    return ColorFiltered(colorFilter: _greyscale, child: child);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalSettings = ref.watch(globalSettingsProvider);

    return globalSettings.when(
      data: (settings) {
        return SizedBox(
          width: maxWidth,
          height: maxHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Opacity(
                opacity: opacity,
                child: _maybeGreyscale(
                  Image.network(
                    settings.clubLogoUrl,
                    width: maxWidth,
                    // ToDo Volle hoogte innemen als geen text wordt weergegeven.
                    height: (maxHeight != null) ? maxHeight! * 0.8 : null,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              if (showClubName)
                FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    settings.clubName,
                    // ToDo Styling!
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => SizedBox(
        width: maxWidth,
        height: maxHeight,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => SizedBox(
        width: maxWidth,
        height: maxHeight,
        child: Center(
          child: Text(
            'Error loading logo: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
