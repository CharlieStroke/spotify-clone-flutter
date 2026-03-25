const express           = require('express');
const router            = express.Router();
const authenticateToken = require('../middleware/authMiddleware');
const { addToFavorites, getFavorites, deleteFavorite } = require('../controllers/favoriteController');

router.post('/add/:id',    authenticateToken, addToFavorites);
router.get('/',            authenticateToken, getFavorites);
router.delete('/remove/:id', authenticateToken, deleteFavorite);

module.exports = router;
