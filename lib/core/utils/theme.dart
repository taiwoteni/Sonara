import 'package:flutter/material.dart';

/// Custom theme extension for font styles with Lufga and SpaceGrotesk
class FontThemeExtension extends ThemeExtension<FontThemeExtension> {
  // Lufga styles
  final TextStyle lufgaThin;
  final TextStyle lufgaExtraLight;
  final TextStyle lufgaLight;
  final TextStyle lufgaRegular;
  final TextStyle lufgaMedium;
  final TextStyle lufgaSemiBold;
  final TextStyle lufgaBold;
  final TextStyle lufgaExtraBold;
  final TextStyle lufgaBlack;

  // SpaceGrotesk styles
  final TextStyle spaceGroteskLight;
  final TextStyle spaceGroteskRegular;
  final TextStyle spaceGroteskMedium;
  final TextStyle spaceGroteskSemiBold;
  final TextStyle spaceGroteskBold;

  FontThemeExtension({
    required this.lufgaThin,
    required this.lufgaExtraLight,
    required this.lufgaLight,
    required this.lufgaRegular,
    required this.lufgaMedium,
    required this.lufgaSemiBold,
    required this.lufgaBold,
    required this.lufgaExtraBold,
    required this.lufgaBlack,
    required this.spaceGroteskLight,
    required this.spaceGroteskRegular,
    required this.spaceGroteskMedium,
    required this.spaceGroteskSemiBold,
    required this.spaceGroteskBold,
  });

  @override
  ThemeExtension<FontThemeExtension> copyWith({
    TextStyle? lufgaThin,
    TextStyle? lufgaExtraLight,
    TextStyle? lufgaLight,
    TextStyle? lufgaRegular,
    TextStyle? lufgaMedium,
    TextStyle? lufgaSemiBold,
    TextStyle? lufgaBold,
    TextStyle? lufgaExtraBold,
    TextStyle? lufgaBlack,
    TextStyle? spaceGroteskLight,
    TextStyle? spaceGroteskRegular,
    TextStyle? spaceGroteskMedium,
    TextStyle? spaceGroteskSemiBold,
    TextStyle? spaceGroteskBold,
  }) {
    return FontThemeExtension(
      lufgaThin: lufgaThin ?? this.lufgaThin,
      lufgaExtraLight: lufgaExtraLight ?? this.lufgaExtraLight,
      lufgaLight: lufgaLight ?? this.lufgaLight,
      lufgaRegular: lufgaRegular ?? this.lufgaRegular,
      lufgaMedium: lufgaMedium ?? this.lufgaMedium,
      lufgaSemiBold: lufgaSemiBold ?? this.lufgaSemiBold,
      lufgaBold: lufgaBold ?? this.lufgaBold,
      lufgaExtraBold: lufgaExtraBold ?? this.lufgaExtraBold,
      lufgaBlack: lufgaBlack ?? this.lufgaBlack,
      spaceGroteskLight: spaceGroteskLight ?? this.spaceGroteskLight,
      spaceGroteskRegular: spaceGroteskRegular ?? this.spaceGroteskRegular,
      spaceGroteskMedium: spaceGroteskMedium ?? this.spaceGroteskMedium,
      spaceGroteskSemiBold: spaceGroteskSemiBold ?? this.spaceGroteskSemiBold,
      spaceGroteskBold: spaceGroteskBold ?? this.spaceGroteskBold,
    );
  }

  @override
  ThemeExtension<FontThemeExtension> lerp(
    covariant ThemeExtension<FontThemeExtension>? other,
    double t,
  ) {
    if (other is! FontThemeExtension) {
      return this;
    }
    return FontThemeExtension(
      lufgaThin: TextStyle.lerp(lufgaThin, other.lufgaThin, t)!,
      lufgaExtraLight: TextStyle.lerp(
        lufgaExtraLight,
        other.lufgaExtraLight,
        t,
      )!,
      lufgaLight: TextStyle.lerp(lufgaLight, other.lufgaLight, t)!,
      lufgaRegular: TextStyle.lerp(lufgaRegular, other.lufgaRegular, t)!,
      lufgaMedium: TextStyle.lerp(lufgaMedium, other.lufgaMedium, t)!,
      lufgaSemiBold: TextStyle.lerp(lufgaSemiBold, other.lufgaSemiBold, t)!,
      lufgaBold: TextStyle.lerp(lufgaBold, other.lufgaBold, t)!,
      lufgaExtraBold: TextStyle.lerp(lufgaExtraBold, other.lufgaExtraBold, t)!,
      lufgaBlack: TextStyle.lerp(lufgaBlack, other.lufgaBlack, t)!,
      spaceGroteskLight: TextStyle.lerp(
        spaceGroteskLight,
        other.spaceGroteskLight,
        t,
      )!,
      spaceGroteskRegular: TextStyle.lerp(
        spaceGroteskRegular,
        other.spaceGroteskRegular,
        t,
      )!,
      spaceGroteskMedium: TextStyle.lerp(
        spaceGroteskMedium,
        other.spaceGroteskMedium,
        t,
      )!,
      spaceGroteskSemiBold: TextStyle.lerp(
        spaceGroteskSemiBold,
        other.spaceGroteskSemiBold,
        t,
      )!,
      spaceGroteskBold: TextStyle.lerp(
        spaceGroteskBold,
        other.spaceGroteskBold,
        t,
      )!,
    );
  }
}

/// BuildContext extension for easy access to custom font styles
extension FontThemeContextExtension on BuildContext {
  FontThemeExtension get fontTheme =>
      Theme.of(this).extension<FontThemeExtension>()!;

  // Lufga getters
  TextStyle get lufgaThin => fontTheme.lufgaThin;
  TextStyle get lufgaExtraLight => fontTheme.lufgaExtraLight;
  TextStyle get lufgaLight => fontTheme.lufgaLight;
  TextStyle get lufgaRegular => fontTheme.lufgaRegular;
  TextStyle get lufgaMedium => fontTheme.lufgaMedium;
  TextStyle get lufgaSemiBold => fontTheme.lufgaSemiBold;
  TextStyle get lufgaBold => fontTheme.lufgaBold;
  TextStyle get lufgaExtraBold => fontTheme.lufgaExtraBold;
  TextStyle get lufgaBlack => fontTheme.lufgaBlack;

  // SpaceGrotesk getters
  TextStyle get spaceGroteskLight => fontTheme.spaceGroteskLight;
  TextStyle get spaceGroteskRegular => fontTheme.spaceGroteskRegular;
  TextStyle get spaceGroteskMedium => fontTheme.spaceGroteskMedium;
  TextStyle get spaceGroteskSemiBold => fontTheme.spaceGroteskSemiBold;
  TextStyle get spaceGroteskBold => fontTheme.spaceGroteskBold;
}
