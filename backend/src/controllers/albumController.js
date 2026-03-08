const pool = require('../config/db');
const { uploadFile } = require('../services/supabaseStorageService'); // importamos el servicio de subida de imágenes (Supabase)
const asyncHandler = require('../utils/asyncHandler');
const { albumSchema } = require('../validators/artistValidator');

const createAlbum = asyncHandler(async (req, res) => {
    const { error } = albumSchema.validate(req.body);
    if (error) {
        error.statusCode = 400;
        throw error;
    }

    const { title } = req.body;
    const artistId = req.artist.artist_id; // Using the retrieved artist_id from ensureArtist middleware
    const cover = req.files?.cover?.[0]; // Assuming the cover image is uploaded using multer and available in req.files.cover

    if (!cover) {
        const err = new Error('Archivo de portada es requerido');
        err.statusCode = 400;
        throw err;
    }

    const coverName = `covers/albums/${Date.now()}_${cover.originalname}`; // le asignamos un nombre único a la imagen para evitar colisiones en el almacenamiento, y organizamos las imágenes en carpetas por tipo (covers/albums/)

    const coverUrl = await uploadFile(
        cover.buffer,
        coverName,
        cover.mimetype
    ); // subimos la imagen a OCI y obtenemos la URL pública para almacenarla en la base de datos

    const newAlbum = await pool.query(
        `INSERT INTO albums (title, artist_id, cover_url) 
        VALUES ($1, $2, $3) 
        RETURNING album_id, title, artist_id, cover_url`,
        [title, artistId, coverUrl]
    );

    res.status(201).json({
        success: true,
        message: 'Álbum con nombre "' + title + '" creado exitosamente',
        album: newAlbum.rows[0]
    });
});

const getAlbums = asyncHandler(async (req, res) => {

    const artistId = req.artist.artist_id;

    const albums = await pool.query(
        `SELECT album_id, title, cover_url 
        FROM albums 
        WHERE artist_id = $1`,
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
    const artistId = req.artist.artist_id;

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
        message: 'Álbum con nombre "' + albumResult.rows[0].title + '" eliminado exitosamente',
        album: albumResult.rows[0]
    });
});

const updateAlbumName = asyncHandler(async (req, res) => {

    const albumId = req.params.id;
    const artistId = req.artist.artist_id;
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
        message: 'Nombre del álbum actualizado exitosamente con el nuevo título: ' + newTitle,
        album: {
            ...albumResult.rows[0],
            title: newTitle
        }
    });
});

const getAllAlbums = asyncHandler(async (req, res) => {
    // No requiere que sea un artista, solo un usuario logueado.
    // Hacemos JOIN con users para obtener el nombre del artista que lo creó.
    const albums = await pool.query(
        `SELECT a.album_id, a.title, a.cover_url, u.username as artist_name 
         FROM albums a
         JOIN users u ON a.artist_id = u.user_id
         ORDER BY a.created_at DESC`
    );

    res.status(200).json({
        success: true,
        albums: albums.rows
    });
});



// =============================
// OBTENER CANCIONES DE UN ÁLBUM (NUEVO)
// =============================
const getAlbumSongs = asyncHandler(async (req, res) => {
    const { id } = req.params;

    // Verificar si el álbum existe
    const albumResult = await pool.query(
        'SELECT * FROM albums WHERE album_id = $1',
        [id]
    );

    if (albumResult.rows.length === 0) {
        return res.status(404).json({
            success: false,
            message: 'Álbum no encontrado'
        });
    }

    // Obtener las canciones que pertenecen al álbum
    const songsResult = await pool.query(
        `SELECT song_id, title, duration, audio_url, cover_url 
         FROM songs 
         WHERE album_id = $1
         ORDER BY created_at ASC`,
        [id]
    );

    res.status(200).json({
        success: true,
        message: 'Canciones del álbum obtenidas exitosamente',
        songs: songsResult.rows
    });
});

module.exports = {
    createAlbum,
    getAlbums,
    deleteAlbum,
    updateAlbumName,
    getAllAlbums,
    getAlbumSongs
};