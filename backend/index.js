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
