# SwiftCart - Mobile E-Commerce Application

A production-ready mobile e-commerce application built with **Flutter** for Android and iOS platforms, featuring **Firebase Authentication** and **MySQL** database via **PHP REST API**.

## Features

### Authentication & User Management
- ✅ User registration and login via Firebase Authentication
- ✅ Forgot Password functionality with email recovery
- ✅ Role-based access control (Admin, Seller, Buyer)
- ✅ Secure session management

### Seller Features
- ✅ Product Management Dashboard (Add, Edit, Delete)
- ✅ Product Information: Name, Description, Price, Stock, Images
- ✅ Order Management with status updates (Pending → Shipped → Completed)
- ✅ Sales statistics and revenue tracking

### Buyer Features
- ✅ Product browsing with search and filter
- ✅ Shopping cart with quantity management
- ✅ Checkout process with order confirmation
- ✅ Order history tracking

### Admin Features
- ✅ User management (view, edit roles, delete)
- ✅ View all products and orders
- ✅ Platform statistics dashboard

## Technology Stack

- **Frontend:** Flutter (Android & iOS)
- **Authentication:** Firebase Authentication
- **Backend:** PHP REST API
- **Database:** MySQL via phpMyAdmin (XAMPP)
- **State Management:** Provider
- **Image Storage:** Base64 in MySQL

## Project Structure

```
act5/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── config/
│   │   ├── constants.dart        # App constants & API config
│   │   ├── theme.dart            # UI theme configuration
│   │   └── routes.dart           # Navigation routes
│   ├── models/
│   │   ├── user_model.dart       # User data model
│   │   ├── product_model.dart    # Product data model
│   │   ├── cart_model.dart       # Cart data model
│   │   ├── order_model.dart      # Order data model
│   │   └── category_model.dart   # Category data model
│   ├── services/
│   │   ├── api_service.dart      # HTTP API client
│   │   ├── auth_service.dart     # Firebase auth service
│   │   ├── product_service.dart  # Product CRUD service
│   │   ├── order_service.dart    # Order service
│   │   └── user_service.dart     # User management service
│   ├── controllers/
│   │   ├── auth_controller.dart    # Auth state management
│   │   ├── cart_controller.dart    # Cart state management
│   │   ├── product_controller.dart # Product state management
│   │   └── order_controller.dart   # Order state management
│   ├── screens/
│   │   ├── auth/                 # Login, Register, Forgot Password
│   │   ├── buyer/                # Buyer screens
│   │   ├── seller/               # Seller screens
│   │   ├── admin/                # Admin screens
│   │   └── common/               # Shared screens
│   ├── widgets/                  # Reusable UI components
│   └── utils/                    # Helper functions
├── backend/
│   ├── config/
│   │   ├── database.php          # Database connection
│   │   └── cors.php              # CORS configuration
│   ├── helpers/
│   │   └── response.php          # Response helpers
│   ├── users/                    # User API endpoints
│   ├── products/                 # Product API endpoints
│   ├── categories/               # Category API endpoints
│   └── orders/                   # Order API endpoints
└── database/
    └── ecommerce_db.sql          # MySQL schema
```

## Setup Instructions

### Prerequisites
- Flutter SDK (3.0+)
- Android Studio or VS Code with Flutter extension
- XAMPP (Apache & MySQL)
- Firebase project with Authentication enabled

### 1. Firebase Setup

#### Quick Setup (Recommended)
1. **Create .env file:**
   ```bash
   # Windows
   copy .env.template .env
   
   # Mac/Linux
   cp .env.template .env
   ```

2. **Get Firebase Web Config:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Project Settings > General > Your apps > Web app
   - Copy config values to `.env` file

3. **For Android/iOS (if needed):**
   - Download `google-services.json` → `android/app/google-services.json`
   - Download `GoogleService-Info.plist` → `ios/Runner/GoogleService-Info.plist`
   - Extract values from these files to `.env`

4. **Enable Authentication:**
   - Firebase Console > Authentication > Sign-in method
   - Enable Email/Password

**📚 For detailed instructions, see [Firebase Setup Guide](docs/FIREBASE_SETUP.md)**

### 2. Database Setup

1. Start XAMPP and ensure Apache & MySQL are running
2. Open phpMyAdmin (http://localhost/phpmyadmin)
3. Import the database schema:
   - Click "Import"
   - Select `database/ecommerce_db.sql`
   - Click "Go"

### 3. Backend Setup

1. Copy the `backend` folder to XAMPP's htdocs:
   ```
   C:\xampp\htdocs\ecommerce_api
   ```

2. Update database credentials in `backend/config/database.php`:
   ```php
   private $host = "localhost";
   private $db_name = "ecommerce_db";
   private $username = "root";
   private $password = "";
   ```

3. Test API by visiting: `http://localhost/ecommerce_api/categories/get_categories.php`

### 4. Flutter App Setup

1. Update API base URL in `lib/config/constants.dart`:
   ```dart
   // For Android Emulator:
   static const String baseUrl = 'http://10.0.2.2/ecommerce_api';
   
   // For iOS Simulator:
   static const String baseUrl = 'http://localhost/ecommerce_api';
   
   // For Physical Device (use your computer's IP):
   static const String baseUrl = 'http://192.168.1.x/ecommerce_api';
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
   
   This installs `flutter_dotenv` for secure environment variable management.

3. **Run the app:**
   ```bash
   # Web (lightweight, no Android Studio needed)
   flutter run -d chrome
   
   # Or build for web
   flutter build web
   
   # Android
   flutter run -d android
   
   # iOS
   flutter run -d ios
   ```

## API Endpoints

### Users
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/users/register.php` | Register new user |
| GET | `/users/get_user.php?firebase_uid=xxx` | Get user by Firebase UID |
| PUT | `/users/update_user.php` | Update user profile |
| GET | `/users/get_all_users.php` | Get all users (Admin) |
| PUT | `/users/update_user_role.php` | Update user role (Admin) |
| DELETE | `/users/delete_user.php?id=xxx` | Delete user (Admin) |
| GET | `/users/get_admin_stats.php` | Get admin statistics |

### Products
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/products/get_products.php` | Get all products |
| GET | `/products/get_product.php?id=xxx` | Get single product |
| POST | `/products/add_product.php` | Add new product |
| PUT | `/products/update_product.php` | Update product |
| DELETE | `/products/delete_product.php?id=xxx` | Delete product |
| GET | `/products/get_seller_stats.php?seller_id=xxx` | Get seller statistics |

### Categories
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/categories/get_categories.php` | Get all categories |

### Orders
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/orders/create_order.php` | Create new order |
| GET | `/orders/get_buyer_orders.php?buyer_id=xxx` | Get buyer orders |
| GET | `/orders/get_seller_orders.php?seller_id=xxx` | Get seller orders |
| GET | `/orders/get_all_orders.php` | Get all orders (Admin) |
| GET | `/orders/get_order.php?id=xxx` | Get single order |
| PUT | `/orders/update_order_status.php` | Update order status |

## Database Schema

### Tables
- **users** - User accounts (admin, seller, buyer)
- **categories** - Product categories
- **products** - Product listings
- **orders** - Customer orders
- **order_items** - Items within orders

See `database/ecommerce_db.sql` for complete schema with relationships, indexes, and triggers.

## Testing

### Test Accounts
After setting up, register accounts with different roles:
1. **Admin** - Full platform access
2. **Seller** - Product and order management
3. **Buyer** - Shopping and ordering

### Testing Workflow
1. Register as Seller → Add products
2. Register as Buyer → Browse, add to cart, checkout
3. As Seller → View and process orders
4. Register as Admin → Manage users and view statistics

## Build for Production

### Android APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### iOS IPA
```bash
flutter build ios --release
```
Then archive in Xcode for distribution.

## Security Considerations

- Firebase Authentication handles user credentials securely
- PHP API uses prepared statements (SQL injection prevention)
- Input validation on both client and server side
- HTTPS recommended for production deployment

## License

This project is for educational purposes.

---

**Developed for Mobile E-Commerce Application Project**
