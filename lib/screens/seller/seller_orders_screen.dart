import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/order_controller.dart';
import '../../widgets/order_card.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/helpers.dart';

/// Seller Orders Screen
class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadOrders() {
    final user = context.read<AuthController>().user;
    if (user != null) {
      context.read<OrderController>().fetchSellerOrders(user.id);
    }
  }

  Future<void> _updateOrderStatus(String orderId, String status) async {
    final success = await context.read<OrderController>().updateOrderStatus(
          orderId: orderId,
          status: status,
        );

    if (mounted) {
      if (success) {
        Helpers.showSnackBar(
          context,
          'Order status updated to ${status.toUpperCase()}',
          isSuccess: true,
        );
      } else {
        Helpers.showSnackBar(
          context,
          context.read<OrderController>().error ?? 'Failed to update status',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Shipped'),
            Tab(text: 'Done'),
          ],
        ),
      ),
      body: Consumer<OrderController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const LoadingWidget(message: 'Loading orders...');
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList(controller.sellerOrders),
              _buildOrderList(
                controller.sellerOrders.where((o) => o.isPending).toList(),
                showStatusActions: true,
              ),
              _buildOrderList(
                controller.sellerOrders.where((o) => o.isShipped).toList(),
                showStatusActions: true,
              ),
              _buildOrderList(
                controller.sellerOrders
                    .where((o) => o.isCompleted || o.isCancelled)
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderList(List orders, {bool showStatusActions = false}) {
    if (orders.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.receipt_long_outlined,
        title: 'No Orders',
        subtitle: 'No orders in this category',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadOrders();
      },
      color: AppTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: OrderCard(
              order: order,
              showBuyerInfo: true,
              showStatusActions: showStatusActions,
              onStatusUpdate: () {
                if (order.isPending) {
                  _showStatusUpdateDialog(order.id, 'shipped');
                } else if (order.isShipped) {
                  _showStatusUpdateDialog(order.id, 'completed');
                }
              },
            ),
          );
        },
      ),
    );
  }

  void _showStatusUpdateDialog(String orderId, String newStatus) {
    final statusText = newStatus == 'shipped'
        ? 'ship this order'
        : 'mark this order as completed';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: Text('Are you sure you want to $statusText?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateOrderStatus(orderId, newStatus);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

