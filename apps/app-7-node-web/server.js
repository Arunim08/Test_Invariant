const express = require('express');
const app = express();
const os = require('os');

app.get('/', (req, res) => {
  res.send('Hello from App-7 (Node.js Web Server)! 🟩\n');
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', app: 'app-7' });
});

app.get('/info', (req, res) => {
  res.json({
    app: 'app-7',
    type: 'Node.js Web Server',
    hostname: os.hostname(),
    platform: process.platform,
    node_version: process.version
  });
});

app.get('/api/data', (req, res) => {
  res.json({
    app: 'app-7',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

const PORT = 8080;
app.listen(PORT, () => {
  console.log(`App-7 listening on port ${PORT}`);
});
