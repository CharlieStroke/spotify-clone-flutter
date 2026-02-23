const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/authRoutes');
const playlistRoutes = require('./routes/playlistRoutes');
const artistRoutes = require('./routes/artistRoutes');
const albumRoutes = require('./routes/albumRoutes');
const songRoutes = require('./routes/songRoutes');
const favoriteRoutes = require('./routes/favoriteRoute');
const errorHandler = require('./middleware/errorHandler');
const httpLogger = require('./middleware/httpLogger');

const app = express();

app.use(cors());
app.use(express.json());
app.use(httpLogger);
app.use('/api/auth', authRoutes);
app.use('/api/playlists', playlistRoutes);
app.use('/api/artists', artistRoutes);
app.use('/api/albums', albumRoutes);
app.use('/api/songs', songRoutes);
app.use('/api/favorites', favoriteRoutes);
app.use(errorHandler);

module.exports = app;

