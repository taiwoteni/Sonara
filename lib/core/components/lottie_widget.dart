import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieWidget extends StatelessWidget {
  final String src;
  final bool loop;
  final BoxFit fit;
  final Size size;
  final Color? color;
  const LottieWidget({
    super.key,
    required this.src,
    this.size = const Size.square(28),
    this.fit = BoxFit.cover,
    this.color,
    this.loop = true,
  });

  Widget lottie() {
    return Lottie.asset(
      src,
      width: size.width,
      height: size.height,
      fit: fit,
      repeat: loop,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (color != null) {
      return ColorFiltered(
        colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
        child: lottie(),
      );
    }

    return lottie();
  }
}
