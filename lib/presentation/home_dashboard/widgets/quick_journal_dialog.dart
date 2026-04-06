import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../services/firestore_service.dart';

class QuickJournalDialog extends StatefulWidget {
  const QuickJournalDialog({super.key});

  @override
  State<QuickJournalDialog> createState() => _QuickJournalDialogState();
}

class _QuickJournalDialogState extends State<QuickJournalDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Quick Journal Entry',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'What\'s on your mind right now?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Start writing...',
                border: OutlineInputBorder(),
              ),
              minLines: 5,
              maxLines: 10,
              maxLength: 500,
              autofocus: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final text = _controller.text.trim();
            if (text.isNotEmpty) {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                try {
                  await FirestoreService().logJournal(user.uid, text);
                  Navigator.pop(context, true);
                } catch (e) {
                  // Handle save error (e.g., show a local error message if needed)
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error saving journal: $e')),
                    );
                  }
                  Navigator.pop(context, false);
                }
              } else {
                Navigator.pop(context, false);
              }
            } else {
              Navigator.pop(context, false);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}