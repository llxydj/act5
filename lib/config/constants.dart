/// Application Constants
class AppConstants {
  // App Info
  static const String appName = 'SwiftCart';
  static const String appVersion = '1.0.0';

  // API Configuration - Update this with your XAMPP server IP
  // For Android Emulator use: 10.0.2.2
  // For iOS Simulator use: localhost
  // For Physical Device use: Your computer's IP address
  static const String baseUrl = 'http://10.0.2.2/ecommerce_api';

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

