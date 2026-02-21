# Student Link App - Complete Setup & Deployment Guide

## 🎯 Overview

Student Link is a production-ready, real-time campus networking mobile application built with Flutter and Firebase. It features a modern dark theme with glassmorphism design, smooth animations, and comprehensive social networking capabilities.

## ✨ Features

### Core Features
- **Authentication System**: Email/password authentication with .edu email verification
- **Campus Pulse (Feed)**: Social feed with posts, images, likes, comments, and shares  
- **Connect (Networking)**: Discover students, send connection requests, build your network
- **AnonySpace**: Anonymous posting system with upvote/downvote functionality
- **Campus Clubs**: Create and join clubs with approval workflow
- **Real-time Messaging**: One-on-one chat with typing indicators and read receipts
- **Study Room**: Pomodoro timer with animated circular progress and focus mode
- **Profile Management**: Customizable profiles with photo uploads and galleries
- **Admin Dashboard**: Moderation tools, user management, and analytics

### Technical Features
- Clean Architecture (Presentation, Domain, Data layers)
- State Management with BLoC pattern
- Firebase real-time synchronization
- Offline-first with Firestore persistence
- Push notifications via FCM
- Image caching and optimization
- Secure role-based access control
- Comprehensive security rules

## 📋 Prerequisites

Before you begin, ensure you have installed:

- **Flutter SDK** (>= 3.0.0): https://flutter.dev/docs/get-started/install
- **Dart SDK** (>= 3.0.0): Comes with Flutter
- **Android Studio / VS Code**: With Flutter/Dart plugins
- **Xcode** (for iOS): Mac only, from App Store  
- **CocoaPods** (for iOS): `sudo gem install cocoapods`
- **Firebase CLI**: `npm install -g firebase-tools`
- **Node.js** (>= 18.x): For Cloud Functions
- **Git**: Version control

## 🚀 Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/RamSuryaCH/student-link-app.git
cd student-link-app
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

#### 3.1 Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `student-link-app`
4. Enable Google Analytics (optional)
5. Create project

#### 3.2 Enable Firebase Services

In your Firebase project:

1. **Authentication**:
   - Go to Authentication → Sign-in method
   - Enable "Email/Password"
   
2. **Firestore Database**:
   - Go to Firestore Database
   - Click "Create database"
   - Start in **production mode**
   - Choose location closest to your users
   
3. **Storage**:
   - Go to Storage
   - Click "Get started"
   - Use default security rules for now
   
4. **Cloud Messaging**:
   - Go to Project Settings → Cloud Messaging
   - Note your Server Key (for later)

#### 3.3 Register Apps

**For Android:**
1. Click "Add app" → Android icon
2. Package name: `com.example.student_link_app` (or your package)
3. Download `google-services.json`
4. Place it in `android/app/`

**For iOS:**
1. Click "Add app" → iOS icon
2. Bundle ID: `com.example.studentLinkApp` (or your bundle)
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/`

#### 3.4 Configure Flutter Firebase

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your Flutter app
flutterfire configure
```

Select your Firebase project and platforms (Android, iOS).

### 4. Deploy Firestore Security Rules

```bash
cd firebase
firebase login
firebase use --add  # Select your project
firebase deploy --only firestore:rules
```

### 5. Deploy Cloud Functions

```bash
cd firebase/functions
npm install
firebase deploy --only functions
```

### 6. Update App Configuration

#### Android Configuration

Edit `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        applicationId "com.example.student_link_app"
        minSdkVersion 21  // Required for Firebase
        targetSdkVersion 33
    }
}
```

#### iOS Configuration

Edit `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR-IOS-URL-SCHEME</string>
        </array>
    </dict>
</array>
```

### 7. Environment Setup (Optional)

Create `.env` file in root for API keys:

```env
GEMINI_API_KEY=your_gemini_api_key_here
```

## 🏃 Running the Application

### Run on Device/Emulator

```bash
# Check connected devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run in release mode
flutter run --release
```

### Debug Mode

```bash
flutter run --debug
```

### Hot Reload

Press `r` in terminal while app is running to hot reload.
Press `R` to hot restart.
Press `q` to quit.

## 🧪 Testing

Run tests:

```bash
flutter test
```

## 📦 Building for Production

### Android APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS

```bash
flutter build ios --release
```

Then open `ios/Runner.xcworkspace` in Xcode to archive and upload.

## 🔒 Security Configuration

### Firestore Indexes

Create composite indexes for efficient queries:

1. Go to Firestore → Indexes
2. Add these composite indexes:

```
Collection: posts
Fields: isReported (Ascending), createdAt (Descending)

Collection: anonymous_posts  
Fields: isReported (Ascending), createdAt (Descending)

Collection: clubs
Fields: isApproved (Ascending), createdAt (Descending)
```

### Storage Rules

Update Firebase Storage rules:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /posts/{postId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    match /clubs/{clubId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## 📱 App Features & Usage

### For Students

1. **Sign Up**: Use .edu email to create account
2. **Complete Profile**: Add photo, bio, department, interests
3. **Connect**: Search and connect with fellow students
4. **Post**: Share updates in Campus Pulse
5. **Join Clubs**: Explore and join campus clubs
6. **Anonymous Posts**: Share thoughts in AnonySpace
7. **Study**: Use Pomodoro timer in Study Room
8. **Chat**: Message your connections

### For Admins

1. **Access admin role** in Firestore manually:
   ```
   users/{userId}
   {
     "role": "Admin"
   }
   ```
2. **Moderate content**: Review reported posts
3. **Manage users**: Ban/unban users
4. **Approve clubs**: Review club creation requests
5. **View analytics**: Monitor platform usage

## 🎨 Customization

### Color Scheme

Edit `lib/core/constants/colors.dart`:

```dart
static const Color primary = Color(0xFF7B61FF);
static const Color accent = Color(0xFFFF4D9D);
static const Color background = Color(0xFF0D0F23);
```

### App Name & Icon

1. Update `pubspec.yaml`: `name: your_app_name`
2. Use [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons) package
3. Place your icon in `assets/icon.png`
4. Run: `flutter pub run flutter_launcher_icons`

## 📊 Monitoring & Analytics

### Firebase Analytics

Events are automatically tracked. View in Firebase Console → Analytics.

### Crashlytics (Optional)

1. Add dependency: `firebase_crashlytics`
2. Initialize in `main.dart`
3. Deploy and monitor crashes

## 🐛 Troubleshooting

### Common Issues

**Build fails with Firebase error:**
- Run `flutterfire configure` again
- Ensure google-services.json is in correct location
- Clean build: `flutter clean && flutter pub get`

**iOS build fails:**
- Run `cd ios && pod install`
- Update CocoaPods: `sudo gem install cocoapods`
- Clean Xcode build folder

**Permission errors:**
```bash
chmod +x ios/Runner.app
chmod +x android/gradlew
```

**Cloud Functions not working:**
- Check Firebase billing (Blaze plan required for functions)
- View logs: `firebase functions:log`

## 📚 Architecture Overview

```
lib/
├── core/              # App-wide utilities, theme, constants
│   ├── constants/
│   ├── theme.dart
│   └── di/           # Dependency injection
├── data/             # Data layer
│   └── datasources/  # Firebase services
├── domain/           # Business logic
│   └── entities/     # Data models
└── presentation/     # UI layer
    ├── auth/
    ├── pulse/
    ├── connect/
    ├── anonyspace/
    ├── clubs/
    ├── messaging/
    ├── profile/
    └── common/widgets/
```

## 🚢 Deployment Checklist

- [ ] Update app version in `pubspec.yaml`
- [ ] Test on physical devices (Android & iOS)
- [ ] Review and deploy security rules
- [ ] Deploy Cloud Functions
- [ ] Enable offline persistence
- [ ] Configure proper signing keys
- [ ] Test push notifications
- [ ] Add privacy policy URL
- [ ] Prepare app store listings
- [ ] Take screenshots for stores

## 📞 Support

For issues and questions:
- Create an issue on GitHub
- Email: support@studentlink.app (if applicable)

## 📄 License

This project is licensed under the MIT License.

## 👥 Contributors

- Ram Surya CH - Initial work

## 🙏 Acknowledgments

- Firebase for backend infrastructure
- Flutter team for the amazing framework
- Community packages and contributors

---

**Built with ❤️ using Flutter & Firebase**
