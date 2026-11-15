#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
#  ☁️  ZERO CLOUD SERVICE — ONE-CLICK STOP
#  Double-click karo → sab containers gracefully stop.
#  DATA DELETE NAHI HOTA — sab ./data/ me safe rehta hai.
#  Dobara shuru karne ke liye START-ZeroCloud.command double-click.
# ═══════════════════════════════════════════════════════════════════
export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit 1

G='\033[0;32m'; R='\033[0;31m'; Y='\033[1;33m'; B='\033[0;34m'; C='\033[0;36m'; N='\033[0m'
say()   { printf "%b\n" "$1"; }
banner(){ say "$R════════════════════════════════════════════════════"; say "$R  ☁️  ZERO CLOUD SERVICE  —  $1"; say "$R════════════════════════════════════════════════════$N"; }
pause() { if [ -t 0 ]; then printf "%b" "$Y→ Window band karne ke liye [Enter] dabao...$N"; read -r _; fi }

banner "STOPPING"

if ! command -v docker >/dev/null 2>&1; then
  say "$R❌ Docker install nahi hai — kuch stop karne ko nahi.$N"
  pause; exit 1
fi

if ! docker info >/dev/null 2>&1; then
  say "$Yℹ️  Docker daemon hi band hai — kuch chal nahi raha, kuch nahi karna.$N"
  pause; exit 0
fi

say "$C⏳ Containers stop ho rahe hain (gracefully, data safe)...$N"
if docker compose stop; then
  say "$G✅ Sab containers STOPPED$N"
else
  say "$R❌ Stop me dikkat aayi. Force stop: docker compose kill$N"
  pause; exit 1
fi

# floci ka auto-spawned sidecar console (compose project ka hissa nahi)
docker stop floci-aws-ui >/dev/null 2>&1 && say "$G✅ floci sidecar console bhi band$N" || true

RUNNING=$(docker compose ps --quiet 2>/dev/null | wc -l | tr -d ' ')
if [ "$RUNNING" = "0" ]; then
  say "$G✅ Verify: 0 containers chal rahe hain$N"
else
  say "$Y⚠️ $RUNNING containers abhi bhi chal rahe hain — dobara STOP try karo$N"
fi

say "$G════════════════════════════════════════════════════"
say "$G  🛑  ZERO CLOUD SERVICE — STOPPED"
say "$G════════════════════════════════════════════════════$N"
say "   💾 Data sab mehfooz hai: ./data/"
say "   ▶️  Dobara start: START-ZeroCloud.command double-click"
say ""
pause
