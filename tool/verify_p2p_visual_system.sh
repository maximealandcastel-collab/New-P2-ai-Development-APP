#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_root"

sha256sum -c docs/audit/P2P_FROZEN_UI_SHA256.txt >/dev/null

generate_banner_hash="$({
  awk '
    /^\/\/ ─── Generate Workout Split banner/ { capture = 1 }
    /^\/\/ ─── Today.s overview card/ { capture = 0 }
    capture
  ' lib/features/home/user_home_screen.dart
} | sha256sum | cut -d' ' -f1)"
if [[ "$generate_banner_hash" != "c250ae1ed1a875a7dacfcc7639cb725910493611e61ea28e85293f828f6d9a0c" ]]; then
  echo "Generate My Split home banner changed; it is frozen." >&2
  exit 1
fi

mapfile -t screens < <(find lib/features -type f -path '*/presentation/screens/*.dart' | sort)
if [[ "${#screens[@]}" -ne 199 ]]; then
  echo "Expected 199 presentation screen files, found ${#screens[@]}." >&2
  exit 1
fi

is_frozen_screen() {
  case "$1" in
    *'/mealPlan/'*|*'/meal_plan/'*|*'/rate_my_peel/'*|*'/workout_find/'*|*'/workout_generating_screen.dart') return 0 ;;
    *) return 1 ;;
  esac
}

violations=0
for screen in "${screens[@]}"; do
  if is_frozen_screen "$screen" || [[ "$screen" == *'/login_screen.dart' ]]; then
    continue
  fi
  if rg -n 'FontWeight\.(bold|w700|w800|w900)' "$screen"; then
    echo "Legacy heavy typography remains in $screen" >&2
    violations=$((violations + 1))
  fi
done

if [[ "$violations" -ne 0 ]]; then
  exit 1
fi

echo "P2P visual-system source audit passed: 199/199 screens inventoried."
echo "Protected modules excluded: Generate My Split, Meal Plan, Rate My Peel."
