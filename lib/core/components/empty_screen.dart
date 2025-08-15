import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sonara/core/components/svg_widget.dart';
import 'package:sonara/core/utils/extensions/device_query_extensions.dart';
import 'package:sonara/core/utils/theme.dart';

class EmptyList extends StatelessWidget {
  final String label;
  final String? icon;
  final Size? iconSize;
  final double? height;
  final BoxFit? fit;
  final bool isSvg;
  const EmptyList({
    super.key,
    this.icon,
    this.height,
    this.iconSize,
    this.isSvg = true,
    this.fit,
    this.label = "Empty List",
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      height: height ?? context.screenSize.height * .7,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 20,
        children: [
          if (icon != null)
            (isSvg
                ? SvgIcon(src: icon!, size: iconSize, fit: fit)
                : Image.asset(
                    icon!,
                    width: iconSize?.width,
                    height: iconSize?.height,
                    fit: fit,
                  )),
          Text(
            label,
            style: context.lufgaRegular.copyWith(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
