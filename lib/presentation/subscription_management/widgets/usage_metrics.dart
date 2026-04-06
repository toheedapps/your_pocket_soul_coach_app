// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../../core/app_export.dart';
// import '../../../widgets/custom_icon_widget.dart';
//
// class UsageMetricsCard extends StatelessWidget {
//   final String currentPlan;
//   final Map<String, dynamic> usageData;
//
//   const UsageMetricsCard({
//     super.key,
//     required this.currentPlan,
//     required this.usageData,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//
//     return Container(
//       width: double.infinity,
//       margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
//       padding: EdgeInsets.all(4.w),
//       decoration: BoxDecoration(
//         color: colorScheme.surface,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: colorScheme.shadow.withValues(alpha: 0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               CustomIconWidget(
//                 iconName: 'analytics',
//                 color: colorScheme.primary,
//                 size: 24,
//               ),
//               SizedBox(width: 3.w),
//               Text(
//                 'This Month\'s Usage',
//                 style: theme.textTheme.headlineSmall?.copyWith(
//                   fontWeight: FontWeight.w700,
//                   color: colorScheme.onSurface,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 3.h),
//
//           // AI Coaching Sessions (uncommented and improved)
//           _buildUsageMetric(
//             context,
//             icon: 'chat_bubble_outline',
//             title: 'AI Coaching Sessions',
//             current: usageData['aiSessions'] ?? 0,
//             // limit: _getLimit('aiSessions'),
//             color: colorScheme.primary,
//           ),
//           SizedBox(height: 3.h), // Improved spacing
//
//           // Journal Entries
//           _buildUsageMetric(
//             context,
//             icon: 'book_outlined',
//             title: 'Journal Entries',
//             current: usageData['journalEntries'] ?? 0,
//             // limit: _getLimit('journalEntries'),
//             color: const Color(0xFF7A9B76),
//           ),
//           SizedBox(height: 3.h), // Improved spacing
//
//           // Mood Check-ins
//           _buildUsageMetric(
//             context,
//             icon: 'favorite_outline',
//             title: 'Mood Check-ins',
//             current: usageData['moodCheckins'] ?? 0,
//             // limit: _getLimit('moodCheckins'),
//             color: const Color(0xFFD4A574),
//           ),
//
//           // if (_shouldShowUpgradePrompt()) ...[
//           //   SizedBox(height: 3.h),
//           //   Container(
//           //     padding: EdgeInsets.all(3.w),
//           //     decoration: BoxDecoration(
//           //       gradient: LinearGradient(
//           //         colors: [
//           //           colorScheme.primary.withValues(alpha: 0.1),
//           //           const Color(0xFFD4A574).withValues(alpha: 0.1),
//           //         ],
//           //         begin: Alignment.topLeft,
//           //         end: Alignment.bottomRight,
//           //       ),
//           //       borderRadius: BorderRadius.circular(12),
//           //       border: Border.all(
//           //         color: colorScheme.primary.withValues(alpha: 0.3),
//           //       ),
//           //     ),
//           //     child: Column(
//           //       crossAxisAlignment: CrossAxisAlignment.start,
//           //       children: [
//           //         Row(
//           //           children: [
//           //             CustomIconWidget(
//           //               iconName: 'trending_up',
//           //               color: colorScheme.primary,
//           //               size: 20,
//           //             ),
//           //             SizedBox(width: 2.w),
//           //             Text(
//           //               'Unlock More Features',
//           //               style: theme.textTheme.titleMedium?.copyWith(
//           //                 fontWeight: FontWeight.w600,
//           //                 color: colorScheme.onSurface,
//           //               ),
//           //             ),
//           //           ],
//           //         ),
//           //         SizedBox(height: 1.h),
//           //         Text(
//           //           'Upgrade to Premium for unlimited access to all features and advanced analytics.',
//           //           style: theme.textTheme.bodyMedium?.copyWith(
//           //             color: colorScheme.onSurfaceVariant,
//           //             height: 1.4,
//           //           ),
//           //         ),
//           //         SizedBox(height: 2.h),
//           //         SizedBox(
//           //           width: double.infinity,
//           //           child: ElevatedButton(
//           //             onPressed: () {
//           //               // Navigate to Plans tab for upgrade
//           //               DefaultTabController.of(context).animateTo(1); // Index 1 is Plans
//           //             },
//           //             style: ElevatedButton.styleFrom(
//           //               backgroundColor: colorScheme.primary,
//           //               foregroundColor: colorScheme.onPrimary,
//           //               padding: EdgeInsets.symmetric(vertical: 1.5.h),
//           //               shape: RoundedRectangleBorder(
//           //                 borderRadius: BorderRadius.circular(12),
//           //               ),
//           //             ),
//           //             child: Text(
//           //               'Upgrade Now',
//           //               style: theme.textTheme.labelLarge?.copyWith(
//           //                 fontWeight: FontWeight.w600,
//           //               ),
//           //             ),
//           //           ),
//           //         ),
//           //       ],
//           //     ),
//           //   ),
//           // ],
//
//
//         ],
//       ),
//     );
//   }
//
//   Widget _buildUsageMetric(
//       BuildContext context, {
//         required String icon,
//         required String title,
//         required int current,
//         // required dynamic limit,
//         required Color color,
//       }) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//
//     // final bool isUnlimited = limit == 'Unlimited';
//     // final double progress =
//     // isUnlimited ? 1.0 : (current / (limit as int)).clamp(0.0, 1.0);
//     // final bool isNearLimit = !isUnlimited && progress > 0.8;
//
//     // return Column(
//     //   crossAxisAlignment: CrossAxisAlignment.start,
//     //   children: [
//     //     Row(
//     //       children: [
//     //         CustomIconWidget(
//     //           iconName: icon,
//     //           color: color,
//     //           size: 20,
//     //         ),
//     //         SizedBox(width: 3.w),
//     //         Expanded(
//     //           child: Text(
//     //             title,
//     //             style: theme.textTheme.titleMedium?.copyWith(
//     //               fontWeight: FontWeight.w600,
//     //               color: colorScheme.onSurface,
//     //             ),
//     //           ),
//     //         ),
//     //         Container(
//     //           padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
//     //           decoration: BoxDecoration(
//     //             color: isNearLimit
//     //                 ? const Color(0xFFB85C5C).withValues(alpha: 0.1)
//     //                 : color.withValues(alpha: 0.1),
//     //             borderRadius: BorderRadius.circular(12),
//     //           ),
//     //           child: Text(
//     //             isUnlimited ? 'Unlimited' : '$current / $limit',
//     //             style: theme.textTheme.labelMedium?.copyWith(
//     //               color: isNearLimit ? const Color(0xFFB85C5C) : color,
//     //               fontWeight: FontWeight.w600,
//     //             ),
//     //           ),
//     //         ),
//     //       ],
//     //     ),
//     //     SizedBox(height: 1.h),
//     //     if (!isUnlimited) ...[
//     //       Stack(
//     //         children: [
//     //           Container(
//     //             height: 8,
//     //             decoration: BoxDecoration(
//     //               color: color.withValues(alpha: 0.2),
//     //               borderRadius: BorderRadius.circular(4),
//     //             ),
//     //           ),
//     //           FractionallySizedBox(
//     //             widthFactor: progress,
//     //             child: Container(
//     //               height: 8,
//     //               decoration: BoxDecoration(
//     //                 color: isNearLimit ? const Color(0xFFB85C5C) : color,
//     //                 borderRadius: BorderRadius.circular(4),
//     //               ),
//     //             ),
//     //           ),
//     //         ],
//     //       ),
//     //       SizedBox(height: 0.5.h),
//     //       if (isNearLimit)
//     //         Text(
//     //           'Approaching limit - consider upgrading',
//     //           style: theme.textTheme.bodySmall?.copyWith(
//     //             color: const Color(0xFFB85C5C),
//     //             fontWeight: FontWeight.w500,
//     //           ),
//     //         ),
//     //     ] else ...[
//     //       Container(
//     //         height: 8,
//     //         decoration: BoxDecoration(
//     //           color: color,
//     //           borderRadius: BorderRadius.circular(4),
//     //         ),
//     //       ),
//     //       SizedBox(height: 0.5.h),
//     //       Text(
//     //         'No limits on this feature',
//     //         style: theme.textTheme.bodySmall?.copyWith(
//     //           color: color,
//     //           fontWeight: FontWeight.w500,
//     //         ),
//     //       ),
//     //     ],
//     //   ],
//     // );
//   }
//
//   // dynamic _getLimit(String metric) {
//   //   switch (currentPlan.toLowerCase()) {
//   //     case 'free_trial':
//   //     case 'expired':
//   //       switch (metric) {
//   //         case 'aiSessions':
//   //           return 5;
//   //         case 'journalEntries':
//   //           return 10;
//   //         case 'moodCheckins':
//   //           return 'Unlimited';
//   //         default:
//   //           return 0;
//   //       }
//   //     case 'basic':
//   //       switch (metric) {
//   //         case 'aiSessions':
//   //           return 50;
//   //         case 'journalEntries':
//   //           return 'Unlimited';
//   //         case 'moodCheckins':
//   //           return 'Unlimited';
//   //         default:
//   //           return 0;
//   //       }
//   //     case 'premium':
//   //       return 'Unlimited';
//   //     default:
//   //       return 0;
//   //   }
//   // }
//
//   // bool _shouldShowUpgradePrompt() {
//   //   if (currentPlan.toLowerCase() == 'premium') return false;
//   //   final aiSessions = usageData['aiSessions'] ?? 0;
//   //   final journalEntries = usageData['journalEntries'] ?? 0;
//   //
//   //   switch (currentPlan.toLowerCase()) {
//   //     case 'free_trial':
//   //     case 'expired':
//   //       return aiSessions >= 4 || journalEntries >= 8; // Near limits
//   //     case 'basic':
//   //       return aiSessions >= 40; // Near AI session limit
//   //     default:
//   //       return true;
//   //   }
//   // }
// }