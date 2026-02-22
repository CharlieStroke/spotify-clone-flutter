const express = require('express');
const router = express.Router();
const { createAlbum, getAlbumsByArtist, deleteAlbum, updateAlbumName } = require('../controllers/albumController');
const authenticateToken = require('../middleware/authMiddleware');


router.post('/create', authenticateToken, createAlbum);
router.get('/my-albums', authenticateToken, getAlbumsByArtist);
router.put('/update/:id', authenticateToken, updateAlbumName);
router.delete('/delete/:id', authenticateToken, deleteAlbum);


module.exports = router;