# Claim Your Gym — tenant branding implementation

## Status

Implemented locally on elijah-stabilization after fetching and merging remote e255445802e71090614c8d17158ab9c61f580b98. That remote already contained the previous payment/enterprise/Mux package; its 80 changed files matched the local source exactly before this work. No force push or history rewrite. This package is code for review and integration, not proof of production readiness.

## User journey

A representative submits the existing gym application with an HTTPS logo, name and hex colors, reviews its preview, and completes Clover checkout. The Founder Facilities screen uses a real P2P global-admin JWT to review the applicant, ownership and verified payment. Approval transactionally creates the tenant, facility, empty initial inventory, owner membership and branding, with paid expiry recorded on the tenant. Existing verified web-payment records remain the payment authority; there is no client-issued entitlement.

The owner signs into the same flagship Flutter app. Authenticated bootstrap selects an authorized tenant and supplies branding, membership role, license state and facility inventory. The existing full flagship navigation is mounted inside the tenant session. Owners/admins can edit branding and equipment and assign/revoke verified P2P accounts as members, staff, trainers or administrators. A trainer membership also requires an existing trainer account. Owners remain ordinary global users. Owners cannot be demoted through the membership endpoint, and tenant administrators cannot appoint or modify peer administrators.

My gyms shows authorized choices and the user's own application status. Switching clears the tenant context before loading the next response, rejects stale responses, disposes tenant navigation, resets the flagship navigation controller, and clears decoded image caches. Protected enterprise data is not written to persistent client storage. Logout clears the bootstrap and active context. Session access is rechecked on resume and every minute; server endpoints independently enforce current membership and license state on every protected request.

Refund/revocation retains the gym and audit/payment records but denies access. Expired and revoked bootstrap responses contain no protected branding or inventory. Owners with an unpaid/expired application can open its Clover license checkout. Renewal uses a new expiry-specific idempotency namespace while preserving the original checkout's retry key. A revoked gym requires global-admin reactivation after a current verified payment; expiration renewal follows the existing payment reconciliation policy.

## Backend endpoints

- GET /api/v1/enterprise/me/bootstrap and /me/context: identity, authorized choices, current membership, entitlement, configuration, facility/inventory, capabilities and own application states.
- PUT /api/v1/enterprise/me/context: select an active authorized tenant or null for personal P2P.
- GET /api/v1/enterprise/me/memberships and /me/applications.
- GET/PUT /api/v1/enterprise/tenants/:tenantId/branding: current member read; owner/admin update; explicit global-admin oversight.
- GET /api/v1/enterprise/tenants/:tenantId/memberships and PUT .../memberships/:userId: authorized tenant management only.
- POST /api/v1/enterprise/admin/gym-applications/:id/reactivate: verified ownership and current paid license required.
- Existing approve endpoint also reconciles approved claims that predate branding/membership records; repeat calls do not duplicate them. Provisioning tracks pending/provisioning/active/failed and stores a sanitized retry reason.
- Existing facility/inventory endpoints now use explicit memberships for provisioned claims, so legacy user fields cannot bypass a revoked membership.
- Public GET /enterprise/tenants and /tenants/:id expose public names and neutral P2P display defaults only, not protected branding, members or equipment.
- Existing application intake now rejects invalid branding rather than silently accepting invalid colors.

## Data and reconciliation

New TenantMembership (unique tenantId + userId), TenantBranding (unique tenantId), TenantSelection (unique userId), and TenantAudit collections. Startup initializes their indexes. Claim records gain provisioningState/provisioningFailure. Owner authority is tenant scoped; no global role promotion. Backend selection is per authenticated account and revalidated on every bootstrap.

Use replica-set MongoDB for transactions. Back up before rollout. Existing approved claims need the Founder “Reconcile provisioning” action to create missing owner/branding records; valid ownership and unexpired verified payment are required. Existing staff/member lists must be reviewed and added through the protected membership endpoint; legacy role flags are intentionally not automatically promoted. Branding defaults apply where optional values are absent. Initial inventory is empty until the owner supplies authoritative equipment. No per-gym app copies are created.

## Local validation

- Full P2P backend TypeScript build passed against the downloaded complete backend with source overlays.
- Six ephemeral Mongo replica-set integration tests passed, including provisioning/duplicates, payment refund/replay, purchaser binding, deletion, Mux retry, branding/tenant authorization, forged selection, membership revocation, expiry and rollback with no partial tenant/facility.
- Founder component strict TypeScript check and Vite production component build passed. React DOM tests cover correct-token use, approval gating, retry, rejection reason, unauthorized state, ownership review and branding override.
- Full Flutter suite: 96 tests passed. Two new bootstrap/cache/expiry tests and the relevant session/theme suite passed separately after later UI edits. Flutter analysis: no errors, 552 warnings/info. These are local tests, not device evidence.
- 27 policy/helper tests passed. Clover module type-check passed. git diff --check passed.
- Full portal and API-server builds were attempted but blocked: the downloaded export lacks workspace catalogs/packages (including @replit/vite-plugin-cartographer and @types/node catalog entries). The isolated Founder build is NOT a full portal build.

## Remaining external validation / configuration

Run full portal, website and API-server builds in the complete monorepo with its lockfile, workspace catalogs and generated clients. Run the committed Founder tests with Vitest/jsdom/React Testing Library installed in that workspace; the local test harness supplied those dependencies separately. Validate the existing portal P2P_API_BASE configuration and the routing of /api/v1/enterprise to the P2P backend; do not send the SQL founder token to it. Founder authentication uses the existing P2P global-admin account and stores only its issued session token.

Use the existing Clover/server shared-secret settings, a persistent public HTTPS logo provider, and a replica-set MongoDB. Logos are supplied as HTTPS URLs; this change does not create a disk upload path. Confirm ownership and availability of those logo objects. Web and native-store provider policy is preserved.

Still required before claiming this journey production-complete: live owner approval, existing-claim migration, two-gym owner/staff/member exercises in the deployed environment, real payment/refund/renewal, production restart/index checks, full flagship navigation on physical devices, signed TestFlight review, and accessibility verification with real gym logos/colors. The original wider release audit (Apple/Google lifecycle, non-Mux deletion, production notifications and other live verification) remains separate unfinished work.

## Files changed

- artifacts/p2p-app-backend/src/modules/enterprise/enterprise.model.ts
- artifacts/p2p-app-backend/src/modules/enterprise/enterprise.route.ts
- artifacts/p2p-app-backend/src/modules/enterprise/enterprise.service.ts
- artifacts/p2p-app-backend/src/modules/enterprise/tenant.model.ts
- artifacts/p2p-app-backend/src/modules/enterprise/tenant.service.ts
- artifacts/p2p-app-backend/src/server.ts
- artifacts/p2p-portal/src/pages/superadmin/FacilitiesPage.tsx
- artifacts/p2p-portal/src/pages/superadmin/__tests__/FacilitiesPage.test.tsx
- artifacts/p2p-website/src/pages/EnrollPage.tsx
- lib/core/constants/enterprise_flags.dart
- lib/core/services/tenant_brand_service.dart
- lib/features/authentication/presentation/controllers/login_controller.dart
- lib/features/gyms/data/models/tenant_configuration.dart
- lib/features/gyms/data/services/enterprise_service.dart
- lib/features/gyms/presentation/screens/enterprise_session_screen.dart
- lib/features/gyms/presentation/screens/tenant_management_screen.dart
- lib/features/gyms/presentation/widgets/enterprise_theme.dart
- lib/features/splash/controllers/splash_controller.dart
- scripts/tests/enterprise_integration.cjs
- test/enterprise/directory_fixture.dart
- test/enterprise/enterprise_service_test.dart
- test/enterprise/enterprise_session_test.dart
- test/enterprise/gym_partner_test.dart
- test/enterprise/member_signup_test.dart
- test/enterprise/staff_signup_test.dart
- test/enterprise/tenant_bootstrap_test.dart
