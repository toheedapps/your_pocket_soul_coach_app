import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class BillingHistorySection extends StatelessWidget {
  final List<Map<String, dynamic>> billingHistory;

  const BillingHistorySection({
    super.key,
    required this.billingHistory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (billingHistory.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: 'receipt_long',
              color: colorScheme.onSurfaceVariant,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              'No Billing History',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Your billing history will appear here once you make your first purchase.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'receipt_long',
                  color: colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Billing History',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: billingHistory.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
            itemBuilder: (context, index) {
              final transaction = billingHistory[index];
              return _buildTransactionItem(context, transaction);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
      BuildContext context, Map<String, dynamic> transaction) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final String status = transaction['status'] ?? 'completed';
    final String amount = transaction['amount'] ?? '\$0.00';
    final String date = transaction['date'] ?? '';
    final String plan = transaction['plan'] ?? '';
    final String receiptId = transaction['receiptId'] ?? '';

    return InkWell(
      onTap: () => _showReceiptDetails(context, transaction),
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color:
                _getStatusColor(status, colorScheme).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: _getStatusIcon(status),
                color: _getStatusColor(status, colorScheme),
                size: 20,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      Text(
                        date,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.2.h),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status, colorScheme)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _getStatusColor(status, colorScheme),
                            fontWeight: FontWeight.w600,
                            fontSize: 8.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Receipt',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 1.w),
                    CustomIconWidget(
                      iconName: 'arrow_forward_ios',
                      color: colorScheme.primary,
                      size: 12,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
        return const Color(0xFF7A9B76);
      case 'pending':
        return const Color(0xFFC4956C);
      case 'failed':
      case 'cancelled':
        return const Color(0xFFB85C5C);
      case 'refunded':
        return colorScheme.onSurfaceVariant;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
        return 'check_circle';
      case 'pending':
        return 'schedule';
      case 'failed':
      case 'cancelled':
        return 'error';
      case 'refunded':
        return 'undo';
      default:
        return 'info';
    }
  }

  void _showReceiptDetails(
      BuildContext context, Map<String, dynamic> transaction) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReceiptDetailsSheet(transaction: transaction),
    );
  }
}

class _ReceiptDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const _ReceiptDetailsSheet({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 3.h),

          Row(
            children: [
              CustomIconWidget(
                iconName: 'receipt',
                color: colorScheme.primary,
                size: 28,
              ),
              SizedBox(width: 3.w),
              Text(
                'Receipt Details',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Receipt details
          _buildReceiptRow(context, 'Plan', transaction['plan'] ?? ''),
          _buildReceiptRow(context, 'Amount', transaction['amount'] ?? ''),
          _buildReceiptRow(context, 'Date', transaction['date'] ?? ''),
          _buildReceiptRow(context, 'Status', transaction['status'] ?? ''),
          _buildReceiptRow(
              context, 'Receipt ID', transaction['receiptId'] ?? ''),
          _buildReceiptRow(context, 'Payment Method',
              transaction['paymentMethod'] ?? 'PayPal'),

          SizedBox(height: 3.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _downloadReceipt(context),
                  icon: CustomIconWidget(
                    iconName: 'download',
                    color: colorScheme.primary,
                    size: 18,
                  ),
                  label: const Text('Download'),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _shareReceipt(context),
                  icon: CustomIconWidget(
                    iconName: 'share',
                    color: colorScheme.onPrimary,
                    size: 18,
                  ),
                  label: const Text('Share'),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Close button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ),

          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25.w,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _downloadReceipt(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Receipt downloaded to your device'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _shareReceipt(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Receipt shared successfully'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
