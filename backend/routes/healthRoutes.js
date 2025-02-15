const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');

router.get('/', (req, res) => {
  const dbStatus = mongoose.connection.readyState === 1 ? 'connected' : 'disconnected';
  res.status(200).json({ 
    status: 'Service operational',
    database: dbStatus,
    timestamp: new Date().toISOString(),
    version: process.env.npm_package_version
  });
});

module.exports = router;