const Joi = require('joi');

const createPlaylistSchema = Joi.object({
    name: Joi.string().min(3).max(100).required(),
    description: Joi.string().allow('').optional()
});


module.exports = {
    createPlaylistSchema
};