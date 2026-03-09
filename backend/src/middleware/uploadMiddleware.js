const multer = require('multer');

const allowedAudioTypes = [
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
    'video/mp4', // Android sometimes sends mp3 as video/mp4
    'application/octet-stream' // Generic binary, allow and let the backend handle it
];

const allowedImageTypes = [
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/gif',
    'image/svg+xml',
    'image/bmp',
    'image/tiff'
];

const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 20 * 1024 * 1024 },
    fileFilter: (req, file, cb) => {
        console.log(file.mimetype);
        if (file.fieldname === 'audio') {
            if (!allowedAudioTypes.includes(file.mimetype)) {
                return cb(new Error('Tipo de audio no permitido'), false);
            }

        }

        if (file.fieldname === 'cover' || file.fieldname === 'image' || file.fieldname === 'profile_image' || file.fieldname === 'cover_image') {
            if (!allowedImageTypes.includes(file.mimetype)) {
                return cb(new Error('Tipo de imagen no permitido'), false);
            }
        }

        cb(null, true);

    }
});

module.exports = upload;