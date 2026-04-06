import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; // For StreamSubscription
import 'dart:developer'; // For log
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart'; // NEW: For PayPal
import 'package:url_launcher/url_launcher.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_bottom_bar.dart';
import '../../../widgets/custom_icon_widget.dart';
import 'package:yspc/presentation/subscription_management/widgets/billing_history_section.dart';
import 'package:yspc/presentation/subscription_management/widgets/subscription_status_card.dart';
import 'package:yspc/presentation/subscription_management/widgets/upgrade_cards.dart';
import '../../../services/firestore_service.dart';
import '../../../services/firebase_auth_service.dart'; // Import for auth service

class SubscriptionManagement extends StatefulWidget {
  const SubscriptionManagement({super.key});

  @override
  State<SubscriptionManagement> createState() => _SubscriptionManagementState();
}

class _SubscriptionManagementState extends State<SubscriptionManagement>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuthService _authService = FirebaseAuthService(); // Add auth service
  Map<String, dynamic> subscriptionData = {};
  List<Map<String, dynamic>> billingHistory = [];
  Map<String, dynamic> usageData = {'aiSessions': 0, 'journalEntries': 0, 'moodCheckins': 0};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // Increase to 4 tabs
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _firestoreService.getBillingHistory(uid).then((history) {
        setState(() => billingHistory = history);
      });
    }
  }


  Future<void> openPrivacyPolicy() async {
    final Uri url = Uri.parse('https://yourpocketsoulcoach.com/privacy-and-policies');

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        print('Launching: $url');
        throw 'Launch failed';
      }
    } catch (e) {
      // Handle error (Snackbar, dialog, etc.)
      print('Error opening URL: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar.subscription(),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestoreService.getUserSubscriptionStream(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.exists) {
            subscriptionData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
            if (subscriptionData['subscriptionType'] == 'free_trial') {
              final endDate = subscriptionData['trialEndDate'] as Timestamp?;
              if (endDate != null) {
                final remaining = endDate.toDate().difference(DateTime.now()).inDays;
                subscriptionData['daysRemaining'] = remaining.clamp(0, 7);
              }
            }
            usageData = {
              'aiSessions': subscriptionData['aiSessionsCount'] ?? 0,
              'journalEntries': subscriptionData['journalEntriesCount'] ?? 0,
              'moodCheckins': subscriptionData['moodCheckinsCount'] ?? 0,
            };
          } else {
            // Default or handle no data
            subscriptionData = {};
            usageData = {'aiSessions': 0, 'journalEntries': 0, 'moodCheckins': 0};
          }

          return Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Plans'),
                    Tab(text: 'Billing'),
                    Tab(text: 'Account'), // New tab
                  ],
                  labelColor: colorScheme.primary,
                  unselectedLabelColor: colorScheme.onSurfaceVariant,
                  indicator: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                ),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildPlansTab(),
                    _buildBillingTab(),
                    _buildAccountTab(), // New tab content
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: CustomBottomBar(),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.h),

          SubscriptionStatusCard(
            subscriptionType: subscriptionData['subscriptionType'] ?? 'expired',
            status: subscriptionData['subscriptionStatus'] ?? 'expired',
            daysRemaining: subscriptionData['daysRemaining'],
            nextBillingDate: (subscriptionData['nextBillingDate'] as Timestamp?)?.toDate().toString() ?? '',
          ),

          // UsageMetricsCard(
          //   currentPlan: subscriptionData['subscriptionType'] ?? 'expired',
          //   usageData: usageData,
          // ),

          _buildQuickActions(),

          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildPlansTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.h),

          // FeatureComparisonTable(
          //   currentPlan: subscriptionData['subscriptionType'] ?? 'expired',
          // ),

          UpgradeCards(
            currentPlan: subscriptionData['subscriptionType'] ?? 'expired',
            onUpgradeBasic: _handleUpgradeBasic,
            onUpgradePremium: _handleUpgradePremium,
            // onStartTrial: _handleStartTrial,
          ),

          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildBillingTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.h),

          _buildCurrentSubscriptionDetails(),

          BillingHistorySection(
            billingHistory: billingHistory,
          ),

          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildAccountTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.h),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
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
                Text(
                  'Account Management',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 3.h),
                ElevatedButton.icon(
                  onPressed: _showLogoutDialog,
                  icon: Icon(Icons.logout, color: colorScheme.onPrimary),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    minimumSize: Size(double.infinity, 5.h),
                  ),
                ),
                SizedBox(height: 2.h),
                ElevatedButton.icon(
                  onPressed: _showDeleteDialog,
                  icon: Icon(Icons.delete_forever, color: colorScheme.onError),
                  label: const Text('Delete Account'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                    minimumSize: Size(double.infinity, 5.h),
                  ),
                ),
                SizedBox(height: 2.h),
                ElevatedButton.icon(
                  onPressed: openPrivacyPolicy,
                  icon: Icon(Icons.privacy_tip_outlined, color: colorScheme.onPrimary),
                  label: const Text('Privacy Policy'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    minimumSize: Size(double.infinity, 5.h),
                  ),
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Do you want to logout your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              await _authService.signOut();
              Navigator.pop(context);
              // Navigate to login screen or home
              Navigator.pushReplacementNamed(context, '/authentication-screen')
              ; // Adjust route as needed
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final user = FirebaseAuth.instance.currentUser;

    bool isGoogleUser = user?.providerData.any((info) => info.providerId == 'google.com') ?? false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to permanently delete your account? This action cannot be undone.'),
            if (!isGoogleUser) ...[  // Prompt for email/password if not Google
              SizedBox(height: 2.h),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              final uid = user?.uid;
              if (uid != null) {
                try {
                  if (isGoogleUser) {
                    await _authService.reauthenticateWithGoogle();
                  } else {
                    final email = emailController.text.trim();
                    final password = passwordController.text;
                    if (email.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter credentials to confirm')));
                      return;
                    }
                    await _authService.reauthenticateUser(email, password);
                  }
                  await _authService.deleteAccount();
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/authentication-screen');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete account: $e')));
                }
              }
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            'Quick Actions',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: 'support_agent',
                  label: 'Get Support',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showSupportOptions();
                  },
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: 'receipt_long',
                  label: 'View Receipts',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _tabController.animateTo(2);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required String icon,
        required String label,
        required VoidCallback onTap,
        Color? color,
      }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: color ?? colorScheme.primary,
              size: 24,
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: color ?? colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSubscriptionDetails() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              CustomIconWidget(
                iconName: 'credit_card',
                color: colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Current Subscription',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildDetailRow(context, 'Plan', subscriptionData['subscriptionType'] ?? 'None'),
          _buildDetailRow(context, 'Status', subscriptionData['subscriptionStatus'] ?? 'Inactive'),
          _buildDetailRow(context, 'Next Billing', (subscriptionData['nextBillingDate'] as Timestamp?)?.toDate().toString() ?? 'N/A'),
          _buildDetailRow(context, 'Payment Method', subscriptionData['paymentMethod'] ?? 'None'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showSupportOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SupportOptionsSheet(),
    );
  }

  // Future<void> _handleStartTrial() async {
  //   final uid = FirebaseAuth.instance.currentUser?.uid;
  //   if (uid != null) {
  //     try {
  //       await _firestoreService.startFreeTrial(uid);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Free trial started! Enjoy 7 days of full access.')),
  //       );
  //       // The stream listener will update subscriptionData automatically
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Failed to start free trial: $e')),
  //       );
  //     }
  //   }
  // }

  void _handleUpgradeBasic() {
    _processPayment('basic', '9.99', '\$9.99');
  }

  void _handleUpgradePremium() {
    _processPayment('premium', '29.99', '\$29.99');
  }

  Future<void> _processPayment(String planType, String totalAmount, String amountStr) async {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => PaypalCheckoutView(
        sandboxMode: true, // Set to false for production
        clientId: "AWzgq1JYosEXyl5th45QlXEzEYLcDCOBar5Pru9Ictd-VZ1G4FXQ0kJl47727XjSGNp6VJehcaLtw96K",
        secretKey: "EEkbKoGTitC0K3bcfXo0iA75tu-D6GaAfx1mGqy7gSz3tOZ2D1Bq5E3t4ETy_uwjfw9GCOG_vbfvvfEN",
        transactions:  [
          {
            "amount": {
              "total": totalAmount,
              "currency": "USD",
              "details": {
                "subtotal": totalAmount,
                "shipping": '0',
                "shipping_discount": 0
              }
            },
            "description": "Subscription to $planType plan.",
            "item_list": {
              "items": [
                {
                  "name": "$planType Subscription",
                  "quantity": 1,
                  "price": totalAmount,
                  "currency": "USD"
                }
              ]
            }
          }
        ],
        note: "Contact us for any questions on your order.",
        onSuccess: (Map params) async {
          log("onSuccess: $params");
          final receiptId = params['id'] ?? 'unknown'; // Extract from params if available
          await _firestoreService.updateSubscriptionAfterPayment(
            uid: FirebaseAuth.instance.currentUser!.uid,
            planType: planType,
            amount: amountStr,
            receiptId: receiptId,
          );
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully upgraded to $planType plan!')));
          Navigator.pop(context);
        },
        onError: (error) {
          log("onError: $error");
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment failed')));
          Navigator.pop(context);
        },
        onCancel: () {
          log('cancelled:');
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment cancelled')));
          Navigator.pop(context);
        },
      ),
    ));
  }
}

class _SupportOptionsSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Get Support',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 3.h),
          _buildSupportOption(
            context,
            icon: 'email',
            title: 'Email Support',
            subtitle: 'support@soulcoach.ai',
            onTap: () {},
          ),
          SizedBox(height: 2.h),
          _buildSupportOption(
            context,
            icon: 'help',
            title: 'FAQ',
            subtitle: 'Common questions',
            onTap: () {
              Navigator.pushNamed(context, '/faq');
            },
          ),
          SizedBox(height: 3.h),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildSupportOption(
      BuildContext context, {
        required String icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pop(context);
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}