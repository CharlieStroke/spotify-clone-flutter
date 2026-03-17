## 🛠 Tech Stack

![Node.js](https://img.shields.io/badge/Node.js-339933?style=flat-square&logo=nodedotjs&logoColor=white)
![Express.js](https://img.shields.io/badge/Express.js-000000?style=flat-square&logo=express&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-336791?style=flat-square&logo=postgresql&logoColor=white)
![Oracle Cloud](https://img.shields.io/badge/OCI-F80000?style=flat-square&logo=oracle&logoColor=white)
![JWT](https://img.shields.io/badge/JWT-000000?style=flat-square&logo=jsonwebtokens&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker&logoColor=white)

## 📁 Architecture

The project follows a **Layered Architecture** to ensure separation of concerns:
- **Controllers**: Handle HTTP requests and responses.
- **Services**: Business logic and third-party integrations (OCI, Supabase).
- **Routes**: Define API endpoints and apply middleware.
- **Middleware**: Authentication, Error Handling, File Uploads, Validation.

## 🔑 Key Features

- **JWT Authentication**: Secure user registration and login.
- **Role-based Middleware**: Specialized access for Artists.
- **Media Management**: Progressive upload of songs and images to OCI/Supabase.
- **Advanced Search**: Resource-efficient searching for songs, albums, and artists.
- **Rate Limiting**: Protection against brute-force and DDoS attacks.
- **Structured Logging**: Production-ready logging for debugging.

## 📡 API Endpoints

### Auth
- `POST /api/auth/register` - Create a new user.
- `POST /api/auth/login` - Authenticate and get token.
- `GET /api/auth/` - Get current user info.
- `PUT /api/auth/profile` - Update profile image and details.

### Artists & Music
- `POST /api/artists/register` - Become an artist.
- `POST /api/albums/add` - Create a new album.
- `POST /api/songs/addsong` - Upload a song (Audio + Cover).
- `GET /api/songs/all` - List all songs.
- `PATCH /api/songs/:id/play` - Increment play count.

### Playlists & Favorites
- `POST /api/playlists/create` - Create a new playlist.
- `POST /api/playlists/add-song` - Add song to playlist.
- `GET /api/favorites/` - Get user's favorite songs.

## 🚀 Getting Started

1.  **Install dependencies**:
    ```bash
    npm install
    ```

2.  **Environment Variables**:
    Create a `.env` file based on `.env.example`:
    ```env
    PORT=4000
    DATABASE_URL=your_supabase_url
    JWT_SECRET=your_secret
    OCI_USER_ID=...
    OCI_TENANCY_ID=...
    ```

3.  **Run in Dev mode**:
    ```bash
    npm run dev
    ```

4.  **Run in Production**:
    ```bash
    npm start
    ```
