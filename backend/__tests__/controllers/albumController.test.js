jest.mock('../../src/config/db', () => ({ query: jest.fn(), connect: jest.fn() }));
jest.mock('../../src/services/supabaseStorageService', () => ({ uploadFile: jest.fn() }));

const pool = require('../../src/config/db');
const storageService = require('../../src/services/supabaseStorageService');
const { createAlbum, getAlbums, deleteAlbum, updateAlbumName, getAllAlbums, getAlbumSongs } = require('../../src/controllers/albumController');
const { mockReq, mockRes, mockNext } = require('../helpers');

beforeEach(() => jest.clearAllMocks());

const flushPromises = () => new Promise(setImmediate);

describe('createAlbum', () => {
    test('crea álbum y devuelve 201', async () => {
        pool.query.mockResolvedValueOnce({ rows: [{ album_id: 1, title: 'Album', artist_id: 1, cover_url: 'url' }] });
        storageService.uploadFile.mockResolvedValueOnce('url');

        const req = mockReq({
            body: { title: 'Album' },
            files: { cover: [{}] },
            artist: { artist_id: 1 }
        });
        const res = mockRes();
        const next = mockNext();

        createAlbum(req, res, next);
        await flushPromises();

        expect(res.status).toHaveBeenCalledWith(201);
        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ success: true, album: expect.any(Object) }));
    });

    test('lanza error si falla el upload', async () => {
        storageService.uploadFile.mockRejectedValueOnce(new Error('Upload error'));

        const req = mockReq({
            body: { title: 'Album' },
            files: { cover: [{}] },
            artist: { artist_id: 1 }
        });
        const res = mockRes();
        const next = mockNext();

        createAlbum(req, res, next);
        await flushPromises();

        expect(next).toHaveBeenCalledWith(expect.objectContaining({ message: 'Upload error' }));
    });
});

describe('getAlbums', () => {
    test('devuelve álbumes del artista', async () => {
        pool.query.mockResolvedValueOnce({ rows: [{ album_id: 1 }] });

        const req = mockReq({ artist: { artist_id: 1 } });
        const res = mockRes();
        const next = mockNext();

        getAlbums(req, res, next);
        await flushPromises();

        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ success: true, albums: [{ album_id: 1 }] }));
    });

    test('devuelve array vacío si no tiene álbumes', async () => {
        pool.query.mockResolvedValueOnce({ rows: [] });

        const req = mockReq({ artist: { artist_id: 1 } });
        const res = mockRes();
        const next = mockNext();

        getAlbums(req, res, next);
        await flushPromises();

        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ success: true, albums: [] }));
    });
});

describe('deleteAlbum', () => {
    test('elimina álbum con transacción y devuelve 200', async () => {
        const album = { album_id: 1, title: 'Album X', artist_id: 1 };
        pool.query.mockResolvedValueOnce({ rows: [album] });

        const mockClient = { query: jest.fn(), release: jest.fn() };
        pool.connect.mockResolvedValueOnce(mockClient);
        mockClient.query
            .mockResolvedValueOnce({}) // BEGIN
            .mockResolvedValueOnce({}) // DELETE playlist_songs
            .mockResolvedValueOnce({}) // DELETE songs
            .mockResolvedValueOnce({}) // DELETE albums
            .mockResolvedValueOnce({}); // COMMIT

        const req = mockReq({ params: { id: '1' }, artist: { artist_id: 1 } });
        const res = mockRes();
        const next = mockNext();

        deleteAlbum(req, res, next);
        await flushPromises();

        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ success: true }));
        expect(mockClient.release).toHaveBeenCalled();
    });

    test('lanza 404 si el álbum no pertenece al artista', async () => {
        pool.query.mockResolvedValueOnce({ rows: [] });

        const req = mockReq({ params: { id: '99' }, artist: { artist_id: 1 } });
        const res = mockRes();
        const next = mockNext();

        deleteAlbum(req, res, next);
        await flushPromises();

        expect(next).toHaveBeenCalledWith(expect.objectContaining({ statusCode: 404 }));
    });

    test('hace rollback y propaga error si la transacción falla', async () => {
        const album = { album_id: 1, title: 'Album X', artist_id: 1 };
        pool.query.mockResolvedValueOnce({ rows: [album] });

        const txError = new Error('DB transaction failed');
        const mockClient = { query: jest.fn(), release: jest.fn() };
        pool.connect.mockResolvedValueOnce(mockClient);
        mockClient.query
            .mockResolvedValueOnce({})             // BEGIN
            .mockRejectedValueOnce(txError)        // DELETE playlist_songs fails
            .mockResolvedValueOnce({});            // ROLLBACK

        const req = mockReq({ params: { id: '1' }, artist: { artist_id: 1 } });
        const res = mockRes();
        const next = mockNext();

        deleteAlbum(req, res, next);
        await flushPromises();

        expect(next).toHaveBeenCalledWith(txError);
        expect(mockClient.release).toHaveBeenCalled();
    });
});

describe('updateAlbumName', () => {
    test('actualiza nombre del álbum y devuelve 200', async () => {
        const album = { album_id: 1, title: 'Old Title', artist_id: 1, cover_url: 'url' };
        pool.query
            .mockResolvedValueOnce({ rows: [album] }) // SELECT
            .mockResolvedValueOnce({ rows: [] });     // UPDATE

        const req = mockReq({ params: { id: '1' }, body: { title: 'New Title' }, artist: { artist_id: 1 } });
        const res = mockRes();
        const next = mockNext();

        updateAlbumName(req, res, next);
        await flushPromises();

        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
            success: true,
            album: expect.objectContaining({ title: 'New Title' }),
        }));
    });

    test('lanza 404 si el álbum no existe o no pertenece al artista', async () => {
        pool.query.mockResolvedValueOnce({ rows: [] });

        const req = mockReq({ params: { id: '99' }, body: { title: 'Nuevo' }, artist: { artist_id: 1 } });
        const res = mockRes();
        const next = mockNext();

        updateAlbumName(req, res, next);
        await flushPromises();

        expect(next).toHaveBeenCalledWith(expect.objectContaining({ statusCode: 404 }));
    });
});

describe('getAllAlbums', () => {
    test('devuelve álbumes paginados', async () => {
        pool.query
            .mockResolvedValueOnce({ rows: [{ count: '2' }] })
            .mockResolvedValueOnce({ rows: [{ album_id: 1, artist_name: 'DJ X' }, { album_id: 2, artist_name: 'DJ Y' }] });

        const req = mockReq({ query: { page: '1', limit: '10' } });
        const res = mockRes();
        const next = mockNext();

        getAllAlbums(req, res, next);
        await flushPromises();

        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
            success: true,
            albums: expect.any(Array),
            pagination: expect.objectContaining({ totalItems: 2 }),
        }));
    });

    test('devuelve array vacío si no hay álbumes', async () => {
        pool.query
            .mockResolvedValueOnce({ rows: [{ count: '0' }] })
            .mockResolvedValueOnce({ rows: [] });

        const req = mockReq({ query: { page: '1', limit: '10' } });
        const res = mockRes();
        const next = mockNext();

        getAllAlbums(req, res, next);
        await flushPromises();

        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ albums: [], pagination: expect.objectContaining({ totalItems: 0 }) }));
    });
});

describe('getAlbumSongs', () => {
    test('devuelve álbum con sus canciones', async () => {
        pool.query
            .mockResolvedValueOnce({ rows: [{ album_id: 1 }] })
            .mockResolvedValueOnce({ rows: [{ song_id: 1 }] });

        const req = mockReq({ params: { id: 1 } });
        const res = mockRes();
        const next = mockNext();

        getAlbumSongs(req, res, next);
        await flushPromises();

        expect(res.status).toHaveBeenCalledWith(200);
        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ success: true, songs: [{ song_id: 1 }] }));
    });

    test('lanza 404 si no existe', async () => {
        pool.query.mockResolvedValueOnce({ rows: [] });

        const req = mockReq({ params: { id: 99 } });
        const res = mockRes();
        const next = mockNext();

        getAlbumSongs(req, res, next);
        await flushPromises();

        expect(res.status).toHaveBeenCalledWith(404);
        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ success: false, message: 'Álbum no encontrado' }));
    });
});
