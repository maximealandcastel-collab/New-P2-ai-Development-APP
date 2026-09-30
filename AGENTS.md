# Claimed gym brand rule

For any work on a claimed, verified, or activated gym experience, follow
`docs/enterprise_brand_system_prompt.md`. This is the repository's durable
design and implementation rule for future engineering agents. The rule does
not grant account access; tenant authorization still comes from the backend.

Before changing a gym-facing control, resolve the authorized active tenant and
use its `EnterpriseGymTheme` tokens. Preserve the original approved logo,
white/off-white surfaces, and existing typography and features. Never replace
a gym's theme with the flagship orange because a screen is missing its tenant
context. Add or update a meaningful tenant-scope regression test when the
theme selection path changes.
