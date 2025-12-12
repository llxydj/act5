# Firebase Setup Guide for SwiftCart

Complete step-by-step guide to configure Firebase for **Web**, **Android**, and **iOS** platforms securely using environment variables.

## 📋 Prerequisites

- Firebase account (free tier is sufficient)
- Flutter SDK 3.0+
- Node.js and npm installed
- FlutterFire CLI installed globally

## 🔧 Step 1: Install Required Tools

### Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### Verify Installation
```bash
flutterfire --version
```

### Add to PATH (Windows)
Add `%USERPROFILE%\AppData\Local\Pub\Cache\bin` to your Windows PATH environment variable.

## 🚀 Step 2: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or **"Create a project"**
3. Enter project name: **SwiftCart** (or your preferred name)
4. Enable/disable Google Analytics (optional)
5. Click **"Create project"**

## 📱 Step 3: Add Android App

1. In Firebase Console, click **"Add app"** > **Android**
2. **Android package name**: `com.example.act5` (or your package name)
3. **App nickname** (optional): SwiftCart Android
4. **Debug signing certificate SHA-1** (optional for now)
5. Click **"Register app"**
6. **Download `google-services.json`**
7. Place it in: `android/app/google-services.json`

### Get Android Firebase Config Values

Open `android/app/google-services.json` and find:
- `api_key.current_key` → `FIREBASE_ANDROID_API_KEY`
- `mobilesdk_app_id` → `FIREBASE_ANDROID_APP_ID`
- `project_info.project_id` → `FIREBASE_PROJECT_ID`
- `project_info.storage_bucket` → `FIREBASE_ANDROID_STORAGE_BUCKET`
- `project_info.firebase_url` → Contains messaging sender ID

## 🍎 Step 4: Add iOS App

1. In Firebase Console, click **"Add app"** > **iOS**
2. **iOS bundle ID**: `com.example.act5` (must match your iOS app)
3. **App nickname** (optional): SwiftCart iOS
4. **App Store ID** (optional)
5. Click **"Register app"**
6. **Download `GoogleService-Info.plist`**
7. Place it in: `ios/Runner/GoogleService-Info.plist`

### Get iOS Firebase Config Values

Open `ios/Runner/GoogleService-Info.plist` and find:
- `API_KEY` → `FIREBASE_IOS_API_KEY`
- `GCM_SENDER_ID` → `FIREBASE_IOS_MESSAGING_SENDER_ID`
- `PROJECT_ID` → `FIREBASE_PROJECT_ID`
- `STORAGE_BUCKET` → `FIREBASE_IOS_STORAGE_BUCKET`
- `CLIENT_ID` → `FIREBASE_IOS_CLIENT_ID`
- `BUNDLE_ID` → `FIREBASE_IOS_BUNDLE_ID`
- `GOOGLE_APP_ID` → `FIREBASE_IOS_APP_ID`

## 🌐 Step 5: Add Web App

1. In Firebase Console, click **"Add app"** > **Web** (</> icon)
2. **App nickname** (optional): SwiftCart Web
3. **Firebase Hosting** (optional, skip for now)
4. Click **"Register app"**
5. You'll see Firebase SDK configuration code

### Get Web Firebase Config Values

From the Firebase Console Web app configuration, copy:
- `apiKey` → `FIREBASE_WEB_API_KEY`
- `appId` → `FIREBASE_WEB_APP_ID`
- `messagingSenderId` → `FIREBASE_WEB_MESSAGING_SENDER_ID`
- `projectId` → `FIREBASE_PROJECT_ID`
- `authDomain` → `FIREBASE_WEB_AUTH_DOMAIN` (usually: `your-project-id.firebaseapp.com`)
- `storageBucket` → `FIREBASE_WEB_STORAGE_BUCKET` (usually: `your-project-id.appspot.com`)

## 🔐 Step 6: Enable Authentication

1. In Firebase Console, go to **Authentication** > **Sign-in method**
2. Click **"Email/Password"**
3. Enable **"Email/Password"** toggle
4. Click **"Save"**

## 📝 Step 7: Configure Environment Variables

### 7.1 Create .env File

1. Copy the template file:
   ```bash
   # Windows
   copy .env.template .env
   
   # Mac/Linux
   cp .env.template .env
   ```

2. Open `.env` file in a text editor

3. Fill in all the values you collected from previous steps:

```env
# Firebase Project ID (same for all platforms)
FIREBASE_PROJECT_ID=your-actual-project-id

# Firebase Web Configuration
FIREBASE_WEB_API_KEY=AIzaSyC...your-web-api-key
FIREBASE_WEB_APP_ID=1:123456789:web:abcdef
FIREBASE_WEB_MESSAGING_SENDER_ID=123456789
FIREBASE_WEB_STORAGE_BUCKET=your-project-id.appspot.com
FIREBASE_WEB_AUTH_DOMAIN=your-project-id.firebaseapp.com

# Firebase Android Configuration
FIREBASE_ANDROID_API_KEY=AIzaSyD...your-android-api-key
FIREBASE_ANDROID_APP_ID=1:123456789:android:abcdef
FIREBASE_ANDROID_MESSAGING_SENDER_ID=123456789
FIREBASE_ANDROID_STORAGE_BUCKET=your-project-id.appspot.com

# Firebase iOS Configuration
FIREBASE_IOS_API_KEY=AIzaSyE...your-ios-api-key
FIREBASE_IOS_APP_ID=1:123456789:ios:abcdef
FIREBASE_IOS_MESSAGING_SENDER_ID=123456789
FIREBASE_IOS_STORAGE_BUCKET=your-project-id.appspot.com
FIREBASE_IOS_CLIENT_ID=123456789-abcdef.apps.googleusercontent.com
FIREBASE_IOS_BUNDLE_ID=com.example.act5
```

### 7.2 Verify .env is in .gitignore

Check that `.env` is listed in `.gitignore` (it should already be there).

## 📦 Step 8: Install Dependencies

```bash
flutter pub get
```

This will install `flutter_dotenv` package.

## ✅ Step 9: Verify Configuration

### Test Android
```bash
flutter run -d android
```

### Test iOS
```bash
flutter run -d ios
```

### Test Web
```bash
flutter run -d chrome
```

Or build for web:
```bash
flutter build web
```

## 🔍 Troubleshooting

### Error: "DefaultFirebaseOptions have not been configured for web"

**Solution:**
1. Make sure `.env` file exists in project root
2. Verify all `FIREBASE_WEB_*` values are filled in `.env`
3. Run `flutter pub get` again
4. Restart your development server

### Error: "Failed to load .env file"

**Solution:**
1. Check that `.env` file is in the project root (same level as `pubspec.yaml`)
2. Verify file is named exactly `.env` (not `.env.txt` or `.env.example`)
3. Check file encoding is UTF-8
4. Make sure `flutter_dotenv: ^5.1.0` is in `pubspec.yaml`
5. Verify `.env` is listed in `pubspec.yaml` assets section

### Error: "Firebase app not initialized"

**Solution:**
1. Verify Firebase is initialized in `main.dart` before `runApp()`
2. Check that `.env` values are correct
3. Ensure Firebase project has Authentication enabled
4. Verify internet connection

### Web Build Fails

**Solution:**
1. Make sure all web config values are in `.env`
2. Check browser console for specific errors
3. Verify Firebase project has Web app registered
4. Try clearing Flutter build cache:
   ```bash
   flutter clean
   flutter pub get
   flutter build web
   ```

## 🔒 Security Best Practices

✅ **DO:**
- Keep `.env` file local only
- Never commit `.env` to Git
- Use `.env.template` as a reference
- Rotate API keys if exposed
- Use different Firebase projects for dev/prod

❌ **DON'T:**
- Commit `.env` file to version control
- Share `.env` file publicly
- Hardcode Firebase keys in source code
- Use production keys in development

## 📚 Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Flutter Web Setup](https://docs.flutter.dev/platform-integration/web)

## ✅ Verification Checklist

- [ ] Firebase project created
- [ ] Android app added and `google-services.json` downloaded
- [ ] iOS app added and `GoogleService-Info.plist` downloaded
- [ ] Web app added and config values copied
- [ ] Email/Password authentication enabled
- [ ] `.env` file created from `.env.template`
- [ ] All Firebase config values filled in `.env`
- [ ] `flutter pub get` executed successfully
- [ ] Android app runs without errors
- [ ] iOS app runs without errors
- [ ] Web app runs without errors
- [ ] `.env` is in `.gitignore`
- [ ] `google-services.json` is in `.gitignore`
- [ ] `GoogleService-Info.plist` is in `.gitignore`

---

**🎉 Once all steps are completed, your SwiftCart app will be fully configured for Firebase on all platforms!**

