# Enterprise Gym — existing P2P backend handoff

Future gym builders: preserve the shared home logo placement and follow the
[home branding contract](HOME_BRANDING.md) when configuring gyms.

## Branch and source verification

Use `elijah-stabilization` in `maximealandcastel-collab/New-P2-ai-Development-APP`. Before integration, fetch the developer's pushed commit and verify that `docs/enterprise/REPLIT_HANDOFF.md`, `docs/enterprise/contracts.ts`, `lib/core/constants/enterprise_flags.dart`, and the shared gym screens are tracked at that commit. A file existing only in the developer's working tree is not available to the Replit agent. Do not assume the working-tree changes have already been committed or pushed.

The Flutter entry points are `lib/features/authentication/presentation/controllers/login_controller.dart` and `lib/features/splash/controllers/splash_controller.dart`. Requests are in `lib/features/gyms/data/services/enterprise_service.dart`; module resource names, fields and actions are in `lib/features/gyms/presentation/screens/enterprise_module_screen.dart`. Review those exact files before implementing adapters.

In the complete existing backend, place the new tenant models/services/controllers/routes in an enterprise module under `artifacts/p2p-app-backend/src/modules/enterprise/`, following the project's established module conventions. Add tenant permission middleware under its existing middleware directory and mount routes in its actual router composition. Discover that composition from the complete server source; do not fabricate the missing server entrypoint or replace unrelated routes. Keep global identity and payment models intact, adding references through gym memberships instead.

## Target and responsibility

Extend the existing backend represented by `artifacts/p2p-app-backend` (TypeScript, Express, Mongoose). Do not create a replacement backend, a separate KMF app, or assume `artifacts/api-server` is the integration target. The app's default public origin is `https://p2pfitechai.com`, with mobile API base `/api/v1`. Replit is the client's implementation/publishing workflow, not a requirement to change the backend architecture or app domain. The client has confirmed they will handle publishing after receiving the build changes.

**Status: this package contains an implementation contract and supporting tools, not implemented live enterprise endpoints.** This checkout has selected backend modules but lacks `src/server.ts`, `tsconfig.json` and multiple imported dependencies. Apply the work in the complete matching backend source. Inspect existing route mounts and models first, reuse compatible services, and add adapters where existing wire formats differ. Do not overwrite existing authentication, subscriptions, Clover redemption, or global users.

## Current Flutter mode

`lib/core/constants/enterprise_flags.dart` defines `isSingleMode`, default `true`.

- `true`: previous KMF-only flow. Login/startup skips enterprise context. KMF admins use the authenticated `/api/v1/gym-admin/kmf-fitness/dashboard`; public branding is bundled. Other users retain the existing P2P member/trainer flow. No new privileges are granted.
- `false`: shared multi-gym directory, context, dashboard and modules. This requires the backend integration below. Enable with `--dart-define=IS_SINGLE_MODE=false`, followed by a full restart/build.

Keep the current default until backend tests and end-to-end checks pass. Both modes reuse the same dashboard components. The old endpoint must still authorize requests; single mode is not an authentication bypass.

## Authentication and wire conventions

Reuse the existing bearer-token authentication and `sendResponse` envelope: `{success, message, data}` with the existing status/statusCode convention. Success `data` is an object; collection responses are `{items: [], nextCursor: null}`. Return string IDs (`id`, not only `_id`). Errors must use appropriate HTTP codes and contain no private records, stack traces, tokens or credentials. Do not redirect API requests to website HTML.

The existing `guardRole` checks global P2P roles; it is **not sufficient for tenant authorization**. Resolve the current global identity and account validity, then current active tenant membership and operation permissions on every protected request. A global `user` can be a gym owner; a gym trainer does not become a global admin. Never grant gym access from a submitted tenant ID, selected login tab, email naming convention or cached Flutter role.

## Endpoint contract

Paths below are relative to `/api/v1`. `:tenantId` and every resource ID must be validated and scoped on the server. `contracts.ts` defines DTOs. Preserve any existing equivalent implementation behind these adapters rather than introducing duplicate data stores.

| Method/path | Result and permission |
| --- | --- |
| GET `/enterprise/tenants?limit=30&cursor=&q=&tag=` | Public published directory; paginated configuration objects, no private operational data |
| GET `/enterprise/tenants/:tenantId` | Public published configuration |
| GET `/enterprise/me/memberships?limit=30&cursor=` | Authenticated user's active memberships and invitations; each item has id, tenantId, name, roles, status |
| GET `/enterprise/me/context` | `{context: null}` for personal mode or `{context: {tenant, roles, capabilities}}` for a currently authorized gym |
| PUT `/enterprise/me/context` | Body `{tenantId: string or null}`; validate membership before selecting. Return the same context shape |
| POST `/enterprise/tenants/:tenantId/join-requests` | Submit a join request for the authenticated identity; prevent duplicate pending requests |
| POST `/enterprise/me/invitations/:id/accept` | Verify recipient against authenticated verified identity, invitation tenant, expiry and status; consume atomically |
| GET `/enterprise/tenants/:tenantId/admin/dashboard` | Authorized gym owner/admin, Dashboard DTO |
| GET `/enterprise/tenants/:tenantId/admin/:resource` | Page of authorized module display records |
| POST `/enterprise/tenants/:tenantId/admin/:resource` | Create with validated fields listed below |
| POST `/enterprise/tenants/:tenantId/admin/:resource/:id/:action` | Validated transition listed below |
| PATCH `/enterprise/tenants/:tenantId/admin/facility` | Update validated branding/facility fields; return updated data |
| GET `/enterprise/tenants/:tenantId/member/:resource` | Active membership; member-safe records, own subscriptions only |
| POST `/enterprise/tenants/:tenantId/member/classes/:id/enroll` | Enroll self, atomic capacity check and no duplicates |
| POST `/enterprise/tenants/:tenantId/member/classes/:id/cancel-enrollment` | Cancel own enrollment only |

Context selection should be session-specific, not an unscoped global variable. Store/validate it against the authenticated session, and ensure a client context from one session never changes another identity's authorization. Revocation must deny the next protected operation and invalidate realtime access. Return 401 for invalid identity, 403 for denied membership/permission; cross-tenant resources may use a consistent non-enumerating 404. Missing context must never silently grant KMF access.

Example context response:

```json
{"success":true,"message":"Context loaded","data":{"context":{"tenant":{"schemaVersion":1,"id":"kmf-fitness","name":"KMF Fitness Club","logoUrl":"https://p2pfitechai.com/media/kmf/logo.jpg","slogan":"Keep Moving Forward","primaryColor":"#0A0A0A","secondaryColor":"#171917","accentColor":"#39FF14","timezone":"America/New_York","photos":[],"locations":[],"contact":{}},"roles":["admin"],"capabilities":["gym_admin"]}}}
```

## Shared modules and operation fields

Every gym inherits the same module definitions; future approved modules are added centrally. Admin lists expose server-computed `allowedActions` for UI convenience only. The server must authorize actions independently. Include a human-readable name/title/email alongside id for Flutter record pickers.

| Resource | Create/edit fields | Record actions |
| --- | --- | --- |
| signups | Join requests submitted through member endpoint | approve, decline |
| members | email (creates invitation, not a global user/password) | suspend, reactivate, remove |
| plans | name, description, durationDays | archive |
| subscriptions | membershipId, planId, startsAt, endsAt | cancel |
| trainers | membershipId, bio | remove |
| facility | name, slogan, logoUrl, primaryColor, secondaryColor, accentColor, timezone, email, phone, website, photos | PATCH only |
| locations | name, address, city, zipCode | archive |
| classes | name, trainerId, locationId, startsAt, capacity | cancel |
| content | title, description, mediaUrl | archive |
| activity | Read only, server-generated | None |
| analytics | Read only; from/to YYYY-MM-DD filters | None |

GET facility and analytics must also return `{items, nextCursor}` for the current shared Flutter module renderer. Map facility contact fields from the editor into configuration.contact. Member resources are facility, trainers, classes, plans, subscriptions, content. Trainers may only access operations explicitly authorized for their active assignment; they cannot invite owners, manage other trainers or administer gym finances. Add any trainer-only endpoints to the same scoped service and coordinate their Flutter contract.

Approve requests and invitation acceptance atomically create/reactivate the gym membership without duplicate relationships. Suspension/removal revokes gym entitlements and active context, not global P2P identity. Prevent removing/demoting the last active owner without an authorized replacement. Trainer assignments require an eligible active membership of this gym. Archived plans cannot receive new assignments; existing valid subscriptions retain their contractual duration. Cancellation is immediate. Expiry is enforced at read/authorization time even if a background expiry job is delayed. Class capacity checks, cancellation and enrollment must be concurrency-safe. Gym payments are out of scope; gym entitlements are separate from P2P payment subscriptions and website/Clover access-code redemption.

## Metrics and dates

Signups counts submitted join-request records (including requests subsequently approved/declined), not active members. Members counts currently approved active gym memberships. Active plans (`counts.activeSubscriptions`) counts currently valid subscription records with an active membership, `startsAt <= now < endsAt`, not cancelled; it is not the number of plan definitions. Trainers counts active eligible gym trainer assignments. Return nonnegative integer counts, including zeros, and separate recent lists. Never substitute members for signups.

Analytics must document whether each row is an event count or an as-of membership/subscription snapshot. Use source timestamps/history to reproduce date-filtered values. Interpret from/to as inclusive local calendar dates in the configured IANA timezone; convert to UTC boundaries with an exclusive next-day end, including DST. Return dates and values as display records and reconcile dashboard totals to the same underlying queries. Jobs cannot be the sole authority for expiry.

## Isolation and persistence

Every gym-owned record requires tenantId, including memberships, requests, invitations, subscriptions, trainer assignments, classes/enrollments, content, locations, media metadata and activity. Configuration is versioned; layouts and privileges are not tenant-editable configuration. Use compound indexes and scoped unique constraints (tenantId,userId for memberships; tenantId,classId,membershipId for enrollment; unique provisioning key). Account IDs refer to the one shared P2P identity.

Scope all reads, writes, counts, aggregations, lookups/joins, exports, signed media URLs, background jobs and realtime rooms. Never load a resource by ID alone then authorize after serialization. Validate references using both tenantId and referenced ID; reject cross-gym plan/member/trainer/location/media IDs, including writes targeting one's own gym with another gym's foreign key. Whitelist update fields, never accept user-supplied roles/tenantId/system timestamps through generic updates. Use transactions/atomic conditions for multi-record changes and idempotent transitions. Do not expose emails or private metrics in public configuration.

Private media access needs current permission checks before issuing short-lived URLs; do not expose public buckets for private content. Realtime joins and each event delivery need valid tenant access, with rooms revoked on suspension/logout. Worker inputs must carry validated tenant ownership and recheck it as appropriate. Platform provisioning requires separately validated platform privileges; a gym admin cannot promote their global identity or access another tenant through the existing global-admin bypass.

## Provisioning

Implement platform-only POST `/enterprise/platform/assets` accepting multipart `file` (returns `{assetId,url}`) and POST `/enterprise/platform/tenants` accepting `{configuration,ownerEmail?}` (returns `{tenantId,created,invitationId?}`). Both accept `Idempotency-Key`. Authenticate with existing trusted platform-operator identity; no new client secret in Flutter. Validate against tenant.schema.json plus IANA timezone, content signatures/image decoding, size limits, asset ownership and URL policy. Remote asset fetching must reject private/internal destinations and unsafe redirects. Reject conflicting payload reuse of an idempotency key; use a transaction/unique keys so concurrent retries create no duplicates. A repeated asset key returns the same asset.

Validate all input before creating the published tenant and locations. Initialize operational collections empty; never copy KMF members, subscriptions, signups, classes or activity. Optional ownerEmail creates one expiring invitation; omission leaves ownership for a platform operator to assign later. Never invent passwords or automatically create verified global accounts. Only publish fully initialized tenants into the directory.

Local examples (no network):

```sh
node scripts/provision-enterprise.mjs --config docs/enterprise/kmf.tenant.json --dry-run
node scripts/provision-enterprise.mjs --config docs/enterprise/abc.example.tenant.json --dry-run
```

After implementing and testing the platform endpoints, set `ENTERPRISE_API_BASE` to the trusted API base (for production, `https://p2pfitechai.com/api/v1`) and `ENTERPRISE_PLATFORM_TOKEN` through the environment. Then run the same command without --dry-run and with `--key <stable-unique-key>`; optionally supply `--owner-email <address>`. The script uploads bundled image assets and substitutes server URLs. Replace ABC's placeholder images/address before real provisioning. Dry-run validation does not check remote image availability. Do not execute production provisioning as part of an unreviewed test.

## Migration and deployment order

1. Locate the complete matching `artifacts/p2p-app-backend` source and current route mounting. Compare existing endpoints against this contract; preserve existing login, payment and promo flows.
2. Add tenant-owned models, current-membership authorization and module services. Mount the Flutter-compatible adapters. Run migration in report-only mode first.
3. Seed KMF through the same platform provisioning mechanism used for future gyms. Map old records only with verified ownership evidence. Record source collection/id, evidence, target tenant, disposition and reason in a migration report. Quarantine ambiguous records from all tenant queries until reviewed; do not infer ownership from email or absence of another tenant.
4. Back up data and prepare rollback; apply approved mappings idempotently. Keep the old `/gym-admin/kmf-fitness/dashboard` as a temporary alias to the same authorized KMF service, not a separate unscoped query.
5. Run the acceptance checks below against disposable KMF/ABC test tenants. The client publishes through their Replit workflow to the existing website backend. Verify the public domain routes reach that deployment and return JSON.
6. Test Flutter against the deployed backend with multi-gym mode enabled, then release the app build. Keep single mode until the integration is verified. A publish action alone does not implement missing APIs.

## Acceptance and evidence

`scripts/enterprise-acceptance.mjs` is a read-only HTTP smoke/denial runner. It checks both authorized dashboards, public directory, cross-tenant GETs and member-to-admin denial. It is not a complete authorization suite. Supply two distinct gym IDs and separate admin/member credentials from disposable test fixtures. Its output excludes response bodies/tokens. The complete backend must additionally implement executable integration scenarios:

- Provision KMF and ABC; retry and concurrently repeat identical provisioning keys; assert one tenant/location set/invitation, empty operational data, and no copied KMF records. Conflicting key payload returns 409.
- Submit requests, approve/decline, accept/replay/expire/revoke invitations; counts show signups separately from active members. Suspension/removal denies the next HTTP/realtime operation.
- Assign/remove trainers; member and trainer credentials cannot invoke admin or platform actions. Validate foreign tenant member/plan/trainer/location references on every create/update path.
- Create/archive/assign plans; use a controlled clock to check expiry boundaries and immediate cancellation without waiting for a worker. Existing P2P payments/promo redemption still work.
- Schedule/enroll/cancel classes, including simultaneous final-slot enrollments, replay and other-member cancellation attempts. Publish/archive content; verify private media issuance and expiry.
- Exercise every module's loading, empty, error, denial and success states. Check analytics date/DST boundaries against source records and dashboard totals.
- Matrix Gym A/B credentials against each other's reads, writes, aggregates, exports, media and realtime rooms. Assert denied writes leave data unchanged and denial bodies contain no private records.
- Switch during in-flight requests, restart, logout, revoke membership and retry setup in Flutter; no old protected data survives. KMF and ABC render identical layouts with different configuration.

Run Flutter analysis and focused/full tests, the backend authorization suite, then end-to-end tests against the actual service. Record exact commands, environment, timestamps, fixture IDs and results without secrets in VALIDATION.md. Do not claim complete tenant isolation from Flutter filtering or this read-only runner.
