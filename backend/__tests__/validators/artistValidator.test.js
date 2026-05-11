const { createArtistSchema, albumSchema } = require('../../src/validators/artistValidator');

describe('createArtistSchema', () => {
  test('acepta stage_name válido', () => {
    const { error } = createArtistSchema.validate({ stage_name: 'Mi Artista' });
    expect(error).toBeUndefined();
  });

  test('rechaza sin stage_name', () => {
    const { error } = createArtistSchema.validate({});
    expect(error).toBeDefined();
  });

  test('acepta sin bio (bio es opcional)', () => {
    const { error } = createArtistSchema.validate({ stage_name: 'X' });
    expect(error).toBeUndefined();
  });

  test('rechaza stage_name mayor a 255 caracteres', () => {
    const { error } = createArtistSchema.validate({ stage_name: 'a'.repeat(256) });
    expect(error).toBeDefined();
  });
});

describe('albumSchema', () => {
  test('acepta title válido', () => {
    const { error } = albumSchema.validate({ title: 'Mi Álbum' });
    expect(error).toBeUndefined();
  });

  test('rechaza sin title', () => {
    const { error } = albumSchema.validate({});
    expect(error).toBeDefined();
  });
});
