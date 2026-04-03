const pool = require('../config/db');
const bcrypt = require('bcrypt');
const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const asyncHandler = require('../utils/asyncHandler');
const logger = require('../config/logger');
const { registerSchema, loginSchema } = require('../validators/authValidator');
const supabaseStorage = require('../services/supabaseStorageService');

const REFRESH_TOKEN_BYTES = 40;
const REFRESH_TOKEN_TTL_DAYS = 7;

function generateAccessToken(userId, email) {
    return jwt.sign({ userId, email }, process.env.JWT_SECRET, { expiresIn: '1h' });
}

function hashToken(raw) {
    return crypto.createHash('sha256').update(raw).digest('hex');
}

async function issueRefreshToken(userId) {
    const raw = crypto.randomBytes(REFRESH_TOKEN_BYTES).toString('hex');
    const hash = hashToken(raw);
    const expiresAt = new Date(Date.now() + REFRESH_TOKEN_TTL_DAYS * 24 * 60 * 60 * 1000);

    await pool.query(
        'INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES ($1, $2, $3)',
        [userId, hash, expiresAt]
    );

    return raw;
}


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

    const user = newUser.rows[0];

    const accessToken = generateAccessToken(user.user_id, user.email);
    const refreshToken = await issueRefreshToken(user.user_id);

    res.status(201).json({
        success: true,
        message: 'Usuario registrado exitosamente',
        user: user,
        token: accessToken,
        refreshToken,
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

    const accessToken = generateAccessToken(user.user_id, user.email);
    const refreshToken = await issueRefreshToken(user.user_id);

    res.json({
        success: true,
        message: 'Login exitoso',
        token: accessToken,
        refreshToken,
        user: {
            user_id:           user.user_id,
            email:             user.email,
            username:          user.username,
            profile_image_url: user.profile_image_url,
        },
    });
});

const MyUserInfo = asyncHandler(async (req, res) => {

    const userId = req.user.userId;

    const userResult = await pool.query(
        'SELECT user_id, email, username, profile_image_url FROM users WHERE user_id = $1',
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

    // Actualizar foto de perfil (si viene file en la request gracias a multer)
    if (req.file) {
        try {
            const uploadedUrl = await supabaseStorage.uploadFile(
                req.file,
                'users/avatars'
            );

            updateFields.push(`profile_image_url = $${paramIndex}`);
            queryValues.push(uploadedUrl);
            paramIndex++;
        } catch (uploadError) {
            logger.error({ err: uploadError.message }, 'Error uploading profile image');
            const err = new Error('Error al subir la imagen de perfil');
            err.statusCode = 500;
            throw err;
        }
    }

    if (updateFields.length === 0) {
        return res.json({
            success: true,
            message: 'Sin cambios',
            user: {
                user_id: user.user_id,
                email: user.email,
                username: user.username,
                profile_image_url: user.profile_image_url
            }
        });
    }

    const updateQuery = `
        UPDATE users 
        SET ${updateFields.join(', ')}
        WHERE user_id = $${paramIndex}
        RETURNING user_id, email, username, profile_image_url
    `;
    queryValues.push(userId);

    const updatedUser = await pool.query(updateQuery, queryValues);

    res.json({
        success: true,
        message: 'Perfil actualizado exitosamente',
        user: updatedUser.rows[0]
    });
});

// =============================
// REFRESH TOKEN
// =============================
const refreshToken = asyncHandler(async (req, res) => {
    const { refreshToken: raw } = req.body;

    if (!raw) {
        const err = new Error('Refresh token requerido');
        err.statusCode = 400;
        throw err;
    }

    const hash = hashToken(raw);

    const result = await pool.query(
        'SELECT * FROM refresh_tokens WHERE token_hash = $1 AND expires_at > NOW()',
        [hash]
    );

    if (result.rows.length === 0) {
        const err = new Error('Refresh token inválido o expirado');
        err.statusCode = 401;
        throw err;
    }

    const matched = result.rows[0];

    // Rotar: eliminar el token usado
    await pool.query('DELETE FROM refresh_tokens WHERE token_id = $1', [matched.token_id]);

    const userResult = await pool.query(
        'SELECT user_id, email FROM users WHERE user_id = $1',
        [matched.user_id]
    );

    if (userResult.rows.length === 0) {
        const err = new Error('Usuario no encontrado');
        err.statusCode = 404;
        throw err;
    }

    const user = userResult.rows[0];
    const newAccessToken = generateAccessToken(user.user_id, user.email);
    const newRefreshToken = await issueRefreshToken(user.user_id);

    res.json({
        success: true,
        token: newAccessToken,
        refreshToken: newRefreshToken,
    });
});

// =============================
// LOGOUT
// =============================
const logout = asyncHandler(async (req, res) => {
    const { refreshToken: raw } = req.body;

    if (raw) {
        const hash = hashToken(raw);
        await pool.query(
            'DELETE FROM refresh_tokens WHERE token_hash = $1 AND user_id = $2',
            [hash, req.user.userId]
        );
    }

    res.json({ success: true, message: 'Sesión cerrada' });
});

module.exports = {
    register,
    login,
    MyUserInfo,
    updateProfile,
    refreshToken,
    logout,
};