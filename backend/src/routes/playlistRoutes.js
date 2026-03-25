const express = require('express');
const router = express.Router();
const verifyToken = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');
const { createPlaylist, getUserPlaylists, addSongToPlaylist, deletePlaylist, deleteSongFromPlaylist, getPlaylistSongs } = require('../controllers/playlistController');

router.use(verifyToken);

router.post('/create', upload.single('cover_image'), createPlaylist);

router.get('/', getUserPlaylists);

router.post('/:playlistId/add/:songId', addSongToPlaylist);

router.delete('/:playlistId', deletePlaylist);

router.delete('/:playlistId/remove/:songId', deleteSongFromPlaylist);

router.get('/:playlistId/songs', getPlaylistSongs);


module.exports = router;

