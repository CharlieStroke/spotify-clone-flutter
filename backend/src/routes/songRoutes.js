const express = require('express');
const router = express.Router();
const { createSong } = require('../controllers/songController');
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



module.exports = router;