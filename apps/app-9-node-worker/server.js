const express = require('express');
const app = express();
const os = require('os');

let processCount = 0;

app.get('/', (req, res) => {
  res.send('Hello from App-9 (Node.js Worker)! 🟩\n');
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', app: 'app-9' });
});

app.post('/process', (req, res) => {
  processCount++;
  res.json({
    app: 'app-9',
    message: 'Process queued',
    process_id: processCount,
    hostname: os.hostname()
  });
});

app.get('/stats', (req, res) => {
  res.json({
    app: 'app-9',
    type: 'Node.js Worker',
    processed_items: processCount,
    uptime: Math.floor(process.uptime()),
    pid: process.pid
  });
});

app.get('/ready', (req, res) => {
  res.json({ ready: true, app: 'app-9' });
});

const PORT = 8080;
app.listen(PORT, () => {
  console.log(`App-9 listening on port ${PORT}`);
});
