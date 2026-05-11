jest.mock('../../src/config/db', () => ({ query: jest.fn(), connect: jest.fn() }));

const pool = require('../../src/config/db');
const { addToFavorites, getFavorites, deleteFavorite } = require('../../src/controllers/favoriteController');
const { mockReq, mockRes, mockNext } = require('../helpers');

beforeEach(() => jest.clearAllMocks());

const flushPromises = () => new Promise(setImmediate);

describe('addToFavorites', () => {
    test('agrega a favoritos y devuelve 201', async () => {
        pool.query
            .mockResolvedValueOnce({ rows: [{ song_id: 1 }] }) // song exists
            .mockResolvedValueOnce({ rows: [] }) // not favorite yet
            .mockResolvedValueOnce({ rows: [{ favorite_id: 1, user_id: 1, song_id: 1 }] }); // insert

        const req = mockReq({ params: { id: 1 } });
        const res = mockRes();
        const next = mockNext();

        addToFavorites(req, res, next);
        await flushPromises();

        expect(res.status).toHaveBeenCalledWith(201);
        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ success: true, favorite: expect.any(Object) }));
    });

    test('lanza 400 si ya es favorito', async () => {
        pool.query
            .mockResolvedValueOnce({ rows: [{ song_id: 1 }] })
            .mockResolvedValueOnce({ rows: [{ 1: 1 }] }); // already favorite

        const req = mockReq({ params: { id: 1 } });
        const res = mockRes();
        const next = mockNext();

        addToFavorites(req, res, next);
        await flushPromises();

        expect(next).toHaveBeenCalledWith(expect.objectContaining({ statusCode: 400 }));
    });
});

describe('getFavorites', () => {
    test('devuelve lista de favoritos', async () => {
        pool.query
            .mockResolvedValueOnce({ rows: [{ count: '1' }] })
            .mockResolvedValueOnce({ rows: [{ song_id: 1 }] });

        const req = mockReq({ query: { page: '1', limit: '10' } });
        const res = mockRes();
        const next = mockNext();

        getFavorites(req, res, next);
        await flushPromises();

        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ success: true, favorites: [{ song_id: 1 }] }));
    });

    test('devuelve array vacío', async () => {
        pool.query
            .mockResolvedValueOnce({ rows: [{ count: '0' }] })
            .mockResolvedValueOnce({ rows: [] });

        const req = mockReq({ query: { page: '1', limit: '10' } });
        const res = mockRes();
        const next = mockNext();

        getFavorites(req, res, next);
        await flushPromises();

        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ success: true, favorites: [] }));
    });
});

describe('deleteFavorite', () => {
    test('elimina de favoritos', async () => {
        pool.query.mockResolvedValueOnce({ rowCount: 1 });

        const req = mockReq({ params: { id: 1 } });
        const res = mockRes();
        const next = mockNext();

        deleteFavorite(req, res, next);
        await flushPromises();

        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ success: true }));
    });

    test('lanza 404 si no existe el favorito', async () => {
        pool.query.mockResolvedValueOnce({ rowCount: 0 });

        const req = mockReq({ params: { id: 99 } });
        const res = mockRes();
        const next = mockNext();

        deleteFavorite(req, res, next);
        await flushPromises();

        expect(next).toHaveBeenCalledWith(expect.objectContaining({ statusCode: 404 }));
    });
});
