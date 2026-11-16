# Backend fixes accompanying the mobile release

`verified-backend.patch` preserves the exact reviewed changes from the complete
Replit backend. It is a source change-set, **not a standalone server**, and is
not consumed by Flutter or Codemagic.

The mobile repository's existing `artifacts/p2p-app-backend` directory is a
different, incomplete integration snapshot. Do not apply this patch there,
overwrite that directory, or deploy it as the complete serving backend.

## Source and application

The complete deployment source is the Replit project package
`artifacts/p2p-app-backend`. The patch uses paths relative to that project's
root, including the regression test and reconciliation notes.

In a matching complete source checkout:

```sh
git apply --check /path/to/verified-backend.patch
git apply /path/to/verified-backend.patch
pnpm --filter @workspace/p2p-app-backend run build
node --test scripts/tests/p2p_iap_persistence.cjs
```

The current Replit workspace already contains these changes; do not apply them
twice. `git apply --reverse --check` can identify an already-applied change-set.
Do not force a failed patch application onto a divergent backend.

`SOURCE-MANIFEST.json` records the base checkpoint, source checkpoint, patch
SHA-256 and resulting file hashes. The patch contains source and tests only:
no environment files, credentials, database dumps, media or dependency folders.

## What the change-set covers

- Four Standard/Pro products, authenticated user/trainer verification.
- Store re-verification on restore, purchase ownership and transactional writes.
- Preservation of assigned trainers and legacy affiliate idempotency.
- Authorized gym/location selection and restoration, including personal mode.
- Database-unavailable responses rather than false session-expired responses.
- Registry branding/location compatibility and KMF/neutral fallback colors.
- The isolated regression suite, which passed 17 checks against a temporary
  Mongo replica set with simulated store responses.

## Separate release gates

Publishing this GitHub commit **does not deploy the backend**. Configure the
production store credentials and publish the reviewed complete backend
separately. Transactional purchases require a Mongo replica set.

The 17 passing checks are not live Apple/Google purchase tests. Flutter analysis,
iOS archive compilation, signing, TestFlight processing, subscription lifecycle
notifications and device QA must be confirmed independently. No deployment or
App Store clearance is implied by this handoff.
