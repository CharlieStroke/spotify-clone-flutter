jest.mock('../../src/config/db', () => ({ query: jest.fn(), connect: jest.fn() }));

const pool = require('../../src/config/db');
const { searchSongs } = require('../../src/controllers/searchController');
const { mockReq, mockRes, mockNext } = require('../helpers');

beforeEach(() => jest.clearAllMocks());

const flushPromises = () => new Promise(setImmediate);

describe('searchSongs', () => {
    test('devuelve resultados de canciones, álbumes, playlists y artistas', async () => {
        pool.query
            .mockResolvedValueOnce({ rows: [{ song_id: 1, title: 'Bohemian Rhapsody' }] }) // songs
            .mockResolvedValueOnce({ rows: [{ album_id: 1, title: 'A Night at the Opera' }] }) // albums
            .mockResolvedValueOnce({ rows: [] }) // playlists
            .mockResolvedValueOnce({ rows: [{ artist_id: 1, stage_name: 'Queen', image_url: 'https://img' }] }); // artists

        const req = mockReq({ query: { q: 'queen' } });
        const res = mockRes();
        const next = mockNext();

        searchSongs(req, res, next);
        await flushPromises();

        expect(res.status).toHaveBeenCalledWith(200);
        const payload = res.json.mock.calls[0][0];
        expect(payload.songs).toHaveLength(1);
        expect(payload.albums).toHaveLength(1);
        expect(payload.artists).toHaveLength(1);
    });

    test('devuelve resultados vacíos si no hay matches', async () => {
        pool.query
            .mockResolvedValueOnce({ rows: [] })
            .mockResolvedValueOnce({ rows: [] })
            .mockResolvedValueOnce({ rows: [] })
            .mockResolvedValueOnce({ rows: [] }); // artists

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
            playlists: [],
            artists: [],
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
