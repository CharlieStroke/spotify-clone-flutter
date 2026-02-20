const express = require('express');
const router = express.Router();
const verifyToken = require('../middleware/authMiddleware');
const { createPlaylist, getPlaylists, addSongToPlaylist, deletePlaylist } = require('../controllers/playlistController');

router.use(verifyToken);

router.post('/create', createPlaylist);
router.get('/', getPlaylists);
router.post('/:playlistId/add/:trackId', addSongToPlaylist);
router.delete('/:playlistId', deletePlaylist);


module.exports = router;

