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
  final String imageUrl;
  final String category;
  final ProductStatus status;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.status = ProductStatus.available,
    required this.createdAt,
  });

  /// Creates a copy of this Product with optional field replacements
  Product copyWith({
    String? id,
    String? sellerId,
    String? title,
    String? description,
    double? price,
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
      imageUrl: imageUrl ?? this.imageUrl,
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
      'imageUrl': imageUrl,
      'category': category,
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates Product instance from Map
  static Product fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      sellerId: map['sellerId'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
      imageUrl: map['imageUrl'] as String,
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
          imageUrl == other.imageUrl &&
          category == other.category &&
          status == other.status &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      sellerId.hashCode ^
      title.hashCode ^
      description.hashCode ^
      price.hashCode ^
      imageUrl.hashCode ^
      category.hashCode ^
      status.hashCode ^
      createdAt.hashCode;
}
