const multer = require('multer');
const path   = require('path');

// ─── MIME types permitidos ────────────────────────────────────────────────────
const ALLOWED_AUDIO_MIMES = new Set([
    'audio/mpeg',
    'audio/mp3',
    'audio/mp4',
    'audio/wave',
    'audio/wav',
    'audio/x-wav',
    'audio/x-pn-wav',
    'audio/webm',
    'audio/ogg',
    'audio/aac',
    'audio/x-m4a',
    'video/mp4', // Android a veces envía mp3 como video/mp4
]);

// Extensiones de audio válidas (usadas como fallback para application/octet-stream)
const ALLOWED_AUDIO_EXTENSIONS = new Set([
    '.mp3', '.mp4', '.wav', '.webm', '.ogg', '.aac', '.m4a',
]);

const ALLOWED_IMAGE_MIMES = new Set([
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/gif',
    'image/bmp',
    'image/tiff',
]);

// ─── File filter ──────────────────────────────────────────────────────────────
const fileFilter = (req, file, cb) => {
    // Normalizar originalname para prevenir path traversal
    const safeName = path.basename(file.originalname);
    const ext      = path.extname(safeName).toLowerCase();

    if (file.fieldname === 'audio') {
        // Aceptar MIMEs conocidos de audio
        if (ALLOWED_AUDIO_MIMES.has(file.mimetype)) {
            return cb(null, true);
        }
        // Para application/octet-stream (envío genérico de Android),
        // validar que la extensión sea de audio
        if (file.mimetype === 'application/octet-stream' && ALLOWED_AUDIO_EXTENSIONS.has(ext)) {
            return cb(null, true);
        }
        return cb(new Error(`Tipo de archivo de audio no permitido: ${file.mimetype} (${ext})`), false);
    }

    if (['cover', 'image', 'profile_image', 'cover_image'].includes(file.fieldname)) {
        if (ALLOWED_IMAGE_MIMES.has(file.mimetype)) {
            return cb(null, true);
        }
        return cb(new Error(`Tipo de archivo de imagen no permitido: ${file.mimetype} (${ext})`), false);
    }

    // Campo desconocido: rechazar
    return cb(new Error(`Campo de archivo no reconocido: ${file.fieldname}`), false);
};

// ─── Configuración de multer ──────────────────────────────────────────────────
const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 20 * 1024 * 1024 }, // 20 MB
    fileFilter,
});

module.exports = upload;
