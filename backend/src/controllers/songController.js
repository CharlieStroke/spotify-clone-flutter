const pool = require('../config/db');
const asyncHandler = require('../utils/asyncHandler');
const { uploadSong, uploadCoverImage } = require('../services/objectStorageService');

const createSong = asyncHandler(async (req, res) => {
    
    const { title, album_id, duration } = req.body;
    const song = req.files['audio']; // Assuming the file is uploaded using multer and available in req.files.audio
    const cover = req.files['cover']; // Assuming the cover is uploaded using multer and available in req.files.cover

    if (!song) {
        const err = new Error('Archivo de canción es requerido');
        err.statusCode = 400;
        throw err;
    }

    if (!cover) {
        const err = new Error('Archivo de portada es requerido');
        err.statusCode = 400;
        throw err;
    }

    const songName = `songs/${Date.now()}_${song.originalname}`;
    const coverName = `covers/songs/${Date.now()}_${cover.originalname}`;
     // Replace spaces with underscores for better URL handling

    const songUrl = await uploadSong(
        song.buffer,
        songName,
        song.mimetype
    );

    const coverUrl = await uploadCoverImage(
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
        song: result.rows[0]
    });
});

module.exports = {
    createSong
};