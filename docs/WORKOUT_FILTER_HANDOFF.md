# Facility workout filter and generated split preparation

Base: `elijah-stabilization` at `1c2a231ff9a81db04271ebd809075c1ad7eee68f`.
Status: local preparation; not pushed or deployed.

## Behavior

- Workout creation intersects the user's equipment selections with the supplied facility inventory.
- Missing inventory supports existing personal workouts. An explicit empty inventory means bodyweight only. A supplied facility ID requires an inventory; do not substitute an empty list for a failed inventory fetch.
- If all user-selected equipment is unavailable, the server returns a validation error rather than silently replacing the user's choices.
- Bodyweight movements remain available alongside equipment exercises. Selecting only no-equipment/bodyweight permits only bodyweight exercises.
- `Others` remains accepted as an existing option but never grants unrestricted equipment access. It does not match unknown exercise metadata. Facility workouts require concrete matching selections or explicit bodyweight.
- Exact equipment aliases are normalized. All items in compound requirements must be available. Unknown/missing equipment metadata is excluded; audit the live exercise catalog before rollout. Broad `machines` does not imply every named machine.
- Existing goals, focus/body parts, environment, intensity, session duration and days-per-week behavior are retained.
- Both the legacy single-session library and weekly-program library use equipment filtering. The legacy result mapper rejects generated exercises outside the filtered library and snapshots source IDs and names.
- Fallback split days choose distinct exercises matching that day's muscle focus and fail if fewer than two eligible exercises exist. Recognized generated day labels are checked against exercise muscle metadata; arbitrary AI day labels are not semantically certified. An unrecognized fallback day fails rather than guessing.
- The workout finder now imports the registered core route table.

## Connect the UI

`WorkoutFinderFlow` accepts an optional `FacilityWorkoutFilter` (in `lib/features/user/workout/data/models/facility_workout_filter.dart`). Example:

```dart
WorkoutFinderFlow(
  key: ValueKey(selectedFacilityId),
  facilityFilter: FacilityWorkoutFilter(
    facilityId: selectedFacilityId,
    equipment: loadedFacilityEquipment,
  ),
)
```

Use a fresh flow when the facility/inventory changes, including a new key when inventory changes for the same facility. This prevents reuse of a workout generated for the old inventory. Existing personal entry points remain valid without the argument. The supplied inventory is immutable; user equipment choices continue through the existing questionnaire.

Other workout entry points may use `filter.applyToPayload(existingPayload)`. It preserves existing fields and nested workout preferences; it adds:

```json
{
  "workoutPreferences": {
    "facilityId": "facility-a",
    "facilityEquipment": ["dumbbells", "bench"]
  }
}
```

The server stores the original `selectedEquipment`, normalized `facilityEquipment`, `facilityId`, and effective `equipment_availablity`. The existing API spelling `equipment_availablity` is preserved.

**Inventory integration remains to be connected.** This checkout does not contain a facility inventory source or complete backend. The payload is a preference snapshot, not verified tenant inventory and not authorization. In the complete backend, resolve the selected facility through the authenticated tenant scope and authoritative facility inventory before invoking workout creation; do not trust caller-supplied inventory as proof of facility access or actual equipment. No inventory is inferred from a facility's name or brand.

## Verification and release integration

Passed: 12 dependency-free logic tests using Node 24:

```sh
node --test scripts/tests/workout_filters.test.mjs
```

Passed: `git diff --check` and changed TypeScript syntax checks.

Added Flutter payload-preservation tests in `test/features/user/workout/facility_workout_filter_test.dart`; not run because Flutter/Dart are unavailable on the shell path.

Full backend build and database/HTTP integration tests were not run: the backend artifact is missing imported modules such as `user.model.ts`, `workoutStats.model.ts`, and the platform exercise library, plus its build configuration. Run these in the complete backend before release:

1. Create a workout with user `[dumbbells, cable_machine]` and facility `[dumbbells, bench]`; verify saved effective equipment is `[dumbbells]` and original selections remain stored.
2. Reload it from MongoDB; confirm missing inventory stays absent and an explicit empty inventory stays empty.
3. Generate split options, select a split and generate its full program; verify source exercises satisfy inventory and day focus. Repeat through the legacy generate endpoint.
4. Try unavailable-only selections, unknown metadata, too-small libraries, changed facilities, and missing inventory; ensure failures appear instead of an inappropriate plan.
5. Run the Flutter test above, Flutter analysis and a device flow including generation, retry and navigation.
6. Test warm-up/cool-down provider text for equipment consistency as well as structured exercise choices; free-text instructions are not mechanically equipment-validated by this patch.

Payment/paywall/webhook code is unchanged. Reconcile Elijah's incoming commit with this baseline before integration. This patch is not a payment integration or capacity certification.

## Capacity question: facility with 500–1,000 members

Hosting is Replit; the deployment type, machine size, maximum machines, database provider/tier, and AI rate limits are not yet known. No production load test was performed. Replit supports configurable Autoscale deployments, but hosting brand alone does not establish safe concurrency.

Check Publishing → Adjust settings and the actual database/provider dashboards. A proposed staging test should cover login plus dashboard loading at increasing concurrent users (for example 25, 50, 100), a short arrival burst, and AI generation as a separate workload. These are test scenarios, not measured capacity. Use dedicated test users and sandbox payment events. Record latency percentiles, errors, CPU/RAM, DB connections, and AI throttling. Agree the expected arrival peak before claiming readiness for a facility launch.

Replit reference: https://docs.replit.com/features/publishing/deployment-types
