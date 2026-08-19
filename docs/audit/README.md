# Collaborator Change Audit System

Every time a contractor or collaborator works on the codebase, run this audit
before and after so you know exactly what changed, why, and what patterns to
carry forward — or never repeat.

---

## Quick Start

### Before collaborator starts work
```bash
bash scripts/audit_collaborator.sh --set-baseline
```
This locks the current HEAD as your comparison point.

### After collaborator delivers
```bash
bash scripts/audit_collaborator.sh
```
This generates a full diff report in `docs/audit/AUDIT_REPORT_<date>.md`.

---

## What the report contains

| Section | What it tells you |
|---|---|
| **Summary Table** | Every file touched, its status (added/modified/removed), and auto-categorised fix type |
| **File-by-File Changes** | Full unified diff for each file |
| **Auto-detected fix type** | Script reads the diff and tags it (Navigation fix, Auth token fix, Memory leak, etc.) |
| **Lessons & Patterns** | You fill this in — reusable rules extracted from the fixes |
| **What to Never Do Again** | Anti-patterns uncovered by the diffs |

---

## Fix Type Tags (auto-detected)

| Tag | Triggered by |
|---|---|
| 🧭 Navigation fix | `Get.offAll`, `Navigator` in diff |
| ⏳ Loading state fix | `isLoading`, `LoadingState` |
| 🧠 Controller wiring | `controller` keyword |
| 📎 Import fix | `import` keyword |
| 🌐 API/URL fix | `baseUrl`, `ApiUrl`, `ApiConstants` |
| 🧹 Resource cleanup | `dispose`, `close`, `cancel` |
| 🛡️ Error handling | `try`, `catch`, `Exception` |
| 🎬 Video/Audio lifecycle | `VideoPlayerController`, `AudioPlayer` |
| 🔐 Auth token fix | `token`, `bearer`, `auth` |
| 💳 IAP/Subscription | `subscription`, `iap`, `purchase` |
| 📐 Layout/Overflow fix | `overflow`, `SizedBox`, `Expanded` |

---

## Filling in Lessons & Patterns

After reviewing the generated report, fill in the table at the bottom:

```
| Pattern Observed | What Was Wrong | The Fix | Rule Going Forward |
|---|---|---|---|
| Login navigates before auth | Get.offAll() called before handleLogin() | Removed premature navigation | Never navigate on login tap — let the controller navigate on success |
| Missing files in GitHub | 139 dart files never committed | Pushed all missing files | Run file sync check before every Codemagic build |
```

Save completed lessons to `.agents/memory/` so future sessions learn from them.

---

## Files in this directory

| File | Purpose |
|---|---|
| `BASELINE_SHA.txt` | The commit SHA before a collaborator started — used as the diff base |
| `README.md` | This file |
| `AUDIT_REPORT_*.md` | Generated reports (one per audit run) |
