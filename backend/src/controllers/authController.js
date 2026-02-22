const pool = require('../config/db');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const asyncHandler = require('../utils/asyncHandler');
const { registerSchema, loginSchema } = require('../validators/authValidator');


// =============================
// REGISTER
// =============================
const register = asyncHandler(async (req, res) => {

    const { error } = registerSchema.validate(req.body);
    if (error) {
        error.statusCode = 400;
        throw error;
    }

    const { email, password, username } = req.body;

    const userExists = await pool.query(
        'SELECT * FROM users WHERE email = $1 OR username = $2',
        [email, username]
    );

    if (userExists.rows.length > 0) {
        const err = new Error('Usuario ya existe');
        err.statusCode = 400;
        throw err;
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const newUser = await pool.query(
        'INSERT INTO users (email, password_hash, username) VALUES ($1, $2, $3) RETURNING user_id, email, username',
        [email, hashedPassword, username]
    );

    res.status(201).json({
        success: true,
        message: 'Usuario registrado exitosamente',
        user: newUser.rows[0]
    });
});


// =============================
// LOGIN
// =============================
const login = asyncHandler(async (req, res) => {

    const { error } = loginSchema.validate(req.body);
    if (error) {
        error.statusCode = 400;
        throw error;
    }

    const { email, password } = req.body;

    const userResult = await pool.query(
        'SELECT * FROM users WHERE email = $1',
        [email]
    );

    if (userResult.rows.length === 0) {
        const err = new Error('Email o contraseña inválidos');
        err.statusCode = 401;
        throw err;
    }

    const user = userResult.rows[0];

    const isPasswordValid = await bcrypt.compare(password, user.password_hash);

    if (!isPasswordValid) {
        const err = new Error('Email o contraseña inválidos');
        err.statusCode = 401;
        throw err;
    }

    const token = jwt.sign(
    {
        userId: user.user_id,
        email: user.email
    },
    process.env.JWT_SECRET,
    { expiresIn: '1h' }
    );

    res.json({
        success: true,
        message: 'Login exitoso',
        token
    });
});

const MyUserInfo = asyncHandler(async (req, res) => {
    
    const userId = req.user.userId;

    const userResult = await pool.query(
        'SELECT user_id, email, username FROM users WHERE user_id = $1',
        [userId]
    );
    if (userResult.rows.length === 0) {
        const err = new Error('Usuario no encontrado');
        err.statusCode = 404;
        throw err;
    }

    res.json({
        success: true,
        user: userResult.rows[0]
    });

});

module.exports = {
    register,
    login,
    MyUserInfo
};