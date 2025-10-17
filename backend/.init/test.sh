#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/two-player-tic-tac-toe-30418-30428/backend"
cd "$WORKSPACE"
[ -f package.json ] || { echo "ERROR: package.json missing" >&2; exit 2; }
# jest config if missing
[ -f jest.config.js ] || cat > jest.config.js <<'JS'
module.exports = { testEnvironment: 'node', verbose: false };
JS
# create test only if absent
mkdir -p __tests__
if [ ! -f __tests__/smoke.test.js ]; then
  cat > __tests__/smoke.test.js <<'JS'
test('app module exports', ()=>{
  const app = require('../index.js');
  expect(app).toBeDefined();
});
JS
fi
# run tests with isolated env, prefer local npm scripts
NODE_ENV=test npm test --silent || { echo 'ERROR: tests failed' >&2; exit 3; }
printf "ok\n"
