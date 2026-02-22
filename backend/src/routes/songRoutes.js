const express = require('express');
const router = express.Router();
const { createSong } = require('../controllers/songController');
const authenticateToken = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');

router.post('/addsong', authenticateToken, upload.single('audio'), createSong);

module.exports = router;