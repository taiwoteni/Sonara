import 'package:flutter/material.dart';

/// A customized popup menu item model specifically created to override the default
/// rendering of the item to include a custom icon.
class SonaraPopupMenuItem<String> extends PopupMenuItem<String> {
  /// [label] is the text that will be displayed on the menu item.
  final String label;

  /// [value] is the value that will be returned when the menu item is selected.

  /// [icon] is the icon that will be displayed on the menu item.
  final IconData icon;

  const SonaraPopupMenuItem({
    super.key,
    super.child,
    super.value,
    super.onTap,
    required this.icon,
    required this.label,
  });

  @override
  Widget? get child {
    return ListTile(
      leading: Icon(icon, size: 17, color: Colors.white.withValues(alpha: .8)),
      style: ListTileStyle.drawer,
      horizontalTitleGap: 6,
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(
        label.toString(),
        style: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: .8),
          fontSize: 10,
        ),
      ),
    );
  }
}
