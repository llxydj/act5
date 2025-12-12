import '../config/constants.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import 'api_service.dart';

/// Product Service for CRUD operations
class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final ApiService _api = ApiService();

  /// Get all products
  Future<List<ProductModel>> getProducts({
    String? categoryId,
    String? searchQuery,
    String? sellerId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }
      if (sellerId != null) queryParams['seller_id'] = sellerId;

      final response = await _api.get(
        '${AppConstants.productsEndpoint}/get_products.php',
        queryParams: queryParams,
      );

      if (response.success && response.data != null) {
        final List<dynamic> productsJson = response.data is List
            ? response.data
            : response.data['products'] ?? [];
        return productsJson.map((p) => ProductModel.fromJson(p)).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final response = await _api.get(
        '${AppConstants.productsEndpoint}/get_product.php',
        queryParams: {'id': productId},
      );

      if (response.success && response.data != null) {
        return ProductModel.fromJson(response.data);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Add new product
  Future<ProductResult> addProduct({
    required String sellerId,
    required String name,
    required String description,
    required double price,
    required int stockQuantity,
    String? categoryId,
    String? imageBase64,
  }) async {
    try {
      final response = await _api.post(
        '${AppConstants.productsEndpoint}/add_product.php',
        body: {
          'seller_id': sellerId,
          'name': name,
          'description': description,
          'price': price,
          'stock_quantity': stockQuantity,
          'category_id': categoryId,
          'image_base64': imageBase64,
        },
      );

      if (response.success) {
        return ProductResult(
          success: true,
          message: 'Product added successfully',
          product: response.data != null
              ? ProductModel.fromJson(response.data)
              : null,
        );
      }

      return ProductResult(
        success: false,
        message: response.message ?? 'Failed to add product',
      );
    } catch (e) {
      return ProductResult(success: false, message: e.toString());
    }
  }

  /// Update product
  Future<ProductResult> updateProduct({
    required String productId,
    String? name,
    String? description,
    double? price,
    int? stockQuantity,
    String? categoryId,
    String? imageBase64,
    bool? isActive,
  }) async {
    try {
      final body = <String, dynamic>{'id': productId};
      if (name != null) body['name'] = name;
      if (description != null) body['description'] = description;
      if (price != null) body['price'] = price;
      if (stockQuantity != null) body['stock_quantity'] = stockQuantity;
      if (categoryId != null) body['category_id'] = categoryId;
      if (imageBase64 != null) body['image_base64'] = imageBase64;
      if (isActive != null) body['is_active'] = isActive ? 1 : 0;

      final response = await _api.put(
        '${AppConstants.productsEndpoint}/update_product.php',
        body: body,
      );

      if (response.success) {
        return ProductResult(
          success: true,
          message: 'Product updated successfully',
        );
      }

      return ProductResult(
        success: false,
        message: response.message ?? 'Failed to update product',
      );
    } catch (e) {
      return ProductResult(success: false, message: e.toString());
    }
  }

  /// Delete product
  Future<ProductResult> deleteProduct(String productId) async {
    try {
      final response = await _api.delete(
        '${AppConstants.productsEndpoint}/delete_product.php?id=$productId',
      );

      if (response.success) {
        return ProductResult(
          success: true,
          message: 'Product deleted successfully',
        );
      }

      return ProductResult(
        success: false,
        message: response.message ?? 'Failed to delete product',
      );
    } catch (e) {
      return ProductResult(success: false, message: e.toString());
    }
  }

  /// Get categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _api.get(
        '${AppConstants.categoriesEndpoint}/get_categories.php',
      );

      if (response.success && response.data != null) {
        final List<dynamic> categoriesJson = response.data is List
            ? response.data
            : response.data['categories'] ?? [];
        return categoriesJson.map((c) => CategoryModel.fromJson(c)).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get seller statistics
  Future<Map<String, dynamic>> getSellerStats(String sellerId) async {
    try {
      final response = await _api.get(
        '${AppConstants.productsEndpoint}/get_seller_stats.php',
        queryParams: {'seller_id': sellerId},
      );

      if (response.success && response.data != null) {
        return response.data as Map<String, dynamic>;
      }

      return {
        'total_products': 0,
        'total_orders': 0,
        'total_revenue': 0.0,
        'pending_orders': 0,
      };
    } catch (e) {
      return {
        'total_products': 0,
        'total_orders': 0,
        'total_revenue': 0.0,
        'pending_orders': 0,
      };
    }
  }
}

/// Product Result wrapper
class ProductResult {
  final bool success;
  final String? message;
  final ProductModel? product;

  ProductResult({
    required this.success,
    this.message,
    this.product,
  });
}

