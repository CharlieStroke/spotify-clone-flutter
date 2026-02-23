const express = require('express');
const router = express.Router();
const verifyToken = require('../middleware/authMiddleware');
const { createPlaylist, getPlaylists, addSongToPlaylist, deletePlaylist, deletesongFromPlaylist } = require('../controllers/playlistController');

router.use(verifyToken);

router.post('/create', createPlaylist);
router.get('/', getPlaylists);
router.post('/:playlistId/add/:songId', addSongToPlaylist);
router.delete('/:playlistId', deletePlaylist);
router.delete('/:playlistId/remove/:songId', deletesongFromPlaylist);


module.exports = router;

