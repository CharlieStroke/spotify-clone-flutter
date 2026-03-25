const pool         = require('../config/db');
const asyncHandler = require('../utils/asyncHandler');
const { createPlaylistSchema } = require('../validators/playlistValidator');
const supabaseStorage = require('../services/supabaseStorageService');

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
    let coverUrl = null;

    if (req.file) {
        try {
            coverUrl = await supabaseStorage.uploadFile(req.file, 'playlists/covers');
        } catch (uploadError) {
            const err = new Error('Error al subir la portada');
            err.statusCode = 500;
            throw err;
        }
    }

    const newPlaylist = await pool.query(
        `INSERT INTO playlists (name, description, user_id, cover_url)
         VALUES ($1, $2, $3, $4)
         RETURNING *`,
        [name, description, userId, coverUrl]
    );

    res.status(201).json({
        success: true,
        message: 'Playlist creada exitosamente',
        playlist: newPlaylist.rows[0],
    });
});

// =============================
// GET USER PLAYLISTS
// =============================
const getUserPlaylists = asyncHandler(async (req, res) => {
    const userId = req.user.userId;

    const playlists = await pool.query(
        `SELECT p.playlist_id, p.name, p.description, p.user_id, p.cover_url,
                u.username AS creator_name
         FROM playlists p
         JOIN users u ON p.user_id = u.user_id
         WHERE p.user_id = $1
         ORDER BY p.created_at DESC`,
        [userId]
    );

    res.status(200).json({
        success: playlists.rows.length > 0,
        message: playlists.rows.length > 0
            ? undefined
            : 'No hay playlists para el usuario',
        playlists: playlists.rows,
    });
});

// =============================
// ADD SONG TO PLAYLIST
// =============================
const addSongToPlaylist = asyncHandler(async (req, res) => {
    const { playlistId, songId } = req.params;
    const userId = req.user.userId;

    // Verificar que la playlist exista y pertenezca al usuario
    const playlistResult = await pool.query(
        `SELECT playlist_id FROM playlists WHERE playlist_id = $1 AND user_id = $2`,
        [playlistId, userId]
    );
    if (playlistResult.rows.length === 0) {
        const err = new Error('Playlist no encontrada');
        err.statusCode = 404;
        throw err;
    }

    // Verificar que la canción exista
    const trackResult = await pool.query(
        `SELECT song_id FROM songs WHERE song_id = $1`,
        [songId]
    );
    if (trackResult.rows.length === 0) {
        const err = new Error('Canción no encontrada');
        err.statusCode = 404;
        throw err;
    }

    // Verificar que la canción no esté ya en la playlist
    const existing = await pool.query(
        'SELECT 1 FROM playlist_songs WHERE playlist_id = $1 AND song_id = $2',
        [playlistId, songId]
    );
    if (existing.rows.length > 0) {
        const err = new Error('La canción ya está en la playlist');
        err.statusCode = 400;
        throw err;
    }

    await pool.query(
        `INSERT INTO playlist_songs (playlist_id, song_id) VALUES ($1, $2)`,
        [playlistId, songId]
    );

    res.status(200).json({
        success: true,
        message: 'Canción agregada a la playlist exitosamente',
    });
});

// =============================
// REMOVE SONG FROM PLAYLIST
// =============================
const deleteSongFromPlaylist = asyncHandler(async (req, res) => {
    const { playlistId, songId } = req.params;
    const userId = req.user.userId;

    // Verificar que la playlist exista y pertenezca al usuario
    const playlistResult = await pool.query(
        `SELECT playlist_id FROM playlists WHERE playlist_id = $1 AND user_id = $2`,
        [playlistId, userId]
    );
    if (playlistResult.rows.length === 0) {
        const err = new Error('Playlist no encontrada');
        err.statusCode = 404;
        throw err;
    }

    // Eliminar y verificar que la canción estaba en la playlist
    const result = await pool.query(
        `DELETE FROM playlist_songs WHERE playlist_id = $1 AND song_id = $2 RETURNING song_id`,
        [playlistId, songId]
    );
    if (result.rowCount === 0) {
        const err = new Error('La canción no está en la playlist');
        err.statusCode = 404;
        throw err;
    }

    res.status(200).json({
        success: true,
        message: 'Canción eliminada de la playlist exitosamente',
    });
});

// =============================
// DELETE PLAYLIST (con transacción)
// =============================
const deletePlaylist = asyncHandler(async (req, res) => {
    const { playlistId } = req.params;
    const userId = req.user.userId;

    // Verificar que la playlist exista y pertenezca al usuario
    const playlistResult = await pool.query(
        `SELECT playlist_id FROM playlists WHERE playlist_id = $1 AND user_id = $2`,
        [playlistId, userId]
    );
    if (playlistResult.rows.length === 0) {
        const err = new Error('Playlist no encontrada');
        err.statusCode = 404;
        throw err;
    }

    // Usar transacción para eliminar canciones asociadas y la playlist de forma atómica
    const client = await pool.connect();
    try {
        await client.query('BEGIN');
        await client.query(
            'DELETE FROM playlist_songs WHERE playlist_id = $1',
            [playlistId]
        );
        await client.query(
            'DELETE FROM playlists WHERE playlist_id = $1',
            [playlistId]
        );
        await client.query('COMMIT');
    } catch (err) {
        await client.query('ROLLBACK');
        throw err;
    } finally {
        client.release();
    }

    res.status(200).json({
        success: true,
        message: 'Playlist eliminada exitosamente',
    });
});

// =============================
// GET PLAYLIST SONGS (público)
// =============================
// Las playlists son públicas y accesibles por cualquier usuario autenticado,
// lo que permite buscarlas y reproducirlas desde el buscador.
const getPlaylistSongs = asyncHandler(async (req, res) => {
    const { playlistId } = req.params;

    const playlistResult = await pool.query(
        `SELECT playlist_id FROM playlists WHERE playlist_id = $1`,
        [playlistId]
    );
    if (playlistResult.rows.length === 0) {
        const err = new Error('Playlist no encontrada');
        err.statusCode = 404;
        throw err;
    }

    const songsResult = await pool.query(
        `SELECT s.song_id, s.title, s.duration, s.audio_url, s.cover_url,
                ar.stage_name AS artist_name
         FROM songs s
         JOIN playlist_songs ps ON s.song_id = ps.song_id
         LEFT JOIN albums al ON s.album_id = al.album_id
         LEFT JOIN artists ar ON al.artist_id = ar.artist_id
         WHERE ps.playlist_id = $1
         ORDER BY s.song_id ASC`,
        [playlistId]
    );

    res.status(200).json({
        success: true,
        message: 'Canciones de la playlist obtenidas exitosamente',
        songs: songsResult.rows,
    });
});

module.exports = {
    createPlaylist,
    getUserPlaylists,
    addSongToPlaylist,
    deleteSongFromPlaylist,
    deletePlaylist,
    getPlaylistSongs,
};
