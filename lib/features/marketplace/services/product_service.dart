import 'package:flutter_application_1/features/marketplace/models/product_model.dart';

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
    _mockDb = [
      // BOOK Category (5 items)
      Product(
        id: '1',
        sellerId: 'seller_001',
        title: 'Calculus 1 - Advanced Mathematics',
        description:
            'Clean condition, all notes included. Original price 890 baht.',
        price: 450.0,
        imageUrl: 'https://via.placeholder.com/200?text=Calculus',
        category: 'Book',
        status: ProductStatus.available,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Product(
        id: '2',
        sellerId: 'seller_002',
        title: 'Biology Text - Cell Structure',
        description: 'Latest edition, minimal marking. Perfect for exams.',
        price: 350.0,
        imageUrl: 'https://via.placeholder.com/200?text=Biology',
        category: 'Book',
        status: ProductStatus.available,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Product(
        id: '3',
        sellerId: 'seller_003',
        title: 'Physics Principles and Applications',
        description: 'Comprehensive textbook with solved examples.',
        price: 520.0,
        imageUrl: 'https://via.placeholder.com/200?text=Physics',
        category: 'Book',
        status: ProductStatus.available,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      Product(
        id: '4',
        sellerId: 'seller_004',
        title: 'English Literature - Shakespeare Collection',
        description: 'Annotated with study notes from previous student.',
        price: 280.0,
        imageUrl: 'https://via.placeholder.com/200?text=Literature',
        category: 'Book',
        status: ProductStatus.available,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Product(
        id: '5',
        sellerId: 'seller_005',
        title: 'Organic Chemistry - Mechanisms & Reactions',
        description: 'Reference guide with practice problems.',
        price: 420.0,
        imageUrl: 'https://via.placeholder.com/200?text=Chemistry',
        category: 'Book',
        status: ProductStatus.available,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      // LEARNING TOOLS Category (5 items)
      Product(
        id: '6',
        sellerId: 'seller_006',
        title: 'Casio Scientific Calculator - FX-991EX',
        description:
            'Advanced functions for engineering and science. Like new condition.',
        price: 850.0,
        imageUrl: 'https://via.placeholder.com/200?text=Casio',
        category: 'Learning tools',
        status: ProductStatus.available,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      Product(
        id: '7',
        sellerId: 'seller_007',
        title: 'iPad Stylus Pen - Premium Touch',
        description: 'Perfect for digital notes and design work. Barely used.',
        price: 650.0,
        imageUrl: 'https://via.placeholder.com/200?text=Stylus',
        category: 'Learning tools',
        status: ProductStatus.available,
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
      Product(
        id: '8',
        sellerId: 'seller_008',
        title: 'Lab Coat - White Size M',
        description:
            'Professional quality lab coat for chemistry and biology labs.',
        price: 320.0,
        imageUrl: 'https://via.placeholder.com/200?text=LabCoat',
        category: 'Learning tools',
        status: ProductStatus.available,
        createdAt: DateTime.now(),
      ),
      Product(
        id: '9',
        sellerId: 'seller_009',
        title: 'Compass Set - Geometry Tools',
        description: 'Complete geometry and drafting tool set.',
        price: 180.0,
        imageUrl: 'https://via.placeholder.com/200?text=Compass',
        category: 'Learning tools',
        status: ProductStatus.available,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      Product(
        id: '10',
        sellerId: 'seller_010',
        title: 'Microscope Slide Kit - 50 Prepared Slides',
        description:
            'Collection of prepared microscope slides for biology lab.',
        price: 450.0,
        imageUrl: 'https://via.placeholder.com/200?text=Slides',
        category: 'Learning tools',
        status: ProductStatus.available,
        createdAt: DateTime.now().subtract(const Duration(days: 9)),
      ),
      // OTHER ITEMS Category (5 items)
      Product(
        id: '11',
        sellerId: 'seller_011',
        title: 'Desk Fan - USB Powered',
        description: 'Quiet cooling fan perfect for dorms. White color.',
        price: 280.0,
        imageUrl: 'https://via.placeholder.com/200?text=Fan',
        category: 'Other items',
        status: ProductStatus.available,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Product(
        id: '12',
        sellerId: 'seller_012',
        title: 'LED Desk Lamp - Adjustable Brightness',
        description: 'Energy-efficient lamp with 3 brightness levels.',
        price: 550.0,
        imageUrl: 'https://via.placeholder.com/200?text=Lamp',
        category: 'Other items',
        status: ProductStatus.available,
        createdAt: DateTime.now().subtract(const Duration(days: 11)),
      ),
      Product(
        id: '13',
        sellerId: 'seller_013',
        title: 'MFU Official Uniform - Navy Blue Size S',
        description:
            'Official university uniform, well maintained. Perfect condition.',
        price: 650.0,
        imageUrl: 'https://via.placeholder.com/200?text=Uniform',
        category: 'Other items',
        status: ProductStatus.available,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Product(
        id: '14',
        sellerId: 'seller_014',
        title: 'Dormitory Cabinet - Metal Locker',
        description:
            'Gray metal locker with lock. Excellent for securing items.',
        price: 1200.0,
        imageUrl: 'https://via.placeholder.com/200?text=Locker',
        category: 'Other items',
        status: ProductStatus.available,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
      Product(
        id: '15',
        sellerId: 'seller_015',
        title: 'Travel Backpack - 40L Capacity',
        description:
            'Durable daypack for campus and field trips. Multiple pockets.',
        price: 890.0,
        imageUrl: 'https://via.placeholder.com/200?text=Backpack',
        category: 'Other items',
        status: ProductStatus.available,
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
    ];
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
