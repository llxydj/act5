import 'package:flutter/foundation.dart' show kIsWeb;

/// Application Constants
class AppConstants {
  // App Info
  static const String appName = 'SwiftCart';
  static const String appVersion = '1.0.0';

  // API Configuration - Automatically detects platform
  // For Web/Chrome: uses localhost
  // For Android Emulator: uses 10.0.2.2
  // For iOS Simulator: uses localhost
  // For Physical Device: Update manually to your computer's IP address
  static String get baseUrl {
    if (kIsWeb) {
      // Web/Chrome - use localhost
      return 'http://localhost/ecommerce_api';
    } else {
      // Mobile platforms - use Android emulator address
      // For physical devices, change this to your computer's IP (e.g., 'http://192.168.1.XXX/ecommerce_api')
      return 'http://10.0.2.2/ecommerce_api';
    }
  }

  // API Endpoints
  static const String usersEndpoint = '/users';
  static const String productsEndpoint = '/products';
  static const String ordersEndpoint = '/orders';
  static const String cartEndpoint = '/cart';
  static const String categoriesEndpoint = '/categories';

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleSeller = 'seller';
  static const String roleBuyer = 'buyer';

  // Order Status
  static const String orderPending = 'pending';
  static const String orderShipped = 'shipped';
  static const String orderCompleted = 'completed';
  static const String orderCancelled = 'cancelled';

  // Shared Preferences Keys
  static const String prefUserId = 'user_id';
  static const String prefUserRole = 'user_role';
  static const String prefUserEmail = 'user_email';
  static const String prefIsLoggedIn = 'is_logged_in';

  // Pagination
  static const int itemsPerPage = 20;

  // Image
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
}

