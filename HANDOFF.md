# Stabilization Handoff — P2P FitTech AI

**Branch:** `stabilization` · **Base:** `24fd4cd` · **Flutter:** 3.41.4 / Dart 3.11.1
**Scope:** the full stabilization engagement — P0 launch blockers, P1 client-critical items, and the
P2 operational items that are fixable in the app (taskdoc §35).
**Result:** `flutter analyze` 38 errors → **0**. 19 tests passing. 41 commits, 238 files,
**+3,382 / −5,539**. Debug APK built and verified on a device against the live backend.

This document is written for whoever picks the project up next — including the Replit Agent. Read the
"Rules" section before changing any of the files listed here; several of these bugs were introduced by
well-meaning edits that looked correct in isolation.

**Where this stands against §32 Definition of Done:** 16 of 21 items are complete and device-verified.
Three are blocked on the client or the backend (Codemagic build, TestFlight, `/iap/verify`
idempotency); one — "subscribed user receives the correct trainer experience" — could only be checked
by proxy, because every session in this engagement used a single `role: admin` account and no
subscriber login was available. Two are honestly partial rather than complete: overflow was fixed
where found rather than swept across all 385 screens, and one unreachable module still carries
hardcoded fixtures. Details in §5.

---

## 1. Action required from the client

| # | Action | Why |
|---|---|---|
| 1 | **Rotate the owner account password** (`pmoney78q@gmail.com`) | It was committed in `codemagic.yaml` and compiled into every shipped build. It is in git history. Removing it from the file does not un-ship it. |
| 2 | **Add `ADMIN_KEY` to a Codemagic environment group named `admin`** | The admin API key no longer has a hardcoded fallback. Without this variable the admin dashboard will send an empty `x-admin-key`. |
| 2b | **Rotate the admin bypass code, server-side** | The live bypass code is the *same* 4-digit value that shipped hardcoded as the `x-admin-key` default. Anyone with a shipped binary or repo access can type it into the Admin Access screen and be granted "lifetime admin privileges" on any account the backend marks `role: admin`. Changing `ADMIN_KEY` in CI does **not** change it — `/auth/admin-bypass` validates it on the server. |
| 3 | **Confirm the `/admin/users/:id/suspend` field contract** | The app *reads* suspension as `isDeleted` but *writes* `{suspend: bool}`. If the backend does not set `isDeleted`, suspension state never round-trips. |
| 4 | **Make `/iap/verify` idempotent on `purchaseId`** | The client now de-dupes, but StoreKit replays unfinished transactions across devices and reinstalls. The server is the only place this can be guaranteed. |
| 5 | **Run a Codemagic build and push to TestFlight** | The one open P0. The iOS changes below — Restore Purchases, paywall legal links, `NSMotionUsageDescription`, the Podfile permission macros — are **written but have never been compiled**; no Mac was available in this engagement. Needs items 2 and 2b done first. |
| 6 | **Provide a subscriber test account** | Every session used one `role: admin` login. The subscriber-facing paths — the `Let's crush today's workout` greeting branch, the dashboard as an actual subscriber, and §32's "subscribed user receives the correct trainer experience" — are verified by code reading only. One ordinary account closes that gap. |
| 7 | **Emit a real event type on the metrics payload** | The Live Activity Feed infers event types client-side because none are sent. See §5. |
| 8 | **Include `isDeleted` in `/admin/metrics` `recentUsers`** | The dashboard's Suspended trainer filter is built and will appear on its own once the field arrives. It is deliberately hidden while absent rather than reporting a fabricated "0 suspended". |

---

## 2. What changed and why

### Security — release blockers

- **`codemagic.yaml` shipped the owner's real credentials.** It passed
  `--dart-define=PREFILL_EMAIL` / `PREFILL_PASSWORD`, and `login_controller.dart` prefilled the login
  form from them. Every TestFlight and App Store build opened with owner credentials filled in — anyone
  who installed the app could tap "Sign in" and get owner access. The defines are removed, and the
  prefill is now behind `kDebugMode` so a release build starts empty regardless of what is defined.
- **`admin_dashboard_controller.dart` shipped `x-admin-key` with a hardcoded default of `'2931'`.**
  A four-digit admin key compiled into every binary. The default is gone. **This is worse than it first
  looked:** verifying the admin dashboard on device confirmed that the same value is also the live
  `/auth/admin-bypass` code. So it was never just an API key — it is the credential that grants admin
  privileges through the in-app Admin Access screen, and it was readable in every shipped binary.
  Removing the default stops shipping it; only the backend can invalidate it. See action 2b.
- **`admin_bypass_screen.dart` treats the literal code `67` as a client-side unlock** for affiliate /
  partner mode — no backend call, no validation, straight to the earnings dashboard. Not fixed in this
  pass (it is not a P0 launch blocker) but it is the same class of problem.
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
  > Both of the above were originally verified **in code only** — the paywall never renders for an
  > account that already holds a subscription, which every test account here did. Since confirmed on
  > device by temporarily pointing `initialRoute` at the paywall: both the Restore Purchases action and
  > the Terms/Privacy links are present and rendered. The temporary route was reverted and never
  > committed.
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

### UX / typography restoration — taskdoc §26

`AppThemeData` declared `fontFamily: 'Montserrat'` app-wide while `pubspec.yaml` declared **no fonts at
all**, so it resolved to nothing and fell back silently. Deliberately **not** fixed by bundling
Montserrat: the client's reference screenshots were taken from a build with the same dead declaration,
so they *are* the platform default. Bundling the font would have moved iOS away from the target rather
than toward it. Both dead declarations were removed instead.

The real fault was weight, not family: **776 declarations sat at medium-or-heavier against 40 at
regular.** `core/themes/app_typography.dart` is now the single source of truth — 648 declarations on a
named scale, 179 left raw and almost all deliberate (about 138 in dead code, left raw on purpose so a
`FontWeight.w` search doubles as a dead-code marker).

Fixed alongside: three white-on-light section headers on Find Trainer that were invisible; the Workout
Split card's overflow *and* its half-width rendering (a `Stack` sizes to its only non-positioned child,
and every other layer there was `Positioned`); the mode-select headline weight, orphaned word and card
misalignment; and both `systemOverlayStyle` brightness values, which were inverted so status-bar icons
were illegible on the light bar.

### The subscriber dashboard — taskdoc §12

Was a static mockup: three hardcoded Unsplash gyms with string-literal distances, and a permanent
"0% / Maintain Physique / Full Body / Medium" for every user.

Root cause of the whole section was **one missing line**. `UserHomeController` was registered with
`Get.lazyPut` and nothing ever resolved it, so its `onInit` never ran and `loadData()` never fired.
`user_home_screen.dart` now resolves it, which is what makes everything else possible.

Today's Overview reads `WorkoutTodayOverviewModel`; the backend sends snake_case so values are
title-cased for display. The Gyms card reads `EnterpriseGymModel.partners` sorted through the same
`GymLocationService.sortByDistance` the Gyms tab uses, so the two screens finally agree. The grey
"Disable" chip — the same word on every card, and not a state this app has — now shows the gym's real
standing: **Your Gym / Partner / Coming Soon**. That also stops an unsigned gym being presented as one
a user can walk into, which is the legal exposure logged in §5.

### The greeting showed "Hi there!" to every user, forever

Not a loading race. `FeedAppBar` read `'role'`, `AppConstants.name` and `AppConstants.profilePicture`
from `SharedPreferences`, and **nothing in the codebase has ever written any of those three keys** —
`PrefsHelper.setString` is called in exactly two places, the admin bypass token and a commented-out FCM
line. So the name was always empty and the avatar always showed the `P` fallback.

Two wrong hypotheses were burned before instrumentation found it, and both are recorded in the commit
so nobody repeats them. A temporary `debugPrint` showed `firstName=ali` in the controller while the UI
read "there" — that contradiction is what pointed at the widget reading from somewhere else entirely.

**There are three feed app bars**, which is what made this expensive: `lib/widgets/app_bar.dart`
(`FeedAppBar`, the dashboard), `features/home/widgets/feed_app_bar.dart` (`FeedAppBarSliver` — on five
screens including the subscriber History and Trainer tabs), and
`features/trainer/schedule/.../trainer_app_bar.dart` (`TrainerAppBar`, currently unreachable). The same
two bugs existed in the first two independently, and were fixed separately. All three now read role
from `ProfileController` and show role-appropriate copy.

Two further bugs the role exposed: the avatar tap compared `_role == 'Trainer'` with a capital T while
the API returns lowercase, so a trainer tapping their own avatar was always sent to the *subscriber*
profile; and the subtitle read "Let's Manage your users" to everyone, subscribers included.

### Account actions and admin polish

- **Settings Logout and "Delete my account" were both dead buttons** — each only called `Get.back()`.
  Both wired. See the caveat in §4 about delete-account never having been executed.
- **The "Save Login" checkbox was missing from the login screen entirely**, so `sessionPersisted` was
  never written and nobody could stay signed in. Restored.
- **Credentials survived logout.** `LoginController` is permanent, so its `TextEditingController`s kept
  the previous account's email *and password* for the next person to use the phone. Cleared on logout.
- **The Admin/User pill overlapped screen headers.** An `OverlayEntry` pinned at `top + 6`, drawn over
  whatever each screen put there. The nav bar now adds matching top padding while the pill is shown.
- **Trainer Management's filter pills were decorative** — `active:` hardcoded, no `onTap`. They filter
  now, with one predicate driving both a pill's count and its rows so the two cannot drift.

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
| Admin bypass login → toggle pill appears, admin tab set loads | ✅ |
| **Admin dashboard renders, real backend data, no error box** | ✅ |
| Admin dashboard scrolls end to end with no layout errors | ✅ |
| Status bar icons legible (were inverted for a light bar) | ✅ |
| Mode-select screen: lighter headline, cards aligned, no orphaned word | ✅ |
| "Save Login" persists a session across a force-stop **and a device reboot** | ✅ |
| Paywall renders **Restore Purchases** and **Terms of Use · Privacy Policy** | ✅ |
| Find Trainer section headers legible (were white on a light background) | ✅ |
| Greeting shows the account's real name and initial | ✅ ("Hi ali!", avatar "A") |
| Greeting subtitle is role-aware, all three app bars | ✅ |
| Trainer avatar opens the **trainer** profile, not the subscriber one | ✅ (access code + Business & Clients) |
| Today's Overview shows live workout data | ✅ (Weight Loss / Upper Body / Medium) |
| Gyms card shows real partners, sorted by real distance | ✅ (P2P Fit Factor, LA Fitness) |
| Dashboard pull-to-refresh | ✅ |
| Settings **Logout** signs out; **Delete my account** deletes | ✅ / code-verified only¹ |
| Credentials do not survive logout into the next login | ✅ |
| Admin/User pill no longer overlaps screen headers | ✅ |
| Trainer Management pills filter the list (All / Active / Pending) | ✅ (49 trainers, live) |
| Suspended pill correctly **absent** — payload has no `isDeleted` | ✅ |
| `flutter analyze` | **0 errors** (was 38) |
| `flutter test` | **19 passing** |

¹ Delete-account was **not executed** on device: it would have destroyed the client's only test
account. The wiring was read end to end — `LoginController.deleteAccount()` calls
`AuthService.deleteAccount()` then `logout()` — but the call has never been made against the backend.
Treat it as unverified until someone runs it on a disposable account.

> **Correcting commit `1807147`'s message.** It states the mode-select screen was "NOT verified visually
> on device… not reachable this session". That is wrong. The screen *was* reachable; the fault was in my
> own tooling — a `uiautomator dump` helper that did not delete its output file first, so whenever
> `uiautomator` refused to dump (it does while a window is animating) the script silently re-read the
> **previous** dump and reported the wrong screen. The restyle has since been confirmed on device against
> the client's reference screenshot. Anything in this engagement that was concluded solely from a
> `uiautomator` dump and never corroborated by a screenshot or logcat should be treated as unverified.

The Admin dashboard was verified twice over. On device, through a real admin-role account and the
`/auth/admin-bypass` code path: the full screen renders — KPI grid, activity feed, quick actions,
platform overview with the signups chart, and trainer management — with live backend values and a clean
logcat (no `ObxError`, no `RenderErrorBox`, no overflow). And by widget test, which is the stronger
guard going forward: reinstating one `Obx` wrapper reproduces the original errors verbatim.

Note the three `Row` overflow guards added alongside the fix were precautionary. They surfaced under the
widget test's font, whose glyphs are wider than real ones; the device run showed **no** overflow. The
layouts were still wrong (unbounded text with nothing able to yield) and would stripe at a large system
text-scale setting, so the guards stay.

Audio was verified objectively, not by ear:
`adb shell dumpsys audio | sed -n '/players:/,/^$/p'` lists every player with a `state:` field. Use this
rather than screenshots for any future media work.

---

## 5. Known issues NOT fixed in this pass

Everything still open at the end of the engagement, listed roughly by severity. Items here are either
blocked on the client or the backend, or are new feature work rather than stabilization — §36 is
explicit that the target is *not* "build a better version of the app."

> **Fixed since this section was first written** — kept as struck-through history rather than deleted,
> so anyone comparing an older copy of this file can see what moved: ~~typography and theme~~,
> ~~the subscriber dashboard being a static mockup~~, ~~the Admin/User pill overlapping headers~~,
> ~~Settings logout and delete-account being no-ops~~, ~~three empty admin Quick Actions~~,
> ~~Trainer Management filter tabs being inert~~. Each is described in §2 with its root cause.

**Gym partner status — legal exposure**
21 of the 22 "partner" gyms are not partners. `EnterpriseGymModel` has an `isActivated` flag and a
correct `activatedPartners` getter that is **never called** — all four call sites use `.partners`, so
LA Fitness, Equinox, YogaSix and others render under "Featured Gyms Near You" with member counts and
ratings.

**Also outstanding**
- **Admin mode does not survive a restart for a backend-role admin.** `SplashController` only restores it
  for the hardcoded `ownerEmails`, and the Admin Access screen is reachable *only* from the login flow.
  Now that "Save Login" keeps a session alive across restarts, an account whose role is `admin` in the
  backend loses admin mode on the next launch with **no route back to it** short of clearing app data.
  Whether admin should re-authenticate each session is a product decision, but as it stands the two
  behaviours combine into a dead end.
- The onboarding copy is placeholder text from a waste-management app ("kiosk fill levels & specific
  waste types").
- ~~A visible `RenderFlex` overflow on the Generate Workout Split card ("BOTTOM OVERFLOWED BY 8.4
  PIXELS").~~ **Fixed** — the card was pinned to a fixed height smaller than its own content. It also
  turned out to be rendering at roughly half width, because a `Stack` sizes to its only non-positioned
  child and every other layer in that card is `Positioned`; its photo and gradients were written for a
  full-width card and were overlapping each other. Both fixed and confirmed on device.
- `SmarterCareScreen` lays its content out in a fixed `Column` with a hard-coded `SizedBox(height: 160.h)`
  and **no scroll view**, so it has no vertical headroom. It fits the reference device, but a shorter
  screen or an enlarged system font size would overflow it for real. Making that `Column` scrollable is
  the fix; not done here because it is pre-existing and outside the restyle that was approved.
- The Sign Up screen's Email field uses a real developer address, `dev.milon923@gmail.com`, as its
  placeholder. It is a hint rather than a prefilled value, so it is not a credential leak — but it is
  exactly the kind of hardcoded fixture §28 asks to remove.
- `lib/features/onboarding/presentation/screens/onboarding_selection_screen.dart` is dead: it is an older
  mode-select screen ("Facility" rather than "Clinical") with no inbound references. The live one is
  `features/smarter_care/presentation/screens/smarter_care_screen.dart`.
- **Ten dead files under `lib/features/profile/`, in three clusters.** Found while doing the typography
  pass — about two thirds of that feature's styling lives in code nothing can reach. Unlike the 17 files
  removed in `5ec2643`, these all *compile*, so the analyzer never flagged them. Not deleted here: that
  is a separate call, and the approved work was a restyle. Verified by exact-import-path search plus a
  class-name search, so a barrel export or a route-table reference would have shown up:
  - `profile/children/` — `edit_profile_screen.dart`, `certificate_screen.dart`, `services_screen.dart`.
    A closed loop: `edit_profile_screen` navigates to the other two, and **nothing outside the folder
    imports any of them.** Superseded by `presentation/screens/edit_personal_info_screen.dart` and
    `edit_fitness_info_screen.dart`, which are the ones actually wired up.
  - `profile/presentation/screens/children/` — duplicate copies of the same three screens, zero
    references of any kind.
  - `services_card_widget.dart` and `exercise_card_widget.dart` — **two copies each** (under
    `widgets/` and `presentation/screens/widgets/`), and all four are referenced only by their own
    constructors.

  These were deliberately left un-restyled. Styling code no user can see is wasted effort, and leaving
  them raw keeps them easy to spot: a search for `FontWeight.w` in `lib/features/profile/` now returns
  the dead files and nothing else.
- **Dead code is inflating the remaining UI work by more than a third.** Measuring what is left of the
  typography pass: **247 declarations sit in live code, 138 in files nothing can reach** — 36% of the
  apparent backlog. The same "leave it raw so it stays visible" rule is being applied throughout, so the
  count of raw `FontWeight` literals doubles as a dead-code marker. The two largest single offenders:
  - `core/utils/theme/custom_themes/text_theme.dart` — **30 declarations.** This is `AppTextTheme`,
    defined in full and wired into nothing. Confirmed by searching the whole tree: the only other
    mention of the name is the comment in `core/themes/app_typography.dart` explaining why it is not
    used.
  - `features/paywall/presentation/screens/paywall_screen.dart` — **13 declarations.** Reachable only
    through `lib/routes/app_routes.dart`, which is the *unregistered* route table (see rule 7). The
    live paywall is `features/subscribe/presentation/screens/payment_details_screen.dart`.

  Also unreachable and carrying styling: the seven orphaned `features/home/widgets/*` dashboard
  sections (~19 declarations — these are the data-driven implementation described above, worth wiring
  up rather than deleting), `features/home/home_screen.dart`, `authentication/.../phone_otp_waiting_screen.dart`,
  two `settings/children/` screens, and seven files in `lib/widgets/` that the barrel does not export
  and nothing imports directly.
- **Four of §20's six admin Quick Actions have no backend endpoint to call.** The "no dead buttons"
  requirement is met — zero empty handlers remain, and Send Platform Announcement / Export Revenue
  Report now state plainly that the feature is unavailable rather than silently doing nothing. But
  Review Flagged Content, Process Refund Requests and View IAP Webhook Logs have no UI at all, because
  there is nothing to wire them to. Verified against `artifacts/p2p-app-backend`: the entire admin API
  is `/metrics`, `/users`, `/change-user/status/:id`, and PATCH `verify` / `role` / `suspend` /
  `grant-access` / `fix-role`. Nothing for announcements, revenue export, flagged content, refunds or
  webhook logs. **Backend must expose these first.**
- The Live Activity Feed synthesizes event types client-side from the recent-signups array; a user who
  signed up last year and subscribed later renders as a `purchase` event dated at signup. Not fixable
  app-side — the payload carries no event type. See client action 7.
- Messaging is stubbed, so **a subscriber currently has no way to contact their trainer**. Stream Chat
  was removed in `79922fa` over a `dio` version conflict, not by choice.
- Firebase is half-installed: `GoogleService-Info.plist` is committed but there is no `firebase_core`
  dependency, so push notifications are entirely non-functional.
- Every trainer shares the access code `MAXP210`. Confirmed on device this engagement — the trainer
  profile of a second account renders the same literal.
- "Near Me" sorts by real haversine distance but never *filters* — a user in Miami still sees all 22 gyms.
- 43 dead `onTap: () {}` controls across the app.

### Retracted findings

Things reported earlier in this engagement that turned out **not** to be defects. Listed so nobody spends
time re-investigating them, and so the list above can be trusted as real.

- **Dashboard gym photos showing as grey placeholders.** Reported as a likely regression after both cards
  rendered empty. They load correctly on device. It was a transient image/CDN failure during that one
  observation, not a code fault. Nothing was changed.

---

## 6. Files changed

238 files across 41 commits: **+3,382 / −5,539**. The bulk of the deletions are the dead clusters
described in §2; the bulk of the insertions are the typography pass (648 declarations moved onto a
single named scale) and the dashboard wiring.

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
