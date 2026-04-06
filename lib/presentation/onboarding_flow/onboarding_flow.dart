import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yspc/services/firestore_service.dart';

import '../../core/app_export.dart';
import './widgets/avatar_selection_card.dart';
import './widgets/notification_preference_tile.dart';
import './widgets/progress_indicator_widget.dart';
import './widgets/wellness_goal_chip.dart';
import 'widgets/disclaimer_widget.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _currentStep = 1;
  final int _totalSteps = 5;

  // User selections
  // String? _selectedStylePack;
 final List<String> _selectedGoals = [];

 String? _selectedAvatar;
 final Map<String, bool> _notificationPreferences = {
    'mood_checkins': false,
    'daily_affirmations': false,
    'journal_prompts': false,
  };
  bool _disclaimerAccepted = false;  // ← NEW (required for continue)

  // Mock data
  // final List<Map<String, dynamic>> _stylePacks = [
  //   {
  //     'id': 'aave_friendly',
  //     'title': 'AAVE-Friendly',
  //     'description': 'Culturally authentic communication that feels like home',
  //     'previewText':
  //     '"Hey beautiful soul! I see you\'re going through it right now, and that\'s completely valid. Let\'s work through this together, one step at a time."',
  //   },
  //   {
  //     'id': 'faith_forward',
  //     'title': 'Faith-Forward',
  //     'description': 'Spiritually grounded guidance with biblical wisdom',
  //     'previewText':
  //     '"Remember that you are fearfully and wonderfully made. In times of struggle, lean on your faith and know that this season will pass with purpose."',
  //   },
  //   {
  //     'id': 'standard',
  //     'title': 'Standard',
  //     'description': 'Professional therapeutic communication style',
  //     'previewText':
  //     '"I understand you\'re experiencing some challenges right now. Let\'s explore some coping strategies that can help you navigate this difficult time."',
  //   },
  // ];

  final List<Map<String, dynamic>> _wellnessGoals = [
    {
      'id': 'reduce_anxiety',
      'label': 'Reduce Anxiety',
      'icon': Icons.psychology
    },
    {
      'id': 'build_confidence',
      'label': 'Build Confidence',
      'icon': Icons.trending_up
    },
    {
      'id': 'daily_motivation',
      'label': 'Daily Motivation',
      'icon': Icons.wb_sunny
    },
    {'id': 'better_sleep', 'label': 'Better Sleep', 'icon': Icons.bedtime},
    {
      'id': 'stress_management',
      'label': 'Stress Management',
      'icon': Icons.spa
    },
    {
      'id': 'emotional_balance',
      'label': 'Emotional Balance',
      'icon': Icons.balance
    },
    {'id': 'self_care', 'label': 'Self-Care Habits', 'icon': Icons.favorite},
    {
      'id': 'mindfulness',
      'label': 'Mindfulness Practice',
      'icon': Icons.self_improvement
    },
  ];

  final List<Map<String, dynamic>> _avatars = [
    {
      'id': 'ayana',
      'name': 'Ayana',
      'description': 'The Nurturing Soul',
      'imageUrl': 'assets/coach/ayana.webp',
    },
    {
      'id': 'omari',
      'name': 'Omari',
      'description': 'The Wise Protector',
      'imageUrl': 'assets/coach/alex.webp',
    },
    {
      'id': 'nia',
      'name': 'Nia (Child Specialist)',
      'description': 'The Creative Healer',
      'imageUrl': 'assets/coach/nia.webp',
    },
    {
      'id': 'mateo',
      'name': 'Mateo',
      'description': 'The Accountability Coach',
      'imageUrl': 'assets/coach/mateo.webp',
    },
    {
      'id': 'matthew',
      'name': 'Matthew',
      'description': 'The Emotional Alchemist',
      'imageUrl': 'assets/coach/matthew.webp',
    },
    {
      'id': 'daniel',
      'name': 'Daniel',
      'description': 'The Inner-Child Healer',
      'imageUrl': 'assets/coach/daniel.webp',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps) {
      setState(() {
        _currentStep++;
      });

      _animationController.reset(); // ← fade out instantly

      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      ).then((_) {
        _animationController.forward(); // ← new page fades in
      });
    } else {
      _completeOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });

      _animationController.reset();

      _pageController.previousPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      ).then((_) {
        _animationController.forward();
      });
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {

        await FirestoreService().updateOnboardingStatus(user.uid, true);

        final coachId = _selectedAvatar ?? 'alex';  // Alex default
        await FirestoreService().saveSelectedCoach(user.uid, coachId);
        _saveOnboardingData();

        // Navigate to home dashboard
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home-dashboard',
                (route) => false,
          );
        }
      } else {
        debugPrint('⚠️ No logged-in user found during onboarding completion.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to complete onboarding — please sign in again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Onboarding update failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving onboarding progress: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  void _saveOnboardingData() {
    // In a real app, this would save to SharedPreferences or secure storage
    final onboardingData = {
      'wellness_goals': _selectedGoals,
      // 'selected_avatar': _selectedAvatar,
      'notification_preferences': _notificationPreferences,
      'onboarding_completed': true,
      'free_trial_started': DateTime.now().toIso8601String(),
    };

    // Mock save operation
    debugPrint('Onboarding data saved: $onboardingData');
  }

  bool _canContinue() {
    switch (_currentStep) {
      case 1: return true;
      case 2: return _selectedGoals.isNotEmpty;
      case 3: return _selectedAvatar != null;
      case 4: return true;
      case 5: return _disclaimerAccepted;
      default: return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 1
            ? IconButton(
          onPressed: _previousStep,
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios',
            color: colorScheme.onSurface,
            size: 20,
          ),
        )
            : null,
        actions: [
          if (_currentStep < _totalSteps)
            TextButton(
              onPressed: _skipOnboarding,
              child: Text(
                'Skip',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            ProgressIndicatorWidget(
              currentStep: _currentStep,
              totalSteps: _totalSteps,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildWelcomeScreen(),
                  _buildWellnessGoalsScreen(),
                  _buildAvatarSelectionScreen(),
                  _buildNotificationPreferencesScreen(),
                  _buildDisclaimerScreen(),  // ← NEW SLIDE
                ],
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo/soul_logo.png', width: 60.w, height:
            30.h,
              fit: BoxFit.contain,),
            // SizedBox(height: 4.h),
            Text(
              'Welcome to Your Soul Pocket Coach',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Text(
              'You’ve just entered your safe space for healing, growth and '
                  'peace. This app will guide you through your mental and '
                  'emotional wellness journey — with culturally aware '
                  'insight, gentle reflections, and support that feels human.',
              style: TextStyle(
                fontSize: 10.sp,
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'star',
                    color: colorScheme.primary,
                    size: 24,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      '7-day free trial included',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }


  Widget _buildWellnessGoalsScreen() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),
            Text(
              'What are your wellness goals?',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Select all that apply. This helps us personalize your coaching experience.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            SizedBox(height: 3.h),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 2.w,
                  mainAxisSpacing: 1.h,
                ),
                itemCount: _wellnessGoals.length,
                itemBuilder: (context, index) {
                  final goal = _wellnessGoals[index];
                  return WellnessGoalChip(
                    label: goal['label'],
                    icon: goal['icon'],
                    isSelected: _selectedGoals.contains(goal['id']),
                    onTap: () {
                      setState(() {
                        if (_selectedGoals.contains(goal['id'])) {
                          _selectedGoals.remove(goal['id']);
                        } else {
                          _selectedGoals.add(goal['id']);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSelectionScreen() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),
            Text(
              'Meet Your Coach',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Choose an avatar that resonates with you. This will be your personal AI wellness coach.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            SizedBox(height: 3.h),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 2.w,
                  mainAxisSpacing: 2.h,
                ),
                itemCount: _avatars.length,
                itemBuilder: (context, index) {
                  final avatar = _avatars[index];
                  return AvatarSelectionCard(
                    name: avatar['name'],
                    description: avatar['description'],
                    imageUrl: avatar['imageUrl'],
                    isSelected: _selectedAvatar == avatar['id'],
                    onTap: () {
                      setState(() {
                        _selectedAvatar = avatar['id'];
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationPreferencesScreen() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stay Connected',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Choose how you\'d like to receive gentle reminders and support throughout your wellness journey.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
            Expanded(
              child: ListView(
                children: [
                  NotificationPreferenceTile(
                    title: 'Mood Check-ins',
                    description:
                    'Daily gentle reminders to track your emotional well-being',
                    icon: Icons.favorite_outline,
                    isEnabled: _notificationPreferences['mood_checkins'] ?? true,
                    onChanged: (value) {
                      setState(() {
                        _notificationPreferences['mood_checkins'] = value;
                      });
                    },
                  ),
                  NotificationPreferenceTile(
                    title: 'Daily Affirmations',
                    description:
                    'Uplifting messages and mantras to start your day positively',
                    icon: Icons.wb_sunny_outlined,
                    isEnabled:
                    _notificationPreferences['daily_affirmations'] ?? true,
                    onChanged: (value) {
                      setState(() {
                        _notificationPreferences['daily_affirmations'] = value;
                      });
                    },
                  ),
                  NotificationPreferenceTile(
                    title: 'Journal Prompts',
                    description:
                    'Thoughtful questions to encourage reflection and growth',
                    icon: Icons.edit_outlined,
                    isEnabled:
                    _notificationPreferences['journal_prompts'] ?? false,
                    onChanged: (value) {
                      setState(() {
                        _notificationPreferences['journal_prompts'] = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            // Container(
            //   margin: EdgeInsets.all(4.w),
            //   padding: EdgeInsets.all(4.w),
            //   decoration: BoxDecoration(
            //     color: colorScheme.primary.withValues(alpha: 0.1),
            //     borderRadius: BorderRadius.circular(16),
            //   ),
            //   child: Row(
            //     children: [
            //       CustomIconWidget(
            //         iconName: 'info_outline',
            //         color: colorScheme.primary,
            //         size: 20,
            //       ),
            //       SizedBox(width: 3.w),
            //       Expanded(
            //         child: Text(
            //           'You can change these preferences anytime in your profile settings.',
            //           style: theme.textTheme.bodySmall?.copyWith(
            //             color: colorScheme.primary,
            //             height: 1.3,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
  Widget _buildDisclaimerScreen() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: DisclaimerWidget(
        text: "Your Soul Pocket Coach is a wellness and self-reflection tool. It is not a substitute for Mental Health treatment, psychotherapy, or medical care.\n\nThe information and support provided by this app are for educational and emotional support purposes only and should not be used to diagnose, treat, or manage mental health conditions.\n\nIf you are in crisis, thinking about harming yourself or others, or need urgent help, please contact your local emergency number or a Mental Health professional immediately.",
        onAcceptedChanged: (accepted) {
          setState(() => _disclaimerAccepted = accepted);
        },
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _canContinue() ? _nextStep : null,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _currentStep == _totalSteps ? 'Start Your Journey' : 'Continue',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
