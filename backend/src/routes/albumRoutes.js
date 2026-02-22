const express = require('express');
const router = express.Router();
const { createAlbum } = require('../controllers/albumController');
const authenticateToken = require('../middleware/authMiddleware');

router.post('/create', authenticateToken, createAlbum);

module.exports = router;