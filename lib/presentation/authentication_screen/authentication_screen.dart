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
import './widgets/forgot_password_sheet.dart';
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
        
        try {
          await requestNotificationPermission();
          String? token = await FirebaseMessaging.instance.getToken();
          print('════════════════════════════════');
          print('YOUR FCM TOKEN:');
          print(token);
          print('════════════════════════════════');
        } catch (fcmError) {
          print('FCM setup skipped/failed: $fcmError');
        }

        final profile = await FirestoreService().getUserProfile(user.uid);
        if (profile?['is_onboarded'] == true) {
          Navigator.pushNamedAndRemoveUntil(context, '/home-dashboard', (r) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/onboarding-flow', (r) => false);
        }
      }
    } on FirebaseAuthException catch (e) {
      _showErrorMessage(e.message ?? 'Sign in failed.');
    } catch (e) {
      _showErrorMessage('An error occurred: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }



  Future<void> _handleSignUp(String name, String email, String password) async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signUpWithEmail(email, password, name: name);
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
        
        try {
          await requestNotificationPermission();
          String? token = await FirebaseMessaging.instance.getToken();
          print('════════════════════════════════');
          print('YOUR FCM TOKEN:');
          print(token);
          print('════════════════════════════════');
        } catch (fcmError) {
          print('FCM setup skipped/failed: $fcmError');
        }

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

  void _handleForgotPassword([String initialEmail = '']) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ForgotPasswordSheet(
        initialEmail: initialEmail,
        onNavigateToSignUp: () {
          _tabController.animateTo(1);
        },
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 2.h),

                // App Logo Section
                const AppLogoSection(),
                SizedBox(height: 3.h),

                // Tab Bar
                AuthTabBar(
                  tabController: _tabController,
                  onTabChanged: _handleTabChange,
                ),
                SizedBox(height: 2.5.h),

                // Active Form (rendered with natural intrinsic height, no scroll blocking)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _tabController.index == 0
                      ? SignInForm(
                          key: const ValueKey('sign_in_form'),
                          onSignIn: (email, password, rememberMe) {
                            _handleSignIn(email, password, rememberMe);
                          },
                          onForgotPassword: _handleForgotPassword,
                          isLoading: _isLoading,
                        )
                      : SignUpForm(
                          key: const ValueKey('sign_up_form'),
                          onSignUp: _handleSignUp,
                          isLoading: _isLoading,
                        ),
                ),

                SizedBox(height: 2.h),

                // Social Login Section
                SocialLoginSection(
                  onGoogleSignIn: _handleGoogleSignIn,
                  isLoading: _isLoading,
                ),

                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}