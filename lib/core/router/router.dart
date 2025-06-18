import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sonara/features/audio/presentation/screens/audio_list_screen.dart';
import 'package:sonara/features/home/presentation/views/home_screen.dart';
import 'package:sonara/features/splash/presentation/views/splash_screen.dart';
import 'package:sonara/features/onboarding/presentation/views/onboarding_screen.dart';

// GoRouter configuration
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: '/onboarding',
      builder: (BuildContext context, GoRouterState state) {
        return const OnboardingScreen();
      },
    ),
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: '/audio',
      builder: (BuildContext context, GoRouterState state) {
        return const AudioListScreen();
      },
    ),
    // Add more routes here as needed (e.g., home, login)
  ],
);
