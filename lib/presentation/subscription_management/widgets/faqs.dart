import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_icon_widget.dart';


/// FAQ Screen - Therapeutic, supportive answers with warm design
/// Covers all core features of Your Soul Pocket Coach
class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  // FAQ Data - Grouped for easy reading
  final List<Map<String, dynamic>> _faqSections = const [
    {
      'category': '👤 Account & Login',
      'icon': 'person_outline',
      'questions': [
        {
          'q': 'How do I create an account?',
          'a': 'Tap "Sign Up" on the login screen and enter your name, email, and password. Or use "Continue with Google" for instant signup. We\'ll guide you through personalizing your Soul Pocket Coach right after!',
        },
        {
          'q': 'What if I forget my password?',
          'a': 'On the Sign In tab, tap "Forgot Password?" Enter your email and we\'ll send a secure reset link immediately. Check spam if needed.',
        },
        {
          'q': 'Is "Remember Me" safe?',
          'a': 'Yes! It securely saves your session on this device only. We never store passwords in plain text. You can disable it anytime in Settings.',
        },
        {
          'q': 'Can I delete my account?',
          'a': 'Yes. Go to Profile → Settings → Delete Account. This permanently removes all data (chats, journals, moods). We\'ll miss you, but your privacy comes first.',
        },
      ],
    },
    {
      'category': '🧠 Your AI Soul Coach',
      'icon': 'chat_bubble_outline',
      'questions': [
        {
          'q': 'Who are the coaches?',
          'a': 'Meet Maya (Warm & Nurturing) and Alex (Supportive & Wise). They\'re AI-powered therapists trained on evidence-based techniques like CBT, mindfulness, and positive psychology.',
        },
        {
          'q': 'How do I switch coaches?',
          'a': 'In the chat screen, tap the person icon in the top right → choose your new coach. They\'ll introduce themselves instantly!',
        },
        {
          'q': 'Is my chat history private?',
          'a': '100% yes. Chats are encrypted and only visible to you. We never share with third parties. You can clear history anytime.',
        },
        {
          'q': 'Does the AI replace a real therapist?',
          'a': 'No. We\'re a supportive companion for daily wellness. For crisis or serious mental health needs, please contact a licensed professional or emergency services.',
        },
      ],
    },
    {
      'category': '✨ Wellness Tools',
      'icon': 'self_improvement',
      'questions': [
        {
          'q': 'What are daily affirmations?',
          'a': 'Beautiful, personalized positive statements delivered every morning. Enable in Settings → Notifications. You can favorite them too!',
        },
        {
          'q': 'How does mood check-in work?',
          'a': 'Tap the mood card on Home. Choose how you feel → add a note → save. Track patterns weekly in your Wellness tab.',
        },
        {
          'q': 'Can I journal offline?',
          'a': 'Yes! Write anytime — entries sync when you\'re back online. Access past journals in the Journal section.',
        },
        {
          'q': 'What are wellness goals?',
          'a': 'Set during onboarding (Reduce Anxiety, Better Sleep, etc). Your coach tailors responses to these goals for maximum support.',
        },
      ],
    },
    {
      'category': '💎 Subscription & Billing',
      'icon': 'credit_card',
      'questions': [
        {
          'q': 'What\'s included in the free trial?',
          'a': '7 days of unlimited AI coaching, affirmations, journaling, mood tracking — everything! No card required.',
        },
        {
          'q': 'How much is Premium?',
          'a': 'After trial: \$9.99/month or \$79.99/year (33% savings). Cancel anytime in Profile → Manage Subscription.',
        },
        {
          'q': 'How do I cancel?',
          'a': 'Go to Profile → Subscription → Cancel Plan. Instant, no questions asked. You keep access until the period ends.',
        },
        {
          'q': 'Is there a refund policy?',
          'a': 'Yes! Full refund within 14 days of purchase if you\'re not feeling the vibes. Contact support@soulpocketcoach.com',
        },
      ],
    },
    {
      'category': '🛠 Troubleshooting & Support',
      'icon': 'help_outline',
      'questions': [
        {
          'q': 'App not loading / offline?',
          'a': 'We work offline for journaling & reading past chats. Pull down on Home to refresh when connected. Restart app if stuck.',
        },
        {
          'q': 'Coach not responding?',
          'a': 'Check internet → tap the typing indicator. Still stuck? Clear cache in Settings or reinstall (your data is safe in the cloud).',
        },
        {
          'q': 'How to change notifications?',
          'a': 'Profile → Settings → Notifications. Toggle mood check-ins, affirmations, journal prompts.',
        },
        {
          'q': 'Need help?',
          'a': 'Email support@soulpocketcoach.com or tap "Contact Support" in Settings. We respond within 24 hours with real human care ❤️',
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'FAQ & Help',
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.all(4.w),
          itemCount: _faqSections.length,
          itemBuilder: (context, sectionIndex) {
            final section = _faqSections[sectionIndex];
            return Container(
              margin: EdgeInsets.only(bottom: 4.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Header
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: section['icon'],
                        color: colorScheme.primary,
                        size: 28,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        section['category'],
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),

                  // Questions
                  ...List.generate(
                    section['questions'].length,
                        (qIndex) {
                      final qa = section['questions'][qIndex];
                      return Container(
                        margin: EdgeInsets.only(bottom: 2.h),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        child: ExpansionTile(
                          backgroundColor: Colors.transparent,
                          collapsedBackgroundColor: Colors.transparent,
                          tilePadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                          childrenPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h).copyWith(bottom: 3.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Text(
                            qa['q'],
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          children: [
                            Text(
                              qa['a'],
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w400,
                                color: colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}