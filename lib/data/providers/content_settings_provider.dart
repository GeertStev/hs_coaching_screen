import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hs_coaching_core/core/providers/display_device_ids_provider.dart';
import 'package:hs_coaching_core/core/providers/firebase_providers.dart';

import 'package:hs_coaching_screen/data/models/display_content_settings.dart';

/// A provider that streams the dynamic content settings for a display.
///
/// This is a `StreamProvider` because the content type can change during the
/// app's lifecycle.
final contentSettingsProvider = StreamProvider<DisplayContentSettings>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final ids = ref.watch(displayDeviceIdsProvider);

  final stream = firestore
      .collection('clubs')
      .doc(ids.clubId)
      .collection('displays')
      .doc(ids.displayDeviceId)
      .collection('settings')
      .doc('content')
      .snapshots();

  return stream.map((snapshot) {
    if (!snapshot.exists || snapshot.data() == null) {
      return const DisplayContentSettings();
    }
    return DisplayContentSettings.fromJson(snapshot.data()!);
  });
});
