import 'package:flutter/material.dart';

extension DeviceQueryExtensions on BuildContext {
  /// Private getter to centralize the MediaQueryData retrieval.
  MediaQueryData get _mediaQuery => MediaQuery.of(this);

  /// Returns the device's screen size as a [Size] object.
  Size get screenSize => _mediaQuery.size;

  /// Returns the bottom inset height caused by the keyboard.
  double get keyboardBottomInsets => _mediaQuery.viewInsets.bottom;

  /// Returns the top padding, typically corresponding to the status bar height.
  double get statusBarPadding => _mediaQuery.viewPadding.top;

  /// Returns the bottom padding, typically corresponding to the system's notch or navigator padding.
  double get systemNavPadding => _mediaQuery.viewPadding.bottom;

  /// Returns an [EdgeInsets] with top padding from the status bar and bottom padding from the keyboard.
  EdgeInsets get safeAreaInsets =>
      _mediaQuery.padding.copyWith(bottom: _mediaQuery.viewInsets.bottom);
}
