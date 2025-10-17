#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/two-player-tic-tac-toe-30418-30428/backend"
mkdir -p "$WORKSPACE" && cd "$WORKSPACE"
# create package.json only if missing
if [ ! -f package.json ]; then
  cat > package.json <<'JSON'
{
  "name": "two-player-tic-tac-toe-backend",
  "version": "0.1.0",
  "private": true,
  "engines": { "node": ">=18" },
  "main": "index.js",
  "dependencies": {
    "express": "^4.18.0"
  },
  "devDependencies": {
    "nodemon": "^2.0.22",
    "jest": "^29.6.0",
    "dotenv": "^16.3.0"
  },
  "scripts": {
    "start": "node index.js",
    "dev": "nodemon index.js",
    "test": "jest --colors --runInBand"
  }
}
JSON
fi
# index.js - export app; only start when run directly
if [ ! -f index.js ]; then
  cat > index.js <<'JS'
const express = require('express');
const path = require('path');
const app = express();
const PORT = process.env.PORT || 3000;
app.use(express.static(path.join(__dirname, 'public')));
app.get('/_health', (req, res) => res.json({status: 'ok'}));
let server = null;
function start(){
  server = app.listen(PORT, ()=> console.log(`listening ${PORT}`));
}
function shutdown(sig){
  if(server){
    console.log('shutting down', sig || '');
    server.close(()=> { server = null; });
    setTimeout(()=> { try { process.exit(0); } catch(e){} }, 5000);
  }
}
process.on('SIGINT', ()=> shutdown('SIGINT'));
process.on('SIGTERM', ()=> shutdown('SIGTERM'));
if(require.main === module) start();
module.exports = app;
JS
fi
# public assets
mkdir -p public
[ -f public/index.html ] || cat > public/index.html <<'HTML'
<!doctype html>
<html><head><meta charset="utf-8"><title>TicTacToe</title></head><body>
<h1>Two-player Tic-Tac-Toe (static placeholder)</h1>
<script src="/app.js"></script>
</body></html>
HTML
[ -f public/app.js ] || cat > public/app.js <<'JS'
console.log('frontend placeholder');
JS
printf "ok\n"
