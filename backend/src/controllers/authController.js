const express = require('express');
const pool = require('../config/db');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');


const register = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ error: 'Email and password are required' });
        }
        
        const userExists = await pool.query(
            'SELECT * FROM usuarios WHERE email = $1', 
            [email]
        );

        if (userExists.rows.length > 0) {
            return res.status(400).json({ error: 'User already exists' });
        }

        const hashedPassword = await bcrypt.hash(password, 10); 
        
        const newUser = await pool.query(
            'INSERT INTO usuarios (email, password_hash) VALUES ($1, $2) RETURNING *', 
            [email, hashedPassword]
        );

        res.status(201).json({ 
            message: 'User registered successfully', 
            user: newUser.rows[0] 
        });

    } catch (error) {
        console.error('Error registering user:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
};

const login = async (req, res) => {
    try {
        const { email, password } = req.body;
        if (!email || !password) {
            return res.status(400).json({ error: 'Email and password are required' });
        }

        const userResult = await pool.query(
            'SELECT * FROM usuarios WHERE email = $1', 
            [email]
        );

        if (userResult.rows.length === 0) {
            return res.status(400).json({ error: 'Invalid email or password' });
        }

        const user = userResult.rows[0];
        const isPasswordValid = await bcrypt.compare(password, user.password_hash); // Asegúrate de que el campo en la base de datos se llame "password_hash"

        if (!isPasswordValid) {
            return res.status(400).json({ error: 'Invalid email or password' });
        }

        const token = jwt.sign(
            { userId: user.id, email: user.email },
            process.env.JWT_SECRET,
            { expiresIn: '1h' }
        );

        res.json({ message: 'Login successful', token });

    } catch (error) {
        console.error('Error logging in:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
};


module.exports = {
    register,
    login
}