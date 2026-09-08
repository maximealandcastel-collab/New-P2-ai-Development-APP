# Prompt for the client's Replit agent

Use the developer-confirmed pushed commit on branch `elijah-stabilization` of `maximealandcastel-collab/New-P2-ai-Development-APP`. First report the commit SHA and verify the files below are tracked in it. If they are missing, request the pushed commit before proceeding; do not reconstruct the changes from this prompt alone.

Read `docs/enterprise/REPLIT_HANDOFF.md`, `docs/enterprise/contracts.ts`, and the Flutter request/module files identified by that handoff. Extend the existing P2P backend represented by `artifacts/p2p-app-backend`. Use the complete existing service source and its current authentication, response conventions, database models and route mounts. Do not create a replacement backend or change the app origin away from `https://p2pfitechai.com`.

Implement the tenant-scoped endpoints and permission checks in the handoff, preserving the existing KMF dashboard endpoint as an authorized alias. Keep P2P subscriptions and Clover promo redemption working. Follow the documented provisioning, migration and tenant-isolation acceptance requirements. Provision no production tenant and migrate no ambiguous ownership record without the client's reviewed rollout decision.

`isSingleMode` is already defined in Flutter and defaults to true. Keep it enabled until the multi-gym backend and end-to-end checks pass. Flutter module buttons have client API wiring; do not assume that means their backend actions are implemented.

Report the actual changed backend files, commands and results for authorization/workflow tests, migration report, and remaining limitations. After the client reviews the verified build and backend changes, the client will handle publishing through Replit. Publishing alone is not implementation. Do not report tenant isolation or all dashboard actions as complete without live end-to-end evidence.
