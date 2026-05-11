const express = require('express');
const router = express.Router();
const { createArtist, getMyArtistProfile, getArtistStats } = require('../controllers/artistController');
const authenticateToken = require('../middleware/authMiddleware');
const ensureArtist = require('../middleware/artistMiddleware');
const upload = require('../middleware/uploadMiddleware');

router.post('/create', upload.fields([{ name: 'image', maxCount: 1 }]), authenticateToken, createArtist);
router.get('/me', authenticateToken, getMyArtistProfile);
router.get('/me/stats', authenticateToken, ensureArtist, getArtistStats);

module.exports = router;
