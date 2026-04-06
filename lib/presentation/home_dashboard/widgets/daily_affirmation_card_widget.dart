import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/app_export.dart';
import '../../../services/firestore_service.dart';
import '../../../widgets/custom_icon_widget.dart';

class DailyAffirmationCardWidget extends StatelessWidget {
  final String affirmationText;
  final String category;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onGetNew;

  const DailyAffirmationCardWidget({
    super.key,
    required this.affirmationText,
    required this.category,
    required this.onCopy,
    required this.onShare,
    required this.onGetNew,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.tertiary.withValues(alpha: 0.1),
            colorScheme.tertiary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.tertiary.withValues(alpha: 0.2),
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
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomIconWidget(
                    iconName: 'auto_awesome',
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
                        'Daily Affirmation',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        category,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.tertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildActionButton(
                  context,
                  icon: 'more_vert',
                  onTap: () => _showAffirmationOptions(context),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  CustomIconWidget(
                    iconName: 'format_quote',
                    color: colorScheme.tertiary.withValues(alpha: 0.6),
                    size: 32,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    affirmationText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 2.h),
                  Transform.rotate(
                    angle: 3.14159,
                    child: CustomIconWidget(
                      iconName: 'format_quote',
                      color: colorScheme.tertiary.withValues(alpha: 0.6),
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: 'content_copy',
                    label: 'Copy',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onCopy();
                    },
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildActionButton(
                    context,
                    icon: 'share',
                    label: 'Share',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onShare();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required String icon,
        String? label,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 278.0), // Fix unbounded width
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: label != null ? 2.h : 1.h,
              horizontal: 3.w,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: label != null
                ? Row(
              mainAxisSize: MainAxisSize.min, // Shrink-wrap the Row
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: icon,
                  color: colorScheme.tertiary,
                  size: 16,
                ),
                SizedBox(width: 7.2), // Match logs
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.tertiary,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter_regular',
                      fontSize: 12.0,
                      letterSpacing: 0.4,
                      height: 1.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
                : CustomIconWidget(
              iconName: icon,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  void _showAffirmationOptions(BuildContext context) {
    String? selectedCategory = category;
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
              'Affirmation Options',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedCategory,
              items: ['General'].map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedCategory = value;
                  onGetNew();
                }
              },
            ),
            const SizedBox(height: 16),
            _buildOptionTile(
              context,
              icon: 'refresh',
              title: 'Get New Affirmation',
              subtitle: 'Refresh with a different message',
              onTap: () {
                Navigator.pop(context);
                onGetNew();
              },
            ),
            _buildOptionTile(
              context,
              icon: 'history',
              title: 'View Previous',
              subtitle: 'See your past affirmations',
              onTap: () {
                Navigator.pop(context);
                _showAffirmationHistory(context);
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  void _showAffirmationHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              'Previous Affirmations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: FirestoreService().getAffirmationHistory(
                  FirebaseAuth.instance.currentUser?.uid ?? '',
                ),
                builder: (context, snapshot) {
                  print('FutureBuilder state: ${snapshot.connectionState}');
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    print('FutureBuilder error: ${snapshot.error}');
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    print('No affirmation history found');
                    return const Center(child: Text('No previous affirmations found.'));
                  }
                  final affirmations = snapshot.data!;
                  print('Affirmation history: $affirmations');
                  return ListView.builder(
                    itemCount: affirmations.length,
                    itemBuilder: (context, index) {
                      final affirmation = affirmations[index];
                      return _buildAffirmationHistoryItem(
                        context,
                        affirmation['text'] ?? '',
                        affirmation['category'] ?? '',
                        affirmation['date'] ?? '',
                        affirmation['timestamp'] as DateTime? ?? DateTime.now(),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildAffirmationHistoryItem(
      BuildContext context,
      String text,
      String category,
      String date,
      DateTime timestamp,
      ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'history',
                color: colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                date,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                category,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: theme.textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionButton(
                context,
                icon: 'content_copy',
                label: 'Copy',
                onTap: () {
                  HapticFeedback.lightImpact();
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Affirmation copied to clipboard!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                context,
                icon: 'share',
                label: 'Share',
                onTap: () {
                  HapticFeedback.lightImpact();
                  Share.share(text);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
      BuildContext context, {
        required String icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.tertiary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: icon,
          color: colorScheme.tertiary,
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
      trailing: CustomIconWidget(
        iconName: 'arrow_forward_ios',
        color: colorScheme.onSurfaceVariant,
        size: 16,
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }
}