import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/marketplace/models/product_model.dart';
import 'package:flutter_application_1/features/marketplace/services/product_service.dart';

/// Provider for managing product marketplace state
class ProductProvider extends ChangeNotifier {
  final ProductService _productService;

  /// Internal state
  List<Product> _items = [];
  bool _isLoading = false;
  String? _error;

  ProductProvider({required ProductService productService})
    : _productService = productService;

  // Getters for state access
  List<Product> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Loads products from the service
  Future<void> loadProducts() async {
    _setLoading(true);
    _clearError();

    try {
      _items = await _productService.fetchProducts();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load products: ${e.toString()}');
      _setLoading(false);
      rethrow;
    }
  }

  /// Adds a new product to the marketplace and refreshes the list
  Future<void> addProduct(Product product) async {
    _clearError();

    try {
      // Add the product to the service
      await _productService.addProduct(product);

      // Re-fetch the updated list from the service to ensure sync
      _items = await _productService.fetchProducts();
      notifyListeners();
    } catch (e) {
      _setError('Failed to add product: ${e.toString()}');
      rethrow;
    }
  }

  /// Returns products owned by a specific seller
  List<Product> getProductsBySellerId(String sellerId) {
    return _items.where((product) => product.sellerId == sellerId).toList();
  }

  /// Deletes a product from the marketplace
  void deleteProduct(String id) {
    _items = _items.where((product) => product.id != id).toList();
    notifyListeners();
  }

  /// Updates an existing product in the marketplace
  void updateProduct(Product updatedProduct) {
    final index = _items.indexWhere(
      (product) => product.id == updatedProduct.id,
    );
    if (index != -1) {
      _items[index] = updatedProduct;
      notifyListeners();
    }
  }

  /// Helper method to update loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Helper method to set error message
  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  /// Helper method to clear error message
  void _clearError() {
    _error = null;
  }
}
