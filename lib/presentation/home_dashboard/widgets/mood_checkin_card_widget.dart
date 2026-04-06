import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/firestore_service.dart';
import '../../../widgets/custom_icon_widget.dart';

class MoodCheckinCardWidget extends StatefulWidget {
  final bool hasTodayMood;
  final String? todayMoodEmoji;
  final String? todayMoodNote;
  final VoidCallback onMoodTap;

  const MoodCheckinCardWidget({
    super.key,
    required this.hasTodayMood,
    this.todayMoodEmoji,
    this.todayMoodNote,
    required this.onMoodTap,
  });

  @override
  State<MoodCheckinCardWidget> createState() => _MoodCheckinCardWidgetState();
}

class _MoodCheckinCardWidgetState extends State<MoodCheckinCardWidget> {
  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😢', 'label': 'Very Sad', 'value': 1, 'color': Color(0xFFB85C5C)},
    {'emoji': '😔', 'label': 'Sad', 'value': 2, 'color': Color(0xFFC4956C)},
    {'emoji': '😐', 'label': 'Neutral', 'value': 3, 'color': Color(0xFF8B7355)},
    {'emoji': '😊', 'label': 'Happy', 'value': 4, 'color': Color(0xFF7A9B76)},
    {'emoji': '😄', 'label': 'Very Happy', 'value': 5, 'color': Color(0xFF7A9B76)},
  ];

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
            if (!widget.hasTodayMood) {
              _showMoodSelector(context);
            } else {
              widget.onMoodTap();
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.hasTodayMood
                    ? colorScheme.tertiary.withValues(alpha: 0.3)
                    : colorScheme.primary.withValues(alpha: 0.3),
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
            child: widget.hasTodayMood
                ? _buildCompletedMood()
                : _buildPendingMood(),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingMood() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: 'mood',
                color: colorScheme.primary,
                size: 24,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Mood Check-in',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'How is your heart today?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: colorScheme.primary,
              size: 16,
            ),
          ],
        ),
        SizedBox(height: 3.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          alignment: WrapAlignment.center,
          children: _moods.map((mood) => _buildQuickMoodOption(mood)).toList(),
        ),
      ],
    );
  }

  Widget _buildCompletedMood() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: colorScheme.tertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: 'check_circle',
                color: colorScheme.tertiary,
                size: 24,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Mood',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Logged successfully',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              widget.todayMoodEmoji ?? '😊',
              style: const TextStyle(fontSize: 32),
            ),
          ],
        ),
        if (widget.todayMoodNote != null && widget.todayMoodNote!.isNotEmpty) ...[
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.todayMoodNote!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuickMoodOption(Map<String, dynamic> mood) {
    return Container(
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            mood['emoji'],
            style: TextStyle(fontSize: 18.sp), // Reduced from 20.sp
          ),
          SizedBox(height: 1.h),
          Text(
            mood['label'],
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showMoodSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MoodSelectorSheet(
        moods: _moods,
        onMoodSelected: _selectMood,
      ),
    );
  }

  void _selectMood(Map<String, dynamic> mood) async {
    HapticFeedback.mediumImpact();
    if (mounted) {
      Navigator.pop(context);
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to save mood.')),
        );
      }
      return;
    }

    final userId = user.uid;

    try {
      await FirestoreService().logMood(userId, mood);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Mood logged! You\'re feeling ${mood['label'].toLowerCase()}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }

      widget.onMoodTap();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging mood: $e')),
        );
      }
    }
  }
}

class _MoodSelectorSheet extends StatefulWidget {
  final List<Map<String, dynamic>> moods;
  final Function(Map<String, dynamic>) onMoodSelected;

  const _MoodSelectorSheet({
    required this.moods,
    required this.onMoodSelected,
  });

  @override
  State<_MoodSelectorSheet> createState() => _MoodSelectorSheetState();
}

class _MoodSelectorSheetState extends State<_MoodSelectorSheet> {
  int? selectedMood;
  final TextEditingController _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16, // **CHANGED**
      ), // Reduced from 24
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 20.w,
                height: 2.h,
                decoration: BoxDecoration(
                  color: colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16), // Reduced from 24
            Text(
              'How is your heart today?',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Take a moment to check in with yourself',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16), // Reduced from 32
            Wrap(
              spacing: 1.w, // Reduced from 2.w
              runSpacing: 1.h, // Reduced from 2.h
              alignment: WrapAlignment.center,
              children: widget.moods.map((mood) => _buildMoodOption(mood)).toList(),
            ),
            const SizedBox(height: 16), // Reduced from 24
            TextField(
              textInputAction: TextInputAction.done,
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Add a note (optional)',
                hintText: 'What\'s on your mind?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
              maxLength: 200,
            ),
            const SizedBox(height: 16), // Reduced from 24
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedMood != null ? _saveMood : null,
                child: const Text('Save Mood'),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodOption(Map<String, dynamic> mood) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = selectedMood == mood['value'];

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          selectedMood = mood['value'];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8), // Reduced from 12
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12), // Reduced from 16
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mood['emoji'],
              style: const TextStyle(fontSize: 24), // Reduced from 32
            ),
            const SizedBox(height: 6), // Reduced from 8
            Text(
              mood['label'],
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                fontSize: 10, // Reduced size for better fit
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _saveMood() {
    final selectedMoodData = widget.moods.firstWhere(
          (mood) => mood['value'] == selectedMood,
    );

    if (_noteController.text.isNotEmpty) {
      selectedMoodData['note'] = _noteController.text;
    }

    widget.onMoodSelected(selectedMoodData);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}