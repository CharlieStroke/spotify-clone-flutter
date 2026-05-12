jest.mock('../../src/config/db', () => ({ query: jest.fn(), connect: jest.fn() }));
jest.mock('../../src/services/supabaseStorageService', () => ({ uploadFile: jest.fn() }));

const pool = require('../../src/config/db');
const storageService = require('../../src/services/supabaseStorageService');
const { createSong, getallSongs, getSongsByArtist, deleteSong, updateSong, incrementPlayCount } = require('../../src/controllers/songController');
const { mockReq, mockRes, mockNext } = require('../helpers');

// Helper to mock pagination properties on request
const mockPaginationReq = (overrides = {}) => mockReq({
    query: { page: '1', limit: '10' },
    ...overrides
});

beforeEach(() => jest.clearAllMocks());

const flushPromises = () => new Promise(setImmediate);

describe('getallSongs', () => {
    test('devuelve lista de canciones', async () => {
        pool.query
            .mockResolvedValueOnce({ rows: [{ count: '2' }] }) // count
            .mockResolvedValueOnce({ rows: [{ song_id: 1 }, { song_id: 2 }] }); // select

        const req = mockPaginationReq();
        const res = mockRes();
        const next = mockNext();

        getallSongs(req, res, next);
        await flushPromises();

        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
            success: true,
            songs: [{ song_id: 1 }, { song_id: 2 }]
        }));
    });

    test('devuelve array vacío si no hay canciones', async () => {
        pool.query
            .mockResolvedValueOnce({ rows: [{ count: '0' }] })
            .mockResolvedValueOnce({ rows: [] });

        const req = mockPaginationReq();
        const res = mockRes();
        const next = mockNext();

        getallSongs(req, res, next);
        await flushPromises();

        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
            songs: []
        }));
    });
});

describe('getSongsByArtist', () => {
    test('devuelve canciones incluyendo plays y paginación', async () => {
        pool.query
            .mockResolvedValueOnce({ rows: [{ count: '2' }] }) // Promise.all
            .mockResolvedValueOnce({ rows: [{ song_id: 1, plays: 10 }, { song_id: 2, plays: 20 }] });

        const req = mockPaginationReq({ artist: { artist_id: 1 } });
        const res = mockRes();
        const next = mockNext();

        getSongsByArtist(req, res, next);
        await flushPromises();

        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
            success: true,
            songs: expect.arrayContaining([
                expect.objectContaining({ plays: 10 })
            ]),
            pagination: expect.any(Object)
        }));
    });

    test('devuelve array vacío si el artista no tiene canciones', async () => {
        pool.query
            .mockResolvedValueOnce({ rows: [{ count: '0' }] })
            .mockResolvedValueOnce({ rows: [] });

        const req = mockPaginationReq({ artist: { artist_id: 1 } });
        const res = mockRes();
        const next = mockNext();

        getSongsByArtist(req, res, next);
        await flushPromises();

        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
            songs: [],
            pagination: expect.objectContaining({ totalItems: 0 })
        }));
    });
});

describe('incrementPlayCount', () => {
    test('incrementa plays y devuelve 200', async () => {
        pool.query.mockResolvedValueOnce({ rows: [{ song_id: 1, plays: 11 }] });

        const req = mockReq({ params: { id: 1 } });
        const res = mockRes();
        const next = mockNext();

        incrementPlayCount(req, res, next);
        await flushPromises();

        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
            success: true,
            song: { song_id: 1, plays: 11 }
        }));
    });

    test('lanza 404 si la canción no existe', async () => {
        pool.query.mockResolvedValueOnce({ rows: [] });

        const req = mockReq({ params: { id: 99 } });
        const res = mockRes();
        const next = mockNext();

        incrementPlayCount(req, res, next);
        await flushPromises();

        expect(next).toHaveBeenCalledWith(expect.objectContaining({ statusCode: 404 }));
    });
});

describe('createSong', () => {
    test('crea canción y devuelve 201', async () => {
        storageService.uploadFile
            .mockResolvedValueOnce('https://audio.url/song.mp3')
            .mockResolvedValueOnce('https://cover.url/cover.jpg');
        pool.query.mockResolvedValueOnce({ rows: [{ song_id: 1, title: 'Test Song' }] });

        const req = mockReq({
            body: { title: 'Test Song', album_id: '1', duration: '180' },
            files: { audio: [{ buffer: Buffer.alloc(0), mimetype: 'audio/mpeg', originalname: 'song.mp3' }], cover: [{ buffer: Buffer.alloc(0), mimetype: 'image/jpeg', originalname: 'cover.jpg' }] },
        });
        const res = mockRes();
        const next = mockNext();

        createSong(req, res, next);
        await flushPromises();

        expect(res.status).toHaveBeenCalledWith(201);
        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ success: true, song: { song_id: 1, title: 'Test Song' } }));
    });

    test('lanza 400 si falta el archivo de audio', async () => {
        const req = mockReq({ body: { title: 'Test', album_id: '1' }, files: { cover: [{}] } });
        const res = mockRes();
        const next = mockNext();

        createSong(req, res, next);
        await flushPromises();

        expect(next).toHaveBeenCalledWith(expect.objectContaining({ statusCode: 400 }));
    });

    test('lanza 400 si falta el archivo de portada', async () => {
        const req = mockReq({ body: { title: 'Test', album_id: '1' }, files: { audio: [{}] } });
        const res = mockRes();
        const next = mockNext();

        createSong(req, res, next);
        await flushPromises();

        expect(next).toHaveBeenCalledWith(expect.objectContaining({ statusCode: 400 }));
    });
});

describe('deleteSong', () => {
    test('elimina canción y devuelve 200', async () => {
        const song = { song_id: 1, title: 'Song To Delete' };
        pool.query
            .mockResolvedValueOnce({ rows: [song] }) // SELECT
            .mockResolvedValueOnce({ rows: [] });    // DELETE

        const req = mockReq({ params: { id: '1' }, artist: { artist_id: 1 } });
        const res = mockRes();
        const next = mockNext();

        deleteSong(req, res, next);
        await flushPromises();

        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ success: true, song }));
    });

    test('lanza 404 si la canción no pertenece al artista', async () => {
        pool.query.mockResolvedValueOnce({ rows: [] });

        const req = mockReq({ params: { id: '99' }, artist: { artist_id: 1 } });
        const res = mockRes();
        const next = mockNext();

        deleteSong(req, res, next);
        await flushPromises();

        expect(next).toHaveBeenCalledWith(expect.objectContaining({ statusCode: 404 }));
    });
});

describe('updateSong', () => {
    test('actualiza canción y devuelve 200', async () => {
        const updated = { song_id: 1, title: 'New Title', duration: 200 };
        pool.query
            .mockResolvedValueOnce({ rows: [{ song_id: 1 }] }) // SELECT
            .mockResolvedValueOnce({ rows: [updated] });       // UPDATE

        const req = mockReq({ params: { id: '1' }, body: { title: 'New Title', duration: '200' }, artist: { artist_id: 1 } });
        const res = mockRes();
        const next = mockNext();

        updateSong(req, res, next);
        await flushPromises();

        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ success: true, song: updated }));
    });

    test('lanza 404 si la canción no pertenece al artista', async () => {
        pool.query.mockResolvedValueOnce({ rows: [] });

        const req = mockReq({ params: { id: '99' }, body: { title: 'X' }, artist: { artist_id: 1 } });
        const res = mockRes();
        const next = mockNext();

        updateSong(req, res, next);
        await flushPromises();

        expect(next).toHaveBeenCalledWith(expect.objectContaining({ statusCode: 404 }));
    });
});
