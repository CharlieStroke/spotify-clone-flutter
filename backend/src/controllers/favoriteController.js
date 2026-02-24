const pool = require('../config/db');
const asyncHandler = require('../utils/asyncHandler');

const addtoFavorites = asyncHandler(async (req, res) => {

    const songId = req.params.id;
    const userId = req.user.userId;

    if (!songId) {
        return res.status(400).json({
            success: false,
            message: 'ID de canción es requerido'
        });
    }

    const songalreadyFavorite = await pool.query(
        `SELECT * FROM favorites WHERE user_id = $1 AND song_id = $2`,
        [userId, songId]
    );
    if (songalreadyFavorite.rows.length > 0) {
        return res.status(400).json({
            success: false,
            message: 'La canción ya está en favoritos'
        });
    }

    const songResult = await pool.query(
        `SELECT * FROM songs WHERE song_id = $1`,
        [songId]
    );

    if (songResult.rows.length === 0) {
        return res.status(404).json({
            success: false,
            message: 'Canción no encontrada'
        });
    }


    const favoriteResult = await pool.query(
        `INSERT INTO favorites (user_id, song_id) VALUES ($1, $2) RETURNING *`,
        [userId, songId]
    );



    res.status(201).json({
        success: true,
        message: 'Canción agregada a favoritos exitosamente',
        favorite: favoriteResult.rows[0]
    });
});

const getfavorites = asyncHandler(async (req, res) => {

    const userId = req.user.userId;

    const favorites = await pool.query(
        `SELECT s.song_id, s.title, s.duration, s.audio_url, s.cover_url 
        FROM favorites f
        JOIN songs s ON f.song_id = s.song_id
        WHERE f.user_id = $1`,
        [userId]
    );

    res.status(200).json({
        success: true,
        message: 'Canciones favoritas obtenidas exitosamente',
        favorites: favorites.rows
    });
});

const deleteFavorite = asyncHandler(async (req, res) => {

    const songId = req.params.id;
    const userId = req.user.userId;

    await pool.query(
        `DELETE FROM favorites WHERE user_id = $1 AND song_id = $2`,
        [userId, songId]
    );

    res.status(200).json({
        success: true,
        message: 'Canción eliminada de favoritos exitosamente'
    });
});

module.exports = {
    addtoFavorites,
    getfavorites,
    deleteFavorite
};