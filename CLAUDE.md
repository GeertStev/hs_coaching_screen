@../hs_coaching_core/CLAUDE.md

# hs_coaching_screen — pool display (Flutter web)

Runs full-screen on the pool screen and only renders what `hs_coaching_app` wrote. No auth, no
navigation, no editing UI: `main.dart` boots into `DisplayLimits` (letterboxes to the configured
screen size) → `MainScreen` (`Background` + `ContentSwitcher`).

**This app never writes** to Firestore, Storage or RTDB. If a feature seems to need a write, it
belongs in `hs_coaching_app`.

## Stack specifics
- Web-only. The `android/ios/linux/macos/windows` folders are `flutter create` leftovers;
  `firebase_options.dart` only implements `web`.
- No `firebase_auth`/`firebase_messaging`, no Riverpod codegen packages.
- Theme is a single flat dark `ThemeData` in `lib/common/theme/app_theme.dart`. It deliberately does
  not port the control app's design system.

## Layout
```
lib/
  common/        theme + shared widgets (clock, club logo, sync-lost indicator)
  data/          screen-only model + providers: clock, content settings, global settings
  features/
    main_screen.dart, background.dart, content_switcher.dart, display_limits.dart
    <type>/data/<type>_repository.dart     # providers over core's Display<X>Repository
    <type>/presentation/                    # screen widget (+ *_screen_controller.dart for timers)
```

## Screen-specific rules
- Each `features/<type>/data/` file only defines a `Provider<Display<X>Repository>` (reading
  `firebaseFirestoreProvider` + `displayDeviceIdsProvider`) and a `StreamProvider<X>`, using core's
  class as-is.
- Two exceptions without a core repository:
  - `global_settings_provider.dart` defines its own `GlobalSettingsRepository` around core's
    `DisplayGlobalSettings` model.
  - `DisplayContentSettings` (`settings/content`, which content type is showing) is this repo's own
    Freezed model; regenerate with build_runner after touching it.
- `ContentSwitcher` maps each `DisplayContentType` to one screen widget; add a case for a new type.
- `TrainingScreenController` mirrors the app's controller but **never calls `next()`**: it reads
  `autoAdvanceDue` informationally only.
- `SyncLostIndicator` shows when core's `serverConnectionProvider` (RTDB `.info/connected`) goes
  false, as a proxy for stale Firestore listeners.
