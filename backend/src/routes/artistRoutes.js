const express = require('express');
const router = express.Router();
const { createArtist } = require('../controllers/artistController');
const authenticateToken = require('../middleware/authMiddleware');

router.post('/create', authenticateToken, createArtist);

module.exports = router;
