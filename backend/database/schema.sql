-- =========================================
-- Spotify Clone - Schema Base
-- =========================================

-- =========================
-- DROP TABLES (orden por dependencias)
-- =========================

DROP TABLE IF EXISTS favorites CASCADE;
DROP TABLE IF EXISTS playlist_songs CASCADE;
DROP TABLE IF EXISTS playlists CASCADE;
DROP TABLE IF EXISTS songs CASCADE;
DROP TABLE IF EXISTS albums CASCADE;
DROP TABLE IF EXISTS artists CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- =========================
-- USUARIOS
-- =========================

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    username VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- ARTISTAS
-- =========================

CREATE TABLE artists (
    artist_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- ALBUMS
-- =========================

CREATE TABLE albums (
    album_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    artist_id INTEGER NOT NULL,
    cover_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_album_artist
        FOREIGN KEY (artist_id)
        REFERENCES artists(artist_id)
        ON DELETE CASCADE
);

-- =========================
-- CANCIONES
-- =========================

CREATE TABLE songs (
    song_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    album_id INTEGER NOT NULL,
    duration INTEGER NOT NULL, -- duración en segundos
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_song_album
        FOREIGN KEY (album_id)
        REFERENCES albums(album_id)
        ON DELETE CASCADE
);

-- =========================
-- PLAYLISTS
-- =========================

CREATE TABLE playlists (
    playlist_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    user_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_playlist_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);

-- =========================
-- PLAYLIST_CANCIONES (many-to-many)
-- =========================

CREATE TABLE playlist_songs (
    playlist_id INTEGER NOT NULL,
    song_id INTEGER NOT NULL,

    PRIMARY KEY (playlist_id, song_id),

    CONSTRAINT fk_playlist
        FOREIGN KEY (playlist_id)
        REFERENCES playlists(playlist_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_song
        FOREIGN KEY (song_id)
        REFERENCES songs(song_id)
        ON DELETE CASCADE
);

-- =========================
-- FAVORITOS
-- =========================

CREATE TABLE favorites (
    favorite_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    song_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_fav_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_fav_song
        FOREIGN KEY (song_id)
        REFERENCES songs(song_id)
        ON DELETE CASCADE,

    CONSTRAINT unique_user_song UNIQUE (user_id, song_id)
);

-- =========================
-- INDEXES (optimización básica)
-- =========================

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_playlists_user_id ON playlists(user_id);
CREATE INDEX idx_songs_album_id ON songs(album_id);
CREATE INDEX idx_favorites_user_id ON favorites(user_id);