/// Enum for product status
enum ProductStatus {
  available('available'),
  sold('sold');

  final String value;
  const ProductStatus(this.value);

  /// Parse string to ProductStatus enum
  static ProductStatus fromString(String value) {
    return ProductStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ProductStatus.available,
    );
  }
}

class Product {
  final String id;
  final String sellerId;
  final String title;
  final String description;
  final double price;
  final List<String> imageUrls;
  final String category;
  final ProductStatus status;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.description,
    required this.price,
    List<String>? imageUrls,
    String? imageUrl,
    required this.category,
    this.status = ProductStatus.available,
    required this.createdAt,
  }) : imageUrls = _normalizeImageUrls(
         imageUrls: imageUrls,
         imageUrl: imageUrl,
       );

  static List<String> _normalizeImageUrls({
    List<String>? imageUrls,
    String? imageUrl,
  }) {
    if (imageUrls != null && imageUrls.isNotEmpty) {
      return List<String>.from(imageUrls.where((url) => url.trim().isNotEmpty));
    }

    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      return [imageUrl.trim()];
    }

    return const <String>[];
  }

  String get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  /// Creates a copy of this Product with optional field replacements
  Product copyWith({
    String? id,
    String? sellerId,
    String? title,
    String? description,
    double? price,
    List<String>? imageUrls,
    String? imageUrl,
    String? category,
    ProductStatus? status,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrls: imageUrls ?? this.imageUrls,
      imageUrl: imageUrl,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Converts Product instance to Map for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sellerId': sellerId,
      'title': title,
      'description': description,
      'price': price,
      'imageUrls': imageUrls,
      'category': category,
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates Product instance from Map
  static Product fromMap(Map<String, dynamic> map) {
    final rawUrls = map['imageUrls'];
    final imageUrls = rawUrls is List
        ? rawUrls.whereType<String>().toList()
        : <String>[];

    final legacyImageUrl = map['imageUrl'] as String?;

    return Product(
      id: map['id'] as String,
      sellerId: map['sellerId'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
      imageUrls: imageUrls,
      imageUrl: legacyImageUrl,
      category: map['category'] as String,
      status: ProductStatus.fromString(map['status'] as String? ?? 'available'),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  @override
  String toString() =>
      'Product(id: $id, title: $title, price: $price, status: ${status.value})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          sellerId == other.sellerId &&
          title == other.title &&
          description == other.description &&
          price == other.price &&
          _listEquals(imageUrls, other.imageUrls) &&
          category == other.category &&
          status == other.status &&
          createdAt == other.createdAt;

  static bool _listEquals(List<String> a, List<String> b) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  static int _listHash(List<String> values) {
    var hash = 17;
    for (final value in values) {
      hash = 37 * hash + value.hashCode;
    }
    return hash;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      sellerId.hashCode ^
      title.hashCode ^
      description.hashCode ^
      price.hashCode ^
      _listHash(imageUrls) ^
      category.hashCode ^
      status.hashCode ^
      createdAt.hashCode;
}
