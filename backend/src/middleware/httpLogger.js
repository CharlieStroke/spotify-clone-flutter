const pinoHttp = require('pino-http');
const logger = require('../config/logger');

const httpLogger = pinoHttp({
    logger
});

module.exports = httpLogger;