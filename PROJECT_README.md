# ChatBox - Messaging App

A modern, feature-rich messaging application built with **Flutter** and **GetX** state management, based on Figma design specifications.

## 🚀 Features

### ✅ Implemented Screens
- **Splash Screen** - Beautiful app launch screen
- **Onboarding** - First-time user introduction
- **Authentication**
  - Sign In with email/password
  - Sign Up with validation
  - Password visibility toggle
- **Home/Chats**
  - Chat list with unread count
  - Online/offline status indicators
  - Swipe to delete
  - Search functionality
  - Pull to refresh
- **Chat/Messages**
  - Real-time messaging interface
  - Message bubbles (sent/received)
  - Read receipts
  - Date separators
  - Attachment options (Gallery, Camera, Document, Location)
  - Emoji support
- **Contacts**
  - Contact list with online status
  - Quick chat access
  - Create group option
- **Create Group**
  - Select multiple contacts
  - Group name input
  - Selected contacts preview
- **Calls**
  - Call history
  - Missed/received/made call indicators
  - Video/voice call options
  - Call duration display
- **Settings**
  - Profile access
  - Notification toggle
  - Privacy & Security options
  - Help & Terms
  - Logout functionality
- **Profile**
  - User information display
  - Profile picture
  - Edit profile option

## 📂 Project Structure

```
lib/
├── app/
│   ├── core/              # Core utilities, theme, constants
│   ├── data/              # Data models
│   ├── modules/           # Feature modules (GetX pattern)
│   └── routes/            # Navigation configuration
└── main.dart              # App entry point
```

Each module follows the **GetX pattern**:
- `*_binding.dart` - Dependency injection
- `*_controller.dart` - Business logic & state management
- `*_view.dart` - UI components

## 📦 Dependencies

```yaml
dependencies:
  get: ^4.6.6                    # State management
  google_fonts: ^6.2.1           # Typography
  image_picker: ^1.0.7           # Image selection
  cached_network_image: ^3.3.1   # Image caching
  intl: ^0.19.0                  # Date formatting
```

## 🚀 Getting Started

### Installation

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ GetX Architecture

### State Management
- Reactive programming with `.obs`
- Simple state updates with `Obx()`

### Navigation
- Named routes
- Type-safe navigation
- Easy parameter passing

### Dependency Injection
- Lazy loading with `Get.lazyPut()`
- Bindings for each module

## 📱 Design Reference

Design screenshots are in: `design/` folder

## 🎯 Next Steps

Backend integration needed for:
- Authentication (Firebase/Custom)
- Real-time messaging (Socket.io/Firebase)
- File upload (Cloud storage)
- Push notifications (FCM)
- Video/Voice calls (WebRTC)

## 👨‍💻 Author

Built with ❤️ using Flutter & GetX based on Figma design

---

**Note**: This is a UI implementation. Backend services need to be integrated.
