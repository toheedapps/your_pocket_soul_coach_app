import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/home_dashboard/home_dashboard.dart';
import '../presentation/ai_coaching_chat/ai_coaching_chat.dart';
import '../presentation/authentication_screen/authentication_screen.dart';
import '../presentation/subscription_management/subscription_management.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/subscription_management/widgets/faqs.dart';

class AppRoutes {
  // TODO: Add your routes here
  // static const String initial = '/authentication-screen';
  static const String initial = '/splash-screen';
  static const String splash = '/splash-screen';
  static const String homeDashboard = '/home-dashboard';
  static const String aiCoachingChat = '/ai-coaching-chat';
  static const String authentication = '/authentication-screen';
  static const String subscriptionManagement = '/subscription-management';
  static const String onboardingFlow = '/onboarding-flow';
  static const String faq = '/faq';


  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    homeDashboard: (context) => const HomeDashboard(),
    aiCoachingChat: (context) => const AiCoachingChat(),
    authentication: (context) => const AuthenticationScreen(),
    subscriptionManagement: (context) => const SubscriptionManagement(),
    onboardingFlow: (context) => const OnboardingFlow(),
    faq: (context) => const FaqScreen(),


  };
}