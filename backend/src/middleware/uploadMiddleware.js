const multer = require('multer');


const allowedTypes = ['audio/mpeg', 'audio/wav', 'image/jpeg', 'image/png'];

const fileFilter = (req, file, cb) => {
    if (allowedTypes.includes(file.mimetype)) {
        cb(null, true);
    } else {
        cb(new Error('Tipo de archivo no permitido. Solo se permiten archivos de audio y portadas de imagen.'));
    }
};

const upload = multer({
    storage: multer.memoryStorage(), // Usar almacenamiento en memoria para manejar archivos en buffer
    limits: { fileSize: 20 * 1024 * 1024 }, // Limitar a 20MB
    fileFilter: fileFilter
});

module.exports = upload;