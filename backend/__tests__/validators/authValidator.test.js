const { registerSchema, loginSchema } = require('../../src/validators/authValidator');

describe('registerSchema', () => {
  const valid = { email: 'user@test.com', password: 'Passw0rd!', username: 'testuser' };

  test('acepta datos válidos', () => {
    const { error } = registerSchema.validate(valid);
    expect(error).toBeUndefined();
  });

  test('rechaza password sin mayúscula', () => {
    const { error } = registerSchema.validate({ ...valid, password: 'passw0rd!' });
    expect(error).toBeDefined();
  });

  test('rechaza password sin número', () => {
    const { error } = registerSchema.validate({ ...valid, password: 'Password!' });
    expect(error).toBeDefined();
  });

  test('rechaza password sin símbolo', () => {
    const { error } = registerSchema.validate({ ...valid, password: 'Passw0rd1' });
    expect(error).toBeDefined();
  });

  test('rechaza password menor a 8 caracteres', () => {
    const { error } = registerSchema.validate({ ...valid, password: 'P0rd!' });
    expect(error).toBeDefined();
  });

  test('rechaza email inválido', () => {
    const { error } = registerSchema.validate({ ...valid, email: 'not-an-email' });
    expect(error).toBeDefined();
  });

  test('rechaza username menor a 3 caracteres', () => {
    const { error } = registerSchema.validate({ ...valid, username: 'ab' });
    expect(error).toBeDefined();
  });
});

describe('loginSchema', () => {
  test('acepta email y password válidos', () => {
    const { error } = loginSchema.validate({ email: 'user@test.com', password: 'anypass' });
    expect(error).toBeUndefined();
  });

  test('rechaza sin email', () => {
    const { error } = loginSchema.validate({ password: 'anypass' });
    expect(error).toBeDefined();
  });

  test('rechaza password menor a 6 caracteres', () => {
    const { error } = loginSchema.validate({ email: 'user@test.com', password: '123' });
    expect(error).toBeDefined();
  });
});
