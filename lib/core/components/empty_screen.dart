import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sonara/core/components/svg_widget.dart';
import 'package:sonara/core/utils/extensions/device_query_extensions.dart';

class EmptyList extends StatelessWidget {
  final String label;
  final String icon;
  final Size? iconSize;
  final double? height;
  final BoxFit? fit;
  const EmptyList({
    super.key,
    required this.icon,
    this.height,
    this.iconSize,
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
          SvgIcon(src: icon, size: iconSize, fit: fit),
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
    );
  }
}
