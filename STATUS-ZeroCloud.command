#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
#  ☁️  ZERO CLOUD SERVICE — STATUS CHECK
#  Double-click karo → containers + sab endpoints ka live status.
# ═══════════════════════════════════════════════════════════════════
export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit 1

G='\033[0;32m'; R='\033[0;31m'; Y='\033[1;33m'; B='\033[0;34m'; C='\033[0;36m'; N='\033[0m'
say()   { printf "%b\n" "$1"; }
banner(){ say "$C════════════════════════════════════════════════════"; say "$C  ☁️  ZERO CLOUD SERVICE  —  $1"; say "$C════════════════════════════════════════════════════$N"; }
pause() { if [ -t 0 ]; then printf "%b" "$Y→ Window band karne ke liye [Enter] dabao...$N"; read -r _; fi }

banner "STATUS"

if ! command -v docker >/dev/null 2>&1; then
  say "$R❌ Docker install nahi hai.$N"; pause; exit 1
fi

if ! docker info >/dev/null 2>&1; then
  say "$R❌ Docker daemon band hai — pehle START-ZeroCloud.command chalao.$N"
  pause; exit 1
fi

say "$C─── Containers ───$N"
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null
say ""
say "$C─── RAM usage ───$N"
docker stats --no-stream --format "table {{.Name}}\t{{.MemUsage}}" 2>/dev/null | grep -E "zcs-|NAME"
say ""
say "$C─── Endpoints ───$N"
bash "$DIR/scripts/health-check.sh" || true

say ""
pause
