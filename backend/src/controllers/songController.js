const pool = require('../config/db');
const asyncHandler = require('../utils/asyncHandler');
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

    const songName = `songs/tracks/${Date.now()}_${song.originalname}`;
    const coverName = `songs/covers/${Date.now()}_${cover.originalname}`;
     // Replace spaces with underscores for better URL handling

    const songUrl = await uploadFile(
        song.buffer,
        songName,
        song.mimetype
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

    res.status(201).json({
        success: true,
        message: 'Canción creada exitosamente',
        song: result.rows[0]
    });
});

module.exports = {
    createSong
};