import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:sonara/core/utils/colors.dart';
import 'package:sonara/core/utils/extensions/device_query_extensions.dart';

enum SplashBacgroundType {
  top,
  bottom,
  spread;

  bool get isBottom => this == SplashBacgroundType.bottom;
  bool get isTop => this == SplashBacgroundType.top;
  bool get isSpread => !(isBottom || isTop);
}

class SplashBackground extends StatefulWidget {
  final Widget? child;
  final Widget? floatingActionButton;
  final bool fadeAtBottom;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomBar;
  final EdgeInsets? padding;
  final SplashBacgroundType type;

  const SplashBackground({
    super.key,
    this.child,
    this.padding,
    this.bottomBar,
    this.floatingActionButtonLocation,
    this.floatingActionButton,
    this.type = SplashBacgroundType.bottom,
    this.fadeAtBottom = false,
  });

  @override
  State<SplashBackground> createState() => _SplashBackgroundState();
}

class _SplashBackgroundState extends State<SplashBackground> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: widget.floatingActionButton,
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      bottomNavigationBar: widget.bottomBar,
      extendBody: true,
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        alignment: Alignment.center,
        color: AppColors.background_2,
        child: Stack(
          children: [
            SizedBox(
              width: double.maxFinite,
              height: double.maxFinite,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        width: double.maxFinite,
                        height: context.screenSize.height * .45,
                        color: AppColors.background,
                      ),
                    ),
                  ),

                  // Three large circles positioned
                  if (widget.type.isBottom)
                    ...bottomCircles()
                  else if (widget.type.isSpread)
                    ...spreadCircles()
                  else if (widget.type.isTop)
                    ...topCircles(),

                  // Semi-transparent overlay for overall background softness
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10),
                    child: Container(
                      width: double.maxFinite,
                      height: double.maxFinite,
                      color: Colors.black.withOpacity(0.45),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: double.maxFinite,
              height: double.maxFinite,
              padding: widget.padding,
              child: widget.child,
            ),

            // if (widget.fadeAtBottom)
            // Positioned(
            //   width: double.maxFinite,
            //   left: 0,
            //   bottom: 0,
            //   child: Container(
            //     width: double.maxFinite,
            //     height: context.screenSize.height * .08,
            //     decoration: BoxDecoration(
            //       gradient: LinearGradient(
            //         begin: Alignment.topCenter,
            //         end: Alignment.bottomCenter,
            //         colors: [Colors.transparent, Colors.black],
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  List<Widget> bottomCircles() {
    return [
      Positioned(
        bottom: context.screenSize.height * 0.1,
        right: context.screenSize.width * -0.1,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            width: context.screenSize.width * 0.4,
            height: context.screenSize.height * 0.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.pink.withOpacity(0.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.pink.withOpacity(0.25),
                  blurRadius: 80,
                  spreadRadius: 50,
                ),
              ],
            ),
          ),
        ),
      ),

      // Circle 2
      Positioned(
        bottom: context.screenSize.height * 0.005,
        left: context.screenSize.width * -0.2,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            width: context.screenSize.width * 0.8,
            height: context.screenSize.height * 0.65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.purple.withOpacity(0.00),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple.withOpacity(0.2),
                  blurRadius: 70,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
        ),
      ),

      // Circle 3
      Positioned(
        bottom: context.screenSize.height * .01,
        left: context.screenSize.width * .2,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 10.0),
          child: Container(
            width: context.screenSize.width * 0.5,
            height: context.screenSize.height * 0.3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.purple_2.withOpacity(0.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.pink_2.withOpacity(0.2),
                  blurRadius: 100,
                  spreadRadius: 70,
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> topCircles() {
    return [
      Positioned(
        bottom: context.screenSize.height * 0.1,
        right: context.screenSize.width * -0.1,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            width: context.screenSize.width * 0.4,
            height: context.screenSize.height * 0.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.pink.withOpacity(0.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.pink.withOpacity(0.25),
                  blurRadius: 80,
                  spreadRadius: 50,
                ),
              ],
            ),
          ),
        ),
      ),

      // Circle 2
      Positioned(
        bottom: context.screenSize.height * 0.005,
        left: context.screenSize.width * -0.2,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            width: context.screenSize.width * 0.8,
            height: context.screenSize.height * 0.65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.purple.withOpacity(0.00),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple.withOpacity(0.2),
                  blurRadius: 70,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
        ),
      ),

      // Circle 3
      Positioned(
        bottom: context.screenSize.height * .01,
        left: context.screenSize.width * .2,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 10.0),
          child: Container(
            width: context.screenSize.width * 0.5,
            height: context.screenSize.height * 0.3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.purple_2.withOpacity(0.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.pink_2.withOpacity(0.2),
                  blurRadius: 100,
                  spreadRadius: 70,
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> spreadCircles() {
    return [
      // Circle 1
      Positioned(
        bottom: context.screenSize.height * 0.1,
        right: context.screenSize.width * -0.1,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            width: context.screenSize.width * 0.4,
            height: context.screenSize.height * 0.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.pink.withOpacity(0.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.pink.withOpacity(0.2),
                  blurRadius: 80,
                  spreadRadius: 50,
                ),
              ],
            ),
          ),
        ),
      ),

      // Circle 2
      Positioned(
        bottom: context.screenSize.height * 0.1,
        left: context.screenSize.width * -0.2,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            width: context.screenSize.width * 0.8,
            height: context.screenSize.height * 0.65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.purple.withOpacity(0.00),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.shade800.withOpacity(0.3),
                  blurRadius: 70,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
        ),
      ),

      // Circle 3
      Positioned(
        bottom: context.screenSize.height * .01,
        left: context.screenSize.width * .2,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 10.0),
          child: Container(
            width: context.screenSize.width * 0.5,
            height: context.screenSize.height * 0.3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.purple_2.withOpacity(0.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple_2.withOpacity(0.2),
                  blurRadius: 100,
                  spreadRadius: 70,
                ),
              ],
            ),
          ),
        ),
      ),

      // Circle 4
      Positioned(
        top: context.screenSize.height * .01,
        left: context.screenSize.width * .1,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 10.0),
          child: Container(
            width: context.screenSize.width,
            height: context.screenSize.height * 0.3,
            decoration: BoxDecoration(
              // shape: BoxShape.circle,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
              color: AppColors.purple.withOpacity(0.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.shade800.withOpacity(0.1),
                  blurRadius: 100,
                  spreadRadius: 70,
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }
}
