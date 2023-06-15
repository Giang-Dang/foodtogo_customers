import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_customers/models/dto/create_dto/online_customer_location_create_dto.dart';
import 'package:foodtogo_customers/models/online_customer_location.dart';
import 'package:foodtogo_customers/screens/login_screen.dart';
import 'package:foodtogo_customers/screens/tabs_screen.dart';
import 'package:foodtogo_customers/services/online_customer_location_services.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _textAnimationController;
  late Animation<double> _textAnimation;
  Timer? _loginTimer;

  _login() async {
    //delay for animation
    // await _delay(100);
    //loading data
    final userServices = UserServices();

    await userServices.getUserLocation();

    await userServices.checkLocalLoginAuthorized();
    if (UserServices.isAuthorized) {
      //update location to server
      final onlineCustomerLocationCreateDTO = OnlineCustomerLocationCreateDTO(
        customerId: UserServices.userId!,
        geoLatitude: UserServices.currentLatitude,
        geoLongitude: UserServices.currentLongitude,
      );

      final onlineCustomerLocationSevices = OnlineCustomerLocationServices();
      onlineCustomerLocationSevices.create(onlineCustomerLocationCreateDTO);

      //route
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TabsScreen(),
          ),
        );
      }
    } else {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    }
  }

  _delay(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  @override
  void initState() {
    super.initState();
    //animation
    _textAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _textAnimation =
        Tween(begin: 0.0, end: 1.0).animate(_textAnimationController);

    //login
    _loginTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        _login();
        _loginTimer?.cancel();
      },
    );
  }

  @override
  void dispose() {
    _textAnimationController.dispose();
    _loginTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodToGo - Customers'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Welcome',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: KColors.kPrimaryColor,
                    fontSize: 35,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'We are getting your location. Please wait.',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: KColors.kPrimaryColor,
                    fontSize: 18,
                  ),
            ),
            const SizedBox(height: 40),
            Image.asset(
              'assets/images/getting_location.gif',
              height: 80,
              width: 80,
            ),
            const SizedBox(height: 15),
            AnimatedBuilder(
              animation: _textAnimation,
              builder: (context, child) {
                if (_textAnimation.value < 0.25) {
                  return SizedBox(
                    width: 90,
                    child: Text(
                      'Loading',
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 20,
                          ),
                    ),
                  );
                } else if (_textAnimation.value >= 0.25 &&
                    _textAnimation.value < 0.5) {
                  return SizedBox(
                    width: 90,
                    child: Text(
                      'Loading.',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 20,
                          ),
                    ),
                  );
                } else if (_textAnimation.value >= 0.5 &&
                    _textAnimation.value < 0.75) {
                  return SizedBox(
                    width: 90,
                    child: Text(
                      'Loading..',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 20,
                          ),
                    ),
                  );
                } else {
                  return SizedBox(
                    width: 90,
                    child: Text(
                      'Loading...',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: 20,
                          ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 90)
          ],
        ),
      ),
    );
  }
}
