import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sonara/features/home/presentation/widgets/bottom_bar.dart';
import 'package:sonara/features/splash/presentation/widgets/splash_background.dart';

class HomeScreen extends StatefulWidget {
  final Widget child;
  const HomeScreen({super.key, required this.child});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SplashBackground(
      type: SplashBacgroundType.spread,
      fadeAtBottom: true,
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: const SonaraFAB(),
      bottomBar: SonaraBottomBar(
        currentRoute: GoRouter.of(context).state.uri.path,
      ),
      child: widget.child,
    );
  }
}
