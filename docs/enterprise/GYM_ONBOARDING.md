# Gym onboarding integration

The signup entry opens `GymOnboardingScreen`, which presents the Get Started design in `GymWelcomeScreen`. Member continues to membership selection; Staff / Admin opens the four-step staff access request; Gym Partner and Claim Your Gym open the licensing application. Continue is disabled until a path is selected. Trainer signup retains its existing route; User signup asks about membership and carries the selected partner `tenantId` and display-only `gymName` through the existing paywall into registration. No-gym and non-partner choices omit `tenantId`. The partnership application has five steps for owners and authorized representatives. Selecting a gym never grants privileges or claims active membership.

The default single-gym mode retains bundled KMF branding. Multi-gym search uses the existing public directory contract, including pagination. Popular gym suggestions are explicitly marked as non-partners, not licensed integrations. Membership stays “verification required” at signup; existing authenticated membership/session screens remain authoritative for active, invited and other server statuses.

## Required backend work (not available in this partial checkout)

Implement `POST /api/v1/enterprise/gym-applications` in the complete existing backend. This is a public intake endpoint. The latest Gym Partner design sends schema version 2 (superseding the initial licensing-form payload):

- `schemaVersion: 2`, `gymName`, optional `website` (empty string if omitted), `gymType`
- optional `tenantId` when requesting a claim against a directory gym
- `shortCode`: 2–5 alphanumeric characters, `primaryColor` and `secondaryColor`: `#RRGGBB`
- `city`, `state`, `locationCount`: 1–50, `activeMembers`: 50–10000
- `tier`: `free` or `elite`
- `representativeName`, `workEmail`, `phone`
- `authorizedRepresentative: true`, `reviewConsent: true`

Validate all fields server-side, limit payload sizes, rate-limit public intake, deduplicate retries, persist the application, and return only its receipt:

```json
{"success":true,"data":{"applicationId":"application-id","status":"pending_review"}}
```

Return non-2xx on failure. The client displays pending review only after a valid receipt; failures retain the entered form for retry. No application is transmitted until the user presses Submit for verification. No automatic external emails are sent by the Flutter client.

The reviewing service must verify registration/license evidence and representative authority, arrange any required supporting documents and partnership agreement, and activate the tenant and scoped owner membership only after approval. A checkbox is a declaration, not authorization. Do not automatically promote a global user role or activate membership from a supplied tenant ID. Existing registration must treat `tenantId` only as a request, and verified membership/admin access must be resolved server-side.

The application endpoint and review workflow are not implemented by the selected backend files in this repository; deployment and end-to-end licensing verification require the complete backend. The existing enterprise directory and auth contracts in `REPLIT_HANDOFF.md` still apply. Do not enable multi-gym mode until those integrations are ready.


## Member signup design

Member now opens `MemberSignupScreen` with five steps: identity, physical profile,
multi-select goals, gym choice, and a branded summary. LA Fitness and other popular
suggestions retain non-partner status; choosing a brand changes preview colors,
not account permissions. Existing local logo assets are reused; missing logos use
initials. No-gym resets branding to P2P.

The summary routes to existing paywall/account creation and OTP verification;
it does not claim a new account or verified gym membership already exists.
`memberDraft` carries the names, email, gender, height in inches, weight in pounds,
and all selected goals through the paywall. Account fields are prefilled; after
successful signup verification, profile completion receives the height converted
to centimeters, weight in pounds, preferred name, and goals. The current profile
API has only `primaryGoal`; the first selected goal seeds that editable field.
All selections are retained in the in-memory onboarding draft, but persisting
multiple training goals requires a backend contract extension. Backend gender
validation must accept the two additional displayed choices (`non-binary` and
`prefer not to say`) to support them end to end. Registration errors are displayed
by the existing signup flow. No dashboard or authentication bypass was added.


No Gym now opens `NoGymTransitionScreen` directly from step 4. Its primary action opens the P2P-branded step-5 summary. The summary's dashboard
action carries the same member draft into P2P's existing in-app paywall/account
setup, omitting tenant and gym identifiers. The profile is described as ready
for account creation, not already live; authentication is still required. Both back actions return to step 4 without
losing entered profile information. The screen uses the actual P2P logo and does
not promise free gym access or an external app redirect that is not configured.

## Staff signup

Staff / Admin now opens `StaffSignupScreen`: full name/work email, requested role,
gym selection, then access pending with an optional code. The role is a request,
not a grant of permissions. Popular suggestions remain non-partners until matched
to a directory tenant. Missing logo assets use initials.

The complete backend must implement public `POST /api/v1/enterprise/staff-access-requests`:

- `fullName`, `workEmail`, `requestedRole`, `gymName`
- `requestedRole`: `gym_manager`, `head_trainer`, `front_desk`, `personal_trainer`
- optional `tenantId` for a directory gym, optional `accessCode`
- receipt: `{ "success": true, "data": { "requestId": "id", "status": "pending_review" } }`

Validate and rate-limit intake, deduplicate retries, verify email/identity, and
validate codes against the requested tenant, role, expiry and single-use rules.
Do not log codes. Route non-partner inquiries to partnership review; do not grant
access to an unlicensed gym. Notify only authorized reviewers through the backend
workflow. Neither a submitted role nor a valid-looking client code may create an
admin membership. Approved users authenticate through the existing gym login;
server-owned context and capabilities determine dashboard access.

This endpoint is a new integration contract, not a deployed backend implementation
in this partial checkout. The client shows request received only after a valid
pending-review receipt. Failed submissions retain fields for retry. Access codes
are held only in screen memory and cleared after success or a gym change.


## Gym Partner preview and tiers

Gym Partner and Claim Your Gym use the five-step `GymApplicationScreen`: gym
search/type, brand preview, operations, tier/contact submission, and receipt.
Brand colors and short code only customize the local preview. Changes do not
modify a live tenant. Unknown gym names can be submitted as new gym applications;
search failures are not represented as proof that a gym is absent.

The displayed tiers follow the supplied product design: Free Partner and Elite
Partner at $306 one-time, with no monthly fee. Submission records the requested
tier; it does not charge or mark payment complete. The complete backend must use
its authoritative pricing and arrange Elite payment after review, before enabling
paid features. Server-side claiming must verify ownership, licensing and authority;
collect supporting documents during review. Do not automatically grant control of
an existing tenant from a selected gym ID or check box.

Only a valid `pending_review` receipt unlocks step 5. Show pending review until an
authorized reviewer activates the gym. Do not promise a 48-hour launch or describe
it as live without server evidence. The local preview is not a persisted logo or
theme. Backend processing can generate/persist the approved logo/theme, assign the
pending application to reviewers, and send notifications through its configured
workflow. No emails or Slack messages are sent by the client. Engineering notes
belong here rather than in the app's confirmation screen.
