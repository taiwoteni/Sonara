import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonara/core/utils/theme.dart';
import 'package:sonara/core/router/router.dart';

class Sonara extends StatefulWidget {
  static const Sonara instance = Sonara._internal();

  factory Sonara() => instance;

  const Sonara._internal();

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
        iconTheme: IconThemeData(color: Colors.white),
        extensions: <ThemeExtension<dynamic>>[
          FontThemeExtension(
            lufgaThin: TextStyle(
              fontFamily: 'Lufga',
              fontWeight: FontWeight.w100,
              color: Colors.white,
            ),
            lufgaExtraLight: TextStyle(
              fontFamily: 'Lufga',
              fontWeight: FontWeight.w200,
              color: Colors.white,
            ),
            lufgaLight: TextStyle(
              fontFamily: 'Lufga',
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
            lufgaRegular: TextStyle(
              fontFamily: 'Lufga',
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
            lufgaMedium: TextStyle(
              fontFamily: 'Lufga',
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            lufgaSemiBold: TextStyle(
              fontFamily: 'Lufga',
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            lufgaBold: TextStyle(
              fontFamily: 'Lufga',
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            lufgaExtraBold: TextStyle(
              fontFamily: 'Lufga',
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            lufgaBlack: TextStyle(
              fontFamily: 'Lufga',
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            spaceGroteskLight: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
            spaceGroteskRegular: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
            spaceGroteskMedium: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            spaceGroteskSemiBold: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            spaceGroteskBold: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontWeight: FontWeight.w700,
              color: Colors.white,
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
