const express = require('express');
const router = express.Router();
const { createArtist } = require('../controllers/artistController');
const authenticateToken = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');

router.post('/create', upload.fields([{ name: 'image', maxCount: 1 }]), authenticateToken, createArtist);

module.exports = router;
