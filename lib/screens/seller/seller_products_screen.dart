import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/product_controller.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/helpers.dart';

/// Seller Products Screen
class SellerProductsScreen extends StatefulWidget {
  const SellerProductsScreen({super.key});

  @override
  State<SellerProductsScreen> createState() => _SellerProductsScreenState();
}

class _SellerProductsScreenState extends State<SellerProductsScreen> {
  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    final user = context.read<AuthController>().user;
    if (user != null) {
      context.read<ProductController>().fetchSellerProducts(user.id);
    }
  }

  Future<void> _deleteProduct(String productId) async {
    final confirm = await Helpers.showConfirmDialog(
      context,
      title: 'Delete Product',
      message: 'Are you sure you want to delete this product?',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirm) {
      final success =
          await context.read<ProductController>().deleteProduct(productId);

      if (mounted) {
        if (success) {
          Helpers.showSnackBar(
            context,
            'Product deleted successfully',
            isSuccess: true,
          );
        } else {
          Helpers.showSnackBar(
            context,
            context.read<ProductController>().error ?? 'Failed to delete',
            isError: true,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Products'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () async {
              await Navigator.pushNamed(context, AppRoutes.addProduct);
              _loadProducts();
            },
          ),
        ],
      ),
      body: Consumer<ProductController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const ProductGridShimmer();
          }

          if (controller.sellerProducts.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.inventory_2_outlined,
              title: 'No Products Yet',
              subtitle: 'Add your first product to start selling',
              buttonText: 'Add Product',
              onButtonPressed: () async {
                await Navigator.pushNamed(context, AppRoutes.addProduct);
                _loadProducts();
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadProducts(),
            color: AppTheme.primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.sellerProducts.length,
              itemBuilder: (context, index) {
                final product = controller.sellerProducts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ProductListItem(
                    product: product,
                    showActions: true,
                    onEdit: () async {
                      await Navigator.pushNamed(
                        context,
                        AppRoutes.editProduct,
                        arguments: product.id,
                      );
                      _loadProducts();
                    },
                    onDelete: () => _deleteProduct(product.id),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.addProduct);
          _loadProducts();
        },
        backgroundColor: AppTheme.accentColor,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }
}

