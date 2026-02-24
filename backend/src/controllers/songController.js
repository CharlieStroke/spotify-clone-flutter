const pool = require('../config/db');
const asyncHandler = require('../utils/asyncHandler');
const paginate = require('../utils/pagination');
const { uploadFile } = require('../services/objectStorageService');

const createSong = asyncHandler(async (req, res) => {
    
    const { title, album_id, duration } = req.body;
    const audio = req.files?.audio?.[0]; // Assuming the song is uploaded using multer and available in req.files.audio
    const cover = req.files?.cover?.[0]; // Assuming the cover is uploaded using multer and available in req.files.cover

    if (!audio) {
        const err = new Error('Archivo de canción es requerido');
        err.statusCode = 400;
        throw err;
    }

    if (!cover) {
        const err = new Error('Archivo de portada es requerido');
        err.statusCode = 400;
        throw err;
    }

    const songName = `songs/tracks/${Date.now()}_${audio.originalname}`;
    const coverName = `songs/covers/${Date.now()}_${cover.originalname}`;
     // Replace spaces with underscores for better URL handling

    const songUrl = await uploadFile(
        audio.buffer,
        songName,
        audio.mimetype
    );

        const coverUrl = await uploadFile(
            cover.buffer,
            coverName,
            cover.mimetype
        );

    const result = await pool.query(
        `INSERT INTO songs (title, album_id, duration, audio_url, cover_url)
        VALUES ($1, $2, $3, $4, $5)
        RETURNING *`,
        [title, album_id, duration, songUrl, coverUrl]
    );

    console.log(req.files);
    res.status(201).json({
        success: true,
        message: 'Canción creada exitosamente',
        song: result.rows[0]
        
    });
});

const getallSongs = asyncHandler(async (req, res) => {

    const { page, limit, offset } = paginate.getPagination(req);

    const totalResult = await pool.query(`SELECT COUNT(*) FROM songs`);

    const totalItems = parseInt(totalResult.rows[0].count);
    
    const result = await pool.query(
        `SELECT song_id, album_id, title, duration, audio_url, cover_url 
        FROM songs 
        ORDER BY created_at DESC 
        LIMIT $1 OFFSET $2`,
        [limit, offset]
    );

    const totalPages = Math.ceil(totalItems / limit);
    
    res.status(200).json({
        success: true,
        message: 'Canciones obtenidas exitosamente',
        songs: result.rows,
        pagination: {
            page,
            limit,
            totalItems,
            totalPages
        }
    });
});

const deleteSong = asyncHandler(async (req, res) => {

    const songId = req.params.id;
    const artistId = req.user.userId;
    const songResult = await pool.query(
        `SELECT s.* 
        FROM songs s
        JOIN albums a ON s.album_id = a.album_id
        WHERE s.song_id = $1 AND a.artist_id = $2`,
        [songId, artistId]
    );

    if (songResult.rows.length === 0) {
        const err = new Error('Canción no encontrada o no pertenece al artista');
        err.statusCode = 404;
        throw err;
    }

    await pool.query(
        `DELETE FROM songs WHERE song_id = $1`,
        [songId]
    );

    res.status(200).json({
        success: true,
        message: 'Canción eliminada exitosamente',
        song: songResult.rows[0]
    });
});

const getSongsByArtist = asyncHandler(async (req, res) => {

    const artistId = req.user.userId;

    const songs = await pool.query(
        `SELECT song_id, album_id, title, duration, audio_url, cover_url 
        FROM songs 
        WHERE album_id IN (SELECT album_id FROM albums WHERE artist_id = $1)`,
        [artistId]
    );

    res.status(200).json({
        success: true,
        message: 'Canciones obtenidas exitosamente',
        songs: songs.rows
    });
});

const updateSong = asyncHandler(async (req, res) => {

    const { title, duration } = req.body;

    const songId = req.params.id;
    const artistId = req.user.userId;


    const songResult = await pool.query(

        `SELECT s.* 
        FROM songs s
        JOIN albums a ON s.album_id = a.album_id
        WHERE s.song_id = $1 AND a.artist_id = $2`,
        [songId, artistId]
    );

    if (songResult.rows.length === 0) {
        const err = new Error('Canción no encontrada o no pertenece al artista');
        err.statusCode = 404;
        throw err;
    }
    

    const result = await pool.query(
        `UPDATE songs 
        SET title = COALESCE($1, title), 
        duration = COALESCE($2, duration) 
        WHERE song_id = $3 RETURNING *`,
        [title, duration || null, songId]
    );

    res.status(200).json({
        success: true,
        message: 'Canción actualizada exitosamente',
        song: result.rows[0]
    });
});


const incrementPlayCount = asyncHandler(async (req, res) => {

    const songId = req.params.id;

    const result = await pool.query(
        `UPDATE songs 
        SET plays= plays + 1 
        WHERE song_id = $1 RETURNING *`,
        [songId]
    );

    if (result.rows.length === 0) {
        const err = new Error('Canción no encontrada');
        err.statusCode = 404;
        throw err;
    }

    res.status(200).json({
        success: true,
        message: 'Contador de reproducciones incrementado exitosamente',
        song: result.rows[0]
    });
});

module.exports = {
    createSong,
    getSongsByArtist,
    deleteSong,
    updateSong,
    incrementPlayCount,
    getallSongs
};