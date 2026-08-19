#!/bin/bash
# ============================================================
# Collaborator Audit Script
# Usage:  bash scripts/audit_collaborator.sh
# Output: docs/audit/AUDIT_REPORT_<date>.md
# ============================================================
# Compares the current GitHub main branch against the stored
# baseline SHA to produce a full human-readable report of:
#   • Every file changed
#   • Lines added / removed (unified diff)
#   • Auto-categorised fix type
# Run this whenever you want a snapshot of what changed.
# ============================================================

set -euo pipefail

REPO="maximealandcastel-collab/New-P2-ai-Development-APP"
BASELINE_FILE="docs/audit/BASELINE_SHA.txt"
REPORT_DIR="docs/audit"
DATE=$(date +"%Y-%m-%d_%H-%M")
REPORT="$REPORT_DIR/AUDIT_REPORT_$DATE.md"

if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "❌  GITHUB_TOKEN not set. Export it and retry."
  exit 1
fi

mkdir -p "$REPORT_DIR"

# ── 1. Load baseline SHA ─────────────────────────────────────
if [ ! -f "$BASELINE_FILE" ]; then
  echo "❌  Baseline not found at $BASELINE_FILE."
  echo "    Run:  bash scripts/audit_collaborator.sh --set-baseline"
  exit 1
fi

# Handle --set-baseline flag
if [ "${1:-}" = "--set-baseline" ]; then
  HEAD=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$REPO/git/ref/heads/main" \
    | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['object']['sha'])")
  echo "$HEAD" > "$BASELINE_FILE"
  echo "✅  Baseline set to $HEAD"
  echo "    Saved → $BASELINE_FILE"
  exit 0
fi

BASELINE=$(cat "$BASELINE_FILE")
echo "📍 Baseline : $BASELINE"

# ── 2. Get current HEAD ───────────────────────────────────────
HEAD=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$REPO/git/ref/heads/main" \
  | python3 -c "import json,sys; d=json.load(sys.stdin); print(d['object']['sha'])")
echo "🔖 Current  : $HEAD"

if [ "$BASELINE" = "$HEAD" ]; then
  echo "ℹ️  No changes since baseline. Nothing to report."
  exit 0
fi

# ── 3. Get list of changed files via compare API ─────────────
echo "🔍 Fetching changed files..."
COMPARE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$REPO/compare/$BASELINE...$HEAD")

CHANGED_FILES=$(echo "$COMPARE" | python3 -c "
import json, sys
d = json.load(sys.stdin)
files = d.get('files', [])
for f in files:
    print(f['status'] + '\t' + f['filename'])
")

TOTAL=$(echo "$CHANGED_FILES" | wc -l | tr -d ' ')
echo "📝 $TOTAL files changed"

# ── 4. Generate markdown report ───────────────────────────────
cat > "$REPORT" << EOF
# Collaborator Change Audit
**Date:** $(date "+%B %d, %Y %H:%M")
**Baseline SHA:** \`$BASELINE\`
**Current SHA:**  \`$HEAD\`
**Files changed:** $TOTAL

---

## Summary Table

| Status | File | Category |
|--------|------|----------|
EOF

# Categorise by path
python3 - <<PYEOF >> "$REPORT"
import subprocess, sys

lines = """$CHANGED_FILES""".strip().split('\n')

def categorise(path):
    if 'controller' in path:     return '🧠 Controller / State'
    if 'screen' in path:         return '📱 Screen / UI'
    if 'widget' in path:         return '🧩 Widget'
    if 'service' in path:        return '🔌 Service / Network'
    if 'model' in path:          return '📦 Model / Data'
    if 'route' in path:          return '🗺️ Routing'
    if 'helper' in path:         return '🛠️ Helper / Util'
    if 'theme' in path or 'color' in path: return '🎨 Theme / Style'
    if 'auth' in path:           return '🔐 Auth'
    if 'payment' in path or 'iap' in path or 'stripe' in path: return '💳 Payments / IAP'
    if 'video' in path or 'audio' in path or 'content' in path: return '🎬 Video / Audio'
    if 'nav' in path or 'bar' in path: return '🧭 Navigation'
    return '📄 Other'

for line in lines:
    if not line.strip(): continue
    parts = line.split('\t', 1)
    if len(parts) < 2: continue
    status, path = parts
    status_icon = {'added':'➕','modified':'✏️','removed':'🗑️','renamed':'🔄'}.get(status, '❓')
    cat = categorise(path)
    print(f'| {status_icon} {status} | `{path}` | {cat} |')
PYEOF

# ── 5. Detailed diff per file ─────────────────────────────────
echo "" >> "$REPORT"
echo "---" >> "$REPORT"
echo "" >> "$REPORT"
echo "## File-by-File Changes" >> "$REPORT"

echo "$CHANGED_FILES" | while IFS=$'\t' read -r status filepath; do
  [ -z "$filepath" ] && continue

  echo "" >> "$REPORT"
  echo "### \`$filepath\`" >> "$REPORT"
  echo "**Status:** $status" >> "$REPORT"
  echo "" >> "$REPORT"

  # Get patch from compare API
  PATCH=$(echo "$COMPARE" | python3 -c "
import json, sys
d = json.load(sys.stdin)
for f in d.get('files', []):
    if f['filename'] == '$filepath':
        print(f.get('patch', '_Binary or no diff available_'))
        break
" 2>/dev/null || echo "_Diff unavailable_")

  if [ -n "$PATCH" ]; then
    echo '```diff' >> "$REPORT"
    echo "$PATCH" >> "$REPORT"
    echo '```' >> "$REPORT"
  fi

  # Auto-detect fix type from diff content
  FIX_TYPE=$(echo "$PATCH" | python3 -c "
import sys
patch = sys.stdin.read().lower()
tags = []
if 'get.offall' in patch or 'navigator' in patch: tags.append('🧭 Navigation fix')
if 'isloading' in patch or 'loadingstate' in patch: tags.append('⏳ Loading state fix')
if 'controller' in patch: tags.append('🧠 Controller wiring')
if 'import' in patch: tags.append('📎 Import fix')
if 'baseurl' in patch or 'apiurl' in patch or 'apiconst' in patch: tags.append('🌐 API/URL fix')
if 'dispose' in patch or 'close' in patch or 'cancel' in patch: tags.append('🧹 Resource cleanup / memory leak')
if 'catch' in patch or 'try' in patch or 'exception' in patch: tags.append('🛡️ Error handling')
if 'videoplayercontroller' in patch or 'audioplayer' in patch: tags.append('🎬 Video/Audio lifecycle')
if 'token' in patch or 'bearer' in patch or 'auth' in patch: tags.append('🔐 Auth token fix')
if 'subscription' in patch or 'iap' in patch or 'purchase' in patch: tags.append('💳 IAP/Subscription')
if 'overflow' in patch or 'sizedbox' in patch or 'expanded' in patch: tags.append('📐 Layout/Overflow fix')
print(', '.join(tags) if tags else '🔧 General fix')
" 2>/dev/null || echo "🔧 General fix")

  echo "" >> "$REPORT"
  echo "**Auto-detected fix type:** $FIX_TYPE" >> "$REPORT"

done

# ── 6. Lessons & patterns section ────────────────────────────
cat >> "$REPORT" << 'EOF'

---

## Lessons & Patterns
> Fill this in after reviewing the diffs above.
> Each row = one reusable rule for future development.

| Pattern Observed | What Was Wrong | The Fix | Rule Going Forward |
|---|---|---|---|
| | | | |

---

## What to Never Do Again
> Extracted from the fixes above — concrete anti-patterns.

- [ ] _Add items here after reviewing diffs_

---

*Generated by `scripts/audit_collaborator.sh`*
EOF

echo ""
echo "✅  Report saved → $REPORT"
echo "    Open it, fill in the 'Lessons & Patterns' table, then run:"
echo "    bash scripts/audit_collaborator.sh --set-baseline"
echo "    to update the baseline for the next collaborator."
