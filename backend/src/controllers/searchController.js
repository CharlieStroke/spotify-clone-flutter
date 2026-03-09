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

    // Ejecutamos las 3 búsquedas globales de manera concurrente
    const [songsResult, albumsResult, playlistsResult] = await Promise.all([
        pool.query(
            `SELECT s.song_id, s.album_id, s.title, s.duration, s.audio_url, s.cover_url,
                    ar.stage_name as artist_name 
            FROM songs s
            LEFT JOIN albums al ON s.album_id = al.album_id
            LEFT JOIN artists ar ON al.artist_id = ar.artist_id
            WHERE s.title ILIKE $1
            ORDER BY s.created_at DESC 
            LIMIT $2 OFFSET $3`,
            [searchQuery, limit, offset]
        ),
        pool.query(
            `SELECT a.album_id, a.title, a.cover_url, ar.stage_name as artist_name 
            FROM albums a 
            JOIN artists ar ON a.artist_id = ar.artist_id 
            WHERE a.title ILIKE $1
            ORDER BY a.created_at DESC 
            LIMIT $2 OFFSET $3`,
            [searchQuery, limit, offset]
        ),
        pool.query(
            `SELECT p.playlist_id, p.name, p.description, p.user_id, u.username as creator_name
            FROM playlists p
            JOIN users u ON p.user_id = u.user_id
            WHERE p.name ILIKE $1
            ORDER BY p.created_at DESC 
            LIMIT $2 OFFSET $3`,
            [searchQuery, limit, offset]
        )
    ]);

    res.status(200).json({
        success: true,
        message: 'Búsqueda global exitosa',
        songs: songsResult.rows,
        albums: albumsResult.rows,
        playlists: playlistsResult.rows,
        pagination: {
            page,
            limit,
        }
    });
});

module.exports = {
    searchSongs
};
