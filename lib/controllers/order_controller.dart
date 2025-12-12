import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';
import '../services/order_service.dart';

/// Order Controller for state management
class OrderController extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<OrderModel> _buyerOrders = [];
  List<OrderModel> _sellerOrders = [];
  List<OrderModel> _allOrders = [];
  OrderModel? _selectedOrder;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<OrderModel> get buyerOrders => _buyerOrders;
  List<OrderModel> get sellerOrders => _sellerOrders;
  List<OrderModel> get allOrders => _allOrders;
  OrderModel? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filter orders by status
  List<OrderModel> getSellerOrdersByStatus(String status) {
    return _sellerOrders.where((order) => order.status == status).toList();
  }

  int get pendingOrdersCount {
    return _sellerOrders.where((order) => order.isPending).length;
  }

  /// Create order
  Future<bool> createOrder({
    required String buyerId,
    required String buyerName,
    required String buyerEmail,
    required CartModel cart,
    required String shippingAddress,
    String? phone,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _orderService.createOrder(
      buyerId: buyerId,
      buyerName: buyerName,
      buyerEmail: buyerEmail,
      cart: cart,
      shippingAddress: shippingAddress,
      phone: phone,
      notes: notes,
    );

    _isLoading = false;

    if (result.success) {
      if (result.order != null) {
        _buyerOrders.insert(0, result.order!);
      }
      notifyListeners();
      return true;
    } else {
      _error = result.message;
      notifyListeners();
      return false;
    }
  }

  /// Fetch buyer orders
  Future<void> fetchBuyerOrders(String buyerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _buyerOrders = await _orderService.getBuyerOrders(buyerId);

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch seller orders
  Future<void> fetchSellerOrders(String sellerId, {String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _sellerOrders = await _orderService.getSellerOrders(sellerId, status: status);

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch all orders (admin)
  Future<void> fetchAllOrders({String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _allOrders = await _orderService.getAllOrders(status: status);

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch order by ID
  Future<OrderModel?> fetchOrderById(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _selectedOrder = await _orderService.getOrderById(orderId);

    _isLoading = false;
    notifyListeners();
    return _selectedOrder;
  }

  /// Update order status
  Future<bool> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _orderService.updateOrderStatus(
      orderId: orderId,
      status: status,
    );

    _isLoading = false;

    if (result.success) {
      // Update local lists
      _updateOrderInLists(orderId, status);
      notifyListeners();
      return true;
    } else {
      _error = result.message;
      notifyListeners();
      return false;
    }
  }

  /// Ship order
  Future<bool> shipOrder(String orderId) async {
    return updateOrderStatus(orderId: orderId, status: 'shipped');
  }

  /// Complete order
  Future<bool> completeOrder(String orderId) async {
    return updateOrderStatus(orderId: orderId, status: 'completed');
  }

  /// Cancel order
  Future<bool> cancelOrder(String orderId) async {
    return updateOrderStatus(orderId: orderId, status: 'cancelled');
  }

  // Helper to update order in all lists
  void _updateOrderInLists(String orderId, String status) {
    void updateList(List<OrderModel> list) {
      final index = list.indexWhere((o) => o.id == orderId);
      if (index >= 0) {
        list[index] = list[index].copyWith(
          status: status,
          updatedAt: DateTime.now(),
          shippedAt: status == 'shipped' ? DateTime.now() : null,
          completedAt: status == 'completed' ? DateTime.now() : null,
        );
      }
    }

    updateList(_buyerOrders);
    updateList(_sellerOrders);
    updateList(_allOrders);

    if (_selectedOrder?.id == orderId) {
      _selectedOrder = _selectedOrder!.copyWith(status: status);
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

