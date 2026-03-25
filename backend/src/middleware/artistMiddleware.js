const pool         = require('../config/db');
const asyncHandler = require('../utils/asyncHandler');

// Verifica que el usuario autenticado tenga un perfil de artista.
// Adjunta req.artist para que los controllers downstream lo usen directamente.
const ensureArtist = asyncHandler(async (req, res, next) => {
    const userId = req.user?.userId;

    if (!userId) {
        return res.status(401).json({
            success: false,
            message: 'Usuario no autenticado',
        });
    }

    const result = await pool.query(
        'SELECT artist_id, user_id, stage_name FROM artists WHERE user_id = $1',
        [userId]
    );

    if (result.rows.length === 0) {
        const err = new Error('El usuario no tiene un perfil de artista');
        err.statusCode = 403;
        throw err;
    }

    req.artist = result.rows[0];
    next();
});

module.exports = ensureArtist;
