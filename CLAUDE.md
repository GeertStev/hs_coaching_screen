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
- Match scoreboard (`features/match/`, spec core `docs/uwh/03-wedstrijdtafel-ui.md` §4) is **not** a
  content type: the url decides. `main.dart` reads `ScoreboardRoute.fromUri(Uri.base)`:
  `?match=<matchId>` → `MatchScoreboardScreen`, `?field=<fieldId>` → `FieldScoreboardScreen` (follows
  the live match on that field, keeps the last one until the next goes live); `&display=1` keeps it
  inside the pool display's configured screen size, otherwise it fills the window. Without these
  parameters the normal pool screen starts.
  - `data/match_repository.dart`: core's `FirestoreMatchRepository` as-is, `matchStateProvider(matchId)`
    (a family, never a global active match), `matchNowProvider` (server time, overridden in tests).
  - `LiveScoreboard` repaints with a `Ticker` but **computes** every frame's `ScoreboardModel` from
    core's `clockViewAt`; it only rebuilds when the model changes. `ScoreboardModel.from(ClockView)`
    is pure and holds ready-made texts; `ScoreboardView` just draws it on a 416-high canvas
    (`ScoreboardLayout`, scaled as a whole like Training).
  - Colours and font sizes only via `ScoreboardTheme` (provisional, registered in `AppTheme`).
  - `?match=demo` (also `demo-timeout`, `demo-halftime`, `demo-stopped`, `demo-final`, `?field=demo`)
    shows an in-memory demo match (`data/demo_match.dart`), no Firebase data involved. Goldens of
    these at 624×416 and 1920×1080 in `test/features/match/presentation/goldens/`.
- Team (`features/team/`) has two sources for the lineup, chosen by commenting one block in
  `TeamDisplay.build` (`team.dart`): the Google Apps Script url (`teamsProvider`, active) or the
  app's Team scheduler (`appTeamsProvider`, reads `settings/team.lineup` live). Geert switches
  between them by hand while testing; don't remove the url source without his OK.
- Training uses the pool-display design (`docs/pool-display-spec.md`): `training/presentation/pool/`
  draws a fixed 624×416 canvas that `TrainingScreen` scales into the content area. Colours and fonts
  only via `PoolDisplayTheme` (tokens, registered in `AppTheme`), sizes only via `PoolLayout`; never
  hardcode either in a widget. Data comes from core's `lib/training/display/`. Layout since
  2026-11-07 (spec §10): progress bar (`progress_bar.dart`), timer box with `x/y` + W/R, fixed-height
  lines (5 slots), wide `UpcomingCard`; `BreadcrumbRow` is kept but not shown. Goldens in
  `test/features/training/presentation/pool/goldens/` (`flutter test --update-goldens` after a
  deliberate visual change).
- `TrainingScreenController` mirrors the app's controller: it derives progress with core's
  `trainingProgressAt` (anchor + elapsed time), so timed steps advance here without waiting for the
  tablet. It never writes.
- Render every `AsyncValue` through `AsyncContent` (`common/widgets/async_content.dart`), never
  `.when(error: ...)` with the raw error: it keeps the last good content on error, shows
  `userMessage` otherwise, and reloads the page after 5 minutes of a visible error.
- `SyncLostIndicator` shows when core's `serverConnectionProvider` (RTDB `.info/connected`) goes
  false, as a proxy for stale Firestore listeners.
