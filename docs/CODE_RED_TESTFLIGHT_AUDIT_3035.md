# P2P FitTech AI — CODE RED TestFlight Audit

**Release candidate:** 4.11.0 (3035)  
**Branch:** `stabilization`  
**Audit status:** **CODE RED — NOT CLEARED** pending signed Codemagic compilation and physical-iPhone evidence.

## Executive conclusion

The identified source-level P0/P1 crash and security defects were corrected for build 3035. Static structural checks and an independent architecture review passed the final patch. This environment does not contain Flutter/Xcode, so the release cannot be declared safe until Codemagic compiles the signed IPA and the physical-device smoke matrix passes.

## Findings and corrections

| Severity | Area | Before | Correction in 3035 | Remaining risk |
|---|---|---|---|---|
| P0 | Admin access | Client code `67` locally granted affiliate access without backend authorization. | Removed the client-side grant. All elevated access now requires authenticated backend authorization. | Validate owner, non-owner, wrong-PIN, and throttled attempts against production. |
| P0 | Global admin authorization | A master `x-admin-key` path could bypass JWT role checks, and the app attempted to compile a key into the binary. | Removed the client key and the global backend header bypass. Founder Console requests use the server-issued admin JWT. | Exercise every Founder Console mutation with the 8-hour JWT. |
| P1 | Owner PIN activation | Any authenticated account with the PIN could be promoted; comparison was direct and attempts were unlimited. | Restricted activation to the Pmoney owner account, added timing-safe comparison, and limited failures to five per 15 minutes. | In-memory throttling resets on process restart; production edge/WAF throttling remains desirable. |
| P1 | Trial-code service | Missing `ADMIN_BYPASS_CODE` silently fell back to a committed PIN. | Removed the fallback. Missing configuration returns 503; comparison is timing-safe. | A separate high-entropy service credential should replace shared compatibility use after coordinated deployment. |
| P1 | Codemagic signing | Each build listed and revoked all Apple certificates visible to the API key. | Removed certificate deletion. Uses Codemagic managed App Store signing identities and profiles. | Must prove certificate/profile availability with a successful signed build. |
| P1 | Live video feed | A bad/malformed/slow video could spin forever; player initialization and stop/play operations could race with disposal or tab transitions. | Added URL validation, 20-second terminal timeout, swipeable failure state, generation guards, stable page identities, snapshot iteration, and serialized playback generations. | Test malformed URL, timeout, rapid tab changes, background/foreground, and repeated scrolling on-device. |
| P1 | Reel manager | Preload work could continue while `releaseAll()` disposed native players. | Release/reset now invalidates and awaits tracked preload work before disposing players. | Native player timing still requires device stress testing. |
| P1 | Reel/controller lifecycle | Async completions could write Rx state after controller close. | Added generation/closed checks after relevant awaits and before state writes. | Exercise rapid navigation and route disposal on device. |
| P1 | Contents worker | `_modeWorker` was created but never disposed. | Worker is disposed in `onClose()`. | None identified. |
| P1 | Anam call | Cancelled startup could leak renderer/client state; watchdog timeout did not guarantee session teardown; `_isStarting` could remain stuck. | Cancellation now runs Anam cleanup, timeout ends the call before showing error, and startup state is released on cancellation. | Test decline, background, network loss, timeout, and immediate retry against the real SDK. |
| P2 | Workout generation | Unbounded generation could navigate/write after the user left; malformed response envelopes were force-cast. | Added a 75-second bound, request/route lifecycle guards, and defensive direct/enveloped payload normalization. | Backend work is not cancellable at transport level and may continue server-side after client timeout. |
| P2 | Global crash visibility | No process-wide Flutter/platform/zone capture existed. | Added Flutter framework, platform dispatcher, and zone error logging tagged with build number while preserving normal fatal behavior. | This is local diagnostic capture, not a remote crash-reporting backend. |

## Verification completed in this environment

- Balanced delimiter/structure scan passed for every modified Dart file.
- TypeScript transpilation syntax checks passed for the changed backend authorization files.
- Security regression searches confirmed removal of the local `67` grant, fallback PIN, compiled `ADMIN_KEY`, global header bypass, and certificate-revocation script.
- Codemagic assertions confirmed managed App Store signing configuration and build 3035 metadata.
- Independent final architecture review returned **PASS** for code-level P0/P1 blockers.

## Required release gates

1. Codemagic must compile and sign build 3035 from the root Flutter app on `stabilization`.
2. The IPA must upload successfully to TestFlight without certificate revocation or signing churn.
3. A physical iPhone must pass: cold launch, warm resume, rapid background/foreground, email login/signup, paywall/trial, Pmoney PIN success/failure/throttle, OTP, promo code validation/redeem, workout generation success/timeout/navigation-away, all role navigation, feed bad-video/timeout/rapid tab transitions, audio stop, Anam decline/timeout/network loss, and logout/login.
4. Google Sign-In remains intentionally unavailable in the current UI. Either restore and fully test Firebase/Google native configuration or keep it explicitly out of this release scope; do not advertise it as functional.

Until all gates pass, the only valid status is **CODE RED — NOT CLEARED**.
