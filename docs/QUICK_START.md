# SwiftCart Quick Start Guide

## 🚀 Fast Setup (5 Minutes)

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Create .env File
```bash
# Windows
copy .env.template .env

# Mac/Linux
cp .env.template .env
```

### 3. Get Firebase Web Config

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click **⚙️ Settings** > **Project settings**
4. Scroll to **"Your apps"** section
5. Click on **Web app** (</> icon) or **"Add app"** > **Web**
6. Copy the config values:

```javascript
const firebaseConfig = {
  apiKey: "AIza...",           // → FIREBASE_WEB_API_KEY
  authDomain: "...",           // → FIREBASE_WEB_AUTH_DOMAIN
  projectId: "...",            // → FIREBASE_PROJECT_ID
  storageBucket: "...",        // → FIREBASE_WEB_STORAGE_BUCKET
  messagingSenderId: "...",     // → FIREBASE_WEB_MESSAGING_SENDER_ID
  appId: "1:..."               // → FIREBASE_WEB_APP_ID
};
```

### 4. Fill .env File

Open `.env` and replace all `your-*-here` values with actual Firebase values.

**Required for Web:**
- `FIREBASE_PROJECT_ID`
- `FIREBASE_WEB_API_KEY`
- `FIREBASE_WEB_APP_ID`
- `FIREBASE_WEB_MESSAGING_SENDER_ID`
- `FIREBASE_WEB_STORAGE_BUCKET`
- `FIREBASE_WEB_AUTH_DOMAIN`

**For Android/iOS (if you have them):**
- Copy values from `android/app/google-services.json`
- Copy values from `ios/Runner/GoogleService-Info.plist`

### 5. Enable Authentication

1. Firebase Console > **Authentication** > **Sign-in method**
2. Enable **Email/Password**
3. Click **Save**

### 6. Run the App

```bash
# Web
flutter run -d chrome

# Or build for web
flutter build web
```

## ✅ Verification

If you see the login screen without errors, you're all set! 🎉

## 🔧 Troubleshooting

**Error: ".env file not found"**
- Make sure `.env` exists in project root
- Check file is named exactly `.env` (not `.env.txt`)

**Error: "Firebase not initialized"**
- Verify all `FIREBASE_WEB_*` values in `.env` are filled
- Check values match Firebase Console exactly
- Run `flutter clean` then `flutter pub get`

**Error: "Authentication failed"**
- Make sure Email/Password is enabled in Firebase Console
- Check internet connection

## 📚 Full Documentation

For complete setup instructions, see:
- [Firebase Setup Guide](./FIREBASE_SETUP.md) - Detailed step-by-step
- [Setup Guide](./SETUP_GUIDE.md) - Complete project setup
- [API Documentation](./API_DOCUMENTATION.md) - Backend API reference

