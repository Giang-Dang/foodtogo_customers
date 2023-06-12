import 'package:flutter/material.dart';
import 'package:foodtogo_customers/screens/splash_screen.dart';
import 'package:foodtogo_customers/screens/tabs_screen.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';
import 'package:foodtogo_customers/util/material_color_creator.dart';
import 'package:google_fonts/google_fonts.dart';

final kColorScheme = ColorScheme.fromSwatch(
  primarySwatch: MaterialColorCreator.createMaterialColor(
    KColors.kPrimaryColor,
  ),
);

final kTheme = ThemeData(
  textTheme: GoogleFonts.bitterTextTheme(),
).copyWith(
  useMaterial3: true,
  colorScheme: kColorScheme,
  textTheme: GoogleFonts.bitterTextTheme().copyWith(
    titleSmall: GoogleFonts.dosis(
      fontWeight: FontWeight.bold,
    ),
    titleMedium: GoogleFonts.dosis(
      fontWeight: FontWeight.bold,
    ),
    titleLarge: GoogleFonts.dosis(
      fontWeight: FontWeight.bold,
    ),
  ),
  cardTheme: const CardTheme().copyWith(
    color: KColors.kOnBackgroundColor,
  ),
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodToGo - Customers',
      theme: kTheme,
      home: const Scaffold(
        body: SplashScreen(),
        // body: TabsScreen(),
      ),
    );
  }
}
