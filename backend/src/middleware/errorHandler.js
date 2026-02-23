const errorHandler = (err, req, res, next) => {
    console.error('Error:', err);

    // Multer - tamaño excedido
    if (err.code === 'LIMIT_FILE_SIZE') {
        return res.status(400).json({
            success: false,
            message: 'El archivo excede el tamaño máximo permitido (20MB)'
        });
    }

    // Error de tipo MIME personalizado
    if (err.message && err.message.includes('Tipo')) {
        return res.status(400).json({
            success: false,
            message: err.message
        });
    }

    // Error personalizado con statusCode
    if (err.statusCode) {
        return res.status(err.statusCode).json({
            success: false,
            message: err.message
        });
    }

    // Error genérico
    return res.status(500).json({
        success: false,
        message: 'Internal Server Error'
    });
};

module.exports = errorHandler;