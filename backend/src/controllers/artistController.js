const pool         = require('../config/db');
const asyncHandler = require('../utils/asyncHandler');
const { createArtistSchema } = require('../validators/artistValidator');
const { uploadFile } = require('../services/supabaseStorageService');

// =============================
// CREATE ARTIST
// =============================
const createArtist = asyncHandler(async (req, res) => {
    const userId = req.user.userId;

    // Verificar que el usuario no tenga ya un perfil de artista
    const userArtist = await pool.query(
        'SELECT artist_id FROM artists WHERE user_id = $1',
        [userId]
    );
    if (userArtist.rows.length > 0) {
        const err = new Error('El usuario ya tiene un perfil de artista');
        err.statusCode = 400;
        throw err;
    }

    const { error } = createArtistSchema.validate(req.body);
    if (error) {
        error.statusCode = 400;
        throw error;
    }

    const { stage_name, bio } = req.body;

    // Verificar nombre artístico ANTES de subir la imagen para evitar
    // archivos huérfanos en Supabase Storage si el nombre ya está en uso
    const artistExists = await pool.query(
        'SELECT stage_name FROM artists WHERE stage_name = $1',
        [stage_name]
    );
    if (artistExists.rows.length > 0) {
        const err = new Error('El nombre artístico ya existe');
        err.statusCode = 400;
        throw err;
    }

    const imageFile = req.files?.image?.[0];
    if (!imageFile) {
        const err = new Error('Archivo de imagen es requerido');
        err.statusCode = 400;
        throw err;
    }

    const image_url = await uploadFile(imageFile, 'artists');

    const newArtist = await pool.query(
        `INSERT INTO artists (user_id, stage_name, bio, image_url)
         VALUES ($1, $2, $3, $4)
         RETURNING artist_id, user_id, stage_name, bio, image_url`,
        [userId, stage_name, bio, image_url]
    );

    res.status(201).json({
        success: true,
        message: 'Artista creado exitosamente',
        artist: newArtist.rows[0],
    });
});

// =============================
// GET MY ARTIST PROFILE
// =============================
const getMyArtistProfile = asyncHandler(async (req, res) => {
    const userId = req.user.userId;

    const result = await pool.query(
        'SELECT * FROM artists WHERE user_id = $1',
        [userId]
    );

    if (result.rows.length === 0) {
        const err = new Error('El usuario no tiene un perfil de artista');
        err.statusCode = 404;
        throw err;
    }

    res.json({
        success: true,
        artist: result.rows[0],
    });
});

// =============================
// GET ARTIST STATS
// =============================
const getArtistStats = asyncHandler(async (req, res) => {
    const artistId = req.artist.artist_id;

    const [totals, topSongs, playsByAlbum] = await Promise.all([
        pool.query(
            `SELECT
               COALESCE(SUM(s.plays), 0) AS total_plays,
               COUNT(s.song_id)           AS total_songs,
               COUNT(DISTINCT s.album_id) AS total_albums
             FROM songs s
             WHERE s.album_id IN (
               SELECT album_id FROM albums WHERE artist_id = $1
             )`,
            [artistId]
        ),
        pool.query(
            `SELECT s.song_id, s.title, s.plays, s.cover_url
             FROM songs s
             WHERE s.album_id IN (
               SELECT album_id FROM albums WHERE artist_id = $1
             )
             ORDER BY s.plays DESC
             LIMIT 5`,
            [artistId]
        ),
        pool.query(
            `SELECT al.album_id, al.title, al.cover_url,
                    COALESCE(SUM(s.plays), 0) AS plays
             FROM albums al
             LEFT JOIN songs s ON s.album_id = al.album_id
             WHERE al.artist_id = $1
             GROUP BY al.album_id, al.title, al.cover_url
             ORDER BY plays DESC`,
            [artistId]
        ),
    ]);

    const row = totals.rows[0];
    res.status(200).json({
        success: true,
        stats: {
            total_plays:   parseInt(row.total_plays, 10),
            total_songs:   parseInt(row.total_songs, 10),
            total_albums:  parseInt(row.total_albums, 10),
            top_songs: topSongs.rows.map(s => ({
                song_id:   s.song_id,
                title:     s.title,
                plays:     parseInt(s.plays, 10),
                cover_url: s.cover_url,
            })),
            plays_by_album: playsByAlbum.rows.map(a => ({
                album_id:  a.album_id,
                title:     a.title,
                cover_url: a.cover_url,
                plays:     parseInt(a.plays, 10),
            })),
        },
    });
});

// =============================
// GET PUBLIC ARTIST PROFILE
// =============================
const getPublicArtistProfile = asyncHandler(async (req, res) => {
    const artistId = parseInt(req.params.id, 10);

    const result = await pool.query(
        `SELECT artist_id, stage_name, bio, image_url
         FROM artists WHERE artist_id = $1`,
        [artistId]
    );

    if (result.rows.length === 0) {
        const err = new Error('Artista no encontrado');
        err.statusCode = 404;
        throw err;
    }

    res.status(200).json({ success: true, artist: result.rows[0] });
});

// =============================
// GET PUBLIC ARTIST TOP SONGS
// =============================
const getPublicArtistTopSongs = asyncHandler(async (req, res) => {
    const artistId = parseInt(req.params.id, 10);

    const result = await pool.query(
        `SELECT s.song_id, s.title, s.plays, s.cover_url, s.audio_url,
                s.duration, s.album_id, ar.stage_name AS artist_name
         FROM songs s
         JOIN albums al ON s.album_id = al.album_id
         JOIN artists ar ON al.artist_id = ar.artist_id
         WHERE al.artist_id = $1
         ORDER BY s.plays DESC
         LIMIT 5`,
        [artistId]
    );

    res.status(200).json({ success: true, songs: result.rows });
});

// =============================
// GET PUBLIC ARTIST ALBUMS
// =============================
const getPublicArtistAlbums = asyncHandler(async (req, res) => {
    const artistId = parseInt(req.params.id, 10);

    const result = await pool.query(
        `SELECT album_id, title, cover_url
         FROM albums
         WHERE artist_id = $1
         ORDER BY created_at DESC`,
        [artistId]
    );

    res.status(200).json({ success: true, albums: result.rows });
});

module.exports = {
    createArtist,
    getMyArtistProfile,
    getArtistStats,
    getPublicArtistProfile,
    getPublicArtistTopSongs,
    getPublicArtistAlbums,
};
