import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Default [FirebaseOptions] for the current platform.
/// 
/// Reads configuration from .env file for security.
/// Make sure to run: flutter pub get
/// And create .env file from .env.template
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// Web Firebase Configuration
  /// Get these values from Firebase Console > Project Settings > General > Your apps > Web app
  static FirebaseOptions get web {
    return FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_WEB_API_KEY'] ?? '',
      appId: dotenv.env['FIREBASE_WEB_APP_ID'] ?? '',
      messagingSenderId: dotenv.env['FIREBASE_WEB_MESSAGING_SENDER_ID'] ?? '',
      projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
      authDomain: dotenv.env['FIREBASE_WEB_AUTH_DOMAIN'] ?? '',
      storageBucket: dotenv.env['FIREBASE_WEB_STORAGE_BUCKET'] ?? '',
    );
  }

  /// Android Firebase Configuration
  /// Values are read from .env file for security
  static FirebaseOptions get android {
    return FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? '',
      appId: dotenv.env['FIREBASE_ANDROID_APP_ID'] ?? '',
      messagingSenderId: dotenv.env['FIREBASE_ANDROID_MESSAGING_SENDER_ID'] ?? '',
      projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
      storageBucket: dotenv.env['FIREBASE_ANDROID_STORAGE_BUCKET'] ?? '',
    );
  }

  /// iOS Firebase Configuration
  /// Values are read from .env file for security
  static FirebaseOptions get ios {
    return FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_IOS_API_KEY'] ?? '',
      appId: dotenv.env['FIREBASE_IOS_APP_ID'] ?? '',
      messagingSenderId: dotenv.env['FIREBASE_IOS_MESSAGING_SENDER_ID'] ?? '',
      projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
      storageBucket: dotenv.env['FIREBASE_IOS_STORAGE_BUCKET'] ?? '',
      iosClientId: dotenv.env['FIREBASE_IOS_CLIENT_ID'] ?? '',
      iosBundleId: dotenv.env['FIREBASE_IOS_BUNDLE_ID'] ?? '',
    );
  }
}
