import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/custom_icon_widget.dart';




class JournalTimelineSheet extends StatefulWidget {
  final VoidCallback onRefresh;

  const JournalTimelineSheet({super.key, required this.onRefresh});

  @override
  State<JournalTimelineSheet> createState() => _JournalTimelineSheetState();
}

class _JournalTimelineSheetState extends State<JournalTimelineSheet> {
  List<Map<String, dynamic>> _journalEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchJournalEntries();
  }

  Future<void> _fetchJournalEntries() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('journals')
          .orderBy('timestamp', descending: true)
          .get();
      setState(() {
        _journalEntries = snapshot.docs.map((doc) => doc.data()).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching journals: $e')),
        );
      }
    }
  }

  Widget _buildJournalTimelineItem(
      BuildContext context, String timeLabel, String preview, DateTime date) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
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
                iconName: 'edit_note',
                color: colorScheme.secondary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                timeLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            preview,
            style: theme.textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 1.h),
              decoration: BoxDecoration(
                color: colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Text(
              'Journal Timeline',
              style: theme.textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _journalEntries.isEmpty
                ? Center(
              child: Text(
                'No journal entries yet.',
                style: theme.textTheme.bodyMedium,
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              itemCount: _journalEntries.length,
              itemBuilder: (context, index) {
                final journal = _journalEntries[index];
                final date = (journal['timestamp'] as Timestamp).toDate();
                final preview = (journal['text'] as String).length > 100
                    ? '${journal['text'].substring(0, 100)}...'
                    : journal['text'];
                return _buildJournalTimelineItem(
                  context,
                  '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                  preview,
                  date,
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onRefresh();
                    },
                    child: const Text('Refresh'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}