import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foodtogo_customers/models/dto/login_request_dto.dart';
import 'package:foodtogo_customers/models/enum/login_from_app.dart';
import 'package:foodtogo_customers/screens/tabs_screen.dart';
import 'package:foodtogo_customers/screens/user_register_screen.dart';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/kcolors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final UserServices _userServices = UserServices();

  late bool _isPasswordObscured;
  late bool _isLogining;
  bool _isLoginFailed = false;

  Future<void> _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      var loginRequestDTO = LoginRequestDTO(
        username: _usernameController.text,
        password: _passwordController.text,
        loginFromApp: LoginFromApp.Customer.name,
      );

      if (mounted) {
        setState(() {
          _isLogining = true;
        });
      }

      final loginResponseDTO = await _userServices.login(loginRequestDTO);

      if (mounted) {
        setState(() {
          _isLogining = false;
        });
      }

      if (!loginResponseDTO.isSuccess) {
        setState(() {
          _isLoginFailed = true;
        });
      } else {
        setState(() {
          _isLoginFailed = false;
        });

        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => TabsScreen(),
            ),
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _isPasswordObscured = true;
    _isLogining = false;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FoodToGo - Customer'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(35, 25, 40, 0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Log In',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: KColors.kPrimaryColor,
                      fontSize: 30,
                    ),
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person,
                    size: 30,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Enter your username.'),
                      ),
                      controller: _usernameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username.';
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
                    size: 30,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      obscureText: _isPasswordObscured,
                      decoration: InputDecoration(
                        label: const Text('Enter your password.'),
                        suffixIcon: IconButton(
                          icon: _isPasswordObscured
                              ? const Icon(Icons.visibility)
                              : const Icon(Icons.visibility_off),
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
              const SizedBox(height: 20),
              if (_isLoginFailed)
                Text(
                  'Login Failed. Please check your username and password.',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.red,
                      ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _login(context);
                },
                child: _isLogining
                    ? const CircularProgressIndicator()
                    : const Text('Login'),
              ),
              const SizedBox(height: 15),
              RichText(
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
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const UserRegisterScreen(),
                            ),
                          );
                        },
                    ),
                    const TextSpan(text: ' to register.'),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
