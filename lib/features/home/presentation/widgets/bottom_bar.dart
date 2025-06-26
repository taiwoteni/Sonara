import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:sonara/core/utils/colors.dart';
import 'package:sonara/features/songs/presentation/widgets/mini_player.dart';
import 'package:sonara/features/home/data/datasources/navigation_menu_datasource.dart';
import 'package:sonara/features/home/util/custom_notch_clipper.dart';

class SonaraBottomBar extends StatelessWidget {
  final String currentRoute;
  const SonaraBottomBar({super.key, required this.currentRoute});

  int _getCurrentIndex(BuildContext context) {
    log("Current home shell route is: $currentRoute", name: 'BottomBar');
    if (currentRoute == '/home/discover') {
      return 0;
    } else if (currentRoute == '/home/songs') {
      return 1;
    } else if (currentRoute == '/home/playlists') {
      return 2;
    } else if (currentRoute == '/home/settings') {
      return 3;
    } else {
      return -1; // Default to first item
    }
  }

  void _navigateToRoute(BuildContext context, int index) {
    final routes = [
      '/home/discover',
      '/home/songs',
      '/home/playlists',
      '/home/settings',
    ];
    context.go(routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 3,
      children: [
        const MiniPlayer(),
        Container(
          width: double.maxFinite,
          height: 115,
          // color: Colors.black,
          child: Stack(
            children: [
              Positioned(
                left: 12,
                right: 12,
                bottom: 25,
                child: SizedBox(
                  width: double.maxFinite,
                  child: ClipPath(
                    clipper: CustomNotchClipper(
                      cornerRadius: 25.0,
                      notchRadius: 36.0,
                      notchOffset: 0.0,
                      notchEdgeSmoothness: 10,
                    ),
                    child: Container(
                      color: AppColors.background,
                      height: 75.0,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Left side navigation items
                          ...navigationMenus
                              .sublist(0, 2)
                              .map(
                                (item) => GestureDetector(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Icon(
                                      currentIndex ==
                                              navigationMenus.indexOf(item)
                                          ? item.selectedIcon
                                          : item.icon,
                                      color:
                                          currentIndex ==
                                              navigationMenus.indexOf(item)
                                          ? AppColors.purple
                                          : Colors.white70,
                                      size: 28,
                                    ),
                                  ),
                                  onTap: () {
                                    _navigateToRoute(
                                      context,
                                      navigationMenus.indexOf(item),
                                    );
                                  },
                                ),
                              ),
                          // Space for the notch (FAB will be centered over this)
                          const SizedBox(width: 80),
                          // Right side navigation items
                          ...navigationMenus
                              .sublist(2)
                              .map(
                                (item) => GestureDetector(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Icon(
                                      currentIndex ==
                                              navigationMenus.indexOf(item)
                                          ? item.selectedIcon
                                          : item.icon,
                                      color:
                                          currentIndex ==
                                              navigationMenus.indexOf(item)
                                          ? AppColors.purple
                                          : Colors.white70,
                                      size: 28,
                                    ),
                                  ),
                                  onTap: () {
                                    _navigateToRoute(
                                      context,
                                      navigationMenus.indexOf(item),
                                    );
                                  },
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 1,
                left: 0,
                right: 0,
                child: sonaraAIButton(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget sonaraAIButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.goNamed('ai'),
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.purple,
              Colors.deepPurple.shade600,
              Colors.purple.shade800,
            ],
            stops: [0.4, 0.6, 1.0],
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(IconsaxPlusLinear.cpu),
      ),
    );
  }
}

// Optional: Floating Action Button to be used with the notch
class SonaraFAB extends StatelessWidget {
  const SonaraFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      shape: const StadiumBorder(),
      tooltip: 'Sonara AI',
      onPressed: () {
        // Placeholder for central action
      },
      backgroundColor: AppColors.purple,
      child: const Icon(IconsaxPlusBold.cpu, color: Colors.white, size: 28),
    );
  }
}
