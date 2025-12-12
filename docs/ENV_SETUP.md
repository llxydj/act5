# Environment Variables Setup Guide

## 🔐 Secure Configuration with .env

SwiftCart uses environment variables to securely store Firebase credentials without committing them to Git.

## 📋 Step-by-Step Setup

### 1. Create .env File

```bash
# Windows PowerShell
Copy-Item .env.template .env

# Windows CMD
copy .env.template .env

# Mac/Linux
cp .env.template .env
```

### 2. Get Firebase Configuration Values

#### For Web Platform

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click **⚙️ Settings** > **Project settings**
4. Scroll to **"Your apps"** section
5. Find your **Web app** (</> icon)
6. You'll see a config object like this:

```javascript
const firebaseConfig = {
  apiKey: "AIzaSyC...",
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project-id.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abcdef"
};
```

#### Mapping to .env File

| Firebase Config | .env Variable |
|----------------|---------------|
| `apiKey` | `FIREBASE_WEB_API_KEY` |
| `authDomain` | `FIREBASE_WEB_AUTH_DOMAIN` |
| `projectId` | `FIREBASE_PROJECT_ID` |
| `storageBucket` | `FIREBASE_WEB_STORAGE_BUCKET` |
| `messagingSenderId` | `FIREBASE_WEB_MESSAGING_SENDER_ID` |
| `appId` | `FIREBASE_WEB_APP_ID` |

### 3. Get Android Configuration

If you have `android/app/google-services.json`:

```json
{
  "project_info": {
    "project_id": "...",           // → FIREBASE_PROJECT_ID
    "storage_bucket": "...",       // → FIREBASE_ANDROID_STORAGE_BUCKET
    "firebase_url": "https://..."  // Contains messaging sender ID
  },
  "client": [{
    "client_info": {
      "mobilesdk_app_id": "...",   // → FIREBASE_ANDROID_APP_ID
      "android_client_info": {
        "package_name": "..."
      }
    },
    "api_key": [{
      "current_key": "..."         // → FIREBASE_ANDROID_API_KEY
    }]
  }]
}
```

### 4. Get iOS Configuration

If you have `ios/Runner/GoogleService-Info.plist`:

```xml
<key>API_KEY</key>
<string>...</string>              // → FIREBASE_IOS_API_KEY

<key>GCM_SENDER_ID</key>
<string>...</string>              // → FIREBASE_IOS_MESSAGING_SENDER_ID

<key>PROJECT_ID</key>
<string>...</string>              // → FIREBASE_PROJECT_ID

<key>STORAGE_BUCKET</key>
<string>...</string>              // → FIREBASE_IOS_STORAGE_BUCKET

<key>CLIENT_ID</key>
<string>...</string>              // → FIREBASE_IOS_CLIENT_ID

<key>BUNDLE_ID</key>
<string>...</string>              // → FIREBASE_IOS_BUNDLE_ID

<key>GOOGLE_APP_ID</key>
<string>...</string>              // → FIREBASE_IOS_APP_ID
```

### 5. Fill .env File

Open `.env` and replace placeholders:

```env
# Example filled .env file
FIREBASE_PROJECT_ID=swiftcart-12345

# Web
FIREBASE_WEB_API_KEY=AIzaSyC1234567890abcdefghijklmnop
FIREBASE_WEB_APP_ID=1:123456789:web:abcdef123456
FIREBASE_WEB_MESSAGING_SENDER_ID=123456789
FIREBASE_WEB_STORAGE_BUCKET=swiftcart-12345.appspot.com
FIREBASE_WEB_AUTH_DOMAIN=swiftcart-12345.firebaseapp.com

# Android
FIREBASE_ANDROID_API_KEY=AIzaSyD9876543210zyxwvutsrqponmlk
FIREBASE_ANDROID_APP_ID=1:123456789:android:fedcba654321
FIREBASE_ANDROID_MESSAGING_SENDER_ID=123456789
FIREBASE_ANDROID_STORAGE_BUCKET=swiftcart-12345.appspot.com

# iOS
FIREBASE_IOS_API_KEY=AIzaSyE5555555555mnopqrstuvwxyz
FIREBASE_IOS_APP_ID=1:123456789:ios:1234567890abcdef
FIREBASE_IOS_MESSAGING_SENDER_ID=123456789
FIREBASE_IOS_STORAGE_BUCKET=swiftcart-12345.appspot.com
FIREBASE_IOS_CLIENT_ID=123456789-abcdef.apps.googleusercontent.com
FIREBASE_IOS_BUNDLE_ID=com.example.act5
```

## ✅ Verification

### Check .env is Loaded

Run the app and check console for:
- ✅ No "Warning: .env file not found" message
- ✅ Firebase initializes successfully
- ✅ Login screen appears without errors

### Test Each Platform

```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios
```

## 🔒 Security Checklist

- [ ] `.env` file exists in project root
- [ ] `.env` is listed in `.gitignore` ✅ (already done)
- [ ] `.env.template` is committed (safe, no secrets)
- [ ] `google-services.json` is in `.gitignore` ✅
- [ ] `GoogleService-Info.plist` is in `.gitignore` ✅
- [ ] Never commit `.env` to Git
- [ ] Never share `.env` file publicly

## 🚨 Common Issues

### Issue: ".env file not found"

**Solution:**
1. Verify `.env` is in project root (same level as `pubspec.yaml`)
2. Check file name is exactly `.env` (not `.env.txt`)
3. Ensure file encoding is UTF-8
4. Check `pubspec.yaml` has `.env` in assets section

### Issue: "Empty Firebase config values"

**Solution:**
1. Verify all `FIREBASE_*` variables are filled in `.env`
2. Check for typos in variable names
3. Ensure no extra spaces around `=` sign
4. Restart your IDE/terminal after creating `.env`

### Issue: "Firebase initialization failed"

**Solution:**
1. Verify Firebase project exists
2. Check all config values match Firebase Console
3. Ensure Email/Password auth is enabled
4. Check internet connection

## 📝 Notes

- **Minimum Required:** For web-only testing, you only need `FIREBASE_WEB_*` values
- **Android/iOS Optional:** Only fill if you're testing those platforms
- **Same Project ID:** `FIREBASE_PROJECT_ID` is the same for all platforms
- **No Quotes Needed:** Don't wrap values in quotes unless they contain special characters

## 🔄 Updating Values

If you need to update Firebase config:
1. Update values in `.env` file
2. Restart the app (hot reload won't reload .env)
3. Run `flutter clean` if issues persist

---

**✅ Your Firebase credentials are now securely configured!**

