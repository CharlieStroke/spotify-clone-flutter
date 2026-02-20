const pool = require('../config/db');
const asyncHandler = require('../utils/asyncHandler');
const { createPlaylistSchema, addSongSchema } = require('../validators/playlistValidator');

// =============================
// CREATE PLAYLIST
// =============================
const createPlaylist = asyncHandler(async (req, res) => {
    const { error } = createPlaylistSchema.validate(req.body);
    if (error) {
        error.statusCode = 400;
        throw error;
    }

    const { name, description } = req.body;
    const userId = req.user.userId;

    const newPlaylist = await pool.query(
        `INSERT INTO playlists (name, description, user_id) 
        VALUES ($1, $2, $3) 
        RETURNING *`,
        [name, description, userId]
    );
    
    res.status(201).json({
        success: true,
        message: 'Playlist creada exitosamente',
        playlist: newPlaylist.rows[0]
    });
});

const getPlaylists = asyncHandler(async (req, res) => {
    
    const userId = req.user.userId;

    const playlists = await pool.query(
        `SELECT playlist_id, name, description 
        FROM playlists WHERE user_id = $1 
        ORDER BY created_at DESC`,
        [userId]
    );
    
    res.status(200).json({
        success: true,
        playlists: playlists.rows
    });
});

const addSongToPlaylist = asyncHandler(async (req, res) => {

    const { error } = addSongSchema.validate(req.body);
    if (error) {
        error.statusCode = 400;
        throw error;
    }

    const { playlistId } = req.params;
    const { trackId } = req.body;
    const userId = req.user.userId;

    // Verificar que la playlist exista y pertenezca al usuario
    const playlistResult = await pool.query(
        `SELECT * 
        FROM playlists 
        WHERE playlist_id = $1 
        AND user_id = $2`,
        [playlistId, userId]
    );
    if (playlistResult.rows.length === 0) {
        const err = new Error('Playlist no encontrada');
        err.statusCode = 404;
        throw err;
    }

    // Verificar que la cancion ya esta en la playlist 
    const existing = await pool.query(
        'SELECT * FROM playlist_canciones WHERE playlist_id = $1 AND cancion_id = $2',
        [playlistId, trackId]
    );

    if (existing.rows.length > 0) {
        const err = new Error('La canción ya está en la playlist');
        err.statusCode = 400;
        throw err;
    }

    const trackResult = await pool.query(
        `SELECT * 
        FROM songs 
        WHERE song_id = $1`,
        [trackId]
    );

    if (trackResult.rows.length === 0) {
        const err = new Error('Canción no encontrada');
        err.statusCode = 404;
        throw err;
    }

    // Agregar la canción a la playlist
    await pool.query(
        `INSERT INTO playlist_songs 
        (playlist_id, song_id) 
        VALUES ($1, $2)`,
        [playlistId, trackId]
    );

    res.status(200).json({
        success: true,
        message: 'Canción agregada a la playlist exitosamente'
    });
});

const deletePlaylist = asyncHandler(async (req, res) => {

    const { playlistId } = req.params;
    const userId = req.user.userId;

    // Verificar que la playlist exista y pertenezca al usuario
    const playlistResult = await pool.query(
        `SELECT * 
        FROM playlists 
        WHERE playlist_id = $1 AND user_id = $2`,
        [playlistId, userId]
    );

    if (playlistResult.rows.length === 0) {
        const err = new Error('Playlist no encontrada');
        err.statusCode = 404;
        throw err;
    }

    // Eliminar la playlist
    await pool.query(
        `DELETE FROM playlists 
        WHERE playlist_id = $1`,
        [playlistId]
    );

    res.status(200).json({
        success: true,
        message: 'Playlist eliminada exitosamente'
    });
});

module.exports = {
    createPlaylist,
    getPlaylists,
    addSongToPlaylist,
    deletePlaylist
};