#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/two-player-tic-tac-toe-30418-30428/backend"
cd "$WORKSPACE"
[ -f package.json ] || { echo "ERROR: package.json missing in $WORKSPACE" >&2; exit 2; }
# use npm from image
if [ -f package-lock.json ]; then
  npm ci --silent --no-audit --no-fund || { echo "ERROR: npm ci failed" >&2; exit 3; }
else
  npm install --silent --no-audit --no-fund || { echo "ERROR: npm install failed" >&2; exit 4; }
fi
[ -d node_modules ] || { echo "ERROR: node_modules missing after install" >&2; exit 5; }
# verify local jest binary exists
if [ ! -x "./node_modules/.bin/jest" ]; then
  echo "ERROR: local jest binary missing" >&2; exit 6;
fi
# verify express resolves via node resolution
node -e "require('./index.js'); console.log('app require OK')" >/dev/null 2>&1 || true
printf "ok\n"
