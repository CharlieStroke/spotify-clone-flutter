const pool = require('../config/db');
const asyncHandler = require('../utils/asyncHandler');

const validateAlbumOwnership = asyncHandler(async (req, res, next) => {
    
    const album_id = req.body.album_id;
    const userId = req.user.userId;

    if (!album_id) {
        const err = new Error('Album ID is required');
        err.statusCode = 400;
        throw err;
    }

    const result = await pool.query(
        `
        SELECT a.album_id
        FROM albums a
        JOIN artists ar ON a.artist_id = ar.artist_id
        WHERE a.album_id = $1
        AND ar.user_id = $2
        `,
        [album_id, userId]
    );

    if (result.rows.length === 0) {
        const err = new Error('You do not own this album');
        err.statusCode = 403;
        throw err;
    }

    next();
});

module.exports = validateAlbumOwnership;