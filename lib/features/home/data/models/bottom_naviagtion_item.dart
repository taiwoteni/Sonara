import 'package:flutter/widgets.dart';

class BottomNaviagtionItem {
  final String label;
  final IconData icon, selectedIcon;
  final String route;

  const BottomNaviagtionItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });
}
