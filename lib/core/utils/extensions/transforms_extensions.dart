import 'dart:math' as math;
import 'package:flutter/widgets.dart';

/// Extension on [Widget] to apply transform properties easily.
extension TransformExtensions on Widget {
  /// Rotates the widget by the specified [degrees] (0 to 360).
  /// Internally converts degrees to radians for Flutter's Transform widget.
  Widget rotate(double degrees) {
    final radians = degrees * (math.pi / 180.0);
    return Transform.rotate(angle: radians, child: this);
  }

  /// Scales the widget by the specified [factor].
  /// A factor of 1.0 is the original size, >1.0 enlarges, <1.0 shrinks.
  Widget scale(double factor) {
    return Transform.scale(scale: factor, child: this);
  }

  /// Translates the widget by the specified [dx] (horizontal) and [dy] (vertical) offsets.
  Widget translate({double dx = 0.0, double dy = 0.0}) {
    return Transform.translate(offset: Offset(dx, dy), child: this);
  }

  /// Flips the widget horizontally or vertically.
  /// Set [horizontal] to true to flip horizontally, [vertical] to true to flip vertically.
  /// If both are true, the widget will be flipped in both directions.
  Widget flip({bool horizontal = false, bool vertical = false}) {
    return Transform.scale(
      scaleX: horizontal ? -1.0 : 1.0,
      scaleY: vertical ? -1.0 : 1.0,
      child: this,
    );
  }
}
