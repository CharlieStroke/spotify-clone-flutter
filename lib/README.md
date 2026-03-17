## 🛠 Tech Stack

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white)
![BLoC](https://img.shields.io/badge/BLoC-5FB9FF?style=flat-square&logo=flutter&logoColor=white)
![Hive](https://img.shields.io/badge/Hive-FFD200?style=flat-square&logo=hive&logoColor=black)
![Dio](https://img.shields.io/badge/Dio-0175C2?style=flat-square&logo=dart&logoColor=white)

## 🌟 Premium Features

### 💎 Elite UI/UX
- **Hero Animations**: Smooth transitions where album covers "fly" into place.
- **Glassmorphic Skeletons**: Modern shimmer loading states that preserve page structure.
- **Dynamic Player**: Gesture-controlled player (Swipe to change tracks).
- **Responsive Layout**: Pixel-perfect design inspired by Spotify's premium aesthetics.

### 📶 Offline-First Experience
- **Search Caching**: Remembers your recent searches even without internet.
- **Persistent Favorites**: Your favorite music is always accessible through local storage synchronization.
- **Network Resilience**: Automatic error handling and elegant empty states when offline.

### 👨‍🎤 Artist Workflow
- **Profile Customization**: Upload profile images and bios.
- **Music Management**: Streamlined UI for creating albums and uploading tracks directly from the app.

## 📁 Architecture (Clean Architecture)

Following Clean Architecture principles to ensure testability and scalability:
- **Data**: Repositories, Models, and Data Sources (Remote/Local).
- **Domain**: Entities and Use Cases.
- **Presentation**: BLoCs, Pages, and Widgets.

## 🚀 Getting Started

1.  **Dependencies**:
    ```bash
    flutter pub get
    ```

2.  **Environment Setup**:
    Ensure the `ApiConstants.baseUrl` in `lib/core/constants/api_constants.dart` points to your running backend.

3.  **Run**:
    ```bash
    flutter run
    ```

## 🛠 Project Structure (Lib)
```
lib/
 ├── core/          # Constants, Theme, Injections, Shared Widgets
 ├── features/      # Feature-based modular structure
 │    ├── auth/     # User login/register
 │    ├── player/   # Audio logic & UI
 │    ├── search/   # Search functionality with Hive cache
 │    └── ...       # Other modules
 └── main.dart      # App Entry Point
```
