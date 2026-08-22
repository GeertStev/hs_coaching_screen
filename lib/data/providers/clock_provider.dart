import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A provider that yields the formatted current time every second.
final clockProvider = StreamProvider<String>((ref) {
  // Create a stream that emits a value every second.
  return Stream.periodic(const Duration(seconds: 1), (_) {
    final now = DateTime.now();
    // Format the time with leading zeros for a "HH : mm : ss" display.
    return '${now.hour.toString().padLeft(2, '0')} : ${now.minute.toString().padLeft(2, '0')} : ${now.second.toString().padLeft(2, '0')}';
  });
});
