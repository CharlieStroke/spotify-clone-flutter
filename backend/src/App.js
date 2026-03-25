const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

const authRoutes = require('./routes/authRoutes');
const playlistRoutes = require('./routes/playlistRoutes');
const artistRoutes = require('./routes/artistRoutes');
const albumRoutes = require('./routes/albumRoutes');
const songRoutes = require('./routes/songRoutes');
const favoriteRoutes = require('./routes/favoriteRoute');
const searchRoutes = require('./routes/searchRoutes');
const errorHandler = require('./middleware/errorHandler');
const httpLogger = require('./middleware/httpLogger');

const app = express();

// Confiar en el primer proxy (necesario para rate-limit en Render, Railway, OCI)
app.set('trust proxy', 1);

// ─── Seguridad: cabeceras HTTP seguras ────────────────────────────────────────
app.use(helmet());

// ─── CORS ─────────────────────────────────────────────────────────────────────
// Para clientes móviles (Flutter) el navegador no envía Origin, por lo que
// este control afecta principalmente a clientes web o herramientas de desarrollo.
// Configura ALLOWED_ORIGINS en .env como lista separada por comas.
const rawOrigins = process.env.ALLOWED_ORIGINS;
const corsOptions = {
    origin: rawOrigins
        ? rawOrigins.split(',').map((o) => o.trim())
        : '*',
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
};
app.use(cors(corsOptions));

// ─── Rate limiting ────────────────────────────────────────────────────────────
// Límite global: protección básica contra scraping y abuso general.
const globalLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutos
    max: 1000,
    standardHeaders: true,    // RateLimit-* headers (RFC 6585)
    legacyHeaders: false,
    message: {
        success: false,
        message: 'Demasiadas solicitudes desde esta IP. Inténtalo de nuevo en 15 minutos.',
    },
});

// Límite estricto para autenticación: frena ataques de fuerza bruta.
// Se aplica individualmente en authRoutes.
const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 15,
    standardHeaders: true,
    legacyHeaders: false,
    message: {
        success: false,
        message: 'Demasiados intentos de autenticación. Inténtalo de nuevo en 15 minutos.',
    },
});

app.use(globalLimiter);

// ─── Parsing y logging ────────────────────────────────────────────────────────
app.use(express.json());
app.use(httpLogger);

// ─── Rutas ───────────────────────────────────────────────────────────────────
app.use('/api/auth', authLimiter, authRoutes);
app.use('/api/playlists', playlistRoutes);
app.use('/api/artists', artistRoutes);
app.use('/api/albums', albumRoutes);
app.use('/api/songs', songRoutes);
app.use('/api/favorites', favoriteRoutes);
app.use('/api/search', searchRoutes);

// ─── Manejo global de errores ─────────────────────────────────────────────────
app.use(errorHandler);

module.exports = app;
