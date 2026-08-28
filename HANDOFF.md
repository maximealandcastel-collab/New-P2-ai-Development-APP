# P0 Stabilization Handoff — P2P FitTech AI

**Branch:** `stabilization` · **Base:** `24fd4cd` · **Flutter:** 3.41.4 / Dart 3.11.1
**Scope of this pass:** P0 launch blockers (taskdoc §35), hard crashes, App Store rejection blockers.
**Result:** `flutter analyze` 38 errors → **0**. Debug APK built and verified on device.

This document is written for whoever picks the project up next — including the Replit Agent. Read the
"Rules" section before changing any of the files listed here; several of these bugs were introduced by
well-meaning edits that looked correct in isolation.

---

## 1. Action required from the client

| # | Action | Why |
|---|---|---|
| 1 | **Rotate the owner account password** (`pmoney78q@gmail.com`) | It was committed in `codemagic.yaml` and compiled into every shipped build. It is in git history. Removing it from the file does not un-ship it. |
| 2 | **Add `ADMIN_KEY` to a Codemagic environment group named `admin`** | The admin API key no longer has a hardcoded fallback. Without this variable the admin dashboard will send an empty `x-admin-key`. |
| 3 | **Confirm the `/admin/users/:id/suspend` field contract** | The app *reads* suspension as `isDeleted` but *writes* `{suspend: bool}`. If the backend does not set `isDeleted`, suspension state never round-trips. |
| 4 | **Make `/iap/verify` idempotent on `purchaseId`** | The client now de-dupes, but StoreKit replays unfinished transactions across devices and reinstalls. The server is the only place this can be guaranteed. |

---

## 2. What changed and why

### Security — release blockers

- **`codemagic.yaml` shipped the owner's real credentials.** It passed
  `--dart-define=PREFILL_EMAIL` / `PREFILL_PASSWORD`, and `login_controller.dart` prefilled the login
  form from them. Every TestFlight and App Store build opened with owner credentials filled in — anyone
  who installed the app could tap "Sign in" and get owner access. The defines are removed, and the
  prefill is now behind `kDebugMode` so a release build starts empty regardless of what is defined.
- **`admin_dashboard_controller.dart` shipped `x-admin-key` with a hardcoded default of `'2931'`.**
  A four-digit admin key compiled into every binary. The default is gone.
- **`codemagic.yaml` deleted every Apple distribution certificate on the account before each build.**
  That is account-wide and irreversible; it breaks every other pipeline and every teammate's local
  signing. Removed — `fetch-signing-files --create` already covers the real need.
- Pinned `flutter: 3.41.4` (was `stable`) and dropped the hardcoded `--build-name=3.2`, which
  contradicted `pubspec.yaml` (`2.7.0+96`) and made TestFlight builds untraceable to a commit.

### Audio bleed — taskdoc §22, the flagged Critical Bug

The previous diagnosis was wrong, so this is worth stating precisely.

**The entire reel package is dead code.** `ContentsReelPageView`, `ReelController`, `ReelPlayerManager`,
`ReelRouteObserver` and `AudioFocusService` have zero inbound references. Commit `346b488`
("restore: contents_screen.dart from build 141") reverted one file and orphaned the rest.

**What actually plays** is `features/contents/presentation/screens/contents_screen.dart`, which created
raw `VideoPlayerController`s with `setLooping(true)` and an unconditional `play()`.

> **The structural point:** tab screens live inside an `IndexedStack`. Their `State` is **never disposed
> on a tab change**, so `dispose()` — the screen's only teardown — never fired. The video looped forever
> and the audio followed the user onto the dashboard.

Fixes:
- Playback now goes through `VideoPlaybackManager`, which enforces one audible player at a time.
- That manager had to be **registered in DI** — it existed only in the dead `ControllerBinder`, so
  `Get.find<VideoPlaybackManager>()` had always thrown.
- A screen-level `VisibilityDetector` enters/exits the manager's video module. Leaving the tab or
  pushing any route on top drops visibility to zero and hard-stops every player.
- Only the centred page is marked active, so the neighbours `PageView` pre-builds stay silent.
- **`contentsTabIndex` was a hardcoded `2`** — correct only for `adminNavItems`. For users and trainers
  index 2 is **Gyms** and Contents is **3**, so every suspend/resume gate fired on the wrong tab and
  audio started on the Gyms screen. Replaced with a `NavItemId` enum resolved by lookup, removing all
  five hardcoded copies.
- The feed read its bearer token from `SharedPreferences`, which the login flow never writes. Every
  feed request went out unauthenticated. It now reads Hive via `CacheService`.

### Navigation — the "body doesn't switch" bug

`BottomNavBarMain` mounted an admin stack and a user stack side by side, hiding one with `Offstage`.
But `ctrl.navItems` **also returns `adminNavItems` when the admin is in admin mode**, so both branches
mounted the same five screens at once. And because `Offstage` and `IndexedStack` both *build* all
children and only skip painting, **every plain subscriber was mounting `AdminDashboardScreen` and firing
its admin API calls on app entry.**

Replaced with a single `IndexedStack` over the active set. Per-mode tab position is still preserved by
the controller's separate `_adminIndex` / `_userIndex`.

**A second, deeper cause sat underneath it** (fixed separately in `cd92afd`). Even after the above, the
body still froze once admin mode was activated — it kept showing `TrainerHomeScreen` while the pill said
*Viewing as User* and the nav bar had **Gyms** selected, a screen not even in the user set. Instrumenting
the `Obx` proved the widget layer was correct (`adminMode=true rawIndex=2 activeIndex=2`), so the fault
was downstream of it.

> `extendBody: true` is the **only** thing that routes `Scaffold.body` through `_BodyBuilder`, which
> defers building the body to the **layout phase** behind a `LayoutBuilder`. Once admin mode was active
> that deferred rebuild stopped re-running. `bottomNavigationBar` bypasses `_BodyBuilder` entirely —
> which is exactly why the nav bar always updated while only the body went stale.

The fix drops `extendBody` and stacks the nav bar over the body instead of passing it to
`Scaffold.bottomNavigationBar`. That reproduces the floating-over-content look without the
`LayoutBuilder` indirection, and the body is wrapped in a `MediaQuery` supplying the bar's height as
bottom padding — the inset `extendBody` used to contribute.

Also fixed here:
- The nav row hardcoded tap targets `0..4`, leaving the sixth tab unreachable — that is **trainers'
  Messages tab and affiliates' Earnings tab**, both mounted but with no way to tap them.
- The selected label at index 2 rendered white on the white frosted bar (invisible).
- An `AnimationController` was being driven from inside `build()`.
- Ten `Get.offAll(() => NavBar())` calls produced `null` route names, so `ReelRouteObserver` never fired
  on paywall and payment returns. `AdminBypassScreen` now has a registered route for the same reason.

### The Admin dashboard rendered as an error screen

Fixing navigation made the Admin tab reachable for the first time in this engagement, which exposed a
pre-existing fault: the screen rendered as a Flutter error box reading *"A RenderViewport expected a
child of type RenderSliver but received a child of type RenderErrorBox."* It had never been built
before, so nobody could see it.

The sliver list wrapped five of its sections like this:

```dart
Obx(() => SliverToBoxAdapter(child: _KpiGrid(c: c)))   // looks reactive; is not
```

> The closure only **constructs** widgets. `_KpiGrid.build()` — where `c.metrics` is actually read —
> runs later, in its own element, outside the window in which GetX records observable reads.
> `RxInterface.notifyChildren` installs the proxy, calls the builder, and **throws when nothing
> registered**. So all five threw `ObxError` on first build, Flutter replaced each with an
> `ErrorWidget`, and an `ErrorWidget` is a `RenderBox` — sitting directly in `slivers:`, that breaks
> the viewport's child contract and takes the whole screen down.

The `Obx` in the header was always fine, because it reads `c.metricsLoading` *directly inside* its
closure. That contrast is what identified the fault.

Each section now wraps its own content in an `Obx` around a method that is **called** inside the
closure, so the reads happen where GetX can see them. `_QuickActions` gained one too — it reads
`c.withdrawals` for its pending badge but was never reactive, so the badge kept whatever count it had
at first build.

`test/features/admin/admin_dashboard_screen_test.dart` guards this. Reinstating a single `Obx` wrapper
makes it fail with the original pair of errors, so it does catch the regression it is named for.

### Crashes

- **Generate Workout Split hard-crashed.** `user_home_screen.dart` imported the *unregistered*
  `lib/routes/app_routes.dart` and navigated to `/workoutFinderFlow`. With no `unknownRoute` set,
  GetX evaluates `(isUnknown ? unknownRoute : route)!` — a null-check crash on the subscriber
  dashboard's primary call to action. It now points at the registered `workoutScreen`, which drives the
  generator that already worked behind the FAB.
- Added an `unknownRoute` fallback so no unregistered name can crash the app again.
- Trainer **"Clients"** opened `clientDetailsScreen` with no arguments while its binding did
  `Get.arguments as ClientInvoiceModel`. It now switches to the Clients tab.
- Hardened the nine unguarded `Get.arguments as T` casts in the route table.

### Auth, roles, session integrity

- Owner admin-mode restore read `emailController.text` — always empty on a cold start, so **admin mode
  never restored across a restart**. It now reads the email cached at login.
- `Get.put(AdminModeService())` lacked `permanent: true`, so `SmartManagement` deleted it on the next
  `offAllNamed`.
- **`logout()` never cleared `AdminModeService` / `AffiliateModeService`** or their SharedPreferences
  keys. The next account signed in on the same device inherited admin mode.
- `AdminDashboardController`'s token fallback read a SharedPreferences key nothing writes. On the
  owner path it sent **no `Authorization` header at all** and every admin metric failed silently.
- `setVerified` / `setRole` / `suspendUser` / `grantAccess` swallowed every error while the UI reported
  success. **An admin could suspend a user, see "🔴 Suspended", and the account stayed active.** Errors
  now propagate and the UI only mutates state on success.

### App Store rejection blockers

- **Added Restore Purchases.** There was none anywhere in the app; Guideline 3.1.1 requires one for
  auto-renewable subscriptions, and its absence also stranded anyone who reinstalled.
- Added Terms of Use and Privacy Policy links to the paywall (Guideline 3.1.2).
- De-duped `/iap/verify` by `purchaseID`.
- Added `NSMotionUsageDescription` — `HealthDataType.STEPS` can fall through to CoreMotion on iOS and
  hard-crash without it.
- `ios/Podfile` now disables unused `permission_handler` macros (Contacts, Calendar, Reminders, Speech,
  ATT), which otherwise link APIs with no purpose strings and trigger **ITMS-90683** on upload. The
  assignment also changed from `||=` to `=`, because CocoaPods usually populates
  `GCC_PREPROCESSOR_DEFINITIONS` first, which made the old form a silent no-op.

### Deleted code — 17 files

All 38 analyzer errors lived in one unreachable cluster: the abandoned clean-architecture auth branch
(`core/bindings/`, `authentication/data/data_sources/`, `data/models/auth_model.dart`,
`repositories/auth_repository_impl.dart`) and duplicate screen trees (`profile/controller/`,
`profile/profile_screen.dart`, `settings/settings_screen.dart`, `user/user_profile/`,
`trainer/contents/`, `trainer/contentPost/`, `services/socket_services.dart`).

None of it compiled, so none of it could ever have been live functionality — wiring any of it up would
have failed the build. Every file is recoverable from git history.

---

## 3. Rules — please do not undo these

1. **Never put credentials in `codemagic.yaml`, source, or a `--dart-define`.** Dart-defines are
   trivially extractable from a shipped IPA or APK.
2. **Never give a security value a working default.** `String.fromEnvironment('ADMIN_KEY')` must stay
   without a `defaultValue`; a default silently ships in every build when CI forgets the variable.
3. **Never identify a nav tab by an integer literal.** The three nav sets have different orderings and
   different lengths, so no single integer is correct across them. Use `NavItemId` and
   `NavItemModel.indexOf`. This one constant caused the audio bleed.
4. **Never rely on `dispose()` for anything under the bottom nav.** `IndexedStack` keeps every tab
   mounted. Use the `VideoPlaybackManager` module gate or a `VisibilityDetector`.
5. **Do not mount both role stacks at once.** `Offstage` and `IndexedStack` build all children; that is
   what made every subscriber call the admin API.
6. **Navigate with `Get.offAllNamed(AppRoute.x)`, never `Get.offAll(() => Widget())`.** Anonymous
   builders produce a `null` route name and silently break every `NavigatorObserver`.
7. **There are two route tables.** `lib/core/routes/app_routes.dart` is the live one registered in
   `app.dart`. `lib/routes/app_routes.dart` is **not registered** — importing it is how the Generate
   Workout Split crash happened. Always import `core/routes`.
8. **Do not report success on an unverified write.** If an API call can fail, let it fail visibly.
9. **Do not re-enable `extendBody` on `BottomNavBarMain`.** It routes the body through `_BodyBuilder`'s
   layout-phase `LayoutBuilder` and reintroduces the stale body. The nav bar is stacked over the body
   specifically to avoid that. Diagnostic signature: the bottom nav updates but the body does not.
10. **An `Obx` must read its observable *inside* its own closure.** `Obx(() => SomeWidget(c: c))`
    registers nothing, because `SomeWidget.build()` runs later — GetX then throws `ObxError`, and in a
    `slivers:` list that error widget takes the whole screen down. Either read the value in the closure
    or call a method from it; wrapping a widget that reads it is not enough.

---

## 4. Verified on device

Pixel 7 / API 35, debug build, real backend.

| Check | Result |
|---|---|
| Login form opens empty (no prefilled credentials) | ✅ |
| Every bottom-nav tab switches the body, plain session | ✅ (was frozen) |
| Every bottom-nav tab switches the body, admin mode active | ✅ (needed the `extendBody` fix) |
| Admin/User pill toggles the body and the tab set | ✅ |
| Nav renders 5 tabs with the FAB centred; index-2 label visible | ✅ |
| Contents video loads and plays | ✅ (auth token fix) |
| Exactly one media player `state:started` | ✅ |
| Audio on tab change: `state:started` → `state:idle` | ✅ |
| Audio on backgrounding: `state:started` → `state:paused` | ✅ |
| Generate Workout Split opens the generator, no exception | ✅ |
| `flutter analyze` | **0 errors** (was 38) |
| `flutter test` | **18 passing** |

**The Admin dashboard fix was verified by widget test, not on device.** Reaching that tab needs an owner
login, and the owner password is a leaked credential pending rotation, so it was not used. The test
pumps the screen in its real first-paint state (no metrics loaded) and scrolls the whole list so every
sliver lays out; reinstating one `Obx` wrapper reproduces the original errors verbatim. That is stronger
evidence than a screenshot for this particular fault, but it is not a device run — **please confirm the
tab on a real admin session.**

Audio was verified objectively, not by ear:
`adb shell dumpsys audio | sed -n '/players:/,/^$/p'` lists every player with a `state:` field. Use this
rather than screenshots for any future media work.

---

## 5. Known issues NOT fixed in this pass

These were found and documented but are outside the P0 scope. They are listed roughly by severity.

**Typography and theme (taskdoc §26)**
`AppThemeData` sets `fontFamily: 'Montserrat'` app-wide, but `pubspec.yaml` declares **no fonts at all** —
it resolves to nothing and falls back silently. Nine files still reference `Figtree`, also undeclared.
159 occurrences of `w800`/`w900`/`bold` across 55 files contradict the "thin, smooth" target.
`AppTextTheme` in `core/utils/theme/` is fully defined but never wired into `ThemeData`.
`AppBarTheme.foregroundColor` is `Colors.white` on a light background.

**The subscriber dashboard is a static mockup**
`user_home_screen.dart` is a `StatelessWidget` with no controller and no API calls. The three gyms are
hardcoded Unsplash photos with string-literal distances; "Today's overview" is permanently
"0% / Maintain Physique / Full Body / Medium" for every user. A fully data-driven implementation already
exists and is orphaned: `UserHomeController` is registered in DI and its seven consumer widgets
(`overview_section.dart`, `today_workout_section.dart`, `gym_section.dart`, `trainer_plan_section.dart`,
and others) have zero import sites. **Restoring this is wiring, not a rebuild.**

**Gym partner status — legal exposure**
21 of the 22 "partner" gyms are not partners. `EnterpriseGymModel` has an `isActivated` flag and a
correct `activatedPartners` getter that is **never called** — all four call sites use `.partners`, so
LA Fitness, Equinox, YogaSix and others render under "Featured Gyms Near You" with member counts and
ratings.

**Also outstanding**
- The onboarding copy is placeholder text from a waste-management app ("kiosk fill levels & specific
  waste types").
- A visible `RenderFlex` overflow on the Generate Workout Split card ("BOTTOM OVERFLOWED BY 8.4 PIXELS").
- Three admin Quick Actions are `onTap: () {}`; three more the client asked for (Review Flagged Content,
  Process Refund Requests, View IAP Webhook Logs) do not exist anywhere in the codebase.
- Trainer Management filter tabs are bare `Container`s with no `onTap`, and "Suspended" is missing.
- The Live Activity Feed synthesizes event types client-side from the recent-signups array; a user who
  signed up last year and subscribed later renders as a `purchase` event dated at signup.
- Messaging is stubbed, so **a subscriber currently has no way to contact their trainer**.
- Firebase is half-installed: `GoogleService-Info.plist` is committed but there is no `firebase_core`
  dependency, so push notifications are entirely non-functional.
- Settings' logout and delete-account both just call `Get.back()`; the email is hardcoded to
  `Ethancarter77@gmail.com` and the version string reads "1.58.7.1".
- Every trainer shares the access code `MAXP210`.
- "Near Me" sorts by real haversine distance but never *filters* — a user in Miami still sees all 22 gyms.
- 43 dead `onTap: () {}` controls across the app.

---

## 6. Files changed

50 files: **+870 / −4404**. The deletions are the dead cluster described in §2.

Principal files:
`codemagic.yaml` · `ios/Podfile` · `ios/Runner/Info.plist` ·
`lib/app.dart` · `lib/main.dart` · `lib/core/routes/app_routes.dart` ·
`lib/core/di/dependency_injection.dart` · `lib/core/constants/app_constants.dart` ·
`lib/core/services/video_playback_manager.dart` · `lib/core/services/audio_focus_service.dart` ·
`lib/features/contents/presentation/screens/contents_screen.dart` ·
`lib/features/bottom_nav_bar/**` · `lib/features/admin/**` ·
`lib/features/authentication/presentation/controllers/login_controller.dart` ·
`lib/features/splash/controllers/splash_controller.dart` ·
`lib/features/subscribe/presentation/**`
