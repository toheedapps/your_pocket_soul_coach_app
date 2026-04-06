import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CrisisDetectionModal extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback? onCallHotline;
  final VoidCallback? onSafetyPlan;

  const CrisisDetectionModal({
    super.key,
    required this.onClose,
    this.onCallHotline,
    this.onSafetyPlan,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(6.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Crisis icon and title
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: colorScheme.error.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName: 'favorite',
                        color: colorScheme.error,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        'We\'re Here for You',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 3.h),

                Text(
                  'It sounds like you might be going through a difficult time. Your wellbeing matters, and there are people who want to help.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 4.h),

                // Emergency hotline card
                _buildResourceCard(
                  context,
                  icon: 'phone',
                  title: '988 Suicide & Crisis Lifeline',
                  subtitle: 'Free, confidential support 24/7',
                  buttonText: 'Call Now',
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onCallHotline?.call();
                  },
                  isEmergency: true,
                ),

                SizedBox(height: 2.h),

                // Safety plan card
                _buildResourceCard(
                  context,
                  icon: 'security',
                  title: 'Create Safety Plan',
                  subtitle: 'Build coping strategies for difficult moments',
                  buttonText: 'Get Started',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onSafetyPlan?.call();
                  },
                ),

                SizedBox(height: 4.h),

                // Additional resources
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Other Resources',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      _buildResourceLink(
                          'Crisis Text Line: Text HOME to 741741'),
                      _buildResourceLink(
                          'National Domestic Violence Hotline: 1-800-799-7233'),
                      _buildResourceLink(
                          'SAMHSA National Helpline: 1-800-662-4357'),
                    ],
                  ),
                ),

                SizedBox(height: 4.h),

                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onClose();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.surface,
                      foregroundColor: colorScheme.onSurface,
                      side: BorderSide(color: colorScheme.outline),
                    ),
                    child: const Text('Continue Conversation'),
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(
      BuildContext context, {
        required String icon,
        required String title,
        required String subtitle,
        required String buttonText,
        required VoidCallback onTap,
        bool isEmergency = false,
      }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isEmergency
            ? colorScheme.error.withValues(alpha: 0.05)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEmergency
              ? colorScheme.error.withValues(alpha: 0.3)
              : colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: isEmergency
                  ? colorScheme.error.withValues(alpha: 0.1)
                  : colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: icon,
              color: isEmergency ? colorScheme.error : colorScheme.primary,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor:
              isEmergency ? colorScheme.error : colorScheme.primary,
              foregroundColor:
              isEmergency ? colorScheme.onError : colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            ),
            child: Text(
              buttonText,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceLink(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        children: [
          Builder(
            builder: (BuildContext context) => CustomIconWidget(
              iconName: 'circle',
              color: Theme.of(context).colorScheme.primary,
              size: 6,
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Builder(
              builder: (BuildContext context) => Text(
                text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}