import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/core/providers/display_device_ids_provider.dart';
import 'package:hs_coaching_core/core/providers/firebase_providers.dart';
import 'package:hs_coaching_core/image/display_image.dart';
import 'package:hs_coaching_core/image/display_image_repository.dart';

/// Provider for the image repository. This screen never writes, so it uses
/// core's read-only base directly instead of a local subclass.
final imageRepositoryProvider = Provider<DisplayImageRepositoryBase>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final ids = ref.watch(displayDeviceIdsProvider);
  return DisplayImageRepositoryBase(
    firestore: firestore,
    clubId: ids.clubId,
    displayId: ids.displayDeviceId,
  );
});

/// A provider that streams the current image to be displayed.
final imageProvider = StreamProvider.autoDispose<DisplayImage?>((ref) {
  return ref.watch(imageRepositoryProvider).watchCurrentImage();
});
