const joi = require('joi');

const createArtistSchema = joi.object({
    stage_name: joi.string().max(255).required(),
    bio: joi.string().max(1000).allow(''),
    image_url: joi.string().uri().max(255).allow('')
});

const albumSchema = joi.object({
    title: joi.string().max(255).required(),
    coverUrl: joi.string().uri().max(255).allow('')
});

module.exports = {
    createArtistSchema,
    albumSchema
};