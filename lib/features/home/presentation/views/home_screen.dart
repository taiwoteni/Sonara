import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sonara/core/utils/colors.dart';
import 'package:sonara/features/home/presentation/widgets/bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  final Widget child;
  const HomeScreen({super.key, required this.child});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      bottomNavigationBar: SonaraBottomBar(
        currentRoute: GoRouter.of(context).state.uri.path,
      ),
      body: SizedBox.expand(child: widget.child),
    );
  }
}
