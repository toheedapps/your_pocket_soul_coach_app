import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class UpgradeCards extends StatelessWidget {
  final String currentPlan;
  final VoidCallback? onUpgradeBasic;
  final VoidCallback? onUpgradePremium;

  const UpgradeCards({
    super.key,
    required this.currentPlan,
    this.onUpgradeBasic,
    this.onUpgradePremium,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 2.h),
            child: Text(
              'Choose Your Plan',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ),

          Row(
            children: [
              // Basic Plan Card
              Expanded(
                child: _buildPlanCard(
                  context,
                  title: 'Basic',
                  price: '\$9.99',
                  period: '/m',
                  features: [
                    '50 AI coaching sessions',
                    // 'Advanced mood tracking',
                    'Unlimited journaling',
                    // '3 cultural style packs',
                    'Weekly progress reports',
                  ],
                  buttonText: currentPlan.toLowerCase() == 'basic'
                      ? 'Current Plan'
                      : 'Upgrade to Basic',
                  onTap: currentPlan.toLowerCase() == 'basic'
                      ? null
                      : () {
                    HapticFeedback.lightImpact();
                    onUpgradeBasic?.call();
                  },
                  isCurrentPlan: currentPlan.toLowerCase() == 'basic',
                ),
              ),
              SizedBox(width: 3.w),

              // Premium Plan Card
              Expanded(
                child: _buildPlanCard(
                  context,
                  title: 'Premium',
                  price: '\$29.99',
                  period: '/m',
                  features: [
                    'Unlimited AI coaching',
                    // 'Detailed mood insights',
                    'AI journal feedback',
                    // 'All cultural styles',
                    'Custom affirmations',
                    // 'Priority support',
                  ],
                  buttonText: currentPlan.toLowerCase() == 'premium'
                      ? 'Current Plan'
                      : 'Upgrade to Premium',
                  onTap: currentPlan.toLowerCase() == 'premium'
                      ? null
                      : () {
                    HapticFeedback.lightImpact();
                    onUpgradePremium?.call();
                  },
                  isRecommended: currentPlan.toLowerCase() != 'premium',
                  isCurrentPlan: currentPlan.toLowerCase() == 'premium',
                  gradientColors: [
                    const Color(0xFFD4A574),
                    const Color(0xFFC4956C),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Terms and conditions
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'info_outline',
                      color: colorScheme.onSurfaceVariant,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Subscription Terms',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  '• Auto-renewal can be turned off in your account settings\n'
                      '• Cancel anytime without penalty\n'
                      '• Subscriptions managed through PayPal\n'
                      '• Free trial converts to paid subscription if not cancelled',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
      BuildContext context, {
        required String title,
        required String price,
        required String period,
        required List<String> features,
        required String buttonText,
        VoidCallback? onTap,
        bool isRecommended = false,
        bool isCurrentPlan = false,
        List<Color>? gradientColors,
      }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: isRecommended && gradientColors != null
            ? LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        color: isRecommended && gradientColors == null
            ? colorScheme.primary.withValues(alpha: 0.1)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentPlan
              ? colorScheme.primary
              : isRecommended
              ? Colors.transparent
              : colorScheme.outline.withValues(alpha: 0.2),
          width: isCurrentPlan ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isRecommended) ...[
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: gradientColors != null
                          ? Colors.white.withValues(alpha: 0.2)
                          : colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'RECOMMENDED',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: gradientColors != null
                            ? Colors.white
                            : colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 8.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],

                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: gradientColors != null
                        ? Colors.white
                        : colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 1.h),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: gradientColors != null
                            ? Colors.white
                            : colorScheme.onSurface,
                      ),
                    ),
                    if (period.isNotEmpty) ...[
                      SizedBox(width: 1.w),
                      Padding(
                        padding: EdgeInsets.only(bottom: 0.5.h),
                        child: Text(
                          period,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: gradientColors != null
                                ? Colors.white.withValues(alpha: 0.8)
                                : colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 2.h),

                // Features list
                ...features.take(5).map((feature) => Padding(
                  padding: EdgeInsets.only(bottom: 1.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomIconWidget(
                        iconName: 'check_circle',
                        color: gradientColors != null
                            ? Colors.white.withValues(alpha: 0.9)
                            : const Color(0xFF7A9B76),
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          feature,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: gradientColors != null
                                ? Colors.white.withValues(alpha: 0.9)
                                : colorScheme.onSurface,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),

                SizedBox(height: 2.h),

                // Action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrentPlan
                          ? colorScheme.surfaceContainerHighest
                          : gradientColors != null
                          ? Colors.white
                          : colorScheme.primary,
                      foregroundColor: isCurrentPlan
                          ? colorScheme.onSurfaceVariant
                          : gradientColors != null
                          ? gradientColors.first
                          : colorScheme.onPrimary,
                      elevation: isCurrentPlan ? 0 : 2,
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isCurrentPlan)
            Positioned(
              top: 2.w,
              right: 2.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'ACTIVE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 8.sp,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}