const pool         = require('../config/db');
const asyncHandler = require('../utils/asyncHandler');
const paginate     = require('../utils/pagination');

// =============================
// ADD TO FAVORITES
// =============================
const addToFavorites = asyncHandler(async (req, res) => {
    const songId = req.params.id;
    const userId = req.user.userId;

    // Verificar que la canción exista
    const songResult = await pool.query(
        `SELECT song_id FROM songs WHERE song_id = $1`,
        [songId]
    );
    if (songResult.rows.length === 0) {
        const err = new Error('Canción no encontrada');
        err.statusCode = 404;
        throw err;
    }

    // Verificar que no esté ya en favoritos
    const alreadyFavorite = await pool.query(
        `SELECT 1 FROM favorites WHERE user_id = $1 AND song_id = $2`,
        [userId, songId]
    );
    if (alreadyFavorite.rows.length > 0) {
        const err = new Error('La canción ya está en favoritos');
        err.statusCode = 400;
        throw err;
    }

    const favoriteResult = await pool.query(
        `INSERT INTO favorites (user_id, song_id) VALUES ($1, $2) RETURNING *`,
        [userId, songId]
    );

    res.status(201).json({
        success: true,
        message: 'Canción agregada a favoritos exitosamente',
        favorite: favoriteResult.rows[0],
    });
});

// =============================
// GET FAVORITES (con paginación)
// =============================
const getFavorites = asyncHandler(async (req, res) => {
    const userId = req.user.userId;
    const { page, limit, offset } = paginate.getPagination(req);

    const [totalResult, favorites] = await Promise.all([
        pool.query(
            'SELECT COUNT(*) FROM favorites WHERE user_id = $1',
            [userId]
        ),
        pool.query(
            `SELECT s.song_id, s.title, s.duration, s.audio_url, s.cover_url,
                    al.album_id, al.title AS album_name, ar.stage_name AS artist_name
             FROM favorites f
             JOIN songs s ON f.song_id = s.song_id
             LEFT JOIN albums al ON s.album_id = al.album_id
             LEFT JOIN artists ar ON al.artist_id = ar.artist_id
             WHERE f.user_id = $1
             ORDER BY f.created_at DESC
             LIMIT $2 OFFSET $3`,
            [userId, limit, offset]
        ),
    ]);

    const totalItems = parseInt(totalResult.rows[0].count, 10);

    res.status(200).json({
        success: true,
        message: 'Canciones favoritas obtenidas exitosamente',
        favorites: favorites.rows,
        pagination: {
            page,
            limit,
            totalItems,
            totalPages: Math.ceil(totalItems / limit),
        },
    });
});

// =============================
// DELETE FAVORITE
// =============================
const deleteFavorite = asyncHandler(async (req, res) => {
    const songId = req.params.id;
    const userId = req.user.userId;

    const result = await pool.query(
        `DELETE FROM favorites WHERE user_id = $1 AND song_id = $2 RETURNING song_id`,
        [userId, songId]
    );
    if (result.rowCount === 0) {
        const err = new Error('La canción no está en favoritos');
        err.statusCode = 404;
        throw err;
    }

    res.status(200).json({
        success: true,
        message: 'Canción eliminada de favoritos exitosamente',
    });
});

module.exports = {
    addToFavorites,
    getFavorites,
    deleteFavorite,
};
