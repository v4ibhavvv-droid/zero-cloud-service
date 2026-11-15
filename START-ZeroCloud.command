#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
#  ☁️  ZERO CLOUD SERVICE — ONE-CLICK START
#  Double-click karo → Docker start (agar band hai) → sab containers
#  up → health check → browser me landing page khul jayega.
# ═══════════════════════════════════════════════════════════════════
export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit 1

G='\033[0;32m'; R='\033[0;31m'; Y='\033[1;33m'; B='\033[0;34m'; C='\033[0;36m'; N='\033[0m'
say()   { printf "%b\n" "$1"; }
banner(){ say "$B════════════════════════════════════════════════════"; say "$B  ☁️  ZERO CLOUD SERVICE  —  $1"; say "$B════════════════════════════════════════════════════$N"; }
pause() { if [ -t 0 ]; then printf "%b" "$Y→ Window band karne ke liye [Enter] dabao...$N"; read -r _; fi }

banner "STARTING"

# ── 1) Docker installed? ──────────────────────────────────────────
if ! command -v docker >/dev/null 2>&1; then
  say "$R❌ Docker install nahi hai. Pehle Docker Desktop install karo:$N"
  say "$R   https://www.docker.com/products/docker-desktop/$N"
  pause; exit 1
fi
say "$G✅ Docker installed (v$(docker --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+'))$N"

# ── 2) Docker daemon chal raha? Nahi to Docker Desktop auto-start ─
if docker info >/dev/null 2>&1; then
  say "$G✅ Docker daemon chal raha hai$N"
else
  say "$Y⏳ Docker daemon band hai — Docker Desktop start kar raha hoon (max 2 min)...$N"
  if [ -d "/Applications/Docker.app" ]; then open -a Docker; fi
  OK=0
  for i in $(seq 1 60); do
    if docker info >/dev/null 2>&1; then OK=1; break; fi
    sleep 2
  done
  if [ "$OK" = "1" ]; then
    say "$G✅ Docker daemon READY$N"
  else
    say "$R❌ Docker 2 minute me ready nahi hua.$N"
    say "$Y   Docker Desktop manually kholo, phir ye file dobara double-click karo.$N"
    pause; exit 1
  fi
fi

# ── 2.5) Missing images pull/build (sirf pehli baar; normal start silent) ─
NEED_PULL=0
for img in floci/floci:latest-compat floci/floci-az:latest floci/floci-gcp:latest \
           mcr.microsoft.com/azure-storage/azurite fsouza/fake-gcs-server \
           gcr.io/google.com/cloudsdktool/google-cloud-cli:emulators \
           floci/floci-ui ghcr.io/drehelis/gcp-emulator-ui:main nginx:alpine \
           omab/cloudbox:latest; do
  docker image inspect "$img" >/dev/null 2>&1 || NEED_PULL=1
done
if [ "$NEED_PULL" = "1" ]; then
  say "$C⏳ Kuch images missing hain — download ho raha hai (pehli baar 5-10 min lag sakta hai)...$N"
  docker compose pull floci floci-az floci-gcp azurite fake-gcs cloudbox \
                      gcp-pubsub gcp-firestore gcp-datastore floci-ui gcp-ui landing \
                      2>&1 | tail -1 || true
fi
docker image inspect zero-cloud-service-aws-emulator >/dev/null 2>&1 \
  || docker compose build aws-emulator 2>&1 | tail -1 || true

# ── 3) STAGED start (RAM spike se crash na ho — 3 waves me) ───────
say "$C⏳ Wave 1/3: main engines (floci AWS/Azure/GCP + storage)...$N"
docker compose up -d floci floci-az floci-gcp azurite fake-gcs >/dev/null 2>&1 \
  && say "$G   ✅ engines started$N" || { say "$R❌ Wave 1 fail — upar error dekho$N"; pause; exit 1; }
sleep 10

say "$C⏳ Wave 2/3: GCP emulators + Cloudbox (Java/Python — heavy)...$N"
docker compose up -d gcp-pubsub gcp-firestore gcp-datastore cloudbox >/dev/null 2>&1 \
  && say "$G   ✅ emulators started$N" || { say "$R❌ Wave 2 fail$N"; pause; exit 1; }
sleep 15

say "$C⏳ Wave 3/3: AWS official emulator + UIs...$N"
docker compose up -d aws-emulator floci-ui gcp-ui landing >/dev/null 2>&1 \
  && say "$G   ✅ UIs started$N" || { say "$R❌ Wave 3 fail$N"; pause; exit 1; }
say "$G✅ docker compose — saare containers up$N"

# ── 4) Saare engines + GUIs ready hone ka wait (max ~3 min) ───────
# NOTE: 9297 (aws-emulator) HTTPS-only hai — usko https:// se probe karte hain
HTTP_PORTS="4566 4577 4588 10000 4443 8085 8086 8087 8888 4510 3010 9090"
HTTPS_PORTS="9297"

probe_ok() { # $1=url → exit 0 agar service up
  local code
  code=$(curl -sk -o /dev/null -w '%{http_code}' --connect-timeout 2 --max-time 3 "$1" 2>/dev/null)
  [ "$code" != "000" ] && [ "$code" != "502" ] && [ "$code" != "503" ]
}

count_up() { # stdout: "UP TOTAL"
  local UP=0 TOTAL=0 p
  for p in $HTTP_PORTS;  do TOTAL=$((TOTAL+1)); probe_ok "http://localhost:$p"   && UP=$((UP+1)); done
  for p in $HTTPS_PORTS; do TOTAL=$((TOTAL+1)); probe_ok "https://localhost:$p" && UP=$((UP+1)); done
  echo "$UP $TOTAL"
}

down_ports() { # stdout: jo ports down hain (ek per line)
  local p
  for p in $HTTP_PORTS;  do probe_ok "http://localhost:$p"   || echo "$p"; done
  for p in $HTTPS_PORTS; do probe_ok "https://localhost:$p" || echo "$p"; done
}

say "$C⏳ Saare services ready hone ka wait (engines + GUIs)...$N"
for i in $(seq 1 60); do
  read -r UP TOTAL <<< "$(count_up)"
  if [ "$UP" = "$TOTAL" ]; then say "$G✅ Saare $TOTAL services UP!$N"; break; fi
  printf "   ⏳ %d/%d endpoints up (attempt %d/60) — down: %s\n" "$UP" "$TOTAL" "$i" "$(down_ports | tr '\n' ' ')"
  sleep 3
done

# ── 4.5) Auto-repair: sirf DOWN services ka targeted restart (1 round) ─
DOWN=$(down_ports)
if [ -n "$DOWN" ]; then
  SVC=""
  for p in $DOWN; do
    case "$p" in
      4566)  SVC="$SVC floci";;         4577) SVC="$SVC floci-az";;
      4588)  SVC="$SVC floci-gcp";;     10000) SVC="$SVC azurite";;
      4443)  SVC="$SVC fake-gcs";;      8085) SVC="$SVC gcp-pubsub";;
      8086)  SVC="$SVC gcp-firestore";; 8087) SVC="$SVC gcp-datastore";;
      8888)  SVC="$SVC cloudbox";;      9297) SVC="$SVC aws-emulator";;
      4510)  SVC="$SVC floci-ui";;      3010) SVC="$SVC landing";;
      9090)  SVC="$SVC gcp-ui";;
    esac
  done
  say "$Y🔧 Down ports: $(echo $DOWN | tr '\n' ' ') → sirf in services ka restart:$N"
  say "$Y   $SVC$N"
  # shellcheck disable=SC2086
  docker compose restart $SVC >/dev/null 2>&1
  for i in $(seq 1 20); do
    read -r UP TOTAL <<< "$(count_up)"
    if [ "$UP" = "$TOTAL" ]; then say "$G✅ Repair successful — saare $TOTAL services UP!$N"; break; fi
    sleep 3
  done
fi

# ── 4.6) Honest final status (jhooth nahi bolenge) ────────────────
read -r UP TOTAL <<< "$(count_up)"
if [ "$UP" != "$TOTAL" ]; then
  say "$Y⚠️ $UP/$TOTAL endpoints up — abhi bhi ye down hain: $(down_ports | tr '\n' ' ')$N"
  say "$Y   STOP file chala ke dobara START karo — agli baar theek ho jata hai.$N"
fi

# ── 4.7) floci ka auto-spawn sidecar console (:4500) bhi wait karo ─
# (ye container floci khud spawn karta hai, boot me ~1 min leta hai)
say "$C⏳ floci built-in AWS console (:4500) boot hone ka wait...$N"
SIDECAR=0
for i in $(seq 1 50); do
  if probe_ok "http://localhost:4500"; then SIDECAR=1; break; fi
  sleep 3
done
if [ "$SIDECAR" = "1" ]; then
  say "$G✅ floci built-in console (:4500) UP$N"
else
  say "$Y⚠️ floci built-in console (:4500) abhi bhi boot ho raha hai — 1-2 min me khud aa jayega$N"
fi

# ── 5) Health check ───────────────────────────────────────────────
bash "$DIR/scripts/health-check.sh" || true

# ── 6) Landing page browser me kholo ──────────────────────────────
say "$C🌐 Browser me landing page khol raha hoon...$N"
open "http://localhost:3010" 2>/dev/null

say "$G════════════════════════════════════════════════════"
say "$G  🎉  ZERO CLOUD SERVICE — STARTED!"
say "$G════════════════════════════════════════════════════$N"
say "   Main Console   : http://localhost:4510   ← TEENO CLOUDS"
say "   AWS Console    : http://localhost:4500   (auto)"
say "   GCP Browser    : http://localhost:9090"
say "   Cloudbox Admin : http://localhost:8888"
say "   Landing        : http://localhost:3010"
say ""
pause
