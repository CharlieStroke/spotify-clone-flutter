const pino = require('pino');

const isProduction = process.env.NODE_ENV === 'production';

const logger = pino(
    isProduction
        ? {}
        : {
            transport: {
                target: 'pino-pretty',
                options: {
                    colorize: true,
                    translateTime: 'yyyy-mm-dd HH:MM:ss'
                }
            }
        }
);

module.exports = logger;