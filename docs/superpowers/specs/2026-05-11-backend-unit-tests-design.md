# Spec: Backend Unit Test Suite

**Fecha:** 2026-05-11  
**Proyecto:** Snakefy — backend Node.js/Express  
**Scope:** Suite completa de tests unitarios para controllers, middleware y validators

---

## Contexto

El backend no tiene tests. Stack: Express 5, pg (pool de PostgreSQL), JWT (jsonwebtoken), bcrypt, Joi, asyncHandler wrapper, pino logger. Los controllers importan `pool` directamente desde `../config/db`, lo que hace trivial el mocking con `jest.mock()`.

---

## Herramientas

| Herramienta | Rol |
|---|---|
| `jest` | test runner, assertions, mocks |
| `jest.mock()` | mock de módulos: `pool`, `bcrypt`, `jsonwebtoken`, `supabaseStorageService` |

No se agrega `supertest` — los tests son unitarios puros.

**Instalación:**
```bash
npm install --save-dev jest
```

**Scripts en `package.json`:**
```json
"test":          "jest",
"test:watch":    "jest --watch",
"test:coverage": "jest --coverage"
```

**Config Jest en `package.json`:**
```json
"jest": {
  "testEnvironment": "node"
}
```

---

## Estructura de archivos

```
backend/
  __tests__/
    helpers.js                          ← req/res/next helpers compartidos
    controllers/
      authController.test.js
      artistController.test.js
      songController.test.js
      albumController.test.js
      playlistController.test.js
      favoriteController.test.js
      searchController.test.js
    middleware/
      authMiddleware.test.js
      artistMiddleware.test.js
      errorHandler.test.js
    validators/
      authValidator.test.js
      artistValidator.test.js
      playlistValidator.test.js
```

---

## Helpers compartidos (`__tests__/helpers.js`)

```js
const mockReq = (overrides = {}) => ({
  user:    { userId: 1 },
  artist:  { artist_id: 1 },
  params:  {},
  body:    {},
  query:   {},
  headers: {},
  files:   null,
  file:    null,
  ...overrides,
});

const mockRes = () => {
  const res = {};
  res.status = jest.fn().mockReturnValue(res);
  res.json   = jest.fn().mockReturnValue(res);
  return res;
};

const mockNext = () => jest.fn();

module.exports = { mockReq, mockRes, mockNext };
```

---

## Módulos a mockear por archivo

| Archivo de test | Mocks necesarios |
|---|---|
| `authController.test.js` | `../config/db`, `bcrypt`, `jsonwebtoken` |
| `artistController.test.js` | `../config/db`, `../services/supabaseStorageService` |
| `songController.test.js` | `../config/db` |
| `albumController.test.js` | `../config/db`, `../services/supabaseStorageService` |
| `playlistController.test.js` | `../config/db`, `../services/supabaseStorageService` |
| `favoriteController.test.js` | `../config/db` |
| `searchController.test.js` | `../config/db` |
| `authMiddleware.test.js` | `jsonwebtoken` |
| `artistMiddleware.test.js` | `../config/db` |
| `errorHandler.test.js` | `../config/logger` |

---

## Tests por archivo

### `authController.test.js`

Mocks al inicio del archivo:
```js
jest.mock('../../src/config/db');
jest.mock('bcrypt');
jest.mock('jsonwebtoken');
const pool   = require('../../src/config/db');
const bcrypt = require('bcrypt');
const jwt    = require('jsonwebtoken');
```

Antes de cada test: `jest.clearAllMocks()`.  
`process.env.JWT_SECRET = 'test-secret'` en `beforeAll`.

**`register`**
- `'registra usuario y devuelve 201 con token'` — pool devuelve `{ rows: [] }` (usuario no existe), luego `{ rows: [{ user_id: 1, email, username }] }` (INSERT), luego `{ rows: [] }` (issueRefreshToken INSERT); bcrypt.hash resuelve `'hashed'`; jwt.sign devuelve `'access-token'` → `res.status(201).json` llamado con `{ success: true, token, refreshToken, user }`
- `'lanza 400 si el usuario ya existe'` — pool devuelve `{ rows: [{ user_id: 1 }] }` en la primera query → `next` llamado con error `statusCode 400`
- `'lanza 400 si el body falla validación Joi'` — body con password sin mayúsculas → `next` llamado con error `statusCode 400`

**`login`**
- `'devuelve token en login exitoso'` — pool devuelve usuario; bcrypt.compare resuelve `true`; jwt.sign devuelve token → `res.json` con `{ success: true, token }`
- `'lanza 401 si el email no existe'` — pool devuelve `{ rows: [] }` → `next` con `statusCode 401`
- `'lanza 401 si la contraseña es incorrecta'` — pool devuelve usuario; bcrypt.compare resuelve `false` → `next` con `statusCode 401`

**`logout`**
- `'elimina refresh token y devuelve success'` — pool.query resuelve; req.body con refreshToken → `res.json({ success: true })`
- `'devuelve success aunque no se envíe refreshToken'` — req.body vacío → `res.json({ success: true })` sin llamar pool

**`refreshToken`**
- `'rota el token y devuelve nuevo par'` — pool devuelve token válido, luego DELETE, luego usuario → `res.json({ success: true, token, refreshToken })`
- `'lanza 400 si no se envía refreshToken'` → `next` con `statusCode 400`
- `'lanza 401 si el token no existe o expiró'` — pool devuelve `{ rows: [] }` → `next` con `statusCode 401`

**`MyUserInfo`**
- `'devuelve datos del usuario autenticado'` — pool devuelve usuario → `res.json({ success: true, user })`
- `'lanza 404 si el usuario no existe'` — pool devuelve `{ rows: [] }` → `next` con `statusCode 404`

---

### `artistController.test.js`

```js
jest.mock('../../src/config/db');
jest.mock('../../src/services/supabaseStorageService');
const pool           = require('../../src/config/db');
const storageService = require('../../src/services/supabaseStorageService');
```

**`getMyArtistProfile`**
- `'devuelve el perfil del artista'` — pool devuelve artista → `res.json({ success: true, artist })`
- `'lanza 404 si no tiene perfil'` — pool devuelve `{ rows: [] }` → `next` con `statusCode 404`

**`getArtistStats`**
- `'devuelve stats completas con Promise.all'` — pool.query resuelve 3 veces (totals, topSongs, playsByAlbum) → `res.status(200).json` con `{ success: true, stats: { total_plays, total_songs, total_albums, top_songs, plays_by_album } }`; verificar que los valores numéricos son `parseInt`eados (no strings)
- `'devuelve zeros si no hay canciones'` — totals con `{ total_plays: '0', total_songs: '0', total_albums: '0' }`, listas vacías → response con ceros
- `'llama next con error si pool falla'` — pool.query rechaza → `next` llamado con el error

**`createArtist`**
- `'crea artista y devuelve 201'` — pool: no existe artista, no existe stage_name, INSERT ok; storageService.uploadFile resuelve URL; req.files con imagen → `res.status(201)`
- `'lanza 400 si ya tiene perfil de artista'` — primera query devuelve artista existente → `next` con `statusCode 400`
- `'lanza 400 si stage_name ya existe'` — segunda query devuelve nombre en uso → `next` con `statusCode 400`
- `'lanza 400 si no se sube imagen'` — req.files vacío → `next` con `statusCode 400`

---

### `songController.test.js`

```js
jest.mock('../../src/config/db');
const pool = require('../../src/config/db');
```

**`getAllSongs`**
- `'devuelve lista de canciones'` — pool devuelve array de canciones → `res.json({ success: true, songs })`
- `'devuelve array vacío si no hay canciones'` — pool devuelve `{ rows: [] }` → `res.json({ songs: [] })`

**`getSongsByArtist`**
- `'devuelve canciones incluyendo plays y paginación'` — pool devuelve `{ rows: [{ count: '2' }] }` (total) y `{ rows: [song1, song2] }` (canciones con campo `plays`) → `res.status(200).json({ success: true, songs, pagination })`; verificar que `plays` está presente en los objetos devueltos
- `'devuelve array vacío si el artista no tiene canciones'` — pool devuelve `{ rows: [{ count: '0' }] }` y `{ rows: [] }` → `res.json({ songs: [], pagination: { totalItems: 0 } })`

**`updateSongPlays` (`PATCH /songs/:id/play`)**
- `'incrementa plays y devuelve 200'` — pool.query resuelve → `res.status(200).json({ success: true })`
- `'lanza 404 si la canción no existe'` — pool devuelve `{ rows: [] }` → `next` con `statusCode 404`

---

### `albumController.test.js`

```js
jest.mock('../../src/config/db');
jest.mock('../../src/services/supabaseStorageService');
```

**`createAlbum`**
- `'crea álbum y devuelve 201'` — pool INSERT ok; storageService resuelve URL → `res.status(201)`
- `'lanza error si falla el upload'` — storageService rechaza → `next` llamado con error

**`getAlbumsByArtist`**
- `'devuelve álbumes del artista'` → `res.json({ success: true, albums })`
- `'devuelve array vacío si no tiene álbumes'`

**`getAlbumById`**
- `'devuelve álbum con sus canciones'` → `res.json` con álbum + canciones
- `'lanza 404 si no existe'` → `next` con `statusCode 404`

---

### `playlistController.test.js`

```js
jest.mock('../../src/config/db');
jest.mock('../../src/services/supabaseStorageService');
```

**`createPlaylist`**
- `'crea playlist y devuelve 201'`
- `'lanza error si falla el upload de cover'`

**`getUserPlaylists`**
- `'devuelve playlists del usuario'`
- `'devuelve array vacío si no tiene playlists'`

**`addSongToPlaylist`**
- `'agrega canción exitosamente'`
- `'lanza 404 si la playlist no existe o no pertenece al usuario'`

**`removeSongFromPlaylist`**
- `'elimina canción exitosamente'`
- `'lanza 404 si la canción no está en la playlist'`

---

### `favoriteController.test.js`

```js
jest.mock('../../src/config/db');
```

**`addFavorite`**
- `'agrega a favoritos y devuelve 201'`
- `'lanza 400 si ya es favorito'` — pool devuelve favorito existente

**`removeFavorite`**
- `'elimina de favoritos'`
- `'lanza 404 si no existe el favorito'`

**`getFavorites`**
- `'devuelve lista de favoritos'`
- `'devuelve array vacío'`

---

### `searchController.test.js`

```js
jest.mock('../../src/config/db');
```

**`search`**
- `'devuelve resultados de canciones, álbumes y artistas'` — pool resuelve 3 queries → `res.json({ success: true, results: { songs, albums, artists } })`
- `'devuelve resultados vacíos si no hay matches'` — todas las queries devuelven `{ rows: [] }`
- `'llama next con error si pool falla'`

---

### `authMiddleware.test.js`

```js
jest.mock('jsonwebtoken');
const jwt = require('jsonwebtoken');
```

- `'adjunta req.user y llama next con token válido'` — jwt.verify devuelve payload `{ userId: 1 }` → `req.user` adjunto, `next()` llamado
- `'devuelve 401 sin header Authorization'` — req sin header → `res.status(401).json`
- `'devuelve 401 con formato incorrecto (sin Bearer)'` — header `"Token abc"` → `res.status(401)`
- `'devuelve 401 con token inválido'` — jwt.verify lanza `JsonWebTokenError` → `res.status(401)`

---

### `artistMiddleware.test.js`

```js
jest.mock('../../src/config/db');
const pool = require('../../src/config/db');
```

- `'adjunta req.artist y llama next si es artista'` — pool devuelve `{ rows: [{ artist_id: 1 }] }` → `req.artist` adjunto, `next()` llamado
- `'lanza 403 si el usuario no tiene perfil de artista'` — pool devuelve `{ rows: [] }` → `next` con error `statusCode 403`
- `'devuelve 401 si req.user no existe'` — `req.user = undefined` → `res.status(401)`

---

### `errorHandler.test.js`

```js
jest.mock('../../src/config/logger', () => ({ error: jest.fn() }));
```

- `'usa statusCode del error si está definido'` — error con `statusCode: 404, message: 'Not found'` → `res.status(404).json({ success: false, message: 'Not found' })`
- `'devuelve 500 para errores sin statusCode'` — error genérico → `res.status(500)`
- `'devuelve 400 para error LIMIT_FILE_SIZE de multer'` — error con `code: 'LIMIT_FILE_SIZE'` → `res.status(400)` con mensaje de tamaño
- `'oculta message en producción para errores 500'` — `NODE_ENV = 'production'`; error sin statusCode → message `'Error interno del servidor'`

---

### `authValidator.test.js`

Sin mocks — tests puros de Joi.

**`registerSchema`**
- `'acepta datos válidos'` — email, password con mayúscula + número + símbolo, username → `error` undefined
- `'rechaza password sin mayúscula'`
- `'rechaza password sin número'`
- `'rechaza password sin símbolo'`
- `'rechaza password menor a 8 caracteres'`
- `'rechaza email inválido'`
- `'rechaza username menor a 3 caracteres'`

**`loginSchema`**
- `'acepta email y password válidos'`
- `'rechaza sin email'`
- `'rechaza password menor a 6 caracteres'`

---

### `artistValidator.test.js`

**`createArtistSchema`**
- `'acepta stage_name válido'` — `{ stage_name: 'Mi Artista' }` → sin error
- `'rechaza sin stage_name'` — body vacío → error definido
- `'acepta sin bio (bio es opcional)'` — solo `{ stage_name: 'X' }` → sin error
- `'rechaza stage_name mayor a 255 caracteres'`

**`albumSchema`**
- `'acepta title válido'` — `{ title: 'Mi Álbum' }` → sin error
- `'rechaza sin title'` → error definido

---

### `playlistValidator.test.js`

- `'acepta nombre válido'`
- `'rechaza nombre vacío'`

---

## Notas de implementación

**`asyncHandler` y `await`:** Los controllers están envueltos en `asyncHandler`. Al llamarlos en tests se debe hacer `await handler(req, res, next)` para que el Promise resuelva antes de los assertions.

**`Promise.all` en `getArtistStats`:** Se necesitan 3 `mockResolvedValueOnce` encadenados (uno por cada query en el `Promise.all`).

**`bcrypt` en `authController`:** Mockear `bcrypt.hash` y `bcrypt.compare` para evitar el costo real de hashing en tests.

**`supabaseStorageService`:** Mockear solo `uploadFile` — devuelve una URL ficticia `'https://storage.test/file.jpg'`.

**Variables de entorno:** `process.env.JWT_SECRET = 'test-secret'` en `beforeAll` de los tests que necesiten JWT.

**`clearAllMocks` entre tests:** Llamar `jest.clearAllMocks()` en `beforeEach` para que los `mockResolvedValueOnce` no se mezclen entre tests.

---

## Fuera de scope

- `asyncHandler.js` — trivial (3 líneas)
- `pool` config (`config/db.js`) — infraestructura
- `supabaseStorageService.js` / `objectStorageService.js` — servicios externos
- `httpLogger.js` — middleware de logging
- `pagination.js` — utilidad sin lógica de negocio compleja
