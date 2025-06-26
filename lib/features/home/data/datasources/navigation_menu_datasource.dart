import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:sonara/features/home/data/models/bottom_naviagtion_item.dart';

final navigationMenus = <BottomNaviagtionItem>[
  const BottomNaviagtionItem(
    label: 'Discover',
    icon: IconsaxPlusLinear.discover,
    selectedIcon: IconsaxPlusBold.discover_1,
    route: '/',
  ),
  const BottomNaviagtionItem(
    label: 'Songs',
    icon: IconsaxPlusLinear.musicnote,
    selectedIcon: IconsaxPlusBold.musicnote,
    route: '/songs',
  ),
  const BottomNaviagtionItem(
    label: 'Playlists',
    icon: IconsaxPlusLinear.music_filter,
    selectedIcon: IconsaxPlusBold.music_filter,
    route: '/playlists',
  ),
  const BottomNaviagtionItem(
    label: 'Settings',
    icon: IconsaxPlusLinear.setting,
    selectedIcon: IconsaxPlusBold.setting,
    route: '/settings',
  ),
];
