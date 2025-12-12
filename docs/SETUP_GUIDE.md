# SwiftCart Setup Guide

This guide provides step-by-step instructions to set up and run the SwiftCart e-commerce application.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.0 or higher)
- **Android Studio** or **VS Code** with Flutter extension
- **XAMPP** (for Apache and MySQL)
- **Git** (optional, for version control)
- **Firebase Account** (free tier is sufficient)

## Step 1: Firebase Configuration

### 1.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" and follow the setup wizard
3. Name your project (e.g., "SwiftCart")

### 1.2 Enable Email/Password Authentication
1. In Firebase Console, go to **Authentication** > **Sign-in method**
2. Enable **Email/Password**
3. Save changes

### 1.3 Add Android App
1. Click **Add app** > **Android**
2. Android package name: `com.example.act5` (or your chosen package name)
3. Download `google-services.json`
4. Place it in `android/app/` directory

### 1.4 Add iOS App
1. Click **Add app** > **iOS**
2. iOS bundle ID: `com.example.act5`
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/` directory

### 1.5 Generate Firebase Options
Run the FlutterFire CLI:
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

This will update `lib/firebase_options.dart` with your project settings.

## Step 2: Database Setup (XAMPP)

### 2.1 Start XAMPP
1. Open XAMPP Control Panel
2. Start **Apache** and **MySQL**

### 2.2 Create Database
1. Open browser and go to: `http://localhost/phpmyadmin`
2. Click **New** to create a database
3. Database name: `ecommerce_db`
4. Collation: `utf8mb4_unicode_ci`
5. Click **Create**

### 2.3 Import Schema
1. Select `ecommerce_db` database
2. Click **Import** tab
3. Choose file: `database/ecommerce_db.sql`
4. Click **Go**

This creates all tables, views, stored procedures, and default categories.

## Step 3: Backend API Setup

### 3.1 Copy Backend Files
Copy the `backend` folder to XAMPP's htdocs:
```
C:\xampp\htdocs\ecommerce_api
```

Your structure should be:
```
C:\xampp\htdocs\ecommerce_api\
├── config\
│   ├── database.php
│   └── cors.php
├── helpers\
│   └── response.php
├── users\
├── products\
├── categories\
└── orders\
```

### 3.2 Configure Database Connection
Edit `C:\xampp\htdocs\ecommerce_api\config\database.php`:
```php
private $host = "localhost";
private $db_name = "ecommerce_db";
private $username = "root";
private $password = ""; // Add your MySQL password if set
```

### 3.3 Test API
Open in browser: `http://localhost/ecommerce_api/categories/get_categories.php`

Expected response:
```json
{
  "success": true,
  "message": "Categories retrieved successfully",
  "data": [...]
}
```

## Step 4: Flutter App Configuration

### 4.1 Update API Base URL
Edit `lib/config/constants.dart`:

**For Android Emulator:**
```dart
static const String baseUrl = 'http://10.0.2.2/ecommerce_api';
```

**For iOS Simulator:**
```dart
static const String baseUrl = 'http://localhost/ecommerce_api';
```

**For Physical Device:**
1. Find your computer's IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
2. Use that IP:
```dart
static const String baseUrl = 'http://192.168.1.XXX/ecommerce_api';
```

### 4.2 Install Dependencies
```bash
cd C:\Users\ACER\Desktop\act5
flutter pub get
```

### 4.3 Run the App
```bash
# Run on connected device/emulator
flutter run

# Or specify device
flutter run -d chrome    # Web
flutter run -d android   # Android
flutter run -d ios       # iOS
```

## Step 5: Testing the Application

### 5.1 Create Test Users
1. **Seller Account:**
   - Register with role: Seller
   - Add some products
   
2. **Buyer Account:**
   - Register with role: Buyer
   - Browse products, add to cart, checkout
   
3. **Admin Account:**
   - Register with role: Admin
   - Manage users, view all orders

### 5.2 Test Flow
1. As Seller: Add 3-5 products with images
2. As Buyer: Browse products, add to cart, place order
3. As Seller: View orders, mark as shipped, then completed
4. As Buyer: Check order status in history
5. As Admin: View all users, products, orders

## Troubleshooting

### API Connection Failed
- Check if XAMPP Apache is running
- Verify baseUrl matches your setup
- For physical device, ensure same WiFi network

### Firebase Authentication Error
- Verify `google-services.json` is in correct location
- Check Firebase Console for authentication settings
- Ensure `firebase_options.dart` is properly configured

### Database Errors
- Verify MySQL is running in XAMPP
- Check database credentials in `database.php`
- Ensure all tables were created (check phpMyAdmin)

### Flutter Build Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## Production Deployment

### Building for Release

**Android APK:**
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```
Then archive in Xcode.

### Production Considerations
1. Use HTTPS for API endpoint
2. Enable Firebase App Check
3. Set up proper database backups
4. Configure error logging
5. Test on various devices

## Support

For issues or questions, refer to:
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [PHP Documentation](https://www.php.net/docs.php)

---

**SwiftCart - Your One-Stop Shop**

