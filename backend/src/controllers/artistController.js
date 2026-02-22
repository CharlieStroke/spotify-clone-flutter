const pool = require('../config/db');
const asyncHandler = require('../utils/asyncHandler');
const { createArtistSchema } = require('../validators/artistValidator');
// =============================
// CREATE ARTIST
const createArtist = asyncHandler(async (req, res) => {
    const { error } = createArtistSchema.validate(req.body);
    if (error) {
        error.statusCode = 400;
        throw error;
    }

    const { stage_name, bio, image_url } = req.body;
    const userId = req.user.userId;

    const artistExists = await pool.query(
        'SELECT stage_name FROM artists WHERE stage_name = $1',
        [stage_name]
    );

    if (artistExists.rows.length > 0) {
        const err = new Error('El nombre artístico ya existe');
        err.statusCode = 400;
        throw err;
    }

    const userArtist = await pool.query(
        'SELECT artist_id FROM artists WHERE user_id = $1',
        [userId]
    ); 

    if (userArtist.rows.length > 0) {
        const err = new Error('El usuario ya tiene un perfil de artista');
        err.statusCode = 400;
        throw err;
    }

    if (!userId) {
        const err = new Error('Usuario no autenticado');
        err.statusCode = 401;
        throw err;
    }
    
    const newArtist = await pool.query(
        `INSERT INTO artists (user_id, stage_name, bio, image_url) 
        VALUES ($1, $2, $3, $4) RETURNING artist_id, user_id, stage_name, bio, image_url`,
        [userId, stage_name, bio, image_url]
    );

    res.status(201).json({
        success: true,
        message: 'Artista creado exitosamente',
        artist: newArtist.rows[0]
    });
});

module.exports = {
    createArtist
};