jest.mock('../../src/config/db', () => ({ query: jest.fn(), connect: jest.fn() }));
jest.mock('../../src/services/supabaseStorageService', () => ({ uploadFile: jest.fn() }));

const pool = require('../../src/config/db');
const storageService = require('../../src/services/supabaseStorageService');
const { createAlbum, getAlbums, getAlbumSongs } = require('../../src/controllers/albumController');
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
