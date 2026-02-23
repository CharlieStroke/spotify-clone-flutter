const express = require('express');
const router = express.Router();
const verifyToken = require('../middleware/authMiddleware');
const { createPlaylist, getUserPlaylists, addSongToPlaylist, deletePlaylist, deletesongFromPlaylist, getPlaylistSongs } = require('../controllers/playlistController');

router.use(verifyToken);



router.post('/create', createPlaylist);

router.get('/userplaylists', getUserPlaylists);

router.post('/:playlistId/add/:songId', addSongToPlaylist);

router.delete('/:playlistId', deletePlaylist);

router.delete('/:playlistId/remove/:songId', deletesongFromPlaylist);

router.get('/:playlistId/songs', getPlaylistSongs);


module.exports = router;

