import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:yspc/presentation/home_dashboard/widgets/journal_timeline_sheet.dart';

import '../../core/app_export.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/chat_coach_card_widget.dart';
import './widgets/daily_affirmation_card_widget.dart';
import './widgets/greeting_card_widget.dart';
import './widgets/mood_checkin_card_widget.dart';
import './widgets/progress_overview_card_widget.dart';
import './widgets/quick_access_tiles_widget.dart';
import './widgets/quick_journal_card_widget.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;
  bool _isOffline = false;
  bool _isFetchingAffirmation = false;
  bool _isLoading = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  StreamSubscription<User?>? _authSubscription;

  Map<String, dynamic> _userData = {};

  String _lastConversationPreview = '';
  DateTime? _lastChatTime;
  bool _hasTodayMood = false;
  String? _todayMoodEmoji;
  String? _todayMoodNote;
  DateTime? _todayMoodTimestamp;
  List<Map<String, dynamic>> _weeklyMoodData = [];
  String? _lastJournalEntry;
  DateTime? _lastJournalDate;

  String _dailyAffirmation = "I am strong and capable of overcoming any challenge.";
  String _affirmationCategory = "General";

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      ConnectivityResult result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      final wasOffline = _isOffline;
      _isOffline = result == ConnectivityResult.none;
      if (wasOffline && !_isOffline) {
        setState(() => _isLoading = true);
        _fetchDashboardData().then((_) {
          if (mounted) setState(() => _isLoading = false);
        });
      }
      setState(() {});
    });
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user == null && mounted) {
        Navigator.pushReplacementNamed(context, '/authentication-screen');
      } else {
        setState(() => _isLoading = true);
        _fetchDashboardData().then((_) {
          if (mounted) setState(() => _isLoading = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _authSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final List<ConnectivityResult> connectivityResults = await Connectivity().checkConnectivity();
    final ConnectivityResult result = connectivityResults.isNotEmpty ? connectivityResults.first : ConnectivityResult.none;
    setState(() => _isOffline = result == ConnectivityResult.none);
  }

  Future<void> _fetchDashboardData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userId = user.uid;
    final email = user.email ?? '';
    final name = user.displayName;

    Map<String, dynamic> localUserData = {
      "name": "Guest",
      "coachName": "null",
      "coachAvatarUrl": "https://images.unsplash.com/photo-1728577740843-5f29c7586afe?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=580",
      "moodStreak": 0,
      "subscriptionTier": "free",
    };
    String localLastConversationPreview = '';
    DateTime? localLastChatTime;
    bool localHasTodayMood = false;
    String? localTodayMoodEmoji;
    String? localTodayMoodNote;
    DateTime? localTodayMoodTimestamp;
    List<Map<String, dynamic>> localWeeklyMoodData = [];
    String? localLastJournalEntry;
    DateTime? localLastJournalDate;

    try {
      final profile = await FirestoreService().getUserProfile(userId);
      if (profile != null) {
        localUserData = profile;
        localUserData['name'] ??= name ?? 'User';
        localUserData['coachName'] ??= 'Maya';
        localUserData['coachAvatarUrl'] ??= "https://images.unsplash.com/photo-1728577740843-5f29c7586afe?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=580";
        localUserData['moodStreak'] ??= 0;
        localUserData['subscriptionTier'] ??= 'free';
      } else {
        await FirestoreService().createUserProfile(
          uid: userId,
          email: email,
          name: name,
        );
        final newProfile = await FirestoreService().getUserProfile(userId);
        localUserData = newProfile ?? localUserData;
      }

      final history = await FirestoreService().getChatHistory(userId);
      if (history.isNotEmpty) {
        final lastMsg = history.last;
        localLastConversationPreview = (lastMsg['message'] as String).substring(0, 100.clamp(0, (lastMsg['message'] as String).length)) + ((lastMsg['message'] as String).length > 100 ? '...' : '');
        localLastChatTime = (lastMsg['timestamp'] as Timestamp?)?.toDate();
      } else {
        localLastConversationPreview = '';
        localLastChatTime = null;
      }

      final weeklyMoods = await FirestoreService().getWeeklyMoods(userId);
      localWeeklyMoodData = weeklyMoods.map((mood) {
        final date = (mood['timestamp'] as Timestamp).toDate();
        return {
          'day': _getDayName(date.weekday),
          'value': mood['value'],
          'emoji': mood['emoji'],
          'date': date,
          'note': mood['note'],
        };
      }).toList();

      final todayMood = await FirestoreService().getTodayMood(userId);
      if (todayMood != null) {
        localHasTodayMood = true;
        localTodayMoodEmoji = todayMood['emoji'];
        localTodayMoodNote = todayMood['note'];
        localTodayMoodTimestamp = (todayMood['timestamp'] as Timestamp).toDate();
      } else {
        localHasTodayMood = false;
        localTodayMoodEmoji = null;
        localTodayMoodNote = null;
        localTodayMoodTimestamp = null;
      }

      final lastJournal = await FirestoreService().getLastJournal(userId);
      if (lastJournal != null) {
        localLastJournalEntry = (lastJournal['text'] as String).substring(0, 100.clamp(0, (lastJournal['text'] as String).length)) + ((lastJournal['text'] as String).length > 100 ? '...' : '');
        localLastJournalDate = (lastJournal['timestamp'] as Timestamp).toDate();
      } else {
        localLastJournalEntry = null;
        localLastJournalDate = null;
      }

      localUserData['moodStreak'] = await FirestoreService().calculateMoodStreak(userId);
      if (localUserData['moodStreak'] != profile?['moodStreak']) {
        await FirestoreService().updateUserField(userId, 'moodStreak', localUserData['moodStreak']);
      }

      final affirmationMap = await _fetchDailyAffirmation();
      _dailyAffirmation = affirmationMap['text'] ?? _dailyAffirmation;
      _affirmationCategory = affirmationMap['category'] ?? _affirmationCategory;

      if (mounted) {
        setState(() {
          _userData = localUserData;
          _lastConversationPreview = localLastConversationPreview;
          _lastChatTime = localLastChatTime;
          _hasTodayMood = localHasTodayMood;
          _todayMoodEmoji = localTodayMoodEmoji;
          _todayMoodNote = localTodayMoodNote;
          _todayMoodTimestamp = localTodayMoodTimestamp;
          _weeklyMoodData = localWeeklyMoodData;
          _lastJournalEntry = localLastJournalEntry;
          _lastJournalDate = localLastJournalDate;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching data: $e. Using cached/default data.')),
        );
      }
    }
  }

  Future<Map<String, String>> _fetchDailyAffirmation({bool forceNew = false}) async {
    if (_isOffline) {
      return {'text': 'I am strong and capable of overcoming any challenge.', 'category': 'General'};
    }

    final user = _auth.currentUser;
    if (user == null) {
      return {'text': 'I am strong and capable of overcoming any challenge.', 'category': 'General'};
    }

    final userId = user.uid;
    final today = DateTime.now().toIso8601String().split('T')[0];

    try {
      final doc = await FirestoreService().getDailyAffirmation(userId, today);
      if (forceNew || doc == null) {
        final affirmation = await FirestoreService().generateAffirmationFromOpenAI(
          category: _affirmationCategory,
          userName: _userData['name'],
        );
        await FirestoreService().saveDailyAffirmation(userId, today, affirmation['text']!, affirmation['category']!);
        return {'text': affirmation['text']!, 'category': affirmation['category']!};
      } else {
        return {'text': doc['text']!, 'category': doc['category']!};
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching affirmation: $e')),
        );
      }
      return {'text': 'I am strong and capable of overcoming any challenge.', 'category': 'General'};
    }
  }

  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
      _isLoading = true;
    });

    HapticFeedback.lightImpact();
    await _fetchDashboardData();

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CustomIconWidget(
                iconName: 'refresh',
                color: Theme.of(context).colorScheme.onInverseSurface,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text('Dashboard updated'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar.home(
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, '/subscription-management');
            },
            icon: CustomIconWidget(
              iconName: 'person_outline',
              color: colorScheme.onSurface,
              size: 24,
            ),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: _isOffline
          ? const Center(child: Text('No internet connection. Working offline with cached data.'))
          : _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _handleRefresh,
        color: colorScheme.primary,
        backgroundColor: colorScheme.surface,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),
                  GreetingCardWidget(
                    userName: _userData['name'] ?? 'Guest',
                    coachName: _userData['coachName'] ?? 'Maya',
                    coachAvatarUrl: _userData['coachAvatarUrl'] ?? "https://images.unsplash.com/photo-1728577740843-5f29c7586afe?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=580",
                    moodStreak: _userData['moodStreak'] ?? 0,
                  ),
                  SizedBox(height: 2.h),
                  ChatCoachCardWidget(
                    lastConversationPreview: _lastConversationPreview,
                    lastChatTime: _lastChatTime,
                    onTap: () {
                      Navigator.pushNamed(context, '/ai-coaching-chat');
                    },
                  ),
                  SizedBox(height: 2.h),
                  MoodCheckinCardWidget(
                    hasTodayMood: _hasTodayMood,
                    todayMoodEmoji: _todayMoodEmoji,
                    todayMoodNote: _todayMoodNote,
                    onMoodTap: _fetchDashboardData,
                  ),
                  SizedBox(height: 2.h),
                  QuickJournalCardWidget(
                    lastEntryPreview: _lastJournalEntry,
                    lastEntryDate: _lastJournalDate,
                    onTap: () {
                      _showJournalTimeline(context);
                    },
                    onSave: _fetchDashboardData,
                  ),
                  SizedBox(height: 2.h),
                  _isFetchingAffirmation
                      ? const Center(child: CircularProgressIndicator())
                      : DailyAffirmationCardWidget(
                    affirmationText: _dailyAffirmation,
                    category: _affirmationCategory,
                    onCopy: () {
                      Clipboard.setData(ClipboardData(text: _dailyAffirmation));
                      _showCopyConfirmation(context);
                    },
                    onShare: () {
                      _shareAffirmation();
                    },
                    onGetNew: () async {
                      setState(() => _isFetchingAffirmation = true);
                      final affirmationMap = await _fetchDailyAffirmation(forceNew: true);
                      if (mounted) {
                        setState(() {
                          _dailyAffirmation = affirmationMap['text'] ?? _dailyAffirmation;
                          _affirmationCategory = affirmationMap['category'] ?? _affirmationCategory;
                          _isFetchingAffirmation = false;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 2.h),
                  ProgressOverviewCardWidget(
                    weeklyMoodData: _weeklyMoodData,
                    onTap: () {
                      // _showDetailedAnalytics(context);
                    },
                  ),
                  SizedBox(height: 2.h),
                  QuickAccessTilesWidget(
                    // onScheduleCoaching: () {
                    //   _showSchedulingInterface(context);
                    // },
                    onViewJournalTimeline: () {
                      _showJournalTimeline(context);
                    },
                    // onAccessCrisisResources: () {
                    //   _showCrisisResources(context);
                    // },
                  ),
                  SizedBox(height: 4.h),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, '/ai-coaching-chat');
              break;
            case 2:
              Navigator.pushNamed(context, '/subscription-management');
              break;
            // case 3:
            //   Navigator.pushNamed(context, '/subscription-management');
            //   break;
          }
        },
      ),
    );
  }

  void _scrollToWellnessSection() {
    _scrollController.animateTo(
      600.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _showCopyConfirmation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Theme.of(context).colorScheme.onInverseSurface,
              size: 20,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Affirmation copied to clipboard!'),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showMoodDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
              'Today\'s Mood Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (_hasTodayMood) ...[
              Row(
                children: [
                  Text(
                    _todayMoodEmoji ?? '😊',
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getMoodLabel(_todayMoodEmoji ?? '😊'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Logged at ${_todayMoodTimestamp?.hour}:${_todayMoodTimestamp?.minute.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_todayMoodNote != null && _todayMoodNote!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _todayMoodNote!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  String _getMoodLabel(String emoji) {
    switch (emoji) {
      case '😢':
        return 'Feeling Very Sad';
      case '😔':
        return 'Feeling Sad';
      case '😐':
        return 'Feeling Neutral';
      case '😊':
        return 'Feeling Happy';
      case '😄':
        return 'Feeling Very Happy';
      default:
        return 'Feeling Good';
    }
  }

  void _showJournalInterface(BuildContext context) {
    final TextEditingController controller = TextEditingController();

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
              'Journal Entry',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Express your thoughts and feelings in a safe space',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'What\'s on your mind today?',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (controller.text.trim().isNotEmpty) {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await FirestoreService().logJournal(user.uid, controller.text);
                          Navigator.pop(context);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Journal entry saved!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                          _fetchDashboardData();
                        }
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Save Entry'),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    ).then((_) => controller.dispose());
  }

  void _shareAffirmation() {
    Share.share(_dailyAffirmation);
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Affirmation shared!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // void _showDetailedAnalytics(BuildContext context) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(
  //       content: Text('Detailed analytics coming soon!'),
  //       behavior: SnackBarBehavior.floating,
  //     ),
  //   );
  // }

  void _showSchedulingInterface(BuildContext context) {
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
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'schedule',
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Schedule Coaching Session',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Book a focused session with your AI coach Maya for deeper guidance and support.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildScheduleOption(context, 'Today', '3:00 PM - 4:00 PM'),
            _buildScheduleOption(context, 'Tomorrow', '10:00 AM - 11:00 AM'),
            _buildScheduleOption(context, 'This Weekend', 'Saturday 2:00 PM - 3:00 PM'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('View All Available Times'),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleOption(BuildContext context, String day, String time) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: 'schedule',
        color: Theme.of(context).colorScheme.primary,
        size: 24,
      ),
      title: Text(day),
      subtitle: Text(time),
      trailing: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Session scheduled for $day at $time'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: const Text('Book'),
      ),
    );
  }

  void _showJournalTimeline(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JournalTimelineSheet(onRefresh: _fetchDashboardData),
    );
  }

  Widget _buildJournalTimelineItem(
      BuildContext context,
      String timeLabel,
      String preview,
      DateTime date,
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
                iconName: 'edit_note',
                color: colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                timeLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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

  void _showCrisisResources(BuildContext context) {
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
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'emergency',
                  color: const Color(0xFFB85C5C),
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Crisis Support Resources',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xFFB85C5C),
                        ),
                      ),
                      Text(
                        'Immediate help is available 24/7',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildCrisisResourceItem(
                    context,
                    'National Suicide Prevention Lifeline',
                    '988',
                    'Free, confidential support 24/7',
                        () => _callEmergencyNumber('988'),
                  ),
                  _buildCrisisResourceItem(
                    context,
                    'Crisis Text Line',
                    'Text HOME to 741741',
                    'Free crisis counseling via text',
                        () => _sendCrisisText(),
                  ),
                  _buildCrisisResourceItem(
                    context,
                    'Emergency Services',
                    '911',
                    'For immediate medical emergencies',
                        () => _callEmergencyNumber('911'),
                  ),
                  _buildCrisisResourceItem(
                    context,
                    'SAMHSA National Helpline',
                    '1-800-662-4357',
                    'Treatment referral and information',
                        () => _callEmergencyNumber('1-800-662-4357'),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFB85C5C).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFB85C5C).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'If you\'re having thoughts of self-harm or suicide, please reach out immediately. You are not alone, and help is available.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFB85C5C),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildCrisisResourceItem(
      BuildContext context,
      String title,
      String contact,
      String description,
      VoidCallback onTap,
      ) {
    final theme = Theme.of(context);
    const crisisColor = Color(0xFFB85C5C);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: crisisColor.withValues(alpha: 0.2),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: crisisColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'phone',
                    color: crisisColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: crisisColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        contact,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: crisisColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                CustomIconWidget(
                  iconName: 'arrow_forward',
                  color: crisisColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _callEmergencyNumber(String number) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling $number...'),
        backgroundColor: const Color(0xFFB85C5C),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _sendCrisisText() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening text message to Crisis Text Line...'),
        backgroundColor: Color(0xFFB85C5C),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}