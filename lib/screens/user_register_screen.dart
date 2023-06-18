import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:foodtogo_customers/models/dto/login_request_dto.dart';
import 'package:foodtogo_customers/models/dto/register_request_dto.dart';
import 'package:foodtogo_customers/models/enum/login_from_app.dart';
import 'package:foodtogo_customers/screens/customer_register_screen.dart';
import 'package:foodtogo_customers/screens/login_screen.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';

class UserRegisterScreen extends StatefulWidget {
  const UserRegisterScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _UserRegisterScreenState();
  }
}

class _UserRegisterScreenState extends State<UserRegisterScreen> {
  final _formUserRegisterKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _reenterPasswordController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();

  final _userServices = UserServices();

  late bool _isPasswordObscured;
  late bool _isReEnterPasswordObscured;

  bool _isRegistering = false;

  _onRegisterPressed() async {
    if (_formUserRegisterKey.currentState!.validate()) {
      if (mounted) {
        setState(() {
          _isRegistering = true;
        });
      }

      final isUsernameExist =
          await _userServices.isUsernameExist(_usernameController.text);

      if (isUsernameExist == null) {
        if (mounted) {
          setState(() {
            _isRegistering = false;
          });
        }
        return;
      }

      if (isUsernameExist) {
        _showAlertDialog(
          'Username Unavailable',
          'The username you have chosen is already in use. Please choose a different username.',
          () {
            Navigator.of(context).pop();
          },
        );
        if (mounted) {
          setState(() {
            _isRegistering = false;
          });
        }
        return;
      }
      final registerRequestDTO = RegisterRequestDTO(
        username: _usernameController.text,
        password: _passwordController.text,
        phoneNumber: _phoneNumberController.text,
        email: _emailController.text,
      );

      final apiResponse = await _userServices.register(registerRequestDTO);

      int userId = apiResponse.result! as int;
      log(userId.toString());

      if (userId == 0) {
        _showAlertDialog(
          'Sorry',
          'Unable to create your account at the moment. Please try again at a later time.',
          () {
            Navigator.of(context).pop();
          },
        );
        if (mounted) {
          setState(() {
            _isRegistering = false;
          });
        }
        return;
      }
      //login
      final loginRequestDTO = LoginRequestDTO(
        username: _usernameController.text,
        password: _passwordController.text,
        loginFromApp: LoginFromApp.Customer.name,
      );
      _userServices.login(loginRequestDTO);
      _userServices.getUserLocation();

      if (mounted) {
        setState(() {
          _isRegistering = false;
        });
      }
      _showAlertDialog(
        'Success',
        'We have successfully created your account. Now we wanna know more about you.',
        () {
          Navigator.pop(context);
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => CustomerRegisterScreen(userId: userId),
          ));
        },
      );
    }
  }

  _showAlertDialog(String title, String message, void Function() onOkPressed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                onOkPressed();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _isPasswordObscured = true;
    _isReEnterPasswordObscured = true;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _reenterPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodToGo - Customers'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(35, 15, 40, 30),
        child: Form(
          key: _formUserRegisterKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'User Register',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: KColors.kPrimaryColor,
                      fontSize: 30,
                    ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person,
                    size: 27,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Enter your username'),
                        errorMaxLines: 4,
                      ),
                      controller: _usernameController,
                      validator: (value) {
                        if (_userServices.isValidUsername(value)) {
                          return null;
                        }
                        return 'Invalid username. Must be 4-30 characters and only contain letters, numbers, and underscores.';
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock,
                    size: 27,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      obscureText: _isPasswordObscured,
                      decoration: InputDecoration(
                        label: const Text('Enter your password'),
                        suffixIcon: IconButton(
                          icon: _isPasswordObscured
                              ? const Icon(
                                  Icons.visibility,
                                  size: 20,
                                )
                              : const Icon(
                                  Icons.visibility_off,
                                  size: 20,
                                ),
                          onPressed: () {
                            setState(() {
                              _isPasswordObscured = !_isPasswordObscured;
                            });
                          },
                        ),
                      ),
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock,
                    size: 27,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      obscureText: _isReEnterPasswordObscured,
                      decoration: InputDecoration(
                        label: const Text('Re-type your password'),
                        suffixIcon: IconButton(
                          icon: _isReEnterPasswordObscured
                              ? const Icon(
                                  Icons.visibility,
                                  size: 20,
                                )
                              : const Icon(
                                  Icons.visibility_off,
                                  size: 20,
                                ),
                          onPressed: () {
                            setState(() {
                              _isReEnterPasswordObscured =
                                  !_isReEnterPasswordObscured;
                            });
                          },
                        ),
                      ),
                      controller: _reenterPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please re-type your password.';
                        }
                        if (value != _passwordController.text) {
                          return 'The re-entered password does not match the original password. Please try again.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.phone,
                    size: 27,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        label: Text('Enter your phone number'),
                      ),
                      controller: _phoneNumberController,
                      validator: (value) {
                        if (_userServices.isValidPhoneNumber(value)) {
                          return null;
                        }
                        return 'Please enter a valid phone number.';
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.email,
                    size: 27,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        label: Text('Enter your email'),
                      ),
                      controller: _emailController,
                      validator: (value) {
                        if (_userServices.isValidEmail(value)) {
                          return null;
                        }
                        return 'Please enter a valid email.';
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _onRegisterPressed();
                  },
                  child: _isRegistering
                      ? const CircularProgressIndicator()
                      : const Text('Next'),
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: KColors.kLightTextColor,
                        ),
                    children: [
                      const TextSpan(text: 'Click '),
                      TextSpan(
                        text: ' here ',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                      ),
                      const TextSpan(text: ' to login.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
