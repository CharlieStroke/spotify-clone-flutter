const express = require('express');
const router = express.Router();
const upload = require('../middleware/uploadMiddleware');
const ensureArtist = require('../middleware/artistMiddleware');
const { createAlbum, getAlbumsByArtist, deleteAlbum, updateAlbumName } = require('../controllers/albumController');
const authenticateToken = require('../middleware/authMiddleware');


router.post('/create', 
    authenticateToken, 
    ensureArtist,
    upload.fields([
        { name: 'cover', maxCount: 1 }
    ]), 
    createAlbum);
router.get('/my-albums', authenticateToken, getAlbumsByArtist);
router.put('/update/:id', authenticateToken, updateAlbumName);
router.delete('/delete/:id', authenticateToken, deleteAlbum);


module.exports = router;