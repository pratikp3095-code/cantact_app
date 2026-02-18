# 📱 Flutter Contacts App

A full-featured Google Contacts-inspired app built with Flutter, featuring SQLite offline storage, Material Design 3, and a clean intuitive UI.

---

## ✨ Features

| Feature | Description |
|---|---|
| **View Contacts** | Browse all contacts in an A–Z grouped list |
| **Add Contact** | Add with name, phone, email, company, address, notes, photo |
| **Edit Contact** | Full editing of all contact fields |
| **Delete Contact** | Delete with confirmation dialog |
| **Contact Profile** | Detailed view with profile photo and all info |
| **Call Contact** | Tap to call via native phone dialer |
| **Send SMS** | Tap to open SMS to contact |
| **Email Contact** | Tap to open email client |
| **Favorites** | Mark/unmark contacts as favorites |
| **Favorites Tab** | Dedicated tab with grid + list view |
| **Search** | Real-time search by name, phone, or email |
| **Photo Upload** | Take photo or pick from gallery |

---

## 🗂 Project Structure

```
lib/
├── main.dart                     # App entry point
├── models/
│   └── contact.dart              # Contact data model
├── providers/
│   └── contacts_provider.dart    # State management (ChangeNotifier)
├── services/
│   └── database_service.dart     # SQLite CRUD operations
├── screens/
│   ├── home_screen.dart          # Bottom nav scaffold
│   ├── contacts_screen.dart      # Contacts list + search
│   ├── favorites_screen.dart     # Favorites tab
│   ├── contact_detail_screen.dart # Profile view
│   └── contact_form_screen.dart  # Add/Edit form
├── widgets/
│   ├── contact_avatar.dart       # Avatar with initials fallback
│   └── contact_list_tile.dart    # Animated list item
└── utils/
    └── app_theme.dart            # Material 3 theme config
```

---

## 🏗 Architecture

- **State Management**: `provider` package with `ChangeNotifier`
- **Database**: SQLite via `sqflite` — fully offline, no internet required
- **Animations**: `flutter_animate` for smooth list/transition effects
- **Navigation**: Named routes + `MaterialPageRoute`

---

## 📦 Dependencies

```yaml
sqflite: ^2.3.0           # Local SQLite database
path: ^1.8.3              # Path utilities for SQLite
url_launcher: ^6.2.2      # tel:, mailto:, sms: scheme launching
shared_preferences: ^2.2.2
uuid: ^4.2.1              # Unique contact IDs
flutter_slidable: ^3.0.1  # Swipe-to-delete
flutter_animate: ^4.3.0   # Entry animations
google_fonts: ^6.1.0      # Roboto font
image_picker: ^1.0.5      # Camera + gallery
permission_handler: ^11.1.0
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / Xcode

### Installation

```bash
# Clone / navigate to the project
cd contacts_app

# Install dependencies
flutter pub get

# Run on connected device
flutter run

# Build for release
flutter build apk --release        # Android
flutter build ipa --release        # iOS
```

### Android Permissions
The following permissions are declared in `AndroidManifest.xml`:
- `CALL_PHONE` — initiate calls
- `CAMERA` — take contact photos
- `READ_MEDIA_IMAGES` / `READ_EXTERNAL_STORAGE` — pick from gallery

### iOS Permissions
Configured in `Info.plist`:
- `NSCameraUsageDescription`
- `NSPhotoLibraryUsageDescription`
- `NSContactsUsageDescription`

---

## 🎨 UI Highlights

- **Material Design 3** with a Google-blue color scheme
- **Alphabetical grouping** with section headers in the contacts list
- **Animated entry** effects on list items using `flutter_animate`
- **Collapsible search bar** integrated into the app bar
- **Expandable profile header** using `SliverAppBar` with parallax
- **Favorites carousel** — horizontal quick-access chips at top of Favorites tab
- **Avatar colors** — deterministic color-coded initials when no photo is set

---

## 🔧 Extending the App

### Add Firebase sync
1. Add `firebase_core` and `cloud_firestore` to `pubspec.yaml`
2. Create a `FirebaseService` that mirrors `DatabaseService`
3. Call both services on write operations for offline+online sync

### Add dark mode
The `AppTheme` class can be extended with a `darkTheme` following the same pattern using `Brightness.dark`.

---

## 📸 Screen Overview

| Screen | Description |
|---|---|
| **Contacts** | Grouped A–Z list, search, FAB to add |
| **Favorites** | Horizontal chip carousel + full list |
| **Contact Detail** | Collapsing header, action buttons, info cards |
| **Add/Edit Form** | Photo picker, validated fields, sectioned layout |
