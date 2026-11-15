#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
#  ZERO CLOUD SERVICE — upstream sync checker
#  9 upstream repos ka latest commit SHA + release tag nikaal kar
#  upstream.yml manifest regenerate karta hai (auto-generated file).
#
#  - GitHub Actions: sync-upstream workflow ise roza chalata hai;
#    manifest change hone pe auto-commit kar deta hai.
#  - Local:  make sync   (ya  bash scripts/check-upstream.sh)
# ═══════════════════════════════════════════════════════════════════
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"

REPOS=(
  floci-io/floci
  floci-io/floci-az
  floci-io/floci-gcp
  floci-io/floci-ui
  aws/aws-emulator
  Azure/Azurite
  fsouza/fake-gcs-server
  drehelis/gcp-emulator-ui
  omab/cloudbox
)
MANIFEST="upstream.yml"
NOW="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

# gh authed ho to wo (high rate-limit), warna public GitHub API
# NOTE: gh api 404 pe bhi JSON body print karke non-zero exit karta hai —
# isliye body CAPTURE karte hai (|| true andar), aur get_field decide karega.
fetch() {
  local out
  if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    out="$(gh api "$1" 2>/dev/null || true)"
  else
    out="$(curl -fsSL "https://api.github.com/$1" 2>/dev/null || true)"
  fi
  printf '%s' "$out"
}

# JSON field nikaalo; 404/empty/koi bhi dikkat → "-" (cloudbox jaise
# no-release repos ke liye yahi expected hai)
get_field() {
  printf '%s' "$1" | python3 -c 'import json,sys
try:
    d = json.load(sys.stdin)
    print(eval(sys.argv[1]))
except Exception:
    print("-")' "$2"
}

TMP="$(mktemp)"
{
  echo "# ═══════════════════════════════════════════════════════════════"
  echo "#  Zero Cloud Service — upstream.lock  (AUTO-GENERATED — edit mat karo)"
  echo "#  Har sync pe scripts/check-upstream.sh ise regenerate karta hai."
  echo "#  Matlab: ye stack upstream repos ke in commits/tags tak track karta hai."
  echo "# ═══════════════════════════════════════════════════════════════"
  echo "last_synced: \"$NOW\""
  echo "repos:"
} > "$TMP"

for repo in "${REPOS[@]}"; do
  branch="$(get_field "$(fetch "repos/$repo")" 'd["default_branch"]')"
  sha="$(get_field "$(fetch "repos/$repo/commits/$branch")" 'd["sha"]')"
  tag="$(get_field "$(fetch "repos/$repo/releases/latest")" 'd["tag_name"]')"
  short="${sha:0:7}"
  printf '  "%s":\n    branch: "%s"\n    sha: "%s"\n    release: "%s"\n' "$repo" "$branch" "$sha" "$tag" >> "$TMP"
  printf '  %-28s %-8s %s\n' "$repo" "$short" "$tag"
done

if [ -f "$MANIFEST" ] \
   && cmp -s <(sed -n '/^repos:/,$p' "$TMP") <(sed -n '/^repos:/,$p' "$MANIFEST"); then
  # repos section identical — timestamp badalne se repo me noise commit na ho
  rm -f "$TMP"
  echo "✅ Sab 9 repos already tracked — koi upstream change nahi."
else
  mv "$TMP" "$MANIFEST"
  echo "✅ upstream.yml UPDATED — upstream me naye commits/tags aaye the."
fi
