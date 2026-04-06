import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/core/constants/app_colors.dart';
import 'package:flutter_application_1/core/widgets/platform_file_preview.dart';
import 'package:flutter_application_1/core/widgets/saga_app_bar.dart';
import 'package:flutter_application_1/features/auth/providers/auth_provider.dart';
import 'package:flutter_application_1/features/marketplace/models/product_model.dart';
import 'package:flutter_application_1/features/marketplace/providers/product_provider.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  late Future<List<Product>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts = _loadProducts();
  }

  Future<List<Product>> _loadProducts() async {
    final authProvider = context.read<AuthProvider>();
    final sellerId =
        authProvider.user?.id ??
        fb_auth.FirebaseAuth.instance.currentUser?.uid ??
        '';

    if (sellerId.isEmpty) {
      return [];
    }

    return context.read<ProductProvider>().loadMyProducts(sellerId: sellerId);
  }

  void _refresh() {
    setState(() {
      _futureProducts = _loadProducts();
    });
  }

  Future<void> _deleteProduct(Product product) async {
    final currentUserId = context.read<AuthProvider>().getCurrentUserId();

    try {
      await context.read<ProductProvider>().deleteProduct(
        id: product.id,
        currentUserId: currentUserId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product deleted', style: GoogleFonts.kanit()),
          backgroundColor: AppColors.mfuRed,
        ),
      );
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
            style: GoogleFonts.kanit(),
          ),
          backgroundColor: AppColors.mfuRed,
        ),
      );
    }
  }

  void _showDeleteDialog(Product product) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Delete product?',
            style: GoogleFonts.kanit(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'This will permanently remove "${product.title}" from SAGA Marketplace.',
            style: GoogleFonts.kanit(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: GoogleFonts.kanit()),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _deleteProduct(product);
              },
              child: Text(
                'Delete',
                style: GoogleFonts.kanit(
                  color: AppColors.mfuRed,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SagaAppBar(
        title: Text(
          'My Products',
          style: GoogleFonts.kanit(fontWeight: FontWeight.w700),
        ),
      ),
      body: FutureBuilder<List<Product>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.mfuRed),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Failed to load your products.',
                  style: GoogleFonts.kanit(fontSize: 16),
                ),
              ),
            );
          }

          final products = snapshot.data ?? const <Product>[];

          if (products.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                _refresh();
                await _futureProducts;
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 72,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'No products posted yet',
                      style: GoogleFonts.kanit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Your marketplace history will appear here.',
                      style: GoogleFonts.kanit(color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _refresh();
              await _futureProducts;
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = products[index];
                return _ProductHistoryCard(
                  product: product,
                  onEdit: () async {
                    final result = await context.push(
                      '/edit-product',
                      extra: product,
                    );
                    if (result == true && mounted) {
                      _refresh();
                    }
                  },
                  onDelete: () => _showDeleteDialog(product),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ProductHistoryCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductHistoryCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(16),
            ),
            child: Container(
              width: 110,
              height: 110,
              color: Colors.grey.shade200,
              child: PlatformFilePreview(path: product.imageUrl),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.kanit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '฿${product.price.toStringAsFixed(0)}',
                    style: GoogleFonts.kanit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mfuRed,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: product.status == ProductStatus.available
                          ? Colors.green.shade50
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      product.status == ProductStatus.available
                          ? 'Available'
                          : 'Sold',
                      style: GoogleFonts.kanit(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: product.status == ProductStatus.available
                            ? Colors.green.shade700
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 18),
                        label: Text('Edit', style: GoogleFonts.kanit()),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.mfuBlue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete, size: 18),
                        label: Text('Delete', style: GoogleFonts.kanit()),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.mfuRed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
