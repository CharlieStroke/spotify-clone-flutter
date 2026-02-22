const pool = require('../config/db');
const asyncHandler = require('../utils/asyncHandler');

// Middleware to ensure the authenticated user has an artist profile
const ensureArtist = asyncHandler(async (req, res, next) => {
    const user = req.user;

    if (!user || !user.userId) {
        return res.status(401).json({ error: 'User not authenticated' });
    }

    const userId = user.userId;

    const result = await pool.query(
        'SELECT artist_id, user_id, stage_name FROM artists WHERE user_id = $1',
        [userId]
    );

    if (result.rows.length === 0) {
        const err = new Error('User does not have an artist profile');
        err.statusCode = 403;
        throw err;
    }

    // Attach artist info to the request for downstream handlers
    req.artist = result.rows[0];
    next();
});

module.exports = ensureArtist;
