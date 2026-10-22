// Herladen kan alleen in de browser; in tests (Dart VM) is het een no-op.
export 'page_reload_stub.dart'
    if (dart.library.js_interop) 'page_reload_web.dart';
