const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');

router.get('/', async (req, res) => {
  try {
    // Check database connection here
    const dbStatus = mongoose.connection.readyState === 1 ? 'connected' : 'disconnected';

    if (dbStatus === 'connected') {
      res.status(200).json({ 
        status: 'Service operational',
        database: dbStatus,
        timestamp: new Date().toISOString(),
        version: process.env.npm_package_version
      });
    } else {
      res.status(503).json({ 
        status: 'Database connection failed',
        database: dbStatus,
        timestamp: new Date().toISOString(),
        version: process.env.npm_package_version
      });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ 
      status: 'Internal server error',
      database: 'unknown',
      timestamp: new Date().toISOString(),
      version: process.env.npm_package_version
    });
  }
});

module.exports = router;