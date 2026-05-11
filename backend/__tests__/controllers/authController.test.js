jest.mock('../../src/config/db', () => ({ query: jest.fn(), connect: jest.fn() }));
jest.mock('bcrypt');
jest.mock('jsonwebtoken');
jest.mock('../../src/config/logger', () => ({ error: jest.fn(), info: jest.fn() }));
jest.mock('../../src/services/supabaseStorageService', () => ({ uploadFile: jest.fn() }));

const pool   = require('../../src/config/db');
const bcrypt = require('bcrypt');
const jwt    = require('jsonwebtoken');
const { register, login, logout, refreshToken, MyUserInfo, updateProfile } =
  require('../../src/controllers/authController');
const { mockReq, mockRes, mockNext } = require('../helpers');

beforeAll(() => { process.env.JWT_SECRET = 'test-secret'; });
beforeEach(() => jest.clearAllMocks());

const flushPromises = () => new Promise(setImmediate);

// ─── register ─────────────────────────────────────────────────────────────────
describe('register', () => {
  test('registra usuario y devuelve 201 con token', async () => {
    pool.query
      .mockResolvedValueOnce({ rows: [] })           // usuario no existe
      .mockResolvedValueOnce({ rows: [{ user_id: 1, email: 'a@b.com', username: 'user1' }] }) // INSERT user
      .mockResolvedValueOnce({ rows: [] });           // INSERT refresh_token
    bcrypt.hash.mockResolvedValue('hashed');
    jwt.sign.mockReturnValue('access-token');

    const req  = mockReq({ body: { email: 'a@b.com', password: 'Passw0rd!', username: 'user1' } });
    const res  = mockRes();
    const next = mockNext();

    register(req, res, next);
    await flushPromises();

    expect(res.status).toHaveBeenCalledWith(201);
    expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ 
        success: true, 
        message: 'Usuario registrado exitosamente',
        token: 'access-token' 
    }));
  });

  test('lanza 400 si el usuario ya existe', async () => {
    pool.query.mockResolvedValueOnce({ rows: [{ user_id: 99 }] });
    const req  = mockReq({ body: { email: 'a@b.com', password: 'Passw0rd!', username: 'user1' } });
    const res  = mockRes();
    const next = mockNext();

    register(req, res, next);
    await flushPromises();

    expect(next).toHaveBeenCalledWith(expect.objectContaining({ statusCode: 400 }));
  });

  test('lanza 400 si el body falla validación Joi', async () => {
    const req  = mockReq({ body: { email: 'bad', password: '123', username: 'x' } });
    const res  = mockRes();
    const next = mockNext();

    register(req, res, next);
    await flushPromises();

    expect(next).toHaveBeenCalledWith(expect.objectContaining({ statusCode: 400 }));
  });
});

// ─── login ────────────────────────────────────────────────────────────────────
describe('login', () => {
  const user = { user_id: 1, email: 'a@b.com', username: 'user1', password_hash: 'hashed', profile_image_url: null };

  test('devuelve token en login exitoso', async () => {
    pool.query
      .mockResolvedValueOnce({ rows: [user] })  // SELECT user
      .mockResolvedValueOnce({ rows: [] });      // INSERT refresh_token
    bcrypt.compare.mockResolvedValue(true);
    jwt.sign.mockReturnValue('access-token');

    const req  = mockReq({ body: { email: 'a@b.com', password: 'Passw0rd!' } });
    const res  = mockRes();
    const next = mockNext();

    login(req, res, next);
    await flushPromises();

    expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ 
        success: true, 
        message: 'Login exitoso',
        token: 'access-token' 
    }));
  });

  test('lanza 401 si el email no existe', async () => {
    pool.query.mockResolvedValueOnce({ rows: [] });
    const req  = mockReq({ body: { email: 'x@x.com', password: 'Passw0rd!' } });
    const res  = mockRes();
    const next = mockNext();

    login(req, res, next);
    await flushPromises();

    expect(next).toHaveBeenCalledWith(expect.objectContaining({ statusCode: 401 }));
  });

  test('lanza 401 si la contraseña es incorrecta', async () => {
    pool.query.mockResolvedValueOnce({ rows: [user] });
    bcrypt.compare.mockResolvedValue(false);
    const req  = mockReq({ body: { email: 'a@b.com', password: 'WrongPass1!' } });
    const res  = mockRes();
    const next = mockNext();

    login(req, res, next);
    await flushPromises();

    expect(next).toHaveBeenCalledWith(expect.objectContaining({ statusCode: 401 }));
  });
});

// ─── logout ───────────────────────────────────────────────────────────────────
describe('logout', () => {
  test('elimina refresh token y devuelve success', async () => {
    pool.query.mockResolvedValue({ rows: [] });
    const req  = mockReq({ body: { refreshToken: 'some-token' } });
    const res  = mockRes();
    const next = mockNext();

    logout(req, res, next);
    await flushPromises();

    expect(res.json).toHaveBeenCalledWith({ success: true, message: 'Sesión cerrada' });
  });

  test('devuelve success aunque no se envíe refreshToken', async () => {
    const req  = mockReq({ body: {} });
    const res  = mockRes();
    const next = mockNext();

    logout(req, res, next);
    await flushPromises();

    expect(pool.query).not.toHaveBeenCalled();
    expect(res.json).toHaveBeenCalledWith({ success: true, message: 'Sesión cerrada' });
  });
});

// ─── refreshToken ─────────────────────────────────────────────────────────────
describe('refreshToken', () => {
  test('rota el token y devuelve nuevo par', async () => {
    pool.query
      .mockResolvedValueOnce({ rows: [{ token_id: 1, user_id: 1 }] })
      .mockResolvedValueOnce({ rows: [] })
      .mockResolvedValueOnce({ rows: [{ user_id: 1, email: 'a@b.com' }] })
      .mockResolvedValueOnce({ rows: [] });
    jwt.sign.mockReturnValue('new-access-token');

    const req  = mockReq({ body: { refreshToken: 'raw-token' } });
    const res  = mockRes();
    const next = mockNext();

    refreshToken(req, res, next);
    await flushPromises();

    expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ success: true, token: 'new-access-token' }));
  });

  test('lanza 400 si no se envía refreshToken', async () => {
    const req  = mockReq({ body: {} });
    const res  = mockRes();
    const next = mockNext();

    refreshToken(req, res, next);
    await flushPromises();

    expect(next).toHaveBeenCalledWith(expect.objectContaining({ statusCode: 400 }));
  });

  test('lanza 401 si el token no existe o expiró', async () => {
    pool.query.mockResolvedValueOnce({ rows: [] });
    const req  = mockReq({ body: { refreshToken: 'expired-token' } });
    const res  = mockRes();
    const next = mockNext();

    refreshToken(req, res, next);
    await flushPromises();

    expect(next).toHaveBeenCalledWith(expect.objectContaining({ statusCode: 401 }));
  });
});

// ─── MyUserInfo ───────────────────────────────────────────────────────────────
describe('MyUserInfo', () => {
  test('devuelve datos del usuario autenticado', async () => {
    pool.query.mockResolvedValue({ rows: [{ user_id: 1, email: 'a@b.com', username: 'user1', profile_image_url: null }] });
    const req  = mockReq();
    const res  = mockRes();
    const next = mockNext();

    MyUserInfo(req, res, next);
    await flushPromises();

    expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ success: true, user: expect.any(Object) }));
  });

  test('lanza 404 si el usuario no existe', async () => {
    pool.query.mockResolvedValue({ rows: [] });
    const req  = mockReq();
    const res  = mockRes();
    const next = mockNext();

    MyUserInfo(req, res, next);
    await flushPromises();

    expect(next).toHaveBeenCalledWith(expect.objectContaining({ statusCode: 404 }));
  });
});

// ─── updateProfile ────────────────────────────────────────────────────────────
describe('updateProfile', () => {
  const currentUser = { user_id: 1, email: 'a@b.com', username: 'oldname', password_hash: 'hash', profile_image_url: null };

  test('actualiza username exitosamente', async () => {
    pool.query
      .mockResolvedValueOnce({ rows: [currentUser] })
      .mockResolvedValueOnce({ rows: [] })
      .mockResolvedValueOnce({ rows: [{ ...currentUser, username: 'newname' }] });
    const req  = mockReq({ body: { username: 'newname' } });
    const res  = mockRes();
    const next = mockNext();

    updateProfile(req, res, next);
    await flushPromises();

    expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ success: true, message: 'Perfil actualizado exitosamente' }));
  });

  test('devuelve success sin cambios si no se envía nada', async () => {
    pool.query.mockResolvedValueOnce({ rows: [currentUser] });
    const req  = mockReq({ body: {} });
    const res  = mockRes();
    const next = mockNext();

    updateProfile(req, res, next);
    await flushPromises();

    expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ success: true, message: 'Sin cambios' }));
  });

  test('lanza 401 si oldPassword es incorrecta al cambiar contraseña', async () => {
    pool.query.mockResolvedValueOnce({ rows: [currentUser] });
    bcrypt.compare.mockResolvedValue(false);
    const req  = mockReq({ body: { newPassword: 'NewPass1!', oldPassword: 'wrong' } });
    const res  = mockRes();
    const next = mockNext();

    updateProfile(req, res, next);
    await flushPromises();

    expect(next).toHaveBeenCalledWith(expect.objectContaining({ statusCode: 401 }));
  });
});
