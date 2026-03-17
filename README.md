# 🎵 Full-Stack Spotify Clone

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-336791?style=for-the-badge&logo=postgresql&logoColor=white)
![Oracle Cloud](https://img.shields.io/badge/OCI-F80000?style=for-the-badge&logo=oracle&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)

A professional, production-ready music streaming platform built with **Flutter** and **Node.js**. This project replicates the core experience of Spotify, featuring high-fidelity UI, offline-first capabilities, and a robust artist ecosystem.

---

## 🏛 Project Overview

This repository is split into two main components:

### 1. [📱 High-Fidelity Mobile App](./lib/README.md)
*   **Built with**: 
    ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
    ![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)
    ![BLoC](https://img.shields.io/badge/BLoC-5FB9FF?style=flat&logo=flutter&logoColor=white)
*   **Key Features**: Premium UI (Hero animations, Shimmers), Offline-First caching (Hive), Gesture-based player, and Artist management.
*   **Supported Platforms**: Android & iOS.

### 2. [📡 Scalable Backend API](./backend/README.md)
*   **Built with**: 
    ![Node.js](https://img.shields.io/badge/Node.js-339933?style=flat&logo=nodedotjs&logoColor=white)
    ![Express](https://img.shields.io/badge/Express-000000?style=flat&logo=express&logoColor=white)
    ![PostgreSQL](https://img.shields.io/badge/PostgreSQL-336791?style=flat&logo=postgresql&logoColor=white)
*   **Key Features**: JWT Security, Multimedia streaming (OCI), Multi-cloud storage integration, and Rate limiting.

---

## 🏗 System Architecture

```mermaid
graph TD
    User([User App]) <--> API[Node.js Express API]
    API <--> DB[(PostgreSQL Database)]
    API <--> OCI[OCI Object Storage]
    User <--> Hive[(Local Cache)]
```

### Core Workflows
1.  **Authentication**: Secure JWT flow for users and artists.
2.  **Streaming**: Songs are served via progressive streaming from OCI.
3.  **Offline-First**: Favorites and recent searches are cached locally for an "always-available" experience.
4.  **Artist Ecosystem**: Independent workflow for uploading albums and tracking play counts.

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (Latest Stable)
- Node.js (v18+)
- PostgreSQL instance (or Supabase)

### 1. Setup Backend
```bash
cd backend
npm install
# Configure your .env
npm start
```

### 2. Setup Frontend
```bash
# In the root directory
flutter pub get
# Update ApiConstants with your server IP
flutter run
```

---

## ☁️ Deployment

### Infrastructure
- **API**: Deployable via Docker or directly on VPS/Cloud (Railway, Render, OCI).
- **Database**: PostgreSQL (Supabase recommended for quick setup).
- **Storage**: Oracle Cloud Infrastructure (OCI) Object Storage or Supabase Storage.

### Docker Deployment (Backend)
```bash
cd backend
docker-compose up -d
```

### Building Mobile App
```bash
# Android
flutter build apk --release
# iOS
flutter build ios --release
```

---

## 🎨 Visual Preview

| Home Screen | Player & Gestures | Artist Dashboard |
| :---: | :---: | :---: |
| ![Home](assets/images/preview_home.png) | ![Player](assets/images/preview_player.png) | ![Artist](assets/images/preview_artist.png) |

> [!NOTE]
> For detailed technical documentation of each component, please visit the respective directories listed above.