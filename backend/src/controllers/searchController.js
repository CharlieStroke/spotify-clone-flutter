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
            `SELECT song_id, album_id, title, duration, audio_url, cover_url 
            FROM songs 
            WHERE title ILIKE $1
            ORDER BY created_at DESC 
            LIMIT $2 OFFSET $3`,
            [searchQuery, limit, offset]
        ),
        pool.query(
            `SELECT a.album_id, a.title, a.cover_url, u.username as artist_name 
            FROM albums a 
            JOIN users u ON a.artist_id = u.user_id 
            WHERE a.title ILIKE $1
            ORDER BY a.created_at DESC 
            LIMIT $2 OFFSET $3`,
            [searchQuery, limit, offset]
        ),
        pool.query(
            // Asumiendo que las playlists globales son las que no son privadas (si tuvieras campo) o simplemente buscamos por nombre
            `SELECT playlist_id, name, description, user_id 
            FROM playlists 
            WHERE name ILIKE $1
            ORDER BY created_at DESC 
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
