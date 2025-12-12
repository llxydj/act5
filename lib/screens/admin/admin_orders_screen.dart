import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../controllers/order_controller.dart';
import '../../widgets/order_card.dart';
import '../../widgets/loading_widget.dart';

/// Admin Orders Screen - View all orders
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<OrderController>().fetchAllOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('All Orders'),
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
              _buildOrderList(controller.allOrders),
              _buildOrderList(
                controller.allOrders.where((o) => o.isPending).toList(),
              ),
              _buildOrderList(
                controller.allOrders.where((o) => o.isShipped).toList(),
              ),
              _buildOrderList(
                controller.allOrders
                    .where((o) => o.isCompleted || o.isCancelled)
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderList(List orders) {
    if (orders.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.receipt_long_outlined,
        title: 'No Orders',
        subtitle: 'No orders in this category',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<OrderController>().fetchAllOrders();
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
              showSellerInfo: true,
            ),
          );
        },
      ),
    );
  }
}

