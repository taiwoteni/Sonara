import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:sonara/core/components/svg_widget.dart';
import 'package:sonara/core/di/service_locator.dart';
import 'package:sonara/core/utils/colors.dart';
import 'package:sonara/core/utils/extensions/device_query_extensions.dart';
import 'package:sonara/core/utils/services/audio_service.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';
import 'package:sonara/features/songs/presentation/widgets/mini_player.dart';
import 'package:sonara/features/home/data/datasources/navigation_menu_datasource.dart';

class SonaraBottomBar extends StatelessWidget {
  final String currentRoute;
  const SonaraBottomBar({super.key, required this.currentRoute});

  int getCurrentIndex(BuildContext context) {
    log("Current home shell route is: $currentRoute", name: 'BottomBar');
    if (currentRoute == '/home/discover') {
      return 0;
    } else if (currentRoute.contains('song')) {
      return 1;
    } else if (currentRoute.contains('playlist')) {
      return 3;
    } else if (currentRoute == '/home/settings') {
      return 4;
    } else {
      return 2; // Default to first item
    }
  }

  void navigateToRoute(BuildContext context, int index) {
    final routes = [
      '/home/discover',
      '/home/songs',
      '/home/ai',
      '/home/playlists',
      '/home/settings',
    ];
    context.go(routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = getCurrentIndex(context);
    return StreamBuilder<Song?>(
      stream: getIt<AudioService>().currentSongStream,
      builder: (context, asyncSnapshot) {
        final isPlaying = asyncSnapshot.hasData;
        return Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRect(
                child: SizedBox.fromSize(
                  size: Size.fromHeight(
                    (isPlaying ? 125 : 72) + context.systemNavPadding,
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.black45),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ).copyWith(bottom: context.systemNavPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                spacing: 10,
                children: [
                  const MiniPlayer(),
                  // Bottom bar is 62 in height
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: MediaQuery.removePadding(
                      context: context,
                      removeBottom: true,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                        child: BottomAppBar(
                          height: 62,
                          color: AppColors.background,
                          padding: EdgeInsets.zero,
                          child: BottomNavigationBar(
                            backgroundColor: AppColors.background_2,
                            elevation: 0,
                            showUnselectedLabels: false,
                            currentIndex: currentIndex,
                            showSelectedLabels: false,
                            iconSize: 28,
                            type: BottomNavigationBarType.fixed,
                            onTap: (index) => navigateToRoute(context, index),
                            items: [
                              ...navigationMenus
                                  .sublist(0, 2)
                                  .map(
                                    (menu) => BottomNavigationBarItem(
                                      icon: Icon(
                                        menu.icon,
                                        color: Colors.white54,
                                      ),
                                      tooltip: menu.label,
                                      activeIcon: Icon(
                                        menu.selectedIcon,
                                        color: Colors.white,
                                      ),
                                      label: menu.label,
                                    ),
                                  ),

                              BottomNavigationBarItem(
                                tooltip: 'AI',
                                icon: SvgIcon(
                                  src: 'assets/icons/messenger.svg',
                                  color: Colors.white54,
                                  size: Size.square(28),
                                ),
                                activeIcon: SvgIcon(
                                  src: 'assets/icons/messenger-bold.svg',
                                  color: Colors.white,
                                  size: Size.square(28),
                                ),
                                label: 'AI',
                              ),

                              ...navigationMenus
                                  .sublist(2)
                                  .map(
                                    (menu) => BottomNavigationBarItem(
                                      icon: Icon(
                                        menu.icon,
                                        color: Colors.white54,
                                      ),
                                      activeIcon: Icon(
                                        menu.selectedIcon,
                                        color: Colors.white,
                                      ),
                                      tooltip: menu.label,
                                      label: menu.label,
                                    ),
                                  ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Gap(0),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

Stream<double> buttomBarSpacing(BuildContext context) {
  const offset = 30;
  final totalBottomNavHeight = 72 + context.systemNavPadding;
  return getIt<AudioService>().currentSongStream.map((song) {
    if (song == null) {
      return totalBottomNavHeight + offset;
    }

    return totalBottomNavHeight + offset + 70;
  });
}

Widget bottomBarSpacer(BuildContext context) {
  return StreamBuilder(
    stream: buttomBarSpacing(context),
    builder: (context, snapshot) => Gap(snapshot.data ?? 0),
  );
}
