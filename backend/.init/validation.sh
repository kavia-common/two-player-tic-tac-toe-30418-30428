#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/two-player-tic-tac-toe-30418-30428/backend"
cd "$WORKSPACE"
NODE_BIN=$(command -v node || true)
[ -n "$NODE_BIN" ] || { echo "ERROR: node not found" >&2; exit 2; }
PORT=${PORT:-3000}
TIMEOUT=${TIMEOUT:-30}
OUTDIR=$(mktemp -d /tmp/backend-validate.XXXX)
HEALTH_FILE="$OUTDIR/health.json"
PAGE_FILE="$OUTDIR/page.html"
LOGFILE="$OUTDIR/server.log"
# start server in background using local environment only
NODE_ENV=development PORT=$PORT "$NODE_BIN" index.js >"$LOGFILE" 2>&1 &
PID=$!
start_ts=$(date +%s)
while true; do
  if curl -sSf "http://127.0.0.1:$PORT/_health" -o /dev/null 2>/dev/null; then break; fi
  now=$(date +%s);
  if [ $((now-start_ts)) -ge $TIMEOUT ]; then
    echo "ERROR: timeout waiting for server" >&2
    ps -o pid,cmd -p "$PID" 2>/dev/null || true
    kill "$PID" 2>/dev/null || true
    exit 9
  fi
  sleep 1
done
# capture health and page
curl -sS "http://127.0.0.1:$PORT/_health" -o "$HEALTH_FILE" || { echo "ERROR: cannot fetch health" >&2; kill "$PID" 2>/dev/null || true; exit 10; }
curl -sS "http://127.0.0.1:$PORT/" -o "$PAGE_FILE" || true
# graceful stop
kill -SIGINT "$PID" 2>/dev/null || true
for i in 1 2 3 4 5; do if ! kill -0 "$PID" 2>/dev/null; then break; fi; sleep 1; done
if kill -0 "$PID" 2>/dev/null; then kill -SIGTERM "$PID" 2>/dev/null || true; fi
wait "$PID" 2>/dev/null || true
# produce JSON evidence using python3
if command -v python3 >/dev/null 2>&1; then
  python3 - <<PY
import json
try:
  h=open('$HEALTH_FILE','r',encoding='utf-8').read()
except Exception:
  h=''
try:
  p=open('$PAGE_FILE','r',encoding='utf-8').read()[:200]
except Exception:
  p=''
try:
  s=open('$LOGFILE','r',encoding='utf-8').read()[:1000]
except Exception:
  s=''
print(json.dumps({'health': h, 'page_snippet': p, 'server_log': s}))
PY
else
  health_escaped=$(printf '%s' "$(cat '$HEALTH_FILE' 2>/dev/null || true)" | sed 's/"/\\"/g' | tr -d '\n')
  page_escaped=$(printf '%s' "$(cat '$PAGE_FILE' 2>/dev/null || true)" | sed 's/"/\\"/g' | tr -d '\n' | cut -c1-200)
  log_escaped=$(printf '%s' "$(cat '$LOGFILE' 2>/dev/null || true)" | sed 's/"/\\"/g' | tr -d '\n' | cut -c1-1000)
  printf '{"health":"%s","page_snippet":"%s","server_log":"%s"}\n' "$health_escaped" "$page_escaped" "$log_escaped"
fi
printf "ok\n"
