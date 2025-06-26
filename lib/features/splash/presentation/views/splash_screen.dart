import 'package:flutter/material.dart';
import 'package:sonara/features/splash/presentation/widgets/splash_background.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      // Add a delay to simulate loading or transition to the next screen
      Future.delayed(const Duration(seconds: 3), () {
        // Navigate to the onboarding screen using GoRouter
        context.go('/onboarding');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SplashBackground(
      child: Center(
        child: Image.asset(
          'assets/Sonara-Transparent.png',
          width: 200, // Adjust size as needed
          height: 200,
        ),
      ),
    );
  }
}
