import 'package:flutter/widgets.dart';

/// Extension on [Widget] to apply padding properties easily.
extension PaddingExtension on Widget {
  /// Applies symmetric padding horizontally and/or vertically.
  /// Use [horizontal] for left and right padding, [vertical] for top and bottom padding.
  Widget symmetric({double horizontal = 0.0, double vertical = 0.0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }

  /// Applies padding only to specified sides.
  /// Set individual parameters to apply padding to specific sides.
  /// Unspecified sides will have zero padding.
  Widget only({
    double top = 0.0,
    double bottom = 0.0,
    double left = 0.0,
    double right = 0.0,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
      ),
      child: this,
    );
  }
}
