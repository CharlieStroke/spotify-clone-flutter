const express = require('express');
const router = express.Router();
const { createSong, getSongsByArtist, deleteSong, updateSong, getallSongs, incrementPlayCount } = require('../controllers/songController');
const authenticateToken = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');
const validateAlbumOwnership = require('../middleware/validateAlbumOwnership');
const ensureArtist = require('../middleware/artistMiddleware');


router.post('/addsong', 
    authenticateToken, 
    ensureArtist,
    upload.fields([
        { name: 'audio', maxCount: 1 },
        { name: 'cover', maxCount: 1 }
    ]),
    validateAlbumOwnership,
    createSong
);

router.get('/', authenticateToken, getSongsByArtist);

router.delete('/delete/:id', authenticateToken, deleteSong);

router.put('/update/:id', authenticateToken, updateSong);

router.patch('/:id/play', authenticateToken, incrementPlayCount);

router.get('/all', getallSongs);

module.exports = router;