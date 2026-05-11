jest.mock('../../src/config/db', () => ({ query: jest.fn(), connect: jest.fn() }));
const pool        = require('../../src/config/db');
const { mockReq, mockRes, mockNext } = require('../helpers');
const ensureArtist = require('../../src/middleware/artistMiddleware');

// asyncHandler wraps the async fn in a sync handler: (req,res,next) => Promise.resolve(fn(...)).catch(next)
// awaiting ensureArtist() only awaits the outer sync return (undefined), so we must flush the
// microtask queue afterwards to let the inner promise settle and invoke next/res.
const flushPromises = () => new Promise(setImmediate);

describe('ensureArtist', () => {
  beforeEach(() => jest.clearAllMocks());

  test('adjunta req.artist y llama next si el usuario es artista', async () => {
    pool.query.mockResolvedValue({ rows: [{ artist_id: 1, user_id: 1, stage_name: 'Artista' }] });
    const req  = mockReq();
    const res  = mockRes();
    const next = mockNext();

    ensureArtist(req, res, next);
    await flushPromises();

    expect(req.artist).toEqual({ artist_id: 1, user_id: 1, stage_name: 'Artista' });
    expect(next).toHaveBeenCalledWith();
  });

  test('llama next con error 403 si el usuario no tiene perfil de artista', async () => {
    pool.query.mockResolvedValue({ rows: [] });
    const req  = mockReq();
    const res  = mockRes();
    const next = mockNext();

    ensureArtist(req, res, next);
    await flushPromises();

    expect(next).toHaveBeenCalledWith(expect.objectContaining({ statusCode: 403 }));
  });

  test('devuelve 401 si req.user no existe', async () => {
    const req  = mockReq({ user: undefined });
    const res  = mockRes();
    const next = mockNext();

    ensureArtist(req, res, next);
    await flushPromises();

    expect(res.status).toHaveBeenCalledWith(401);
  });
});
