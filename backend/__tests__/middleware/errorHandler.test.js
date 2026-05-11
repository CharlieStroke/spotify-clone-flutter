jest.mock('../../src/config/logger', () => ({ error: jest.fn() }));

const errorHandler = require('../../src/middleware/errorHandler');

const mockRes = () => {
  const res = {};
  res.status = jest.fn().mockReturnValue(res);
  res.json   = jest.fn().mockReturnValue(res);
  return res;
};

describe('errorHandler', () => {
  const req  = {};
  const next = jest.fn();

  beforeEach(() => {
    jest.clearAllMocks();
  });

  test('usa statusCode del error si está definido', () => {
    const err = new Error('Not found');
    err.statusCode = 404;
    const res = mockRes();

    errorHandler(err, req, res, next);

    expect(res.status).toHaveBeenCalledWith(404);
    expect(res.json).toHaveBeenCalledWith({ success: false, message: 'Not found' });
  });

  test('devuelve 500 para errores sin statusCode', () => {
    const err = new Error('crash');
    const res = mockRes();

    errorHandler(err, req, res, next);

    expect(res.status).toHaveBeenCalledWith(500);
  });

  test('devuelve 400 y mensaje específico para LIMIT_FILE_SIZE', () => {
    const err  = new Error('File too large');
    err.code   = 'LIMIT_FILE_SIZE';
    const res  = mockRes();

    errorHandler(err, req, res, next);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ message: expect.stringContaining('20 MB') })
    );
  });

  test('oculta message en producción para errores 500', () => {
    jest.resetModules();
    process.env.NODE_ENV = 'production';
    jest.mock('../../src/config/logger', () => ({ error: jest.fn() }));
    const prodErrorHandler = require('../../src/middleware/errorHandler');

    const err = new Error('internal details');
    const res = mockRes();

    prodErrorHandler(err, req, res, next);

    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ message: 'Error interno del servidor' })
    );

    delete process.env.NODE_ENV;
  });
});
