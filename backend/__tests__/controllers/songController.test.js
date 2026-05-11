jest.mock('../../src/config/db', () => ({ query: jest.fn(), connect: jest.fn() }));

const pool = require('../../src/config/db');
const { getallSongs, getSongsByArtist, incrementPlayCount } = require('../../src/controllers/songController');
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
