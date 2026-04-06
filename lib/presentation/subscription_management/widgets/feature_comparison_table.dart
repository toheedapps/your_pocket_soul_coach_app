import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class FeatureComparisonTable extends StatelessWidget {
  final String currentPlan;

  const FeatureComparisonTable({
    super.key,
    required this.currentPlan,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final List<Map<String, dynamic>> features = [
      {
        'feature': 'AI Coaching Sessions',
        'free': '5 per month',
        'basic': '50 per month',
        'premium': 'Unlimited',
        'icon': 'chat_bubble_outline',
      },
      {
        'feature': 'Mood Tracking',
        'free': 'Basic tracking',
        'basic': 'Advanced analytics',
        'premium': 'Detailed insights',
        'icon': 'favorite_outline',
      },
      {
        'feature': 'Journal Entries',
        'free': '10 per month',
        'basic': 'Unlimited',
        'premium': 'Unlimited + AI feedback',
        'icon': 'book_outlined',
      },
      {
        'feature': 'Daily Affirmations',
        'free': 'Standard',
        'basic': 'Personalized',
        'premium': 'Custom + Voice',
        'icon': 'self_improvement',
      },
      // {
      //   'feature': 'Crisis Support',
      //   'free': 'Basic resources',
      //   'basic': 'Enhanced support',
      //   'premium': 'Priority assistance',
      //   'icon': 'support_agent',
      // },
      // {
      //   'feature': 'Cultural Style Packs',
      //   'free': '1 style',
      //   'basic': '3 styles',
      //   'premium': 'All styles',
      //   'icon': 'palette',
      // },
      {
        'feature': 'Progress Reports',
        'free': 'Weekly',
        'basic': 'Weekly + Monthly',
        'premium': 'Custom frequency',
        'icon': 'trending_up',
      },
      // {
      //   'feature': 'Coach Avatars',
      //   'free': '2 avatars',
      //   'basic': '5 avatars',
      //   'premium': 'All avatars',
      //   'icon': 'face',
      // },
    ];

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
            child: Text(
              'Feature Comparison',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ),

          // Header row
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Features',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Free',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Basic',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Premium',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFD4A574),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Feature rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: features.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
            itemBuilder: (context, index) {
              final feature = features[index];
              return _buildFeatureRow(context, feature);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, Map<String, dynamic> feature) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: feature['icon'],
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    feature['feature'],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildFeatureValue(
              context,
              feature['free'],
              'free',
            ),
          ),
          Expanded(
            child: _buildFeatureValue(
              context,
              feature['basic'],
              'basic',
            ),
          ),
          Expanded(
            child: _buildFeatureValue(
              context,
              feature['premium'],
              'premium',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureValue(BuildContext context, String value, String plan) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCurrentPlan = currentPlan.toLowerCase() == plan;
    final isPremiumFeature = value.contains('Unlimited') ||
        value.contains('All') ||
        value.contains('Custom');

    Color textColor = colorScheme.onSurfaceVariant;
    FontWeight fontWeight = FontWeight.w400;

    if (plan == 'premium' && isPremiumFeature) {
      textColor = const Color(0xFFD4A574);
      fontWeight = FontWeight.w600;
    } else if (plan == 'basic' &&
        (value.contains('Advanced') || value.contains('Enhanced'))) {
      textColor = colorScheme.primary;
      fontWeight = FontWeight.w500;
    }

    if (isCurrentPlan) {
      fontWeight = FontWeight.w600;
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: fontWeight,
              fontSize: 11.sp,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (isCurrentPlan) ...[
            SizedBox(height: 0.5.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.2.h),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Current',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 8.sp,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
