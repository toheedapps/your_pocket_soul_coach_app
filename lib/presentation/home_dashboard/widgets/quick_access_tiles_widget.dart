import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class QuickAccessTilesWidget extends StatelessWidget {
  // final VoidCallback onScheduleCoaching;
  final VoidCallback onViewJournalTimeline;
  // final VoidCallback onAccessCrisisResources;

  const QuickAccessTilesWidget({
    super.key,
    // required this.onScheduleCoaching,
    required this.onViewJournalTimeline,
    // required this.onAccessCrisisResources,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            child: Text(
              'Quick Access',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // First Row - Schedule Coaching & Journal Timeline
          Row(
            children: [
              // Expanded(
              //   child: _buildQuickAccessTile(
              //     context,
              //     icon: 'schedule',
              //     title: 'Schedule Session',
              //     subtitle: 'Book coaching time',
              //     color: colorScheme.primary,
              //     onTap: () {
              //       HapticFeedback.lightImpact();
              //       onScheduleCoaching();
              //     },
              //   ),
              // ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildQuickAccessTile(
                  context,
                  icon: 'timeline',
                  title: 'Journal Timeline',
                  subtitle: 'View all entries',
                  color: colorScheme.secondary,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onViewJournalTimeline();
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 3.w),

          // Second Row - Crisis Resources (Full Width)
          // _buildCrisisResourceTile(context),

          SizedBox(height: 3.w),

          // Third Row - Additional Features
          // Row(
          //   children: [
          //     Expanded(
          //       child: _buildQuickAccessTile(
          //         context,
          //         icon: 'insights',
          //         title: 'Analytics',
          //         subtitle: 'Detailed progress',
          //         color: colorScheme.tertiary,
          //         onTap: () {
          //           HapticFeedback.lightImpact();
          //           _showAnalyticsPreview(context);
          //         },
          //       ),
          //     ),
          //     SizedBox(width: 3.w),
          //     Expanded(
          //       child: _buildQuickAccessTile(
          //         context,
          //         icon: 'settings',
          //         title: 'Preferences',
          //         subtitle: 'Customize app',
          //         color: colorScheme.onSurfaceVariant,
          //         onTap: () {
          //           HapticFeedback.lightImpact();
          //           _showPreferences(context);
          //         },
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessTile(
      BuildContext context, {
        required String icon,
        required String title,
        required String subtitle,
        required Color color,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 12.h,
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color.withValues(alpha: 0.8),
                  fontSize: 10.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildCrisisResourceTile(BuildContext context) {
  //   final theme = Theme.of(context);
  //   final colorScheme = theme.colorScheme;
  //   const crisisColor = Color(0xFFB85C5C); // Emergency red
  //
  //   return Material(
  //     color: Colors.transparent,
  //     child: InkWell(
  //       onTap: () {
  //         HapticFeedback.mediumImpact();
  //         // onAccessCrisisResources();
  //       },
  //       borderRadius: BorderRadius.circular(12),
  //       child: Container(
  //         width: double.infinity,
  //         padding: EdgeInsets.all(4.w),
  //         decoration: BoxDecoration(
  //           gradient: LinearGradient(
  //             begin: Alignment.centerLeft,
  //             end: Alignment.centerRight,
  //             colors: [
  //               crisisColor.withValues(alpha: 0.1),
  //               crisisColor.withValues(alpha: 0.05),
  //             ],
  //           ),
  //           borderRadius: BorderRadius.circular(12),
  //           border: Border.all(
  //             color: crisisColor.withValues(alpha: 0.3),
  //             width: 1,
  //           ),
  //         ),
  //         child: Row(
  //           children: [
  //             Container(
  //               padding: EdgeInsets.all(3.w),
  //               decoration: BoxDecoration(
  //                 color: crisisColor.withValues(alpha: 0.2),
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               child: CustomIconWidget(
  //                 iconName: 'emergency',
  //                 color: crisisColor,
  //                 size: 24,
  //               ),
  //             ),
  //             SizedBox(width: 4.w),
  //             // Expanded(
  //             //   child: Column(
  //             //     crossAxisAlignment: CrossAxisAlignment.start,
  //             //     children: [
  //             //       Text(
  //             //         'Crisis Support Resources',
  //             //         style: theme.textTheme.titleSmall?.copyWith(
  //             //           color: crisisColor,
  //             //           fontWeight: FontWeight.w700,
  //             //         ),
  //             //       ),
  //             //       SizedBox(height: 0.5.h),
  //             //       Text(
  //             //         'Immediate help and emergency contacts',
  //             //         style: theme.textTheme.bodySmall?.copyWith(
  //             //           color: crisisColor.withValues(alpha: 0.8),
  //             //         ),
  //             //       ),
  //             //     ],
  //             //   ),
  //             // ),
  //             // Container(
  //             //   padding: EdgeInsets.all(2.w),
  //             //   decoration: BoxDecoration(
  //             //     color: crisisColor.withValues(alpha: 0.2),
  //             //     borderRadius: BorderRadius.circular(8),
  //             //   ),
  //             //   child: CustomIconWidget(
  //             //     iconName: 'arrow_forward',
  //             //     color: crisisColor,
  //             //     size: 16,
  //             //   ),
  //             // ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void _showAnalyticsPreview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
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
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Analytics Preview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            _buildAnalyticsItem(
              context,
              icon: 'trending_up',
              title: 'Mood Trends',
              value: '↗ Improving',
              color: const Color(0xFF7A9B76),
            ),

            _buildAnalyticsItem(
              context,
              icon: 'edit_note',
              title: 'Journal Entries',
              value: '12 this month',
              color: Theme.of(context).colorScheme.secondary,
            ),

            _buildAnalyticsItem(
              context,
              icon: 'chat_bubble',
              title: 'Coach Sessions',
              value: '8 completed',
              color: Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to full analytics
                },
                child: const Text('View Full Analytics'),
              ),
            ),

            // Safe area padding
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsItem(
      BuildContext context, {
        required String icon,
        required String title,
        required String value,
        required Color color,
      }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: icon,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: color,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showPreferences(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
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
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Quick Preferences',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            _buildPreferenceItem(
              context,
              icon: 'notifications',
              title: 'Mood Reminders',
              subtitle: 'Daily check-in notifications',
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // Handle notification toggle
                },
              ),
            ),

            _buildPreferenceItem(
              context,
              icon: 'palette',
              title: 'Communication Style',
              subtitle: 'Standard, AAVE-friendly, Faith-forward',
              trailing: CustomIconWidget(
                iconName: 'arrow_forward_ios',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 16,
              ),
            ),

            _buildPreferenceItem(
              context,
              icon: 'security',
              title: 'Privacy Settings',
              subtitle: 'Data and sharing preferences',
              trailing: CustomIconWidget(
                iconName: 'arrow_forward_ios',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 16,
              ),
            ),

            // Safe area padding
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceItem(
      BuildContext context, {
        required String icon,
        required String title,
        required String subtitle,
        required Widget trailing,
      }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: icon,
          color: colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall,
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: trailing,
      onTap: () {
        HapticFeedback.lightImpact();
        // Handle preference tap
      },
    );
  }
}
