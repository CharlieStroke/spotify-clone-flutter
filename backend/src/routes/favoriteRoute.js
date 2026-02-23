const express = require('express');
const router = express.Router();
const authenticateToken = require('../middleware/authMiddleware');
const { addtoFavorites, getfavorites, deleteFavorite } = require('../controllers/favoriteController');

router.post('/add/:id', authenticateToken, addtoFavorites);

router.get('/', authenticateToken, getfavorites);

router.delete('/remove/:id', authenticateToken, deleteFavorite);

module.exports = router;