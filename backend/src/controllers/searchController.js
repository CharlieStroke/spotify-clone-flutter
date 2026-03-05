const pool = require('../config/db');
const asyncHandler = require('../utils/asyncHandler');
const paginate = require('../utils/pagination');

const searchSongs = asyncHandler(async (req, res) => {
    const { q } = req.query;
    const { page, limit, offset } = paginate.getPagination(req);

    if (!q) {
        return res.status(400).json({
            success: false,
            message: 'El parámetro de búsqueda "q" es requerido'
        });
    }

    // ILIKE es la versión case-insensitive de LIKE en PostgreSQL
    const searchQuery = `%${q}%`;

    const totalResult = await pool.query(
        `SELECT COUNT(*) FROM songs 
            WHERE title ILIKE $1`,
        [searchQuery]
    );

    const totalItems = parseInt(totalResult.rows[0].count);

    const result = await pool.query(
        `SELECT song_id, album_id, title, duration, audio_url, cover_url 
        FROM songs 
        WHERE title ILIKE $1
        ORDER BY created_at DESC 
        LIMIT $2 OFFSET $3`,
        [searchQuery, limit, offset]
    );

    const totalPages = Math.ceil(totalItems / limit);

    res.status(200).json({
        success: true,
        message: 'Búsqueda de canciones exitosa',
        songs: result.rows,
        pagination: {
            page,
            limit,
            totalItems,
            totalPages
        }
    });
});

module.exports = {
    searchSongs
};
