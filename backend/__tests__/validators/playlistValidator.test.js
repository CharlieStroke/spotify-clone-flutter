const { createPlaylistSchema } = require('../../src/validators/playlistValidator');

describe('createPlaylistSchema', () => {
  test('acepta nombre válido', () => {
    const { error } = createPlaylistSchema.validate({ name: 'Mi Playlist' });
    expect(error).toBeUndefined();
  });

  test('rechaza nombre menor a 3 caracteres', () => {
    const { error } = createPlaylistSchema.validate({ name: 'ab' });
    expect(error).toBeDefined();
  });

  test('rechaza sin nombre', () => {
    const { error } = createPlaylistSchema.validate({});
    expect(error).toBeDefined();
  });

  test('acepta nombre con descripción opcional', () => {
    const { error } = createPlaylistSchema.validate({ name: 'Playlist', description: 'desc' });
    expect(error).toBeUndefined();
  });
});
