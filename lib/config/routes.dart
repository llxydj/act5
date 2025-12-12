import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/common/splash_screen.dart';
import '../screens/buyer/buyer_home_screen.dart';
import '../screens/buyer/product_detail_screen.dart';
import '../screens/buyer/cart_screen.dart';
import '../screens/buyer/checkout_screen.dart';
import '../screens/buyer/order_history_screen.dart';
import '../screens/buyer/buyer_profile_screen.dart';
import '../screens/seller/seller_dashboard_screen.dart';
import '../screens/seller/add_product_screen.dart';
import '../screens/seller/edit_product_screen.dart';
import '../screens/seller/seller_orders_screen.dart';
import '../screens/seller/seller_products_screen.dart';
import '../screens/seller/seller_profile_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/manage_users_screen.dart';
import '../screens/admin/admin_products_screen.dart';
import '../screens/admin/admin_orders_screen.dart';

/// App Routes Configuration
class AppRoutes {
  // Route Names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Buyer Routes
  static const String buyerHome = '/buyer/home';
  static const String productDetail = '/buyer/product';
  static const String cart = '/buyer/cart';
  static const String checkout = '/buyer/checkout';
  static const String orderHistory = '/buyer/orders';
  static const String buyerProfile = '/buyer/profile';

  // Seller Routes
  static const String sellerDashboard = '/seller/dashboard';
  static const String sellerProducts = '/seller/products';
  static const String addProduct = '/seller/products/add';
  static const String editProduct = '/seller/products/edit';
  static const String sellerOrders = '/seller/orders';
  static const String sellerProfile = '/seller/profile';

  // Admin Routes
  static const String adminDashboard = '/admin/dashboard';
  static const String manageUsers = '/admin/users';
  static const String adminProducts = '/admin/products';
  static const String adminOrders = '/admin/orders';

  // Route Generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fadeRoute(const SplashScreen(), settings);

      case login:
        return _slideRoute(const LoginScreen(), settings);

      case register:
        return _slideRoute(const RegisterScreen(), settings);

      case forgotPassword:
        return _slideRoute(const ForgotPasswordScreen(), settings);

      // Buyer Routes
      case buyerHome:
        return _fadeRoute(const BuyerHomeScreen(), settings);

      case productDetail:
        final productId = settings.arguments as String;
        return _slideRoute(ProductDetailScreen(productId: productId), settings);

      case cart:
        return _slideRoute(const CartScreen(), settings);

      case checkout:
        return _slideRoute(const CheckoutScreen(), settings);

      case orderHistory:
        return _slideRoute(const OrderHistoryScreen(), settings);

      case buyerProfile:
        return _slideRoute(const BuyerProfileScreen(), settings);

      // Seller Routes
      case sellerDashboard:
        return _fadeRoute(const SellerDashboardScreen(), settings);

      case sellerProducts:
        return _slideRoute(const SellerProductsScreen(), settings);

      case addProduct:
        return _slideRoute(const AddProductScreen(), settings);

      case editProduct:
        final productId = settings.arguments as String;
        return _slideRoute(EditProductScreen(productId: productId), settings);

      case sellerOrders:
        return _slideRoute(const SellerOrdersScreen(), settings);

      case sellerProfile:
        return _slideRoute(const SellerProfileScreen(), settings);

      // Admin Routes
      case adminDashboard:
        return _fadeRoute(const AdminDashboardScreen(), settings);

      case manageUsers:
        return _slideRoute(const ManageUsersScreen(), settings);

      case adminProducts:
        return _slideRoute(const AdminProductsScreen(), settings);

      case adminOrders:
        return _slideRoute(const AdminOrdersScreen(), settings);

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  // Fade Transition Route
  static PageRoute _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // Slide Transition Route
  static PageRoute _slideRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

