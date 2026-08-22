# HS Coaching Screen — Project Guide (for AI-assisted development)

The **display app** for the Holy Squid underwater hockey coaching tool — a Flutter web app that
runs on a screen poolside, purely reading Firestore/RTDB written by the sibling **control app**
(`hs_coaching_app`, separate repo) and rendering it full-screen. No auth, no writes — everything
here is `StreamProvider`s over Firestore and ticking `Notifier`s over derived time-based state.

State flows one way: **control app writes → Firestore → this app reads**. There is no login flow,
no navigation, no editing UI — `main.dart` boots straight into a single `MainScreen`.

---

## Tech stack

- Flutter (web-only target; `android/ios/linux/macos/windows` folders exist from `flutter create`
  scaffolding but are never actually built/shipped — `firebase_options.dart` only implements
  `web`, and throws `UnsupportedError` for every other platform).
- `flutter_riverpod ^3.0`, hand-written providers only — no `riverpod_generator`/
  `riverpod_annotation` dependency at all (unlike `hs_coaching_app`, which has the codegen
  packages installed but unused; this app never added them in the first place).
- `firebase_core`, `cloud_firestore`, `firebase_storage`, `firebase_database`. RTDB is used only
  as a clock/connectivity oracle (see "Realtime sync" below) — never for real content.
- **`hs_coaching_core`** (path dependency, sibling repo `../hs_coaching_core`) — shared Freezed
  models + read-only repository base classes for every content type. This app consumes core's
  repositories **directly**, since it never writes; `hs_coaching_app` `extends` the same base
  classes to add write methods. See "Repository pattern" below.
- `freezed`/`json_serializable` — only `DisplayContentSettings` (this repo's own model; no core
  equivalent exists) is Freezed locally. Every other model comes from `hs_coaching_core`.
- No `firebase_auth`, no `firebase_messaging` — this app never authenticates.

**Codegen:** run `dart run build_runner build --delete-conflicting-outputs` after touching
`lib/data/models/display_content_settings.dart`. Generated `.freezed.dart`/`.g.dart` are committed.

---

## Architecture

```
lib/
  main.dart                     # Firebase init + ProviderScope + MaterialApp(home: DisplayLimits())
  firebase_options.dart         # web-only FirebaseOptions (project: hs-coaching)
  common/
    theme/app_theme.dart         single flat ThemeData.darkTheme — no design-system parity with
                                  hs_coaching_app's AppColors/Typography/Metrics (by choice, not
                                  ported here)
    widgets/
      clock.dart                  clock_provider-backed ticking clock text
      club_logo.dart               renders globalSettingsProvider's clubLogoUrl/clubName
      sync_lost_indicator.dart     hidden while hs_coaching_core's serverConnectionProvider is
                                    true; shows a warning badge once RTDB's `.info/connected`
                                    goes false (a proxy for "Firestore listeners are probably
                                    stale too" — see that provider's doc comment in core)
  data/
    models/display_content_settings.dart   DisplayContentSettings{contentType}, Freezed,
                                            screen-only model, no core equivalent
    providers/
      clock_provider.dart                   ticking StreamProvider<String>
      content_settings_provider.dart         StreamProvider<DisplayContentSettings> on
                                              settings/content
      global_settings_provider.dart          GlobalSettingsRepository + StreamProvider wrapping
                                              core's DisplayGlobalSettings (core ships the model
                                              but deliberately no repository for it — every
                                              consuming app writes its own, same as every
                                              feature below)
  features/
    main_screen.dart              Background() + ContentSwitcher()
    background.dart               club logo, clock, website, sync-lost indicator overlay
    content_switcher.dart         switches on DisplayContentType → one screen widget per case
    display_limits.dart           letterboxes to globalSettingsProvider's screen/content size
    chrono/  game/  image/  sketch/  tabata/  team/  text/  training/
                                   one folder per content type, each split data/ + presentation/
```

### Repository pattern (the house convention)
Every content type follows the same shape:
- `hs_coaching_core` ships a read-only `Display<X>Repository` (constructor:
  `{firestore, clubId, displayId}`) + the Freezed model, documented in core's own source as
  "`hs_coaching_screen` uses this directly; `hs_coaching_app` extends it to add writes."
- This repo's `features/<x>/data/<x>_repository.dart` wraps that in two providers: a
  `Provider<Display<X>Repository>` (reading `firebaseFirestoreProvider` +
  `displayDeviceIdsProvider`, both from core) and a `StreamProvider<X>` on top of it.
- `global_settings` is the one partial exception — core ships the model with **no** repository
  (every consuming app is expected to write its own), so `global_settings_provider.dart` defines
  both the repository class and the providers in one file, same shape as everywhere else.
- `content_settings` has no core equivalent at all (it's screen-specific — which content type is
  currently showing). Its model and provider live entirely in this repo.

Adding a new content type: follow this pattern exactly; don't invent a different shape or a local
model that duplicates something `hs_coaching_core` already provides.

### Realtime sync — ticking controllers, no polling
`chrono`, `tabata`, and `training` all store **config + a runtime pointer**
(`status` / `authoritativeStartTimeMillis` / `accumulatedElapsedMillis`, expressed in RTDB
server-clock milliseconds) in the *same* Firestore document — never the tick-by-tick countdown
itself. Each feature's `presentation/*_screen_controller.dart` is a `Notifier` that:
1. Watches the feature's core `StreamProvider` + `hs_coaching_core`'s `serverTimeOffsetProvider`
   (RTDB `.info/serverTimeOffset`, corrects for local clock drift).
2. Derives the current elapsed/remaining time from that, using core's pure calculation helpers
   (`Tabata.progressAt`, `training_flatten`/`training_navigation`/`computeTrainingProgress`).
3. Runs a `Timer.periodic` **only** while the feature is actually running, to keep the UI ticking
   between Firestore updates, cancelling it on dispose or status change.

**Training is the one place this app comes close to writing, and deliberately doesn't:**
`TrainingScreenController` mirrors `hs_coaching_app`'s controller of the same name almost
exactly, *except* it never calls `next()` when a timed step elapses (`autoAdvanceDue`) — core's
own doc comment on `DisplayTrainingRepository` is explicit that the display app reads that flag
purely informationally; only the coach app is allowed to advance the session pointer.

### Firestore data model (as read by this app)
```
clubs/{clubId}/
  displays/{displayId}/
    settings/
      content     # DisplayContentSettings: { contentType }
      global      # hs_coaching_core's DisplayGlobalSettings
      chrono | tabata | training | game    # hs_coaching_core's per-feature models
                                            #   (config + runtime pointer, same document)
      team        # via hs_coaching_core's team/ (Google-Script-backed roster, not Firestore)
```
`clubId`/`displayId` come from `hs_coaching_core`'s `displayDeviceIdsProvider` — hardcoded to
`(clubId: 'holySquid', displayDeviceId: 'bilzen')` (same known limitation as `hs_coaching_app`;
see its own CLAUDE.md's prioritized problem list).

---

## Working agreements
- This app **never writes** to Firestore/Storage/RTDB. If a feature seems to need a write, that
  belongs in `hs_coaching_app`, not here.
- Adding a new content type: add/extend a `hs_coaching_core` repository+model first, then wire it
  into this repo following the "Repository pattern" above.
- `lib/` **must stay tracked in git**. It went untracked from this repo's very first commit until
  2026-08-22, which is why a filesystem-level data-loss event that same day had no recovery path
  and several other files (`pubspec.yaml`/`.lock`, `firebase_options.dart`, two screen
  controllers) had to be reconstructed by hand. Commit early, commit often — don't let `.gitignore`
  drift into excluding real source/config again.
- Match the sibling repos' convention: Dutch code comments, English UI strings, no localization
  layer.
