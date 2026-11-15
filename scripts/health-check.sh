#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
#  ZERO CLOUD SERVICE — Health Check (sab endpoints)
# ═══════════════════════════════════════════════════════════
GREEN='\033[0;32m'; RED='\033[0;31m'; YEL='\033[1;33m'; NC='\033[0m'
ok()   { printf "  ${GREEN}✅ UP${NC}    $1\n"; }
fail() { printf "  ${RED}❌ DOWN${NC} $1 ${YEL}($2)${NC}\n"; }

probe() { # $1=name $2=url $3=expect-substring(optional)
  local code
  code=$(curl -sk -o /dev/null -w '%{http_code}' --connect-timeout 3 --max-time 6 "$2" 2>/dev/null)
  local body
  body=$(curl -sk --connect-timeout 3 --max-time 6 "$2" 2>/dev/null)
  if [ -n "$code" ] && [ "$code" != "000" ] && [ "$code" != "502" ] && [ "$code" != "503" ]; then
    if [ -n "$3" ] && ! echo "$body" | grep -q "$3"; then
      fail "$1" "HTTP $code, '$3' not found"
    else
      ok "$1  (HTTP $code)"
    fi
  else
    fail "$1" "no response ($code)"
  fi
}

echo "════════ ZERO CLOUD SERVICE — Health Check ════════"
echo "── GUIs ──"
probe "floci-ui (main console)"  "http://localhost:4510"
probe "floci built-in console"   "http://localhost:4500"
probe "gcp-ui (GCP browser)"     "http://localhost:9090"
probe "cloudbox admin (GCP)"     "http://localhost:8888/health"
probe "landing page"             "http://localhost:3010"

echo "── AWS ──"
probe "floci AWS API :4566"      "http://localhost:4566/api/healthz"
probe "floci AWS console"        "http://localhost:4566/_floci/ui"
probe "aws-emulator :9297"       "https://localhost:9297"

echo "── AZURE ──"
probe "floci-az :4577"           "http://localhost:4577"
probe "Azurite blob :10000"      "http://localhost:10000/devstoreaccount1/?comp=list"

echo "── GCP ──"
probe "floci-gcp :4588"          "http://localhost:4588"
probe "fake-gcs :4443"           "http://localhost:4443/storage/v1/b" '"kind"'
probe "pubsub emulator :8085"    "http://localhost:8085/healthz"
probe "firestore emulator :8086" "http://localhost:8086/"
probe "datastore-mode :8087"     "http://localhost:8087/"
echo "═══════════════════════════════════════════════════"
