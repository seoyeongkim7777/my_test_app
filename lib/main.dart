import 'package:flutter/material.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/onboarding_page.dart';
import 'pages/item_submission_page.dart';
import 'pages/nearby_items_page.dart';
import 'pages/loading_page.dart';
import 'theme/app_theme.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Price Lens',
      theme: AppTheme.lightTheme,
      home: const SplashPage(),
      routes: {
        '/splash': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/onboarding': (context) => const OnboardingPage(userId: ''),
        '/loading': (context) => const LoadingPage(),
        '/submit-item': (context) => const ItemSubmissionPage(),
        '/nearby-items': (context) => const NearbyItemsPage(),
        // Note: price-comparison and store-detail routes are handled via navigation
        // with actual data rather than static routes
        // '/theme-preview': (context) => const SampleThemePreview(), // Optional route
      },
    );
  }
}


