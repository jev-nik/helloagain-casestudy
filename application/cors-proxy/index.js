const express = require('express');
const request = require('request');
const app = express();

// Middleware to add CORS headers
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }
  next();
});

// Proxy all requests to the target URL
app.all('/*', (req, res) => {
  const targetUrl = req.url.slice(1); // Remove leading slash
  if (!targetUrl) {
    return res.status(400).send('No target URL provided');
  }

  // Forward the request to the target URL
  req.pipe(request({
    url: targetUrl,
    method: req.method,
    headers: {
      'User-Agent': req.get('User-Agent')
    }
  })).on('error', (err) => {
    res.status(500).send(`Error forwarding request: ${err.message}`);
  }).pipe(res);
});

// Start the server
const port = process.env.PORT || 8080;
app.listen(port, () => {
  console.log(`CORS Proxy running on port ${port}`);
});