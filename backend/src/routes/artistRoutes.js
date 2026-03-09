const express = require('express');
const router = express.Router();
const { createArtist, getMyArtistProfile } = require('../controllers/artistController');
const authenticateToken = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');

router.post('/create', upload.fields([{ name: 'image', maxCount: 1 }]), authenticateToken, createArtist);
router.get('/me', authenticateToken, getMyArtistProfile);

module.exports = router;
