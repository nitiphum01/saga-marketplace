import 'package:flutter_application_1/features/marketplace/models/product_model.dart';

/// Builds mock marketplace products for local development.
List<Product> buildMockProducts({DateTime? now}) {
  final base = now ?? DateTime.now();

  return [
    // BOOK Category (5 items)
    Product(
      id: '1',
      sellerId: 'seller_001',
      title: 'Calculus 1 - Advanced Mathematics',
      description:
          'Clean condition, all notes included. Original price 890 baht.',
      price: 450.0,
      imageUrl:
          'https://cdn.compassclassroom.com/wp-content/uploads/20240411230438/1K_calculus_book_set.jpeg',
      category: 'Book',
      status: ProductStatus.available,
      createdAt: base.subtract(const Duration(days: 5)),
    ),
    Product(
      id: '2',
      sellerId: 'seller_002',
      title: 'Biology Text - Cell Structure',
      description: 'Latest edition, minimal marking. Perfect for exams.',
      price: 350.0,
      imageUrl:
          'https://th.bing.com/th/id/OIP.BmJ6anvPEBbw5oDJmjgzhAHaKe?w=137&h=194&c=7&r=0&o=7&pid=1.7&rm=3',
      category: 'Book',
      status: ProductStatus.available,
      createdAt: base.subtract(const Duration(days: 3)),
    ),
    Product(
      id: '3',
      sellerId: 'seller_003',
      title: 'Physics Principles and Applications',
      description: 'Comprehensive textbook with solved examples.',
      price: 520.0,
      imageUrl: 'https://pictures.abebooks.com/isbn/9780321625922-us.jpg',
      category: 'Book',
      status: ProductStatus.available,
      createdAt: base.subtract(const Duration(days: 7)),
    ),
    Product(
      id: '4',
      sellerId: 'seller_004',
      title: 'English Literature - Shakespeare Collection',
      description: 'Annotated with study notes from previous student.',
      price: 280.0,
      imageUrl:
          'https://th.bing.com/th/id/R.46e6c4aacd6a2314f095a2635b67993d?rik=84DE9vhr6qiP0g&pid=ImgRaw&r=0',
      category: 'Book',
      status: ProductStatus.available,
      createdAt: base.subtract(const Duration(days: 2)),
    ),
    Product(
      id: '5',
      sellerId: 'seller_005',
      title: 'Organic Chemistry - Mechanisms & Reactions',
      description: 'Reference guide with practice problems.',
      price: 420.0,
      imageUrl:
          'https://chemistry.com.pk/wp-content/uploads/2024/01/Organic-Reaction-Mechanisms-Selected-Problems-and-Solutions-2e-By-Groutas-Rathnayake-jpg.webp',
      category: 'Book',
      status: ProductStatus.available,
      createdAt: base.subtract(const Duration(days: 1)),
    ),

    // LEARNING TOOLS Category (5 items)
    Product(
      id: '6',
      sellerId: 'seller_006',
      title: 'Casio Scientific Calculator - FX-991EX',
      description:
          'Advanced functions for engineering and science. Like new condition.',
      price: 850.0,
      imageUrl:
          'https://th.bing.com/th/id/OIP.eCPiwFA0_vAoocp8VNLnsgHaJF?w=163&h=200&c=7&r=0&o=7&pid=1.7&rm=3',
      category: 'Learning tools',
      status: ProductStatus.available,
      createdAt: base.subtract(const Duration(days: 4)),
    ),
    Product(
      id: '7',
      sellerId: 'seller_007',
      title: 'iPad Stylus Pen - Premium Touch',
      description: 'Perfect for digital notes and design work. Barely used.',
      price: 650.0,
      imageUrl:
          'https://th.bing.com/th?id=OIF.X921Bb2Q%2fE7Nlw6bkTjo1g&w=203&h=203&c=7&r=0&o=7&pid=1.7&rm=3',
      category: 'Learning tools',
      status: ProductStatus.available,
      createdAt: base.subtract(const Duration(days: 6)),
    ),
    Product(
      id: '8',
      sellerId: 'seller_008',
      title: 'Lab Coat - White Size M',
      description:
          'Professional quality lab coat for chemistry and biology labs.',
      price: 320.0,
      imageUrl:
          'https://th.bing.com/th/id/OIP._FkuAsgVtZs-RPu-WIwCEgHaHa?w=202&h=202&c=7&r=0&o=7&pid=1.7&rm=3',
      category: 'Learning tools',
      status: ProductStatus.available,
      createdAt: base,
    ),
    Product(
      id: '9',
      sellerId: 'seller_009',
      title: 'Compass Set - Geometry Tools',
      description: 'Complete geometry and drafting tool set.',
      price: 180.0,
      imageUrl:
          'https://th.bing.com/th/id/OIP.Pi1YHc-AN-lQ_8AJ12r0nQHaHw?w=197&h=206&c=7&r=0&o=7&pid=1.7&rm=3',
      category: 'Learning tools',
      status: ProductStatus.available,
      createdAt: base.subtract(const Duration(days: 8)),
    ),
    Product(
      id: '10',
      sellerId: 'seller_010',
      title: 'Microscope Slide Kit - 50 Prepared Slides',
      description: 'Collection of prepared microscope slides for biology lab.',
      price: 450.0,
      imageUrl:
          'https://th.bing.com/th/id/OIP.0u2J89zOOfS3VP-hIsRx1QHaHg?w=172&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      category: 'Learning tools',
      status: ProductStatus.available,
      createdAt: base.subtract(const Duration(days: 9)),
    ),

    // OTHER ITEMS Category (5 items)
    Product(
      id: '11',
      sellerId: 'seller_011',
      title: 'Desk Fan - USB Powered',
      description: 'Quiet cooling fan perfect for dorms. White color.',
      price: 280.0,
      imageUrl:
          'https://th.bing.com/th/id/OIP.UBeSYtMyXlD8yBsAIuhEQwHaHa?w=187&h=187&c=7&r=0&o=7&pid=1.7&rm=3',
      category: 'Other items',
      status: ProductStatus.available,
      createdAt: base.subtract(const Duration(days: 10)),
    ),
    Product(
      id: '12',
      sellerId: 'seller_012',
      title: 'LED Desk Lamp - Adjustable Brightness',
      description: 'Energy-efficient lamp with 3 brightness levels.',
      price: 550.0,
      imageUrl:
          'https://th.bing.com/th/id/OIP.UUFfkXo0Xt-B6eQydpI-vgHaJS?w=154&h=193&c=7&r=0&o=7&pid=1.7&rm=3',
      category: 'Other items',
      status: ProductStatus.available,
      createdAt: base.subtract(const Duration(days: 11)),
    ),
    Product(
      id: '13',
      sellerId: 'seller_013',
      title: 'MFU Official Uniform - Size S',
      description:
          'Official university uniform, well maintained. Perfect condition.',
      price: 650.0,
      imageUrl:
          'https://th.bing.com/th/id/OIP.1h4m8NNx-J3DGAqfeIEQ1QHaHa?w=220&h=220&c=7&r=0&o=7&pid=1.7&rm=3',
      category: 'Other items',
      status: ProductStatus.available,
      createdAt: base.subtract(const Duration(days: 3)),
    ),
    Product(
      id: '14',
      sellerId: 'seller_014',
      title: 'Dormitory Cabinet - Metal Locker',
      description: 'Gray metal locker with lock. Excellent for securing items.',
      price: 1200.0,
      imageUrl:
          'https://th.bing.com/th/id/OIP.Q4C08SDhkmGZPU8og429mwHaHa?w=198&h=198&c=7&r=0&o=7&pid=1.7&rm=3',
      category: 'Other items',
      status: ProductStatus.available,
      createdAt: base.subtract(const Duration(days: 12)),
    ),
    Product(
      id: '15',
      sellerId: 'seller_015',
      title: 'Travel Backpack - 40L Capacity',
      description:
          'Durable daypack for campus and field trips. Multiple pockets.',
      price: 890.0,
      imageUrl:
          'https://th.bing.com/th/id/OIP.HM7Vji-V6MXfRBHV48QjVwHaHo?w=214&h=220&c=7&r=0&o=7&pid=1.7&rm=3',
      category: 'Other items',
      status: ProductStatus.available,
      createdAt: base.subtract(const Duration(days: 6)),
    ),
  ];
}
