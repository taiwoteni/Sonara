import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sonara/core/utils/extensions/transforms_extensions.dart';
import 'package:sonara/features/audio/domain/entities/song.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:sonara/core/utils/colors.dart';

class CDArtworkWidget extends StatelessWidget {
  final double size;
  final String? artworkPath;
  final Color dominantColor;
  final Color? secondaryColor;
  final Song song;

  const CDArtworkWidget({
    super.key,
    required this.size,
    this.artworkPath,
    this.dominantColor = AppColors.background_2,
    this.secondaryColor,
    required this.song,
  });

  @override
  Widget build(BuildContext context) {
    final outerRadius = size / 2;
    final innerRadius =
        outerRadius * 0.19; // CD hole size (18% of outer radius)

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // White CD border - outer ring
          Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),

          // Artwork ring with white border around hole
          ClipPath(
            clipper: CDCircleClipper(
              outerRadius:
                  outerRadius * 0.98, // Slightly smaller for white border
              innerRadius:
                  innerRadius * 1.1, // Slightly larger for white border
            ),
            child: thumbnailWidget(),
          ),

          // White border around the hole
          Container(
            width: innerRadius * 2.2,
            height: innerRadius * 2.2,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: innerRadius * 2,
            height: innerRadius * 2,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),

          // Dominant color in the hole
          Container(
            width: innerRadius * 2,
            height: innerRadius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: secondaryColor != null ? null : dominantColor,
              gradient: secondaryColor == null
                  ? null
                  : LinearGradient(
                      colors: [
                        dominantColor.withOpacity(.5),
                        secondaryColor!.withOpacity(.5),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.4, 1],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to build thumbnail image with robust error handling
  Widget thumbnailWidget() {
    if (artworkPath != null) {
      return Image.file(
        File(artworkPath!),
        width: double.maxFinite,
        height: double.maxFinite,
        errorBuilder: (_, __, ___) => defaultThumbnailWidget(),
        fit: BoxFit.cover,
      );
    }

    return defaultThumbnailWidget();
  }

  Widget defaultThumbnailWidget() {
    final icon = Icon(
      IconsaxPlusLinear.musicnote,
      color: Colors.white54,
      size: 30,
    );

    final icon2 = Icon(
      IconsaxPlusLinear.music,
      color: Colors.white54,
      size: 30,
    );

    final icon3 = Icon(
      IconsaxPlusLinear.star_1,
      color: Colors.white54,
      size: 30,
    );

    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      color: AppColors.background_2,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 25,
            left: size * .48,
            child: icon.scale(.9).rotate(17),
          ),
          Positioned(
            top: size * .28,
            right: size * .55,
            child: icon3.scale(.8).rotate(17),
          ),

          Positioned(
            top: size * .25,
            right: size * .2,
            child: icon2.rotate(307),
          ),
          Positioned(
            right: size * .2,
            top: size * .55,
            child: icon.scale(.9).rotate(10),
          ),
          Positioned(
            bottom: 35,
            right: size * .2,
            child: icon3.scale(.6).rotate(75),
          ),
          Positioned(
            bottom: 50,
            right: size * .45,
            child: icon2.scale(.8).rotate(5),
          ),
          Positioned(
            left: size * .2,
            bottom: size * .13,
            child: icon.scale(.7).rotate(205),
          ),
          Positioned(
            bottom: size * .32,
            left: size * .22,
            child: icon3.scale(.6).rotate(75),
          ),
          Positioned(
            top: size * .35,
            left: size * .08,
            child: icon2.scale(.8).rotate(15),
          ),
        ],
      ),
    );
  }
}

class CDCircleClipper extends CustomClipper<Path> {
  final double outerRadius;
  final double innerRadius;

  CDCircleClipper({required this.outerRadius, required this.innerRadius});

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addOval(Rect.fromCircle(center: center, radius: outerRadius))
      ..addOval(Rect.fromCircle(center: center, radius: innerRadius));

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
