import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:yspc/services/firebase_auth_service.dart' as fb_auth;
import '../../core/app_export.dart';
import './widgets/app_logo_section.dart';
import './widgets/auth_tab_bar.dart';
import './widgets/sign_in_form.dart';
import './widgets/sign_up_form.dart';
import './widgets/social_login_section.dart';
import 'package:yspc/services/firestore_service.dart';



class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}



class _AuthenticationScreenState extends State<AuthenticationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  final _authService = fb_auth.FirebaseAuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool('remember_me') ?? false;
      final user = FirebaseAuth.instance.currentUser;

      if (rememberMe && user != null) {
        Navigator.pushNamedAndRemoveUntil(context, '/home-dashboard', (r) => false);
      } else if (!rememberMe && user != null) {
        await FirebaseAuth.instance.signOut();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupKeyboardListener() {
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;

    if (keyboardHeight > 0) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _handleTabChange(int index) {
    HapticFeedback.lightImpact();
    _tabController.animateTo(index);
  }
  Future<void> _postSignInRedirect(User user) async {
    final creation = user.metadata.creationTime;
    final lastSignIn = user.metadata.lastSignInTime;

    // New user → onboarding
    if (creation != null && lastSignIn != null && creation == lastSignIn) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/onboarding-flow',
            (route) => false,
      );
    } else {
      // Returning user → home
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home-dashboard',
            (route) => false,
      );
    }

  }

  Future<void> _handleSignIn(String email, String password, bool rememberMe) async {
    setState(() => _isLoading = true);
    try {
      // ✅ Set Firebase session persistence according to "remember me"
      // await FirebaseAuth.instance.setPersistence(
      //   rememberMe ? Persistence.LOCAL : Persistence.NONE,
      // );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', rememberMe);

      final user = await _authService.signInWithEmail(email, password);
      if (user != null && mounted) {
        await FirestoreService().createUserProfile(
          uid: user.uid,
          email: user.email ?? '',
          name: user.displayName,
        );
        await requestNotificationPermission();
        String? token = await FirebaseMessaging.instance.getToken();
        print('════════════════════════════════');
        print('YOUR FCM TOKEN:');
        print(token);
        print('════════════════════════════════');// ← ADD THIS LINE

        final profile = await FirestoreService().getUserProfile(user.uid);
        if (profile?['is_onboarded'] == true) {
          Navigator.pushNamedAndRemoveUntil(context, '/home-dashboard', (r) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/onboarding-flow', (r) => false);
        }
      }
    } on FirebaseAuthException catch (e) {
      _showErrorMessage(e.message ?? 'Sign in failed.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }



  Future<void> _handleSignUp(String name, String email, String password) async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signUpWithEmail(email, password);
      if (user != null && mounted) {
        await FirestoreService().createUserProfile(
          uid: user.uid,
          email: user.email ?? '',
          name: name,
        );
        _showSuccessMessage('Account created successfully! Please sign in to continue.');
        _tabController.animateTo(0); // move to sign-in tab
      }
    } on FirebaseAuthException catch (e) {
      _showErrorMessage(e.message ?? 'Account creation failed.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }




  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null && mounted) {
        await FirestoreService().createUserProfile(
          uid: user.uid,
          email: user.email ?? '',
          name: user.displayName,
        );
        await requestNotificationPermission();   // ← ADD THIS LINE

        final profile = await FirestoreService().getUserProfile(user.uid);
        if (profile?['is_onboarded'] == true) {
          Navigator.pushNamedAndRemoveUntil(context, '/home-dashboard', (r) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/onboarding-flow', (r) => false);
        }
      }
    } catch (e) {
      _showErrorMessage('Google Sign-In failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  Future<void> requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void _handleForgotPassword() {
    HapticFeedback.lightImpact();

    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reset Password',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your email address and we’ll send you a link to reset your password.',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            SizedBox(height: 4.h),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter your email',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              Navigator.pop(context);

              if (email.isEmpty) {
                _showErrorMessage('Please enter your email.');
                return;
              }

              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                _showSuccessMessage('Password reset email sent successfully.');
              } on FirebaseAuthException catch (e) {
                _showErrorMessage(e.message ?? 'Password reset failed.');
              }
            },
            child: const Text('Send Link'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }


  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'error_outline',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(4.w),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(4.w),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                children: [
                  SizedBox(height: 4.h),

                  // App Logo Section
                  const AppLogoSection(),
                  SizedBox(height: 4.h),

                  // Tab Bar
                  AuthTabBar(
                    tabController: _tabController,
                    onTabChanged: _handleTabChange,
                  ),
                  SizedBox(height: 3.h),

                  // Tab Bar View (height slightly reduced to remove extra gap)
                  SizedBox(
                    height: _tabController.index == 0 ? 42.h : 55.h,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Sign In Form
                        SignInForm(
                          onSignIn: (email, password, rememberMe) {
                            _handleSignIn(email, password, rememberMe);
                          },
                          onForgotPassword: _handleForgotPassword,
                          isLoading: _isLoading,
                        ),

                        // Sign Up Form
                        SingleChildScrollView(
                          child: SignUpForm(
                            onSignUp: _handleSignUp,
                            isLoading: _isLoading,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Reduced spacing before Google login
                  SizedBox(height: 1.h),

                  // Social Login Section
                  SocialLoginSection(
                    onGoogleSignIn: _handleGoogleSignIn,

                    isLoading: _isLoading,
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}