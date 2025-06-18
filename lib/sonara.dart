import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonara/core/utils/theme.dart';
import 'package:sonara/core/router/router.dart';

class Sonara extends StatefulWidget {
  const Sonara._internal();

  static const Sonara instance = Sonara._internal();

  factory Sonara() => instance;

  @override
  State<Sonara> createState() => _SonaraState();
}

class _SonaraState extends State<Sonara> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sonara',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        fontFamily: 'Lufga',
        appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontWeight: FontWeight.w700,
          ),
          displayMedium: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontWeight: FontWeight.w600,
          ),
          displaySmall: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(fontWeight: FontWeight.w400),
          bodyMedium: TextStyle(fontWeight: FontWeight.w300),
          titleMedium: TextStyle(fontWeight: FontWeight.w500),
          titleSmall: TextStyle(fontWeight: FontWeight.w400),
        ),
        primaryTextTheme: TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          displayMedium: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          displaySmall: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
          titleMedium: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          titleSmall: TextStyle(
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        useMaterial3: true,
        extensions: <ThemeExtension<dynamic>>[
          FontThemeExtension(
            lufgaThin: TextStyle(
              fontFamily: 'Lufga',
              fontWeight: FontWeight.w100,
            ),
            lufgaExtraLight: TextStyle(
              fontFamily: 'Lufga',
              fontWeight: FontWeight.w200,
            ),
            lufgaLight: TextStyle(
              fontFamily: 'Lufga',
              fontWeight: FontWeight.w300,
            ),
            lufgaRegular: TextStyle(
              fontFamily: 'Lufga',
              fontWeight: FontWeight.w400,
            ),
            lufgaMedium: TextStyle(
              fontFamily: 'Lufga',
              fontWeight: FontWeight.w500,
            ),
            lufgaSemiBold: TextStyle(
              fontFamily: 'Lufga',
              fontWeight: FontWeight.w600,
            ),
            lufgaBold: TextStyle(
              fontFamily: 'Lufga',
              fontWeight: FontWeight.w700,
            ),
            lufgaExtraBold: TextStyle(
              fontFamily: 'Lufga',
              fontWeight: FontWeight.w800,
            ),
            lufgaBlack: TextStyle(
              fontFamily: 'Lufga',
              fontWeight: FontWeight.w900,
            ),
            spaceGroteskLight: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w300,
            ),
            spaceGroteskRegular: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w400,
            ),
            spaceGroteskMedium: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w500,
            ),
            spaceGroteskSemiBold: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w600,
            ),
            spaceGroteskBold: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      routerConfig: router,
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarIconBrightness: Brightness.light,
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: child ?? Placeholder(),
      ),
    );
  }
}
