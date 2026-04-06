import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CoachAvatarSelector extends StatefulWidget {
  final List<Map<String, dynamic>> coaches; // Receive as prop
  final String selectedAvatarId;
  final Function(Map<String, dynamic>) onAvatarSelected;

  const CoachAvatarSelector({
    super.key,
    required this.coaches,
    required this.selectedAvatarId,
    required this.onAvatarSelected,
  });

  @override
  State<CoachAvatarSelector> createState() => _CoachAvatarSelectorState();
}

class _CoachAvatarSelectorState extends State<CoachAvatarSelector> {
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
                Text(
                  'Choose Your Coach',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: 1.h),

                Text(
                  'Each coach has a unique approach to support your wellness journey',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),

                SizedBox(height: 4.h),

                // Avatar grid
                ...widget.coaches.map((avatar) => _buildAvatarCard(context, avatar)), // Use passed list

                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarCard(BuildContext context, Map<String, dynamic> avatar) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = widget.selectedAvatarId == avatar['id'];

    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onAvatarSelected(avatar);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Avatar image
              Container(
                width: 15.w,
                height: 15.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: CustomImageWidget(
                    imageUrl: avatar['imageUrl'] as String,
                    width: 15.w,
                    height: 15.w,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              SizedBox(width: 4.w),

              // Avatar details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          avatar['name'] as String,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isSelected) ...[
                          SizedBox(width: 2.w),
                          CustomIconWidget(
                            iconName: 'check_circle',
                            color: colorScheme.primary,
                            size: 16,
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: 1.h),

                    Text(
                      avatar['description'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),

                    SizedBox(height: 1.5.h),

                    // Specialties
                    Wrap(
                      spacing: 1.w,
                      runSpacing: 0.5.h,
                      children: (avatar['specialties'] as List<String>)
                          .map((specialty) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary.withValues(alpha: 0.1)
                                : colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.outline.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            specialty,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}