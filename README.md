# TAMA APP Client

A mobile application developed with Flutter, featuring a TikTok-style food video sharing platform.

## Features
- 🎬 **Recommendation Page** - TikTok-style video recommendation feed
- 👥 **Follow Functionality** - Follow users and view followed content  
- 🔐 **User Authentication** - Complete login and registration system
- 📱 **Responsive Design** - Adapts to different screen sizes
- 🚀 **Performance Optimization** - Video preloading and image caching
- 🍄 **Multi-language Support** - Using i18n

## Feature Description

### ✅ Recommendation Page

<img src="https://raw.githubusercontent.com/adisonshadow/tama-app/main/Screenshots/home.png" alt="Recommendation Screenshot" width="188">

- Vertical swipe to switch videos
- Auto play/pause/fullscreen playback
- Like, favorite, share, comment and comment browsing
- Author information display
- Video detail display

<img src="https://raw.githubusercontent.com/adisonshadow/tama-app/main/Screenshots/video%20detail.png" alt="Video Detail Screenshot" width="188">

- Search functionality
- Browse more videos by tags
- User Space

<img src="https://raw.githubusercontent.com/adisonshadow/tama-app/main/Screenshots/user%20space.png" alt="User Space Screenshot" width="188">


### ✅ Follow Functionality

<img src="https://raw.githubusercontent.com/adisonshadow/tama-app/main/Screenshots/following%20videos.png" alt="Following Screenshot" width="188">

- View followed users list
- Browse followed users' works
- Unfollow operations

### ✅ User Authentication
- Email registration/login

<img src="https://raw.githubusercontent.com/adisonshadow/tama-app/main/Screenshots/auth.png" alt="Login Screenshot" width="188">

- JWT Token management
- Auto login
- Secure logout

### ✅ Messages

### ⏳ Video Publishing 

### ✅ Profile
- Personal profile display and editing
- Followers, likes, favorites

## Technical Features

- ✅ Multi-language

<img src="https://raw.githubusercontent.com/adisonshadow/tama-app/main/Screenshots/i18n.png" alt="Language Switch Screenshot" width="188">

- ✅ Check for new versions and install

## TODO
- ⏳ OTA updates
- ⏳ Android multi-device adaptation (incomplete), iOS not started yet
- ⏳ Video vertical swipe switching not as smooth as TikTok on some low-end devices
- ⏳ Video player interface lacks drag scrollbar, fast forward, volume adjustment

## Tech Stack

- **Flutter** - UI framework
- **Provider** - State management
- **Dio** - Network requests
- **Go Router** - Route management
- **Video Player** - Video playback
- **Cached Network Image** - Image caching
- **flutter i18n** - Multi-language support

## Project Structure

```
lib/
├── core/                 # Core functionality
│   ├── constants/        # Constant definitions
│   ├── network/          # Network configuration
│   └── utils/            # Utility functions
├── features/             # Feature modules
│   ├── auth/             # Authentication module
│   ├── home/             # Home module
│   └── following/        # Following module
└── shared/               # Shared components
    ├── models/           # Data models
    ├── services/         # Service layer
    └── widgets/          # Common components
```

## Development Environment Requirements

- Flutter SDK >= 3.13.0
- Dart SDK >= 3.1.0
- Android SDK (for Android development)
- Xcode (for iOS development, optional)

## Quick Start

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Generate Code

```bash
flutter packages pub run build_runner build
```

### 3. Run Project

```bash
# Android
flutter run

# iOS (requires macOS environment)
flutter run -d ios

# Chrome
flutter run -d chrome --hot

# Validate multi-language
flutter pub run flutter_i18n validate

# Project syntax validation
flutter analyze
```

### 4. Build Project
```bash

# Android
flutter build apk --release

# If only 64-bit ARM is needed (more common on modern devices)
flutter build apk --release --target-platform android-arm64

# iOS
flutter build ios --release

```


## API Interface

The application connects to an existing backend API service:

- **Base URL**: `http://localhost:3003/api` (configured in lib/core/constants/app_constants.dart)
- **Authentication**: JWT Token
- **Main Interfaces**:
  - `POST /auth/login` - User login
  - `POST /auth/register` - User registration
  - `GET /articles/recommendeds` - Get recommended videos
  - `GET /my/getMyFollows` - Get follow list

## Notes

1. Ensure the backend API service is running
2. Video playback requires network connection
3. First run may take longer to download dependencies
4. Android requires allowing cleartext network traffic (development environment)

## License
MIT License
