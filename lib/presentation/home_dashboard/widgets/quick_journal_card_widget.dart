import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:yspc/presentation/home_dashboard/widgets/quick_journal_dialog.dart';

import '../../../core/app_export.dart';
import '../../../services/firestore_service.dart';
import '../../../widgets/custom_icon_widget.dart';
 // Replace with actual path

class QuickJournalCardWidget extends StatelessWidget {
  final VoidCallback onTap;
  final String? lastEntryPreview;
  final DateTime? lastEntryDate;
  final VoidCallback? onSave;

  const QuickJournalCardWidget({
    super.key,
    required this.onTap,
    this.lastEntryPreview,
    this.lastEntryDate,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.secondary.withValues(alpha: 0.3),
                width: 1,
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
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CustomIconWidget(
                        iconName: 'edit_note',
                        color: colorScheme.secondary,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Journal',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Capture your thoughts',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CustomIconWidget(
                      iconName: 'arrow_forward_ios',
                      color: colorScheme.secondary,
                      size: 16,
                    ),
                  ],
                ),

                SizedBox(height: 3.h),

                // Last entry preview or prompt
                if (lastEntryPreview != null &&
                    lastEntryPreview!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Last entry:',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            if (lastEntryDate != null)
                              Text(
                                _formatDate(lastEntryDate!),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          lastEntryPreview!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding:
                    EdgeInsets.symmetric(vertical: 4.h, horizontal: 3.w),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.secondary.withValues(alpha: 0.2),
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        CustomIconWidget(
                          iconName: 'auto_stories',
                          color: colorScheme.secondary,
                          size: 32,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Start your first journal entry',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Express your thoughts and feelings in a safe space',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 2.h),

                // Quick actions
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickAction(
                        context,
                        icon: 'add',
                        label: 'New Entry',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showQuickJournalDialog(context);
                        },
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: _buildQuickAction(
                        context,
                        icon: 'timeline',
                        label: 'View All',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onTap();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(
      BuildContext context, {
        required String icon,
        required String label,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: icon,
                color: colorScheme.onSurfaceVariant,
                size: 16,
              ),
              SizedBox(width: 2.w),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  void _showQuickJournalDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => const QuickJournalDialog(),
    ).then((saved) {
      if (saved == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Journal entry saved!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        onSave?.call();
      }
    });
  }



}