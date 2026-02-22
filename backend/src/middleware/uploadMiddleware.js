const multer = require('multer');

const upload = multer({
    storage: multer.memoryStorage(), // Usar almacenamiento en memoria para manejar archivos en buffer
    limits: { fileSize: 20 * 1024 * 1024 }, // Limitar a 20MB
});

module.exports = upload;