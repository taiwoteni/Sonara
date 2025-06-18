import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sonara/core/utils/extensions/device_query_extensions.dart';
import 'package:sonara/features/onboarding/data/datasources/onboarding_items_datasource.dart';
import 'package:sonara/features/splash/presentation/widgets/splash_background.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SplashBackground(
      floatingActionButton: _currentPage == onboardingItems.length - 1
          ? Padding(
              padding: EdgeInsetsGeometry.all(1),
              child: FloatingActionButton.small(
                onPressed: () {
                  context.push('/home');
                },
                backgroundColor: Colors.white,
                shape: const CircleBorder(),
                child: const Icon(
                  IconsaxPlusLinear.arrow_right,
                  color: Colors.black,
                ),
              ),
            )
          : null,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: onboardingItems.length,
                itemBuilder: (context, index) {
                  final item = onboardingItems[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: context.screenSize.width * 0.8,
                        height: context.screenSize.width * 1.1,
                        child: Image.asset(
                          item.illustration,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          item.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  onboardingItems.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    height: 10,
                    width: _currentPage == index ? 30 : 10,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
