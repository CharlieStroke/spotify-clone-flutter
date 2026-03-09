const express = require('express');
const router = express.Router();
const { register, login, MyUserInfo, updateProfile } = require('../controllers/authController');
const verifyToken = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware'); // Added Multer para subida de fotos

router.post('/register', register);

router.post('/login', login);

router.get('/', verifyToken, MyUserInfo);

router.put('/profile', verifyToken, upload.single('profile_image'), updateProfile);

module.exports = router;