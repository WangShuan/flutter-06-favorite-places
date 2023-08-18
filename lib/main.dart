import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:google_fonts/google_fonts.dart';

import './screens/places_screen.dart';

final colorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 255, 252, 231),
  brightness: Brightness.dark,
);

final theme = ThemeData().copyWith(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: colorScheme.background,
  colorScheme: colorScheme,
  textTheme: GoogleFonts.kiwiMaruTextTheme()
      .copyWith(
        titleSmall: GoogleFonts.kiwiMaru(
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
        titleMedium: GoogleFonts.kiwiMaru(
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
        titleLarge: GoogleFonts.kiwiMaru(
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
      )
      .apply(
        bodyColor: colorScheme.primary,
      ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Great Places',
      theme: theme,
      home: const PlacesScreen(),
    );
  }
}
