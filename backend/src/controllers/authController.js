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
        { expiresIn: '24h' }
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

// =============================
// UPDATE PROFILE
// =============================
const updateProfile = asyncHandler(async (req, res) => {
    const userId = req.user.userId;
    const { username, oldPassword, newPassword } = req.body;

    let updateFields = [];
    let queryValues = [];
    let paramIndex = 1;

    const userResult = await pool.query(
        'SELECT * FROM users WHERE user_id = $1',
        [userId]
    );

    if (userResult.rows.length === 0) {
        const err = new Error('Usuario no encontrado');
        err.statusCode = 404;
        throw err;
    }

    const user = userResult.rows[0];

    // Actualizar username
    if (username && username !== user.username) {
        // Verificar si existe
        const usernameExists = await pool.query(
            'SELECT * FROM users WHERE username = $1 AND user_id != $2',
            [username, userId]
        );
        if (usernameExists.rows.length > 0) {
            const err = new Error('Nombre de usuario ya en uso');
            err.statusCode = 400;
            throw err;
        }

        updateFields.push(`username = $${paramIndex}`);
        queryValues.push(username);
        paramIndex++;
    }

    // Actualizar password
    if (newPassword) {
        if (!oldPassword) {
            const err = new Error('Contraseña actual es requerida para este cambio');
            err.statusCode = 400;
            throw err;
        }

        const isPasswordValid = await bcrypt.compare(oldPassword, user.password_hash);
        if (!isPasswordValid) {
            const err = new Error('Contraseña actual incorrecta');
            err.statusCode = 401;
            throw err;
        }

        const hashedPassword = await bcrypt.hash(newPassword, 10);
        updateFields.push(`password_hash = $${paramIndex}`);
        queryValues.push(hashedPassword);
        paramIndex++;
    }

    if (updateFields.length === 0) {
        return res.json({
            success: true,
            message: 'Sin cambios',
            user: { user_id: user.user_id, email: user.email, username: user.username }
        });
    }

    const updateQuery = `
        UPDATE users 
        SET ${updateFields.join(', ')}
        WHERE user_id = $${paramIndex}
        RETURNING user_id, email, username
    `;
    queryValues.push(userId);

    const updatedUser = await pool.query(updateQuery, queryValues);

    res.json({
        success: true,
        message: 'Perfil actualizado exitosamente',
        user: updatedUser.rows[0]
    });
});

module.exports = {
    register,
    login,
    MyUserInfo,
    updateProfile
};