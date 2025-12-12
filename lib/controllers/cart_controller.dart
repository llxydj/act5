import 'package:flutter/foundation.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

/// Cart Controller for state management
class CartController extends ChangeNotifier {
  final List<CartItem> _items = [];
  bool _isLoading = false;

  // Getters
  List<CartItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  String get formattedTotal => '\$${totalAmount.toStringAsFixed(2)}';

  CartModel get cart => CartModel(items: _items);

  /// Add product to cart
  void addToCart(ProductModel product, {int quantity = 1}) {
    final existingIndex = _items.indexWhere(
      (item) => item.productId == product.id,
    );

    if (existingIndex >= 0) {
      // Update quantity if product already in cart
      final existingItem = _items[existingIndex];
      final newQuantity = existingItem.quantity + quantity;

      if (newQuantity <= product.stockQuantity) {
        _items[existingIndex] = existingItem.copyWith(quantity: newQuantity);
      }
    } else {
      // Add new item
      if (quantity <= product.stockQuantity) {
        _items.add(CartItem.fromProduct(product, quantity: quantity));
      }
    }

    notifyListeners();
  }

  /// Update item quantity
  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.productId == productId);

    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else if (quantity <= _items[index].stockQuantity) {
        _items[index] = _items[index].copyWith(quantity: quantity);
      }
      notifyListeners();
    }
  }

  /// Increment item quantity
  void incrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.productId == productId);

    if (index >= 0) {
      final item = _items[index];
      if (item.quantity < item.stockQuantity) {
        _items[index] = item.copyWith(quantity: item.quantity + 1);
        notifyListeners();
      }
    }
  }

  /// Decrement item quantity
  void decrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.productId == productId);

    if (index >= 0) {
      final item = _items[index];
      if (item.quantity > 1) {
        _items[index] = item.copyWith(quantity: item.quantity - 1);
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  /// Remove item from cart
  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  /// Check if product is in cart
  bool isInCart(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  /// Get cart item by product ID
  CartItem? getCartItem(String productId) {
    try {
      return _items.firstWhere((item) => item.productId == productId);
    } catch (_) {
      return null;
    }
  }

  /// Clear cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

