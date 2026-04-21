const express = require('express');
const app = express();
const os = require('os');

app.get('/', (req, res) => {
  res.send('Hello from App-8 (Node.js API)! 🟩\n');
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', app: 'app-8' });
});

app.get('/api/v1/info', (req, res) => {
  res.json({
    app: 'app-8',
    type: 'Node.js API',
    hostname: os.hostname(),
    cpus: os.cpus().length,
    memory_mb: Math.floor(os.totalmem() / 1024 / 1024)
  });
});

app.get('/api/v1/status', (req, res) => {
  const freeMemory = os.freemem();
  const totalMemory = os.totalmem();
  res.json({
    app: 'app-8',
    uptime: process.uptime(),
    memory_usage_mb: Math.floor((totalMemory - freeMemory) / 1024 / 1024),
    free_memory_mb: Math.floor(freeMemory / 1024 / 1024)
  });
});

const PORT = 8080;
app.listen(PORT, () => {
  console.log(`App-8 listening on port ${PORT}`);
});
