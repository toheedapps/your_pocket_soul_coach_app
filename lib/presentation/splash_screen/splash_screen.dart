// splash_screen.dart - SIMPLIFIED + REAL FIREBASE INTEGRATION
// No subscription logic, no mocks, no style packs, no cached data nonsense
// Just: Auth check → Onboarding check → LLM ping → Navigate
// Clean, fast, premium feel. Retry on any failure (internet/Firestore/OpenAI)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/app_export.dart';
import '../../services/firestore_service.dart';
import '../../services/openai_client.dart';
import '../../theme/app_theme.dart';
import './widgets/animated_logo_widget.dart';
import './widgets/background_gradient_widget.dart';
import './widgets/loading_indicator_widget.dart';
import './widgets/retry_connection_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _showRetry = false;
  String _loadingMessage = 'Initializing your Soul Pocket Coach...';

  String? _uid;
  bool _isAuthenticated = false;
  bool _isOnboarded = false;

  final FirestoreService _firestore = FirestoreService();
  final OpenAIClient _openAI = OpenAIClient();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _showRetry = false;
      _loadingMessage = 'Initializing your Soul Pocket Coach...';
    });

    try {
      // 1. Auth check
      setState(() => _loadingMessage = 'Checking authentication...');
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _uid = user.uid;
        _isAuthenticated = true;
      }
      await Future.delayed(const Duration(milliseconds: 600)); // smooth UX

      // 2. If auth → check onboarding
      if (_isAuthenticated) {
        setState(() => _loadingMessage = 'Loading your profile...');
        final profile = await _firestore.getUserProfile(_uid!);
        _isOnboarded = profile?['is_onboarded'] ?? false;
        await Future.delayed(const Duration(milliseconds: 600));
      }

      // 3. Ping OpenAI (fast health check)
      setState(() => _loadingMessage = 'Connecting to your Soul Coach...');
      final connected = await _openAI.testConnection();
      if (!connected) throw Exception('Soul Coach unreachable');
      await Future.delayed(const Duration(milliseconds: 600));

      // 4. Navigate
      if (!mounted) return;
      _navigateToNextScreen();
    } catch (e) {
      debugPrint('Splash init error: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _showRetry = true;
        _loadingMessage = 'Connection failed. Tap to retry.';
      });
    }
  }

  void _navigateToNextScreen() {
    String route;
    if (!_isAuthenticated) {
      route = '/authentication-screen';
    } else if (!_isOnboarded) {
      route = '/onboarding-flow';
    } else {
      route = '/home-dashboard';
    }

    Navigator.pushReplacementNamed(context, route);
  }

  void _retry() {
    _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    // Therapeutic status bar
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            const BackgroundGradientWidget(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  AnimatedLogoWidget(onAnimationComplete: () {}),
                  const Spacer(flex: 1),
                  _isLoading
                      ? LoadingIndicatorWidget(
                    isVisible: true,
                    message: _loadingMessage,
                  )
                      : RetryConnectionWidget(
                    isVisible: _showRetry,
                    onRetry: _retry,
                    errorMessage:
                    'Unable to connect. Check your internet and tap to retry.',
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}