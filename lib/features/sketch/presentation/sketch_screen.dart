import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hs_coaching_screen/data/providers/global_settings_provider.dart';
import 'package:hs_coaching_screen/features/sketch/data/sketch_providers.dart';
import 'package:hs_coaching_screen/features/sketch/presentation/sketch_painter.dart';

class SketchScreen extends ConsumerStatefulWidget {
  const SketchScreen({super.key});

  @override
  ConsumerState<SketchScreen> createState() => _SketchCanvasState();
}

class _SketchCanvasState extends ConsumerState<SketchScreen> {
  @override
  Widget build(BuildContext context) {
    final globalSettings = ref.watch(globalSettingsProvider);
    final sketchAsync = ref.watch(currentSketchProvider);
    final elementsAsync = ref.watch(sketchElementsStreamProvider);

    return Container(
      decoration: BoxDecoration(
        color: ColorScheme.of(context).surface,
        border: Border.all(
          color: ColorScheme.of(context).onSurface,
          width: 3,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // 1. De SVG Achtergrond
          sketchAsync.when(
            data: (sketch) {
              if (sketch != null &&
                  (sketch.backgroundUrl == null ||
                      sketch.backgroundUrl!.trim().isEmpty)) {
                return SizedBox.shrink();
              }
              if (sketch == null) {
                return Center(
                  child: Text(
                    "Sketch",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                );
              }
              return SvgPicture.network(
                sketch.backgroundUrl!,
                fit: BoxFit.contain,
                placeholderBuilder: (context) =>
                    const Center(child: CircularProgressIndicator()),
                // Voorkom caching-issues bij snelle opeenvolgende wisselingen
                key: ValueKey(sketch.backgroundUrl),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),

          // 2. De Render
          globalSettings.when(
            data: (settings) {
              final targetSize = Size(
                settings.contentWidth.toDouble(),
                settings.contentHeight.toDouble(),
              );
              return CustomPaint(
                painter: SketchPainter(
                  elements: elementsAsync.value ?? [],
                  actualSize: targetSize,
                  targetSize: targetSize,
                ),
                size: Size.infinite,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),

            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ],
      ),
    );
  }
}
