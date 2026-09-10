# CODE RED Enterprise / TestFlight Audit

**Audit date:** September 10, 2026  
**Mobile repository:** maximealandcastel-collab/New-P2-ai-Development-APP  
**Branch audited:** elijah-stabilization  
**Starting head:** c80b1e881ec592e910cc865c5c732cb64b60e698  
**Remediation head:** 0e63f0c5d0f8e49f085585b4078ece708e0d4871  
**Handoff reviewed:** enterprise-replit package (architecture/specification package, not a complete implementation)

## Scope

The audit covered the current Flutter branch, the enterprise handoff contract, and the workspace P2P backend. It reviewed tenant authorization, login/session handling, navigation and state, backend/mobile contracts, network privacy, build configuration, and release evidence.

## Executive result

The branch is materially safer after remediation, but it is not production-ready and cannot yet be called TestFlight-stable. The controlled single-mode enterprise path must remain enabled. Full multi-gym mode is not implemented on the backend. A new native iOS build and real two-tenant account tests are still required.

## Finding counts

| Severity | Confirmed before remediation | Fixed in this audit | Remaining/open |
|---|---:|---:|---:|
| P0 — SHIP BLOCKER | 0 | 0 | 0 |
| P1 — CRITICAL | 8 | 6 | 2 |
| P2 — HIGH | 6 | 1 | 5 |
| P3 — MEDIUM / HARDENING | 5 | 0 | 5 |

Counts exclude speculative claims rejected during source verification, including the alleged accessToken/bearerToken mismatch. Those token stores are synchronized by AuthRepository.

## Fixed findings

### P1 — CRITICAL: mobile bearer token and PII logging

The shared Dio client printed the cached bearer token and logged full Authorization headers, query parameters, bodies, multipart data, response bodies, errors, and local file paths. The remediation removes sensitive values and leaves only method/status/type metadata.

**Status:** Fixed in mobile commit 0e63f0c5d0f8e49f085585b4078ece708e0d4871.

### P1 — CRITICAL: non-legacy gym-admin dashboard response mismatch

The mobile parser requires counts.members for YMCA/non-legacy tenants, but the backend returned only signups, activeSubscriptions, and trainers. YMCA admin dashboards could fail with FormatException.

**Status:** Fixed in the workspace backend by adding the tenant-scoped member count. TypeScript compilation passes.

### P1 — CRITICAL: shared bypass code could promote any authenticated user

The bypass endpoint accepted one shared code and changed the caller's database role to global admin. The remediation now requires a current, verified, non-deleted database user who is already a global admin. It no longer changes role or verification status.

**Status:** Fixed in the workspace backend. The corrected backend must be published before release.

### P1 — CRITICAL: registered cache instance was not initialized

Dependency injection initialized a temporary CacheService and registered a different uninitialized instance.

**Status:** Fixed in mobile commit 0e63f0c5d0f8e49f085585b4078ece708e0d4871.

### P1 — CRITICAL: P2P Fit Factor facility card opened a fake form

The standard preview displayed non-editable field-shaped controls and dead social/forgot-password controls before forwarding users to generic P2P login.

**Status:** Fixed by routing the P2P Fit Factor card directly to the real P2P login. Activated white-label gyms continue to use their tenant-aware login.

### P1 — CRITICAL: backend runtime logs exposed user email addresses

Login and startup/seed paths printed account emails to workflow/deployment logs.

**Status:** Fixed in the workspace backend by removing or generalizing those log lines.

### P2 — HIGH: stale tenant branding could survive a failed account switch

Tenant ID was persisted before final authorization and could remain after an interrupted or failed login.

**Status:** Fixed by clearing tenant context before authentication and persisting only the final server-authorized tenant.

## Remaining findings

### P1 — CRITICAL: the handoff's enterprise API is not implemented

The mobile enterprise service calls /enterprise routes for directory, gym/staff applications, invitations, memberships, context switching, and scoped resources. The backend currently mounts protected /gym-admin/:tenantId routes but no /enterprise router. Any reachable Claim Your Gym, staff application, invitation, membership switching, or full multi-gym flow that calls these endpoints will fail.

**Required before full multi-gym release:** implement and mount the enterprise persistence/routes from the handoff, enforce tenant scope on every read/write/reference, and run two-tenant isolation tests. Until then, isSingleMode must remain true and unavailable flows must be hidden or clearly disabled.

### P1 — CRITICAL: no native release evidence exists for the remediated head

Flutter/Dart/Xcode tooling was unavailable in the reconstructed source environment. The latest form-key fix and the new remediation commit have not been compiled into a native IPA or tested on a physical iPhone. This is an evidence blocker, not proof of a source defect.

**Required before TestFlight:** run flutter pub get, flutter analyze, Flutter tests, CocoaPods, signed archive/export, Codemagic upload, and physical-device tests for standard login, YMCA member/trainer/admin login, KMF login, logout/account switch, and dashboard rendering.

### P2 — HIGH: backend fixes are not confirmed in production

The workspace backend is healthy and compiled, but publishing the revised tenant allowlist/dashboard/bypass behavior is not confirmed. A mobile build pointed at an older deployment can still encounter the missing members field or old bypass behavior.

### P2 — HIGH: production API origin remains independently configurable in two constant classes

ApiConstants and ApiUrls can diverge. Both must be supplied from one validated production origin during Codemagic builds. The existing stable-production-backend task remains release-relevant.

### P2 — HIGH: purchase completion lacks durable reconciliation

A successful Apple purchase followed by backend verification failure can leave a charged user without entitlement and without a durable retry/reconciliation queue. This remains part of the existing IAP work.

### P2 — HIGH: toolchain inputs are not pinned

Codemagic selects flutter: stable and xcode: latest while the project requires a recent Dart SDK. A future runner update can break an unchanged branch. Pin a known-good Flutter/Xcode matrix after the next successful build.

### P2 — HIGH: enterprise editor has unsafe response/date casts

Optional or malformed date fields can reach DateTime.parse and throw. A malformed allowedActions API value can also throw during rendering. Replace casts with validated parsing and cover malformed fixtures.

### P3 — MEDIUM / HARDENING: owner email is embedded in client routing

The hard-coded email does not itself grant admin authority after the backend fix, but it is brittle and exposes operator identity in the app binary. Route from server-issued capabilities/role only.

### P3 — MEDIUM / HARDENING: admin preview logout semantics are ambiguous

Preview exit preserves the powerful admin session while the UI says Sign out. Rename it Exit Preview and provide a separate full logout.

### P3 — MEDIUM / HARDENING: dashboard activity is truncated and metric cards are inert

Only eight activity records are shown and metric cards do not navigate to the related queue/resource.

### P3 — MEDIUM / HARDENING: Firebase/FCM is not release-configured

Firebase options are a stub and no initialization evidence was found. This does not block the core enterprise login but blocks claiming production push-notification readiness.

### P3 — MEDIUM / HARDENING: Android release source is incomplete

The audited branch lacks a complete Gradle project and references a missing network security resource while permitting cleartext traffic. This does not block the iOS TestFlight target, but Android is not release-ready.

## Authorization conclusions

- Backend gym-admin routes verify JWT, reload current database state, require verified/non-deleted users, and enforce gymAdminTenantIds for the requested tenant.
- Global admin is intentionally not a bypass for gym-admin tenant routes.
- Unknown and incomplete white-label tenant configurations fail closed.
- accessToken and legacy bearerToken are synchronized; the reported token-source mismatch was rejected.
- Cached tenant selection is not accepted as backend authority.

## Verification evidence

### Passed

- P2P backend TypeScript build: PASS.
- Focused Jest suites: 3 passed / 3 total.
- Focused Jest tests: 7 passed / 7 total.
- Tenant allowlist tests: PASS.
- Gym-admin guard tests: PASS.
- User profile authority tests: PASS.
- Backend workflow restart: PASS; server listening on port 3000 and MongoDB connected.
- Static mobile remediation assertions: bearer/header/body/response logging removed; tenant cache write ordering corrected; real P2P login route present.

### Failed commands

- One attempted Vitest command failed because Vitest is not installed/configured in this package. The same focused suites were rerun successfully with the configured Jest runner. This is not a product test failure.

### Not run / unverified

- flutter pub get, flutter analyze, Flutter unit/widget tests.
- CocoaPods install, Xcode archive, IPA export, signing, and TestFlight upload.
- Physical-device rendering and navigation.
- Real YMCA and KMF member/trainer/admin credentials.
- Live two-tenant isolation, revocation, account-switch, and in-flight request tests.
- Apple IAP purchase/reconciliation.
- Firebase/FCM, HealthKit, Bluetooth, offline behavior, and background lifecycle.
- Production deployment of the backend remediation.

## Release conditions

1. Publish the remediated backend and verify the production health endpoint.
2. Confirm real YMCA and KMF gym-admin records contain the correct gymAdminTenantIds.
3. Produce a new signed iOS build from mobile head 0e63f0c5d0f8e49f085585b4078ece708e0d4871 or later.
4. Run physical-device login/logout/dashboard tests for standard P2P, YMCA, and KMF roles.
5. Keep isSingleMode=true and hide or disable unimplemented /enterprise flows, or implement the complete enterprise API before exposing them.
6. Do not claim production readiness until Apple purchase reconciliation and stable production API configuration are complete.

CONDITIONAL SHIP
