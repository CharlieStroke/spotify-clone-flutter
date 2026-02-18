CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    username VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE artistas (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    image_url varchar(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE albums (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    artist_id INTEGER REFERENCES artistas(id) ON DELETE CASCADE,
    cover_url varchar(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE canciones (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    album_id INTEGER REFERENCES albums(id) ON DELETE CASCADE,
    duration INTEGER NOT NULL, -- duración en segundos
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE playlists (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    user_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE playlist_canciones (
    playlist_id INTEGER REFERENCES playlists(id) ON DELETE CASCADE,
    cancion_id INTEGER REFERENCES canciones(id) ON DELETE CASCADE,
    PRIMARY KEY (playlist_id, cancion_id)
);

CREATE TABLE FAVORITOS (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES usuarios(id) ON DELETE CASCADE,
    cancion_id INTEGER REFERENCES canciones(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);