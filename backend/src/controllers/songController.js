const pool = require('../config/db');
const asyncHandler = require('../utils/asyncHandler');
const { songSchema } = require('../validators/artistValidator');

const createSong = asyncHandler(async (req, res) => {
    
    const { error } = songSchema.validate(req.body);
    if (error) {
        const err = new Error(error.details[0].message);
        err.statusCode = 400;
        throw err;
    }

    crea