import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_customers/screens/splash_screen.dart';
import 'package:foodtogo_customers/screens/user_register_screen.dart';
import 'package:foodtogo_customers/settings/kTheme.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodToGo - Customers',
      theme: KTheme.kTheme,
      home: const Scaffold(
        body: SplashScreen(),
        // body: UserRegisterScreen(),
      ),
    );
  }
}
