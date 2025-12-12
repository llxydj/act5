import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/order_model.dart';
import '../utils/helpers.dart';

/// Order Card Widget
class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;
  final VoidCallback? onStatusUpdate;
  final bool showBuyerInfo;
  final bool showSellerInfo;
  final bool showStatusActions;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onStatusUpdate,
    this.showBuyerInfo = false,
    this.showSellerInfo = false,
    this.showStatusActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Helpers.formatDateTime(order.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(),
              ],
            ),
            const Divider(height: 24),
            // Customer / Seller Info
            if (showBuyerInfo) ...[
              _buildInfoRow(
                icon: Icons.person_outline,
                label: 'Buyer',
                value: order.buyerName,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: order.buyerEmail,
              ),
              const SizedBox(height: 8),
            ],
            if (showSellerInfo) ...[
              _buildInfoRow(
                icon: Icons.store_outlined,
                label: 'Seller',
                value: order.sellerName,
              ),
              const SizedBox(height: 8),
            ],
            if (order.shippingAddress != null) ...[
              _buildInfoRow(
                icon: Icons.location_on_outlined,
                label: 'Address',
                value: order.shippingAddress!,
              ),
              const SizedBox(height: 8),
            ],
            // Order Items Summary
            _buildInfoRow(
              icon: Icons.shopping_bag_outlined,
              label: 'Items',
              value: '${order.itemCount} item(s)',
            ),
            const SizedBox(height: 12),
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  order.formattedTotal,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            // Status Actions
            if (showStatusActions && order.isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showStatusDialog(context, 'cancelled'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        side: const BorderSide(color: AppTheme.errorColor),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showStatusDialog(context, 'shipped'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      child: const Text('Ship Order'),
                    ),
                  ),
                ],
              ),
            ],
            if (showStatusActions && order.isShipped) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showStatusDialog(context, 'completed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                  ),
                  child: const Text('Mark as Completed'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final color = Helpers.getOrderStatusColor(order.status);
    final icon = Helpers.getOrderStatusIcon(order.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            order.statusDisplay,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showStatusDialog(BuildContext context, String newStatus) {
    final statusText = newStatus == 'shipped'
        ? 'ship this order'
        : newStatus == 'completed'
            ? 'mark this order as completed'
            : 'cancel this order';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Action'),
        content: Text('Are you sure you want to $statusText?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onStatusUpdate?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == 'cancelled'
                  ? AppTheme.errorColor
                  : AppTheme.primaryColor,
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}

