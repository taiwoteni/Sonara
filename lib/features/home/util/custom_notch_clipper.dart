import 'package:flutter/material.dart';

class CustomNotchClipper extends CustomClipper<Path> {
  final double cornerRadius;
  final double notchRadius;
  final double notchOffset;
  final double notchEdgeSmoothness;

  CustomNotchClipper({
    this.cornerRadius = 25.0,
    this.notchRadius = 30.0,
    this.notchOffset = 0.0,
    this.notchEdgeSmoothness = 10.0,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final double width = size.width;
    final double height = size.height;
    final double notchCenterX = width / 2 + notchOffset;

    // Start from the bottom-left corner (with rounded corner)
    path.moveTo(cornerRadius, 0);
    path.lineTo(notchCenterX - notchRadius - notchEdgeSmoothness, 0);

    // Smooth transition into the notch
    path.quadraticBezierTo(
      notchCenterX - notchRadius,
      0,
      notchCenterX - notchRadius,
      notchRadius * 0.3,
    );

    // Draw the circular notch at the top center
    path.arcToPoint(
      Offset(notchCenterX + notchRadius, 0 + notchRadius * 0.3),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    // Smooth transition out of the notch
    path.quadraticBezierTo(
      notchCenterX + notchRadius,
      0,
      notchCenterX + notchRadius + notchEdgeSmoothness,
      0,
    );

    // Continue to the top-right corner (with rounded corner)
    path.lineTo(width - cornerRadius, 0);
    path.arcToPoint(
      Offset(width, cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );

    // Draw right side to bottom-right corner
    path.lineTo(width, height - cornerRadius);
    path.arcToPoint(
      Offset(width - cornerRadius, height),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );

    // Draw bottom side to bottom-left corner
    path.lineTo(cornerRadius, height);
    path.arcToPoint(
      Offset(0, height - cornerRadius),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );

    // Draw left side back to starting point
    path.lineTo(0, cornerRadius);
    path.arcToPoint(
      Offset(cornerRadius, 0),
      radius: Radius.circular(cornerRadius),
      clockwise: true,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomNotchClipper oldClipper) {
    return cornerRadius != oldClipper.cornerRadius ||
        notchRadius != oldClipper.notchRadius ||
        notchOffset != oldClipper.notchOffset ||
        notchEdgeSmoothness != oldClipper.notchEdgeSmoothness;
  }
}
