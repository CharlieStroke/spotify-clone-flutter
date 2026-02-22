const pool = require('../config/db');
const asyncHandler = require('../utils/asyncHandler');
const { uploadFile } = require('../services/objectStorageService');

const createSong = asyncHandler(async (req, res) => {
    
    const { title, album_id, duration, cover_url } = req.body;
    const file = req.file; // Assuming the file is uploaded using multer and available in req.file

    if (!file) {
        const err = new Error('Archivo de canción es requerido');
        err.statusCode = 400;
        throw err;
    }
    const fileName = `songs/${Date.now()}_${file.originalname}`;

    const audioUrl = await uploadFile(
        file.buffer,
        fileName,
        file.mimetype
    );

    const result = await pool.query(
        `INSERT INTO songs (title, album_id, duration, audio_url, cover_url)
        VALUES ($1, $2, $3, $4, $5)
        RETURNING *`,
        [title, album_id, duration, audioUrl, cover_url]
    );

    res.status(201).json({
        success: true,
        song: result.rows[0]
    });
});

module.exports = {
    createSong
};