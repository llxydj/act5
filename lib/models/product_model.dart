/// Product Model for E-Commerce App
class ProductModel {
  final String id;
  final String sellerId;
  final String sellerName;
  final String name;
  final String description;
  final double price;
  final int stockQuantity;
  final String? categoryId;
  final String? categoryName;
  final String? imageBase64; // Legacy support - Base64 from MySQL
  final String? imageUrl; // Legacy support - Firebase Storage URL
  final String? firestoreImageId; // Firestore document ID for Base64 image
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.name,
    required this.description,
    required this.price,
    required this.stockQuantity,
    this.categoryId,
    this.categoryName,
    this.imageBase64,
    this.imageUrl,
    this.firestoreImageId,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      sellerId: json['seller_id']?.toString() ?? '',
      sellerName: json['seller_name'] ?? 'Unknown Seller',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      stockQuantity: int.tryParse(json['stock_quantity']?.toString() ?? '0') ?? 0,
      categoryId: json['category_id']?.toString(),
      categoryName: json['category_name'],
      imageBase64: json['image_base64'],
      imageUrl: json['image_url'],
      firestoreImageId: json['firestore_image_id']?.toString(),
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seller_id': sellerId,
      'seller_name': sellerName,
      'name': name,
      'description': description,
      'price': price,
      'stock_quantity': stockQuantity,
      'category_id': categoryId,
      'category_name': categoryName,
      'image_base64': imageBase64,
      'image_url': imageUrl,
      'firestore_image_id': firestoreImageId,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? sellerId,
    String? sellerName,
    String? name,
    String? description,
    double? price,
    int? stockQuantity,
    String? categoryId,
    String? categoryName,
    String? imageBase64,
    String? imageUrl,
    String? firestoreImageId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      imageBase64: imageBase64 ?? this.imageBase64,
      imageUrl: imageUrl ?? this.imageUrl,
      firestoreImageId: firestoreImageId ?? this.firestoreImageId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get inStock => stockQuantity > 0;

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';
}

