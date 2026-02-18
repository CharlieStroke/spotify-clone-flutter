# spotify_clone

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Spotify_clone Backend

Backend desarrollado con Node.js, Express y PostgreSQL
Incluye autentificación con JWT y arquitectura modular.

## Tech Stack

- Node.js
- Express
- PostgreSQL
- JWT
- bcrypt
- dotenv

## Instalación 

1. git clone https://github.com/tu_usuario/tu_repo.git
2. Install dependencies: npm install
3. Create .env with the .env.example
4. Run the server: node server.js

## Enviroment Variables

PORT=
DB_HOST=
DB_PORT=
DB_USER=
DB_PASSWORD=
DB_NAME=
JWT_SECRET=

## API Endpoints

POST /api/auth/register
POST /api/auth/login
GET /profile (Protected route)

## Project Structure

src/
 ├── config
 ├── controllers
 ├── middleware
 ├── routes

