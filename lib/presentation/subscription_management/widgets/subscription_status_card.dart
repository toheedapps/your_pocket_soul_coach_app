import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SubscriptionStatusCard extends StatelessWidget {
  final String subscriptionType;
  final String status;
  final int? daysRemaining;
  final String? nextBillingDate;

  const SubscriptionStatusCard({
    super.key,
    required this.subscriptionType,
    required this.status,
    this.daysRemaining,
    this.nextBillingDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(colorScheme),
          width: 2,
        ),
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(colorScheme).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: _getStatusIcon(),
                      color: _getStatusColor(colorScheme),
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      status,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: _getStatusColor(colorScheme),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (subscriptionType != 'Free Trial' &&
                  subscriptionType != 'Expired')
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    subscriptionType,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            _getMainTitle(),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            _getSubtitle(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          if (daysRemaining != null || nextBillingDate != null) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color:
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'schedule',
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      _getTimingInfo(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF7A9B76); // Success green
      case 'trial':
        return colorScheme.primary;
      case 'expired':
        return const Color(0xFFB85C5C); // Error red
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  String _getStatusIcon() {
    switch (status.toLowerCase()) {
      case 'active':
        return 'check_circle';
      case 'trial':
        return 'access_time';
      case 'expired':
        return 'error';
      default:
        return 'info';
    }
  }

  String _getMainTitle() {
    switch (subscriptionType) {
      case 'Free Trial':
        return 'Free Trial Active';
      case 'Basic':
        return 'Basic Plan';
      case 'Premium':
        return 'Premium Plan';
      case 'Expired':
        return 'Subscription Expired';
      default:
        return 'Current Plan';
    }
  }

  String _getSubtitle() {
    switch (subscriptionType) {
      case 'Free Trial':
        return 'Enjoy full access to all premium features during your trial period.';
      case 'Basic':
        return 'Essential AI coaching and mood tracking features to support your wellness journey.';
      case 'Premium':
        return 'Complete access to all features including advanced analytics and priority support.';
      case 'Expired':
        return 'Your subscription has ended. Upgrade to continue enjoying premium features.';
      default:
        return 'Manage your subscription and billing preferences.';
    }
  }

  String _getTimingInfo() {
    if (daysRemaining != null) {
      return daysRemaining == 1
          ? '1 day remaining in trial'
          : '$daysRemaining days remaining in trial';
    }
    if (nextBillingDate != null) {
      return 'Next billing: $nextBillingDate';
    }
    return '';
  }
}
