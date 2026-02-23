const multer = require('multer');

const allowedAudioTypes = [
    'audio/mpeg',
    'audio/mp3',
    'audio/wave',
    'audio/wav',
    'audio/x-wav',
    'audio/x-pn-wav',
    'audio/webm'
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

        if (file.fieldname === 'cover' || file.fieldname === 'image') {
            if (!allowedImageTypes.includes(file.mimetype)) {
                return cb(new Error('Tipo de imagen no permitido'), false);
            }
        }

        cb(null, true);
        
    } 
});

module.exports = upload;