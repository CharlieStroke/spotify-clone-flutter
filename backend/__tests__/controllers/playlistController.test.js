jest.mock('../../src/config/db', () => ({ query: jest.fn(), connect: jest.fn() }));
jest.mock('../../src/services/supabaseStorageService', () => ({ uploadFile: jest.fn() }));

const pool = require('../../src/config/db');
const supabaseStorage = require('../../src/services/supabaseStorageService');
const { createPlaylist, getUserPlaylists, addSongToPlaylist, deleteSongFromPlaylist } = require('../../src/controllers/playlistController');
const { mockReq, mockRes, mockNext } = require('../helpers');

beforeEach(() => jest.clearAllMocks());

const flushPromises = () => new Promise(setImmediate);

describe('createPlaylist', () => {
    test('crea playlist y devuelve 201', async () => {
        pool.query.mockResolvedValueOnce({ rows: [{ playlist_id: 1 }] });

        const req = mockReq({ body: { name: 'My Playlist', description: 'desc' } });
        const res = mockRes();
        const next = mockNext();

        createPlaylist(req, res, next);
        await flushPromises();

        expect(res.status).toHaveBeenCalledWith(201);
        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ success: true }));
    });

    test('lanza error si falla el upload de cover', async () => {
        supabaseStorage.uploadFile.mockRejectedValueOnce(new Error('Upload error'));

        const req = mockReq({ body: { name: 'My Playlist' }, file: {} });
        const res = mockRes();
        const next = mockNext();

        createPlaylist(req, res, next);
        await flushPromises();

        expect(next).toHaveBeenCalledWith(expect.objectContaining({ statusCode: 500 }));
    });
});

describe('getUserPlaylists', () => {
    test('devuelve playlists del usuario', async () => {
        pool.query.mockResolvedValueOnce({ rows: [{ playlist_id: 1 }] });

        const req = mockReq();
        const res = mockRes();
        const next = mockNext();

        getUserPlaylists(req, res, next);
        await flushPromises();

        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ success: true, playlists: [{ playlist_id: 1 }] }));
    });

    test('devuelve array vacío si no tiene playlists', async () => {
        pool.query.mockResolvedValueOnce({ rows: [] });

        const req = mockReq();
        const res = mockRes();
        const next = mockNext();

        getUserPlaylists(req, res, next);
        await flushPromises();

        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ success: false, playlists: [] }));
    });
});

describe('addSongToPlaylist', () => {
    test('agrega canción exitosamente', async () => {
        pool.query
            .mockResolvedValueOnce({ rows: [{ playlist_id: 1 }] }) // playlist
            .mockResolvedValueOnce({ rows: [{ song_id: 1 }] }) // track
            .mockResolvedValueOnce({ rows: [] }) // existing
            .mockResolvedValueOnce({ rows: [] }); // insert

        const req = mockReq({ params: { playlistId: 1, songId: 1 } });
        const res = mockRes();
        const next = mockNext();

        addSongToPlaylist(req, res, next);
        await flushPromises();

        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ success: true }));
    });

    test('lanza 404 si la playlist no existe o no pertenece al usuario', async () => {
        pool.query.mockResolvedValueOnce({ rows: [] });

        const req = mockReq({ params: { playlistId: 99, songId: 1 } });
        const res = mockRes();
        const next = mockNext();

        addSongToPlaylist(req, res, next);
        await flushPromises();

        expect(next).toHaveBeenCalledWith(expect.objectContaining({ statusCode: 404 }));
    });
});

describe('deleteSongFromPlaylist', () => {
    test('elimina canción exitosamente', async () => {
        pool.query
            .mockResolvedValueOnce({ rows: [{ playlist_id: 1 }] }) // playlist
            .mockResolvedValueOnce({ rowCount: 1 }); // delete

        const req = mockReq({ params: { playlistId: 1, songId: 1 } });
        const res = mockRes();
        const next = mockNext();

        deleteSongFromPlaylist(req, res, next);
        await flushPromises();

        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ success: true }));
    });

    test('lanza 404 si la canción no está en la playlist', async () => {
        pool.query
            .mockResolvedValueOnce({ rows: [{ playlist_id: 1 }] })
            .mockResolvedValueOnce({ rowCount: 0 });

        const req = mockReq({ params: { playlistId: 1, songId: 99 } });
        const res = mockRes();
        const next = mockNext();

        deleteSongFromPlaylist(req, res, next);
        await flushPromises();

        expect(next).toHaveBeenCalledWith(expect.objectContaining({ statusCode: 404 }));
    });
});
