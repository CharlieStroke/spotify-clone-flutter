const express = require('express');
const router = express.Router();
const upload = require('../middleware/uploadMiddleware');
const ensureArtist = require('../middleware/artistMiddleware');
const { createAlbum, getAlbums, deleteAlbum, updateAlbumName, getAllAlbums } = require('../controllers/albumController');
const authenticateToken = require('../middleware/authMiddleware');


router.post('/create',
    authenticateToken,
    ensureArtist,
    upload.fields([
        { name: 'cover', maxCount: 1 }
    ]),
    createAlbum);
router.get('/', authenticateToken, ensureArtist, getAlbums);
router.get('/all', authenticateToken, getAllAlbums); // Nueva ruta pública para usuarios
router.put('/update/:id', authenticateToken, ensureArtist, updateAlbumName);
router.delete('/delete/:id', authenticateToken, ensureArtist, deleteAlbum);


module.exports = router;