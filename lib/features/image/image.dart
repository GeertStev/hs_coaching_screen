import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_screen/features/image/data/image_repository.dart';

class ImageDisplay extends ConsumerWidget {
  const ImageDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = ref.watch(imageProvider);

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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: image.when(
            data: (imageModel) {
              return imageModel == null || imageModel.url.isEmpty
                  ? Text("Image", style: Theme.of(context).textTheme.titleLarge)
                  : Image.network(
                      imageModel.url,
                      fit: BoxFit.contain,
                      // Show a loading indicator while the image is downloading.
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return CircularProgressIndicator();
                      },
                      // Show an error icon if the image fails to load.
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.error,
                          size: 72,
                        );
                      },
                    );
            },
            loading: () => CircularProgressIndicator(),
            error: (error, stack) {
              return Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 72,
              );
            },
          ),
        ),
      ),
    );
  }
}
