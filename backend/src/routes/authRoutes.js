const express = require('express');
const router = express.Router();
const { register, login, MyUserInfo } = require('../controllers/authController');
const authenticateToken = require('../middleware/authMiddleware');

router.post('/register', register);

router.post('/login', login);

router.get('/me', authenticateToken, MyUserInfo);

module.exports = router;