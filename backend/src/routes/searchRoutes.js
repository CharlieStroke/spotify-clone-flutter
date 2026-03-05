const express = require('express');
const router = express.Router();
const authenticateToken = require('../middleware/authMiddleware');
const { searchSongs } = require('../controllers/searchController');

router.get('/', authenticateToken, searchSongs);

module.exports = router;
