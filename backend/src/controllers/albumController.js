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

const getAlbumsByArtist = asyncHandler(async (req, res) => {

    const artistId = req.user.userId;
    
    const albums = await pool.query(
        `SELECT album_id, title, cover_url FROM albums WHERE artist_id = $1`,
        [artistId]
    );

    res.status(200).json({
        success: true,
        message: 'Álbumes obtenidos exitosamente',
        albums: albums.rows
    });
});

const deleteAlbum = asyncHandler(async (req, res) => {

    const albumId = req.params.id;
    const artistId = req.user.userId;

    const albumResult = await pool.query(
        `SELECT * FROM albums WHERE album_id = $1 AND artist_id = $2`,
        [albumId, artistId]
    );

    if (albumResult.rows.length === 0) {
        const err = new Error('Álbum no encontrado o no pertenece al artista');
        err.statusCode = 404;
        throw err;
    }

    await pool.query(
        `DELETE FROM albums WHERE album_id = $1 AND artist_id = $2`,
        [albumId, artistId]
    );

    res.status(200).json({
        success: true,
        message: 'Álbum eliminado exitosamente',
        album: albumResult.rows[0]
    });
});

const updateAlbumName = asyncHandler(async (req, res) => {

    const albumId = req.params.id;
    const artistId = req.user.userId;
    const { newTitle } = req.body;

    const albumResult = await pool.query(
        `SELECT * FROM albums WHERE album_id = $1 AND artist_id = $2`,
        [albumId, artistId]
    );

    if (albumResult.rows.length === 0) {
        const err = new Error('Álbum no encontrado o no pertenece al artista');
        err.statusCode = 404;
        throw err;
    }

    await pool.query(
        `UPDATE albums SET title = $1 WHERE album_id = $2 AND artist_id = $3`,
        [newTitle, albumId, artistId]
    );

    res.status(200).json({
        success: true,
        message: 'Nombre del álbum actualizado exitosamente',
        album: {
            ...albumResult.rows[0],
            title: newTitle
        }
    });
});



module.exports = {
    createAlbum,
    getAlbumsByArtist,
    deleteAlbum,
    updateAlbumName
};