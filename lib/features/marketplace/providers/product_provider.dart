import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/features/marketplace/models/product_model.dart';
import 'package:flutter_application_1/features/marketplace/services/product_service.dart';

/// Provider for managing product marketplace state
class ProductProvider extends ChangeNotifier {
  static const int _pageSize = 10;
  static const String _cloudinaryCloudName = 'dkj7zbvjx';
  static const String _cloudinaryUploadPreset = 'SAGAflutter_app';

  late final CloudinaryPublic _cloudinary = CloudinaryPublic(
    _cloudinaryCloudName,
    _cloudinaryUploadPreset,
    cache: false,
  );

  final FirebaseFirestore _firestore;
  final ProductService? _productService;

  /// Internal state
  List<Product> _items = [];
  DocumentSnapshot<Map<String, dynamic>>? _lastDocument;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  ProductProvider({
    FirebaseFirestore? firestore,
    ProductService? productService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _productService = productService;

  // Getters for state access
  List<Product> get items => _items;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;

  /// Loads the first page of products from Firestore.
  Future<void> loadProducts() async {
    _setLoading(true);
    _clearError();

    try {
      final snapshot = await _firestore
          .collection('products')
          .orderBy('createdAt', descending: true)
          .limit(_pageSize)
          .get();

      _items = snapshot.docs.map(_productFromDoc).toList();
      _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      _hasMore = snapshot.docs.length == _pageSize;
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load products: ${e.toString()}');
      _setLoading(false);
      rethrow;
    }
  }

  /// Loads the next page of products.
  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore || _lastDocument == null) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('products')
          .orderBy('createdAt', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(_pageSize)
          .get();

      final moreItems = snapshot.docs.map(_productFromDoc).toList();
      _items = [..._items, ...moreItems];
      _lastDocument = snapshot.docs.isNotEmpty
          ? snapshot.docs.last
          : _lastDocument;
      _hasMore = snapshot.docs.length == _pageSize;
    } catch (e) {
      _setError('Failed to load more products: ${e.toString()}');
      rethrow;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Loads products for a single seller.
  Future<List<Product>> loadMyProducts({required String sellerId}) async {
    final normalizedSellerId = sellerId.trim();
    if (normalizedSellerId.isEmpty || normalizedSellerId == 'user_guest') {
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: normalizedSellerId)
          .get();

      final products = snapshot.docs.map(_productFromDoc).toList();
      products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return products;
    } catch (e) {
      throw Exception('Failed to load your products: ${e.toString()}');
    }
  }

  /// Uploads multiple product images to Cloudinary and returns secure URLs.
  Future<List<String>> uploadProductImages({
    required String sellerId,
    required List<XFile> imageFiles,
  }) async {
    if (sellerId.trim().isEmpty || sellerId == 'user_guest') {
      throw Exception('Please sign in to upload images.');
    }

    if (_cloudinaryCloudName.trim().isEmpty ||
        _cloudinaryUploadPreset.trim().isEmpty) {
      throw Exception(
        'Set your Cloudinary cloud name and upload preset before uploading images.',
      );
    }

    if (imageFiles.isEmpty) {
      return [];
    }

    final uploadedUrls = <String>[];

    for (var i = 0; i < imageFiles.length; i++) {
      final file = imageFiles[i];
      try {
        final response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            file.path,
            resourceType: CloudinaryResourceType.Image,
          ),
        );
        uploadedUrls.add(response.secureUrl);
      } on CloudinaryException catch (e) {
        throw Exception('Cloudinary Error: ${e.message}');
      } catch (e) {
        throw Exception('Unknown Error during upload: $e');
      }
    }

    return uploadedUrls;
  }

  /// Adds a new product to Firestore and refreshes the first page.
  Future<void> addProduct(Product product) async {
    _clearError();

    try {
      await _firestore.collection('products').doc(product.id).set({
        'id': product.id,
        'sellerId': product.sellerId,
        'title': product.title,
        'description': product.description,
        'price': product.price,
        'imageUrls': product.imageUrls,
        'category': product.category,
        'status': product.status.value,
        'createdAt': Timestamp.fromDate(product.createdAt),
      });

      await loadProducts();
    } catch (e) {
      _setError('Failed to add product: ${e.toString()}');
      rethrow;
    }
  }

  /// Returns products owned by a specific seller from the loaded cache.
  List<Product> getProductsBySellerId(String sellerId) {
    return _items.where((product) => product.sellerId == sellerId).toList();
  }

  Product _findByIdOrThrow(String id) {
    final index = _items.indexWhere((product) => product.id == id);
    if (index == -1) {
      throw Exception('Product not found');
    }
    return _items[index];
  }

  void _assertOwnership(Product product, String currentUserId) {
    if (product.sellerId != currentUserId) {
      throw Exception('Unauthorized action');
    }
  }

  /// Deletes a product from Firestore and local cache.
  Future<void> deleteProduct({
    required String id,
    required String currentUserId,
  }) async {
    _clearError();

    try {
      final existingProduct = _findByIdOrThrow(id);
      _assertOwnership(existingProduct, currentUserId);

      await _firestore.collection('products').doc(id).delete();
      _items = _items.where((product) => product.id != id).toList();
      notifyListeners();
    } catch (e) {
      _setError('Delete failed: ${e.toString()}');
      rethrow;
    }
  }

  /// Updates an existing product in Firestore and local cache.
  Future<void> updateProduct({
    required Product updatedProduct,
    required String currentUserId,
  }) async {
    _clearError();

    try {
      final index = _items.indexWhere(
        (product) => product.id == updatedProduct.id,
      );

      Product persistedProduct;
      if (index != -1) {
        final existingProduct = _items[index];
        _assertOwnership(existingProduct, currentUserId);
        persistedProduct = updatedProduct.copyWith(
          sellerId: existingProduct.sellerId,
          createdAt: existingProduct.createdAt,
        );
      } else {
        _assertOwnership(updatedProduct, currentUserId);
        persistedProduct = updatedProduct;
      }

      await _firestore.collection('products').doc(persistedProduct.id).set({
        'id': persistedProduct.id,
        'sellerId': persistedProduct.sellerId,
        'title': persistedProduct.title,
        'description': persistedProduct.description,
        'price': persistedProduct.price,
        'imageUrls': persistedProduct.imageUrls,
        'category': persistedProduct.category,
        'status': persistedProduct.status.value,
        'createdAt': Timestamp.fromDate(persistedProduct.createdAt),
      });

      if (index != -1) {
        _items[index] = persistedProduct;
      }
      notifyListeners();
    } catch (e) {
      _setError('Update failed: ${e.toString()}');
      rethrow;
    }
  }

  Product _productFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final createdAtValue = data['createdAt'];
    final rawImageUrls = data['imageUrls'];

    final imageUrls = rawImageUrls is List
        ? rawImageUrls.whereType<String>().toList()
        : <String>[];

    final legacyImageUrl = data['imageUrl'] as String?;

    DateTime createdAt;
    if (createdAtValue is Timestamp) {
      createdAt = createdAtValue.toDate();
    } else if (createdAtValue is String) {
      createdAt = DateTime.tryParse(createdAtValue) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    return Product(
      id: (data['id'] as String?) ?? doc.id,
      sellerId: data['sellerId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      imageUrls: imageUrls,
      imageUrl: legacyImageUrl,
      category: data['category'] as String? ?? '',
      status: ProductStatus.fromString(
        data['status'] as String? ?? ProductStatus.available.value,
      ),
      createdAt: createdAt,
    );
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
