jest.mock('jsonwebtoken');
const jwt = require('jsonwebtoken');
const authenticateToken = require('../../src/middleware/authMiddleware');

const mockRes = () => {
  const res = {};
  res.status = jest.fn().mockReturnValue(res);
  res.json   = jest.fn().mockReturnValue(res);
  return res;
};

describe('authenticateToken', () => {
  const next = jest.fn();

  beforeEach(() => jest.clearAllMocks());

  test('adjunta req.user y llama next con token válido', () => {
    jwt.verify.mockReturnValue({ userId: 1, email: 'a@b.com' });
    const req = { headers: { authorization: 'Bearer valid-token' } };
    const res = mockRes();

    authenticateToken(req, res, next);

    expect(req.user).toEqual({ userId: 1, email: 'a@b.com' });
    expect(next).toHaveBeenCalledWith();
  });

  test('devuelve 401 si no hay header Authorization', () => {
    const req = { headers: {} };
    const res = mockRes();

    authenticateToken(req, res, next);

    expect(res.status).toHaveBeenCalledWith(401);
    expect(next).not.toHaveBeenCalled();
  });

  test('devuelve 401 si el formato no es Bearer', () => {
    const req = { headers: { authorization: 'Token abc123' } };
    const res = mockRes();

    authenticateToken(req, res, next);

    expect(res.status).toHaveBeenCalledWith(401);
  });

  test('devuelve 401 si el token es inválido o expirado', () => {
    jwt.verify.mockImplementation(() => { throw new Error('invalid signature'); });
    const req = { headers: { authorization: 'Bearer bad-token' } };
    const res = mockRes();

    authenticateToken(req, res, next);

    expect(res.status).toHaveBeenCalledWith(401);
    expect(next).not.toHaveBeenCalled();
  });
});
