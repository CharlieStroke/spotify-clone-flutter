const { Pool } = require('pg');

const pool = new Pool({
    user:     process.env.DB_USER,
    host:     process.env.DB_HOST,
    port:     parseInt(process.env.DB_PORT, 10),
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    // Límite de conexiones simultáneas al pool
    max: 20,
    // Tiempo máximo (ms) que una conexión idle puede permanecer abierta
    idleTimeoutMillis: 30_000,
    // Tiempo máximo (ms) para obtener una conexión del pool antes de lanzar error
    connectionTimeoutMillis: 5_000,
});

// Loggear errores inesperados en clientes idle para detectar drops de conexión
pool.on('error', (err) => {
    console.error('Error inesperado en cliente idle del pool:', err.message);
});

module.exports = pool;
