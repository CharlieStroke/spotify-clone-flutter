const isProduction = process.env.NODE_ENV === 'production';

const errorHandler = (err, req, res, next) => {
    // Log estructurado — en producción pino lo captura; en dev se ve en consola
    console.error('Error:', err);

    // Multer: tamaño de archivo excedido
    if (err.code === 'LIMIT_FILE_SIZE') {
        return res.status(400).json({
            success: false,
            message: 'El archivo excede el tamaño máximo permitido (20 MB)',
        });
    }

    // Errores con statusCode explícito (lanzados desde controllers/middleware)
    if (err.statusCode) {
        return res.status(err.statusCode).json({
            success: false,
            message: err.message,
        });
    }

    // Error genérico: en producción no exponer detalles internos
    return res.status(500).json({
        success: false,
        message: isProduction ? 'Error interno del servidor' : err.message,
    });
};

module.exports = errorHandler;
