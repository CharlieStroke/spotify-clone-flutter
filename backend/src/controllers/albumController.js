const pool = require('../config/db');
const asyncHandler = require('../utils/asyncHandler');
const { albumSchema } = require('../validators/artistValidator');

const createAlbum = asyncHandler(async (req, res) => {
    
    const { error } = albumSchema.validate(req.body);
    if (error) {
        const err = new Error(error.details[0].message);
        err.statusCode = 400;
        throw err;
    }

    const { title, coverUrl } = req.body;
    const artistId = req.user.userId; // Assuming the user ID is stored in the token and represents the artist

    

    const newAlbum = await pool.query(
        `INSERT INTO albums (title, artist_id, cover_url) 
        VALUES ($1, $2, $3) 
        RETURNING album_id, title, artist_id, cover_url`,
        [title, artistId, coverUrl]
    ); 

    res.status(201).json({
        success: true,
        message: 'Álbum creado exitosamente',
        album: newAlbum.rows[0]
    });
});

module.exports = {
    createAlbum
};