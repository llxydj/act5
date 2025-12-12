import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../services/product_service.dart';

/// Product Controller for state management
class ProductController extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<ProductModel> _products = [];
  List<ProductModel> _sellerProducts = [];
  List<CategoryModel> _categories = [];
  ProductModel? _selectedProduct;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _searchQuery;
  String? _selectedCategoryId;

  // Getters
  List<ProductModel> get products => _products;
  List<ProductModel> get sellerProducts => _sellerProducts;
  List<CategoryModel> get categories => _categories;
  ProductModel? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMore => _hasMore;
  String? get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;

  /// Fetch products
  Future<void> fetchProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _products = [];
    }

    if (!_hasMore && !refresh) return;

    _isLoading = _products.isEmpty;
    _isLoadingMore = _products.isNotEmpty;
    _error = null;
    notifyListeners();

    final newProducts = await _productService.getProducts(
      page: _currentPage,
      searchQuery: _searchQuery,
      categoryId: _selectedCategoryId,
    );

    if (refresh) {
      _products = newProducts;
    } else {
      _products.addAll(newProducts);
    }

    _hasMore = newProducts.length >= 20;
    _currentPage++;
    _isLoading = false;
    _isLoadingMore = false;
    notifyListeners();
  }

  /// Load more products
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    await fetchProducts();
  }

  /// Fetch seller products
  Future<void> fetchSellerProducts(String sellerId, {bool refresh = false}) async {
    if (refresh) {
      _sellerProducts = [];
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    _sellerProducts = await _productService.getProducts(sellerId: sellerId);

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch product by ID
  Future<ProductModel?> fetchProductById(String productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _selectedProduct = await _productService.getProductById(productId);

    _isLoading = false;
    notifyListeners();
    return _selectedProduct;
  }

  /// Fetch categories
  Future<void> fetchCategories() async {
    _categories = await _productService.getCategories();
    notifyListeners();
  }

  /// Search products
  void search(String query) {
    _searchQuery = query.isEmpty ? null : query;
    fetchProducts(refresh: true);
  }

  /// Filter by category
  void filterByCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    fetchProducts(refresh: true);
  }

  /// Clear filters
  void clearFilters() {
    _searchQuery = null;
    _selectedCategoryId = null;
    fetchProducts(refresh: true);
  }

  /// Add product
  Future<bool> addProduct({
    required String sellerId,
    required String name,
    required String description,
    required double price,
    required int stockQuantity,
    String? categoryId,
    String? imageBase64,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _productService.addProduct(
      sellerId: sellerId,
      name: name,
      description: description,
      price: price,
      stockQuantity: stockQuantity,
      categoryId: categoryId,
      imageBase64: imageBase64,
    );

    _isLoading = false;

    if (result.success && result.product != null) {
      _sellerProducts.insert(0, result.product!);
      notifyListeners();
      return true;
    } else {
      _error = result.message;
      notifyListeners();
      return false;
    }
  }

  /// Update product
  Future<bool> updateProduct({
    required String productId,
    String? name,
    String? description,
    double? price,
    int? stockQuantity,
    String? categoryId,
    String? imageBase64,
    bool? isActive,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _productService.updateProduct(
      productId: productId,
      name: name,
      description: description,
      price: price,
      stockQuantity: stockQuantity,
      categoryId: categoryId,
      imageBase64: imageBase64,
      isActive: isActive,
    );

    _isLoading = false;

    if (result.success) {
      // Update local list
      final index = _sellerProducts.indexWhere((p) => p.id == productId);
      if (index >= 0) {
        _sellerProducts[index] = _sellerProducts[index].copyWith(
          name: name,
          description: description,
          price: price,
          stockQuantity: stockQuantity,
          categoryId: categoryId,
          imageBase64: imageBase64,
          isActive: isActive,
        );
      }
      notifyListeners();
      return true;
    } else {
      _error = result.message;
      notifyListeners();
      return false;
    }
  }

  /// Delete product
  Future<bool> deleteProduct(String productId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _productService.deleteProduct(productId);

    _isLoading = false;

    if (result.success) {
      _sellerProducts.removeWhere((p) => p.id == productId);
      _products.removeWhere((p) => p.id == productId);
      notifyListeners();
      return true;
    } else {
      _error = result.message;
      notifyListeners();
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

