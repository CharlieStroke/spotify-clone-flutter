const express = require('express');
const router = express.Router();
const { createArtist, getMyArtistProfile, getArtistStats,
        getPublicArtistProfile, getPublicArtistTopSongs, getPublicArtistAlbums,
        followArtist, unfollowArtist } = require('../controllers/artistController');
const authenticateToken = require('../middleware/authMiddleware');
const ensureArtist = require('../middleware/artistMiddleware');
const upload = require('../middleware/uploadMiddleware');

router.post('/create', upload.fields([{ name: 'image', maxCount: 1 }]), authenticateToken, createArtist);
router.get('/me', authenticateToken, getMyArtistProfile);
router.get('/me/stats', authenticateToken, ensureArtist, getArtistStats);

router.get('/:id',              authenticateToken, getPublicArtistProfile);
router.get('/:id/top-songs',    authenticateToken, getPublicArtistTopSongs);
router.get('/:id/albums',       authenticateToken, getPublicArtistAlbums);
router.post('/:id/follow',      authenticateToken, followArtist);
router.delete('/:id/follow',    authenticateToken, unfollowArtist);

module.exports = router;
