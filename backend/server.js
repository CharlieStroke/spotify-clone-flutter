require('dotenv').config();

// ─── Validación de variables de entorno requeridas ────────────────────────────
// Fallar rápido antes de conectar a BD o arrancar el servidor.
const REQUIRED_ENV = [
    'JWT_SECRET',
    'DB_HOST', 'DB_PORT', 'DB_USER', 'DB_PASSWORD', 'DB_NAME',
    'SUPABASE_URL', 'SUPABASE_ANON_KEY', 'SUPABASE_BUCKET',
];
const missingEnv = REQUIRED_ENV.filter((key) => !process.env[key]);
if (missingEnv.length > 0) {
    console.error(`[FATAL] Faltan variables de entorno requeridas: ${missingEnv.join(', ')}`);
    process.exit(1);
}
// ─────────────────────────────────────────────────────────────────────────────

const app  = require('./src/App');
const pool = require('./src/config/db');

const PORT = process.env.PORT || 4000;

const server = app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on port ${PORT} [${process.env.NODE_ENV || 'development'}]`);
});

// ─── Graceful shutdown (PM2 SIGTERM / Docker stop) ───────────────────────────
const shutdown = (signal) => {
    console.log(`[${signal}] Cerrando servidor...`);
    server.close(async () => {
        try {
            await pool.end();
            console.log('Pool de base de datos cerrado.');
        } catch (err) {
            console.error('Error al cerrar el pool:', err.message);
        }
        process.exit(0);
    });

    // Forzar salida si tarda más de 10 segundos
    setTimeout(() => {
        console.error('Cierre forzado por timeout.');
        process.exit(1);
    }, 10_000);
};

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT',  () => shutdown('SIGINT'));
// ─────────────────────────────────────────────────────────────────────────────
