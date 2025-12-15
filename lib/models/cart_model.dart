import 'product_model.dart';

/// Cart Item Model
class CartItem {
  final String id;
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String? imageBase64; // Legacy support
  final String? imageUrl; // Legacy support
  final String? firestoreImageId; // Firestore document ID
  final int stockQuantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.imageBase64,
    this.imageUrl,
    this.firestoreImageId,
    required this.stockQuantity,
  });

  factory CartItem.fromProduct(ProductModel product, {int quantity = 1}) {
    return CartItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productId: product.id,
      productName: product.name,
      price: product.price,
      quantity: quantity,
      imageBase64: product.imageBase64,
      imageUrl: product.imageUrl,
      firestoreImageId: product.firestoreImageId,
      stockQuantity: product.stockQuantity,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      imageBase64: json['image_base64'],
      imageUrl: json['image_url'],
      firestoreImageId: json['firestore_image_id']?.toString(),
      stockQuantity: int.tryParse(json['stock_quantity']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'image_base64': imageBase64,
      'image_url': imageUrl,
      'firestore_image_id': firestoreImageId,
      'stock_quantity': stockQuantity,
    };
  }

  CartItem copyWith({
    String? id,
    String? productId,
    String? productName,
    double? price,
    int? quantity,
    String? imageBase64,
    String? imageUrl,
    String? firestoreImageId,
    int? stockQuantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageBase64: imageBase64 ?? this.imageBase64,
      imageUrl: imageUrl ?? this.imageUrl,
      firestoreImageId: firestoreImageId ?? this.firestoreImageId,
      stockQuantity: stockQuantity ?? this.stockQuantity,
    );
  }

  double get totalPrice => price * quantity;

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String get formattedTotalPrice => '\$${totalPrice.toStringAsFixed(2)}';

  bool get canIncrement => quantity < stockQuantity;
}

/// Cart Model containing multiple items
class CartModel {
  final List<CartItem> items;

  CartModel({required this.items});

  factory CartModel.empty() {
    return CartModel(items: []);
  }

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  String get formattedTotal => '\$${totalAmount.toStringAsFixed(2)}';

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  bool containsProduct(String productId) {
    return items.any((item) => item.productId == productId);
  }

  CartItem? getItem(String productId) {
    try {
      return items.firstWhere((item) => item.productId == productId);
    } catch (_) {
      return null;
    }
  }
}

