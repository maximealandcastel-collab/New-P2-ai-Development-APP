# Integration snapshot — not a standalone backend

This directory contains historical mobile/backend integration work, but is
missing the complete server bootstrap and supporting modules. Do not deploy
it as an independent service or substitute the older backend branch.

The runnable source for the existing deployment is the Replit project's
complete `artifacts/p2p-app-backend` package. Purchase and gym-context fixes
must be integrated and verified there; a Codemagic mobile build does not deploy
Node backend changes.

The Replit project now includes `scripts/prepare-p2p-backend-release.mjs`, which
compiles that complete source and exports a credential-free backend release
archive with a source-hash manifest. Its reconciliation notes are in
`docs/P2P_BACKEND_RECONCILIATION.md`.

Current client contracts:

- `POST /api/v1/iap/verify`: authenticated user or trainer, store-verified access.
- `GET /api/v1/enterprise/me/bootstrap`: authenticated tenant restoration.
- `GET/PUT /api/v1/enterprise/me/context`: authorized gym/location preference,
  or explicit personal mode using `tenantId: null`.

Screens remain shared and tenant-scoped. This note does not certify the rest of
the historical snapshot, live deployment, lifecycle webhooks or device behavior.
