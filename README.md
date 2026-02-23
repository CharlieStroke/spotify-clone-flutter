# 🎵 Spotify Clone Backend

Backend developed as part of a **Semester Project for the Mobile Application Development course**.

This system replicates the core functionality of Spotify, allowing management of users, artists, albums, songs, playlists, and favorites, including multimedia file uploads to Object Storage.

---

# 🧱 Architecture

The project follows a **Layered Architecture** with clear separation of responsibilities.

```
src/
 ├── config/        → Database, OCI, and logger configuration
 ├── controllers/   → Business logic
 ├── middleware/    → Authentication, validation, and error handling
 ├── routes/        → API endpoints
 ├── services/      → External services (Object Storage)
 ├── utils/         → Helpers (asyncHandler, pagination)
 ├── validators/    → Request validation using Joi
```

### Implemented Layers

* **Presentation Layer** → Routes
* **Application Layer** → Controllers
* **Service Layer** → Services
* **Infrastructure Layer** → Config
* **Cross-cutting Concerns** → Middleware

This structure ensures scalability, maintainability, and clean separation of concerns.

---

# 🛠 Tech Stack

* Node.js
* Express 5
* PostgreSQL
* JWT (jsonwebtoken)
* bcrypt
* Joi
* Multer (file uploads)
* OCI Object Storage
* Pino (structured logging)
* Helmet (security headers)
* CORS
* Rate Limiting

---

# 🗄 Database

Database Engine: **PostgreSQL**

### Main Tables

* `users`
* `artists`
* `albums`
* `songs`
* `playlists`
* `playlist_songs` (many-to-many relationship)
* `favorites`

### Database Features

* Foreign keys with `ON DELETE CASCADE`
* Unique constraints
* CHECK constraints
* Optimized indexes
* 1–1, 1–N, and N–N relationships

---

# 🔐 Security Features

* JWT-based authentication
* Password hashing using bcrypt
* Role-based authorization (artist role)
* Album ownership validation
* Helmet security headers
* CORS configuration
* Rate limiting
* File validation:

  * MIME type validation
  * 20MB size limit
* Centralized error handler
* Request validation with Joi
* Structured logging with Pino

---

# 📦 Installation

```bash
git clone <repository_url>
cd backend
npm install
```

Create a `.env` file based on `.env.example`:

```
PORT=
DB_HOST=
DB_PORT=
DB_USER=
DB_PASSWORD=
DB_NAME=
JWT_SECRET=
```

Run in development mode:

```bash
npm run dev
```

Run in production mode:

```bash
npm start
```

---

# 📡 Main API Endpoints

## 🔑 Authentication

```
POST   /api/auth/register
POST   /api/auth/login
GET    /api/auth/my-info
```

## 🎤 Artists

```
POST   /api/artists/create
```

## 💿 Albums

```
POST   /api/albums/create
GET    /api/albums/my-albums
PUT    /api/albums/update/:id
DELETE /api/albums/delete/:id
```

## 🎵 Songs

```
POST   /api/songs/addsong
GET    /api/songs/my-songs
GET    /api/songs/all
PUT    /api/songs/update/:id
DELETE /api/songs/delete/:id
PATCH  /api/songs/:id/play
```

## 📁 Playlists

```
POST   /api/playlists/create
GET    /api/playlists/userplaylists
POST   /api/playlists/:playlistId/add/:songId
DELETE /api/playlists/:playlistId
DELETE /api/playlists/:playlistId/remove/:songId
GET    /api/playlists/:playlistId/songs
```

## ❤️ Favorites

```
POST   /api/favorites/add/:id
GET    /api/favorites/
DELETE /api/favorites/remove/:id
```

---

# 📂 File Upload System

* Multer with `memoryStorage`
* MIME type validation
* 20MB file size limit
* Upload to OCI Object Storage
* URLs stored in the database

---

# 📈 Implemented Features

✔ User registration and login
✔ Artist profile creation
✔ Album creation
✔ Song upload (audio + cover)
✔ Playlist management
✔ Favorites system
✔ Play count increment
✔ Pagination
✔ Structured logging
✔ Advanced security configuration

---

# 🧠 Future Improvements

* UUID-based file naming
* Soft delete for songs
* Audio duration validation
* Additional strategic indexes
* Automated testing
* Swagger/OpenAPI documentation

---

# 🎓 Academic Justification

This backend demonstrates:

* Modular and scalable architecture
* Clear separation of concerns
* Secure authentication and authorization
* Multimedia file handling
* Integration with external storage services
* Complete relational database modeling
* Production-ready middleware structure