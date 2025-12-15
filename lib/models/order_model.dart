import 'cart_model.dart';

/// Order Item Model
class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String? imageBase64; // Legacy support
  final String? imageUrl; // Legacy support
  final String? firestoreImageId; // Firestore document ID

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.imageBase64,
    this.imageUrl,
    this.firestoreImageId,
  });

  factory OrderItem.fromCartItem(CartItem cartItem, String orderId) {
    return OrderItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      orderId: orderId,
      productId: cartItem.productId,
      productName: cartItem.productName,
      price: cartItem.price,
      quantity: cartItem.quantity,
      imageBase64: cartItem.imageBase64,
      imageUrl: cartItem.imageUrl,
      firestoreImageId: cartItem.firestoreImageId,
    );
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      imageBase64: json['image_base64'],
      imageUrl: json['image_url'],
      firestoreImageId: json['firestore_image_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'image_base64': imageBase64,
      'image_url': imageUrl,
      'firestore_image_id': firestoreImageId,
    };
  }

  double get totalPrice => price * quantity;

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String get formattedTotalPrice => '\$${totalPrice.toStringAsFixed(2)}';
}

/// Order Model
class OrderModel {
  final String id;
  final String buyerId;
  final String buyerName;
  final String buyerEmail;
  final String sellerId;
  final String sellerName;
  final String status;
  final double totalAmount;
  final String? shippingAddress;
  final String? phone;
  final String? notes;
  final List<OrderItem> items;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? shippedAt;
  final DateTime? completedAt;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    required this.buyerEmail,
    required this.sellerId,
    required this.sellerName,
    required this.status,
    required this.totalAmount,
    this.shippingAddress,
    this.phone,
    this.notes,
    required this.items,
    required this.createdAt,
    this.updatedAt,
    this.shippedAt,
    this.completedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      buyerId: json['buyer_id']?.toString() ?? '',
      buyerName: json['buyer_name'] ?? '',
      buyerEmail: json['buyer_email'] ?? '',
      sellerId: json['seller_id']?.toString() ?? '',
      sellerName: json['seller_name'] ?? '',
      status: json['status'] ?? 'pending',
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      shippingAddress: json['shipping_address'],
      phone: json['phone'],
      notes: json['notes'],
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      shippedAt: json['shipped_at'] != null
          ? DateTime.parse(json['shipped_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyer_id': buyerId,
      'buyer_name': buyerName,
      'buyer_email': buyerEmail,
      'seller_id': sellerId,
      'seller_name': sellerName,
      'status': status,
      'total_amount': totalAmount,
      'shipping_address': shippingAddress,
      'phone': phone,
      'notes': notes,
      'items': items.map((item) => item.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'shipped_at': shippedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? buyerId,
    String? buyerName,
    String? buyerEmail,
    String? sellerId,
    String? sellerName,
    String? status,
    double? totalAmount,
    String? shippingAddress,
    String? phone,
    String? notes,
    List<OrderItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? shippedAt,
    DateTime? completedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      buyerEmail: buyerEmail ?? this.buyerEmail,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      shippedAt: shippedAt ?? this.shippedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  String get formattedTotal => '\$${totalAmount.toStringAsFixed(2)}';

  bool get isPending => status == 'pending';
  bool get isShipped => status == 'shipped';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'shipped':
        return 'Shipped';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}

