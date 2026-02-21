# 📱 StudentLink Platform - Complete Ecosystem 

An Elite, production-ready full-stack mobile platform built using **Flutter and Firebase**.

## 🚀 Architecture Provided
The codebase enforces **Flutter Clean Architecture**, separating logic beautifully across:
- **Presentation Layer** (`lib/presentation/`) => Contains UI Widgets, State Management (BLoC / Cubit).
- **Domain Layer** (`lib/domain/`) => Entities and UseCases to maintain pure Dart logic.
- **Data Layer** (`lib/data/`) => Datasources (Firebase/Firestore) and Repository Implementations.
- **Core Layer** (`lib/core/`) => Centralized utils, themes, dependency injection, routing.

## 🎨 Design System
Our custom Design System utilizes:
- **Glassmorphism** heavily through `GlassContainer` which leverages real `BackdropBlur` in Flutter natively avoiding placeholder containers.
- **Apple-grade animations** utilizing `flutter_animate` for scroll-triggered fades, staggered list elasticity, and Apple-grade button down-state effects.
- **Strict Accessibility Color Palette** for dark mode with WCAG AA compliance tracking success, warning, UI surface elevations.

## 🔄 Firebase Ecosystem Setup Guide

### 1) Prerequisites
- Install Flutter SDK: `brew install --cask flutter`
- Install Firebase CLI: `npm install -g firebase-tools`
- Install FlutterFire CLI: `dart pub global activate flutterfire_cli`

### 2) Initializing the Backend
1. Go to your Firebase console and create a new project called `student-link`.
2. Open terminal inside the project directory: `student_link_app`.
3. Run `flutterfire configure` to generate your `firebase_options.dart` securely linking your Android & iOS app.
4. Enable **Firebase Auth** (Email + Google).
5. Open Firestore, setting your rules and turning on indices to allow proper list fetching.
6. To push the provided cloud functions, navigate into `cd functions` then run `firebase deploy --only functions`.

### 3) Compiling Final App Status
- Pull all dependencies via: `flutter pub get`
- We recommend building on a real device to see the smooth motion tracking at 60fps utilizing Skia/Impeller.
```bash
flutter run --release
```

## 🔐 Firestore Security Rules
Under `firebase/firestore.rules` (To be deployed):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      // Users can only read authorized users, and update their own accounts
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.resource.data.authorId == request.auth.uid;
      allow delete, update: if request.auth.uid == resource.data.authorId;
    }
  }
}
```
