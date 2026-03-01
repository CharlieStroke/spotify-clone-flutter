const express = require('express');
const router = express.Router();
const { register, login, MyUserInfo } = require('../controllers/authController');
const verifyToken = require('../middleware/authMiddleware');

router.post('/register', register);

router.post('/login', login);

router.get('/', verifyToken, MyUserInfo);

module.exports = router;