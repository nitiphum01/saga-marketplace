import 'package:flutter_application_1/features/marketplace/models/product_model.dart';
import 'package:flutter_application_1/features/marketplace/data/mock_products.dart';

/// Abstract service interface for product operations
abstract class ProductService {
  Future<List<Product>> fetchProducts();
  Future<void> addProduct(Product product);
}

/// Mock implementation of ProductService with in-memory database
class MockProductService implements ProductService {
  /// In-memory database for products
  late final List<Product> _mockDb;

  MockProductService() {
    _initializeMockData();
  }

  /// Initialize mock database with 15 sample products distributed evenly across 3 categories
  void _initializeMockData() {
    _mockDb = buildMockProducts();
  }

  /// Fetches all products from the in-memory database
  @override
  Future<List<Product>> fetchProducts() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    // Return a copy of the list to prevent external modifications
    return List<Product>.from(_mockDb);
  }

  /// Adds a new product to the in-memory database
  @override
  Future<void> addProduct(Product product) async {
    // Simulate network request with 1 second delay
    await Future.delayed(const Duration(seconds: 1));
    // Add the product to the in-memory database
    _mockDb.add(product);
    print(
      '[MockProductService] Product added: ${product.title} (Total items: ${_mockDb.length})',
    );
  }
}
