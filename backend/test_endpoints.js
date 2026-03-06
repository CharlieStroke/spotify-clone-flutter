// test_endpoints.js
// Script para testear todo tu Backend E2E (End-to-End) remotamente o localmente.
const fs = require('fs');

// Permite pasar la IP de la VM por argumento en la terminal. Si no se pasa, usa localhost.
// Ejemplo: node test_endpoints.js http://150.136.x.x:4000
const HOST = process.argv[2] || 'http://localhost:4000';
const API_URL = `${HOST}/api`;

// Generar una imagen falsa en memoria
const generateFakeImage = () => new Blob([new Uint8Array(20)], { type: 'image/png' });
// Generar un audio falso en memoria
const generateFakeAudio = () => new Blob([new Uint8Array(20)], { type: 'audio/mpeg' });

async function runTests() {
    let token = '';
    let artistId = null;
    let albumId = null;
    let songId = null;
    let playlistId = null;

    const email = `testuser_${Date.now()}@mail.com`;
    const password = 'Password123!';
    const username = `TestUser_${Date.now()}`;

    console.log(`🚀 Iniciando Pruebas E2E del Backend...`);
    console.log(`📡 Apuntando al Servidor: ${HOST}\n`);

    try {
        // ==========================================
        // 1. AUTH - REGISTRO Y LOGIN
        // ==========================================
        console.log('1️⃣  Testeando Auth (Registro/Login)...');
        let res = await fetch(`${API_URL}/auth/register`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ username, email, password })
        });
        const regData = await res.json();
        console.log(' - Registro:', regData.success ? '✅ OK' : '❌ FALLÓ', regData.message || regData.error);
        if (!regData.success && !regData.token) throw new Error('Fallo el registro');

        res = await fetch(`${API_URL}/auth/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, password })
        });
        const loginData = await res.json();
        token = loginData.token;
        console.log(' - Login:', token ? '✅ OK' : '❌ FALLÓ', loginData.message || loginData.error);

        res = await fetch(`${API_URL}/auth/`, {
            headers: { 'Authorization': `Bearer ${token}` }
        });
        const meData = await res.json();
        console.log(' - Obtener Mi Perfil (/auth/):', meData.success ? '✅ OK' : '❌ FALLÓ', meData.user ? meData.user.email : '');

        // ==========================================
        // 2. ARTISTAS - CREAR PERFIL
        // ==========================================
        console.log('\n2️⃣  Testeando Artistas (Crear Perfil)...');
        const artistFormData = new FormData();
        artistFormData.append('stage_name', `The Test Band ${Date.now()}`);
        artistFormData.append('bio', 'Banda de pruebas remotas E2E');
        artistFormData.append('image', generateFakeImage(), 'test_image.png');

        res = await fetch(`${API_URL}/artists/create`, {
            method: 'POST',
            headers: { 'Authorization': `Bearer ${token}` },
            body: artistFormData
        });
        const artistData = await res.json();
        console.log(' - Crear Artista:', artistData.success ? '✅ OK' : '❌ FALLÓ', artistData.message || artistData.error);

        // ==========================================
        // 3. ALBUMS - CREAR ALBUM
        // ==========================================
        console.log('\n3️⃣  Testeando Albums (Crear)...');
        const albumFormData = new FormData();
        albumFormData.append('title', `Album E2E Remoto`);
        albumFormData.append('cover', generateFakeImage(), 'test_cover.png');

        res = await fetch(`${API_URL}/albums/create`, {
            method: 'POST',
            headers: { 'Authorization': `Bearer ${token}` },
            body: albumFormData
        });
        const albumData = await res.json();
        albumId = albumData.album?.album_id;
        console.log(' - Crear Album:', albumData.success ? '✅ OK' : '❌ FALLÓ', albumData.message || albumData.error);

        // ==========================================
        // 4. CANCIONES - SUBIR, LISTAR Y BUSCAR
        // ==========================================
        console.log('\n4️⃣  Testeando Canciones (Subir, Buscar)...');
        if (albumId) {
            const songFormData = new FormData();
            songFormData.append('title', 'Canción E2E VM');
            songFormData.append('album_id', albumId.toString());
            songFormData.append('duration', '180');
            songFormData.append('audio', generateFakeAudio(), 'test_audio.mp3');
            songFormData.append('cover', generateFakeImage(), 'test_cover_song.png');

            res = await fetch(`${API_URL}/songs/addsong`, {
                method: 'POST',
                headers: { 'Authorization': `Bearer ${token}` },
                body: songFormData
            });
            const songData = await res.json();
            songId = songData.song?.song_id;
            console.log(' - Subir Canción a BD y Bucket:', songData.success ? '✅ OK' : '❌ FALLÓ', songData.message || songData.error);
        } else {
            console.log(' - ⚠️ Saltando Subir Canción (Falta ID del album)');
        }

        res = await fetch(`${API_URL}/songs/`, {
            headers: { 'Authorization': `Bearer ${token}` }
        });
        const songsArtistData = await res.json();
        console.log(' - Mis Canciones:', songsArtistData.success ? '✅ OK' : '❌ FALLÓ');

        res = await fetch(`${API_URL}/search?q=Canción E2E`, {
            headers: { 'Authorization': `Bearer ${token}` }
        });
        const searchData = await res.json();
        console.log(' - Buscar Canción (/search):', searchData.success ? '✅ OK' : '❌ FALLÓ', searchData.songs ? `(${searchData.songs.length} resultados)` : '');

        // ==========================================
        // 5. PLAYLISTS - CREAR, AGREGAR
        // ==========================================
        console.log('\n5️⃣  Testeando Playlists y Favoritos...');
        res = await fetch(`${API_URL}/playlists/create`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
            body: JSON.stringify({ name: 'Playlist VM', description: 'Pruebas Remotas' })
        });
        const playlistData = await res.json();
        playlistId = playlistData.playlist?.playlist_id;
        console.log(' - Crear Playlist:', playlistData.success ? '✅ OK' : '❌ FALLÓ', playlistData.message || playlistData.error);

        if (playlistId && songId) {
            res = await fetch(`${API_URL}/playlists/${playlistId}/add/${songId}`, {
                method: 'POST',
                headers: { 'Authorization': `Bearer ${token}` }
            });
            const addToPlData = await res.json();
            console.log(' - Añadir Canción a Playlist:', addToPlData.success ? '✅ OK' : '❌ FALLÓ', addToPlData.message || addToPlData.error);

            res = await fetch(`${API_URL}/favorites/add/${songId}`, {
                method: 'POST',
                headers: { 'Authorization': `Bearer ${token}` }
            });
            const favData = await res.json();
            console.log(' - Marcar Canción como Favorita:', favData.success ? '✅ OK' : '❌ FALLÓ', favData.message || favData.error);
        }

        console.log('\n🎉 ¡PRUEBAS EN LA VM FINALIZADAS EXITOSAMENTE!');

    } catch (error) {
        console.error('\n❌ Hubo un error crítico comunicándose con la VM:', error.message);
    }
}

runTests();
