import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgIcon extends StatelessWidget {
  final String src;
  final Color? color;
  final Size? size;
  final BoxFit? fit;
  const SvgIcon({
    super.key,
    required this.src,
    this.fit,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return color != null
        ? ColorFiltered(
            colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
            child: svgIcon(),
          )
        : svgIcon();
  }

  Widget svgIcon() {
    return SvgPicture.asset(
      src,
      width: size?.width,
      height: size?.height,
      fit: fit ?? BoxFit.contain,
    );
  }
}
