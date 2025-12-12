import '../config/constants.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';
import 'api_service.dart';

/// Order Service for order management
class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final ApiService _api = ApiService();

  /// Create new order
  /// Note: buyerId, buyerName, buyerEmail are now obtained from authenticated user on backend
  Future<OrderResult> createOrder({
    required CartModel cart,
    required String shippingAddress,
    String? phone,
    String? notes,
  }) async {
    try {
      // Backend will:
      // 1. Get buyer info from authenticated user
      // 2. Fetch product prices from database (security fix)
      // 3. Group items by seller
      // 4. Calculate totals server-side
      final response = await _api.post(
        '${AppConstants.ordersEndpoint}/create_order.php',
        body: {
          'shipping_address': shippingAddress,
          if (phone != null) 'phone': phone,
          if (notes != null) 'notes': notes,
          'items': cart.items
              .map((item) => {
                    'product_id': item.productId,
                    'quantity': item.quantity,
                    // Note: price, product_name, and image will be fetched from database by backend
                    // We only send product_id and quantity for security
                  })
              .toList(),
        },
      );

      if (response.success) {
        return OrderResult(
          success: true,
          message: 'Order placed successfully',
          order: response.data != null
              ? OrderModel.fromJson(response.data)
              : null,
        );
      }

      return OrderResult(
        success: false,
        message: response.message ?? 'Failed to create order',
      );
    } catch (e) {
      return OrderResult(success: false, message: e.toString());
    }
  }

  /// Get orders for buyer
  Future<List<OrderModel>> getBuyerOrders(String buyerId) async {
    try {
      final response = await _api.get(
        '${AppConstants.ordersEndpoint}/get_buyer_orders.php',
        queryParams: {'buyer_id': buyerId},
      );

      if (response.success && response.data != null) {
        final List<dynamic> ordersJson =
            response.data is List ? response.data : response.data['orders'] ?? [];
        return ordersJson.map((o) => OrderModel.fromJson(o)).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get orders for seller
  Future<List<OrderModel>> getSellerOrders(String sellerId,
      {String? status}) async {
    try {
      final queryParams = {'seller_id': sellerId};
      if (status != null) queryParams['status'] = status;

      final response = await _api.get(
        '${AppConstants.ordersEndpoint}/get_seller_orders.php',
        queryParams: queryParams,
      );

      if (response.success && response.data != null) {
        final List<dynamic> ordersJson =
            response.data is List ? response.data : response.data['orders'] ?? [];
        return ordersJson.map((o) => OrderModel.fromJson(o)).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get all orders (for admin)
  Future<List<OrderModel>> getAllOrders({String? status}) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;

      final response = await _api.get(
        '${AppConstants.ordersEndpoint}/get_all_orders.php',
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.success && response.data != null) {
        final List<dynamic> ordersJson =
            response.data is List ? response.data : response.data['orders'] ?? [];
        return ordersJson.map((o) => OrderModel.fromJson(o)).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final response = await _api.get(
        '${AppConstants.ordersEndpoint}/get_order.php',
        queryParams: {'id': orderId},
      );

      if (response.success && response.data != null) {
        return OrderModel.fromJson(response.data);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update order status
  Future<OrderResult> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      final response = await _api.put(
        '${AppConstants.ordersEndpoint}/update_order_status.php',
        body: {
          'id': orderId,
          'status': status,
        },
      );

      if (response.success) {
        return OrderResult(
          success: true,
          message: 'Order status updated to ${status.toUpperCase()}',
        );
      }

      return OrderResult(
        success: false,
        message: response.message ?? 'Failed to update order status',
      );
    } catch (e) {
      return OrderResult(success: false, message: e.toString());
    }
  }

  /// Cancel order
  Future<OrderResult> cancelOrder(String orderId) async {
    return updateOrderStatus(orderId: orderId, status: 'cancelled');
  }

  /// Mark order as shipped
  Future<OrderResult> shipOrder(String orderId) async {
    return updateOrderStatus(orderId: orderId, status: 'shipped');
  }

  /// Mark order as completed
  Future<OrderResult> completeOrder(String orderId) async {
    return updateOrderStatus(orderId: orderId, status: 'completed');
  }
}

/// Order Result wrapper
class OrderResult {
  final bool success;
  final String? message;
  final OrderModel? order;

  OrderResult({
    required this.success,
    this.message,
    this.order,
  });
}

