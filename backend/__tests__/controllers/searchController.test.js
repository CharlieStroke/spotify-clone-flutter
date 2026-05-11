jest.mock('../../src/config/db', () => ({ query: jest.fn(), connect: jest.fn() }));

const pool = require('../../src/config/db');
const { searchSongs } = require('../../src/controllers/searchController');
const { mockReq, mockRes, mockNext } = require('../helpers');

beforeEach(() => jest.clearAllMocks());

const flushPromises = () => new Promise(setImmediate);

describe('searchSongs', () => {
    test('devuelve resultados de canciones, álbumes y artistas', async () => {
        pool.query
            .mockResolvedValueOnce({ rows: [{ song_id: 1 }] }) // songs
            .mockResolvedValueOnce({ rows: [{ album_id: 1 }] }) // albums
            .mockResolvedValueOnce({ rows: [{ playlist_id: 1 }] }); // playlists

        const req = mockReq({ query: { q: 'test' } });
        const res = mockRes();
        const next = mockNext();

        searchSongs(req, res, next);
        await flushPromises();

        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
            success: true,
            songs: [{ song_id: 1 }],
            albums: [{ album_id: 1 }],
            playlists: [{ playlist_id: 1 }]
        }));
    });

    test('devuelve resultados vacíos si no hay matches', async () => {
        pool.query
            .mockResolvedValueOnce({ rows: [] })
            .mockResolvedValueOnce({ rows: [] })
            .mockResolvedValueOnce({ rows: [] });

        const req = mockReq({ query: { q: 'unknown' } });
        const res = mockRes();
        const next = mockNext();

        searchSongs(req, res, next);
        await flushPromises();

        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
            success: true,
            songs: [],
            albums: [],
            playlists: []
        }));
    });

    test('llama next con error si pool falla', async () => {
        const err = new Error('DB error');
        pool.query.mockRejectedValueOnce(err);

        const req = mockReq({ query: { q: 'error' } });
        const res = mockRes();
        const next = mockNext();

        searchSongs(req, res, next);
        await flushPromises();

        expect(next).toHaveBeenCalledWith(err);
    });
});
