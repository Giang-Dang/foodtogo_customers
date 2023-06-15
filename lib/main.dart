import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_customers/models/online_customer_location.dart';
import 'package:foodtogo_customers/screens/login_screen.dart';
import 'package:foodtogo_customers/screens/splash_screen.dart';
import 'package:foodtogo_customers/screens/tabs_screen.dart';
import 'package:foodtogo_customers/services/online_customer_location_services.dart';
import 'package:foodtogo_customers/services/user_services.dart';
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
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      int userId = UserServices.userId ?? 0;
      if (userId != 0) {
        final onlineCustomerLocationServices = OnlineCustomerLocationServices();
        final getOCL = await onlineCustomerLocationServices.get(userId);
        if (getOCL != null) {
          onlineCustomerLocationServices.delete(userId);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodToGo - Customers',
      theme: kTheme,
      home: const Scaffold(
        // body: SplashScreen(),
        body: LoginScreen(),
      ),
    );
  }
}
