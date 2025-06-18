import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sonara/sonara.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

  // Enforce portrait orientation (portraitUp only) for the entire app
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(Sonara.instance);
}
